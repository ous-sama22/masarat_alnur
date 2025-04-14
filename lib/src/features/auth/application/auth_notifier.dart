import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Only needed for SignOut if passed
import 'package:masarat_alnur/src/core/domain/result.dart'; // Import generic Result
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias
import 'dart:async'; // For Future

part 'auth_notifier.g.dart';

// Define Auth State (Sealed Class for UI State Representation)
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState { const AuthInitial(); } // Not authenticated / Initial
class AuthLoading extends AuthState { const AuthLoading(); } // Processing
class AuthSuccess extends AuthState { // Successfully authenticated (used internally, maybe signal UI differently)
  final fb_auth.User user;
  const AuthSuccess(this.user);
}
class AuthPasswordResetSent extends AuthState { const AuthPasswordResetSent(); }
class AuthError extends AuthState { // Authentication failed
  final String message;
  const AuthError(this.message);
}
// Add states for navigation triggers if needed (or handle navigation in UI based on AuthSuccess)
// class AuthNavigateToOnboarding extends AuthState { const AuthNavigateToOnboarding(); }
// class AuthNavigateToMain extends AuthState { const AuthNavigateToMain(); }


@riverpod // Using Riverpod Generator
class AuthNotifier extends _$AuthNotifier {

  @override
  AuthState build() {
    return const AuthInitial(); // Initial state
  }

  // Helper to ensure user document exists after successful auth
  Future<bool> _ensureUserDocument(fb_auth.User user) async {
    state = const AuthLoading(); // Show loading during profile setup
    try {
      final userRepo = ref.read(userRepositoryProvider);
      // Ensure both user profile and progress docs are created/exist
      await userRepo.createUserDocument(user);
      await userRepo.createInitialUserProgress(user.uid);
      print("User document and progress ensured for ${user.uid}");
      return true;
    } catch (e) {
      print("Error ensuring user/progress document: $e");
      state = AuthError("Failed to setup user profile: ${e.toString()}");
      // Consider signing out if profile setup fails critically
      // await ref.read(authRepositoryProvider).signOut();
      return false;
    }
  }

  // --- Actions ---
  Future<void> signUpWithEmailPassword(String email, String password) async {
    state = const AuthLoading();
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.signUpWithEmailPassword(email, password);

    if (result is Success<fb_auth.User>) {
      final setupOk = await _ensureUserDocument(result.data);
      if (setupOk) {
        // Successfully signed up AND profile setup done
        state = AuthSuccess(result.data); // Signal success (UI decides navigation)
      }
      // Error state already set in _ensureUserDocument if setup failed
    } else if (result is Failure<fb_auth.User>) {
      state = AuthError(result.exception.toString());
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    state = const AuthLoading();
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.signInWithEmailPassword(email, password);
    await _handleSignInResult(result); // Use common handler
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.signInWithGoogle();

    // Handle specific Google cancellation slightly differently maybe
    if (result is Failure && result.exception.toString().contains("cancelled")) {
         state = const AuthInitial(); // Go back to initial if cancelled
         return;
    }
    await _handleSignInResult(result);
  }

  // Common Handler for Sign In Results
  Future<void> _handleSignInResult(Result<fb_auth.User> result) async {
      if (result is Success<fb_auth.User>) {
        final setupOk = await _ensureUserDocument(result.data);
        if (setupOk) {
           // Successfully signed in AND profile setup done
          state = AuthSuccess(result.data); // Signal success (UI decides navigation)
        }
         // Error state handled in _ensureUserDocument if setup failed
      } else if (result is Failure<fb_auth.User>) {
        state = AuthError(result.exception.toString());
      }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AuthLoading();
    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.sendPasswordResetEmail(email);
      state = const AuthPasswordResetSent();
    } catch (e) {
      state = AuthError("Failed to send password reset email: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
     state = const AuthLoading();
     final authRepo = ref.read(authRepositoryProvider);
      try {
         await authRepo.signOut();
         state = const AuthInitial(); // Go back to initial state after sign out
      } catch (e) {
         print("Sign out error: $e");
         state = const AuthInitial(); // Reset state even on error during signout?
      }
   }

    // Reset state (e.g., after showing an error message or handling success)
    void resetState() {
      // Only reset if not currently loading to avoid interrupting process
      if (state is! AuthLoading) {
          state = const AuthInitial();
      }
    }
}