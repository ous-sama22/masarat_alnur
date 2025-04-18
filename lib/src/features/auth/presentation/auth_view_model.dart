import 'dart:async'; // For Completer maybe if needed

import 'package:google_sign_in/google_sign_in.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart'; // Riverpod generator

// --- Define UI State ---
// Using AsyncValue is often cleaner for representing loading/error/data states with Riverpod
// Alternatively, use a custom sealed class if more complex states needed.
// Let's stick with our custom sealed class for now as we defined it earlier.

sealed class AuthUiState {
  const AuthUiState();
}

class AuthUiInitial extends AuthUiState { const AuthUiInitial(); } // Initial state
class AuthUiLoading extends AuthUiState { const AuthUiLoading(); } // Show progress indicator
class AuthUiError extends AuthUiState {
  final String message;
  const AuthUiError(this.message);
}
class AuthUiPasswordResetSent extends AuthUiState { const AuthUiPasswordResetSent(); }
class AuthUiAuthSuccessful extends AuthUiState { // Trigger navigation within onboarding
  final fb_auth.User user; // Pass user if needed by next step
  const AuthUiAuthSuccessful(this.user);
}

// --- ViewModel using Riverpod Generator ---
@riverpod // Use generator for simplified provider definition
class AuthViewModel extends _$AuthViewModel { // Name matches file, 'Notifier' suffix added by generator

  // Build method required by generator, sets initial state
  @override
  AuthUiState build() {
    // No initial async work needed here to build the state itself
    return const AuthUiInitial();
  }

  // Helper method to get repositories (dependencies injected by Riverpod)
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);
  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  // --- Sign Up ---
  Future<void> signUpWithEmailPassword(String email, String pass) async {
    state = const AuthUiLoading(); // Set loading state
    final result = await _authRepository.signUpWithEmailPassword(email, pass);
    switch (result) {
      case AuthSuccess(data: final user):
        print("AuthViewModel: Sign up success for ${user.email}");
        // Ensure user document exists (includes initial progress doc creation)
        try {
          await _userRepository.createUserDocument(user);
          await _userRepository.createInitialUserProgress(user.uid); // Ensure progress doc
          print("AuthViewModel: User/Progress document ensured after signup.");
          state = AuthUiAuthSuccessful(user); // Signal success for navigation
        } catch (e) {
           print("AuthViewModel: Signup success BUT failed user/progress doc creation: $e");
           state = AuthUiError("Account created, but profile setup failed: ${e.toString()}");
           // Consider attempting cleanup? (e.g., delete the auth user) - complex!
        }
      case AuthError(exception: final e):
        print("AuthViewModel: Sign up error: $e");
        state = AuthUiError(e.toString()); // Use e.message or map specific FirebaseAuthExceptions
    }
  }

  // --- Sign In ---
  Future<void> signInWithEmailPassword(String email, String pass) async {
    state = const AuthUiLoading();
    final result = await _authRepository.signInWithEmailPassword(email, pass);
    await _handleSignInResult(result); // Use common handler
  }

  Future<void> signInWithGoogle() async {
    state = const AuthUiLoading();
    // Use GoogleSignIn instance from its provider
    final googleSignIn = ref.read(googleSignInProvider);
    try {
       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
       if (googleUser == null) {
          state = const AuthUiInitial(); // User cancelled
          return;
       }
       final result = await _authRepository.signInWithGoogle(); 
       await _handleSignInResult(result);
    } catch(e) {
       print("AuthViewModel: Google Sign In method error: $e");
       state = AuthUiError("Google Sign-In failed: ${e.toString()}");
    }
  }

  // --- Common Handler for Sign In Results ---
  Future<void> _handleSignInResult(AuthResult<fb_auth.User> result) async {
    switch (result) {
      case AuthSuccess(data: final user):
        print("AuthViewModel: Sign in success for ${user.email}");
        // Ensure user document exists (includes initial progress doc creation)
        try {
           await _userRepository.createUserDocument(user);
           await _userRepository.createInitialUserProgress(user.uid); // Ensure progress doc
           print("AuthViewModel: User/Progress document ensured after signin.");
           state = AuthUiAuthSuccessful(user); // Signal success for navigation
        } catch (e) {
           print("AuthViewModel: Signin success BUT failed user/progress doc creation: $e");
           state = AuthUiError("Login successful, but profile setup failed: ${e.toString()}");
           await _authRepository.signOut();
        }
      case AuthError(exception: final e):
        print("AuthViewModel: Sign in error: $e");
        state = AuthUiError(e.toString());
    }
  }


  // --- Forgot Password ---
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AuthUiLoading();
    try {
       await _authRepository.sendPasswordResetEmail(email);
       state = const AuthUiPasswordResetSent();
    } catch(e) {
       print("AuthViewModel: Password reset error: $e");
       state = AuthUiError(e.toString());
    }
    // Optionally reset state after a delay?
     await Future.delayed(const Duration(seconds: 2));
     if (state is AuthUiPasswordResetSent || state is AuthUiError) {
       resetUiStateToIdle();
     }
  }

  // --- Logout ---
  // Logout logic might live elsewhere now, maybe in a ProfileViewModel?
  // If needed here, it would trigger navigation differently.
  // Let's assume ProfileViewModel handles logout for now.

  // Function to reset UI state if needed after an event is handled
  void resetUiStateToIdle() {
    if (state is! AuthUiLoading) { // Don't reset if still loading
      state = const AuthUiInitial();
    }
  }
}