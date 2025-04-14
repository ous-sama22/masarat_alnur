import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias FirebaseAuth
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/app_user.dart'; // Import AppUser model

part 'auth_repository.g.dart'; // Riverpod generator

// Define AuthResult equivalent in Dart (using sealed class/Freezed)
sealed class AuthResult<T> {
  const AuthResult();
}

class AuthSuccess<T> extends AuthResult<T> {
  final T data;
  const AuthSuccess(this.data);
}

class AuthError<T> extends AuthResult<T> {
  final Exception exception;
  const AuthError(this.exception);
}

// --- Auth Repository using Riverpod for dependency injection ---
class AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn; // For Google Sign-Out

  AuthRepository(this._firebaseAuth, this._googleSignIn);

  // Expose auth state changes stream mapped to AppUser or null
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_appUserFromFirebase);
  }

  AppUser? get currentUser => _appUserFromFirebase(_firebaseAuth.currentUser);

  // Helper to convert FirebaseUser to AppUser
  AppUser? _appUserFromFirebase(fb_auth.User? user) {
    if (user == null) {
      return null;
    }
    // We fetch role and potentially displayName override from Firestore,
    // so this conversion might be preliminary. A UserRepo fetch is needed
    // for the complete AppUser profile after auth.
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName, // Use Firebase display name initially if available
      // Role needs to be fetched from Firestore
    );
  }

  Future<AuthResult<fb_auth.User>> signUpWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return AuthSuccess(credential.user!);
    } on fb_auth.FirebaseAuthException catch (e) {
      return AuthError(e);
    } catch (e) {
      return AuthError(Exception(e.toString()));
    }
  }

   Future<AuthResult<fb_auth.User>> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return AuthSuccess(credential.user!);
    } on fb_auth.FirebaseAuthException catch (e) {
      return AuthError(e);
    } catch (e) {
       return AuthError(Exception(e.toString()));
    }
  }

   Future<AuthResult<fb_auth.User>> signInWithGoogle() async {
     try {
       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
       if (googleUser == null) {
         // User cancelled the sign-in
         return AuthError(Exception("Google Sign-In cancelled by user."));
       }
       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
       final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
         accessToken: googleAuth.accessToken,
         idToken: googleAuth.idToken,
       );
       final userCredential = await _firebaseAuth.signInWithCredential(credential);
       return AuthSuccess(userCredential.user!);
     } on fb_auth.FirebaseAuthException catch (e) {
       return AuthError(e);
     } catch (e) {
        return AuthError(Exception(e.toString()));
     }
   }

   Future<void> sendPasswordResetEmail(String email) async {
     // Doesn't return Result here, exceptions handled by caller/ViewModel
     await _firebaseAuth.sendPasswordResetEmail(email: email);
   }


   Future<void> signOut() async {
     await _firebaseAuth.signOut();
     // Also sign out from Google if needed to ensure account chooser appears next time
     // Check if last sign in was Google? Or just sign out anyway.
     final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut();
      }
   }
}

// --- Riverpod Providers ---

@Riverpod(keepAlive: true) // Keep auth instance alive globally
fb_auth.FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return fb_auth.FirebaseAuth.instance;
}

@Riverpod(keepAlive: true) // Keep google sign in instance alive
GoogleSignIn googleSignIn(GoogleSignInRef ref) {
   // You might need to pass client IDs here if web support is added later
   return GoogleSignIn();
}


@Riverpod(keepAlive: true) // Keep repository alive
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider), ref.watch(googleSignInProvider));
}

// Stream provider for auth state changes -> AppUser?
@riverpod
Stream<AppUser?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}