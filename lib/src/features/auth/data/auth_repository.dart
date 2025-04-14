import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias FirebaseAuth
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Firestore instance potentially

// Import domain models
import 'package:masarat_alnur/src/features/auth/domain/app_user.dart';
import 'package:masarat_alnur/src/core/domain/result.dart'; // Import generic Result

part 'auth_repository.g.dart'; // Riverpod generator

// --- Auth Repository Definition ---
class AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  // Optionally inject Firestore if needed for related operations directly here
  // final FirebaseFirestore _firestore;

  AuthRepository(this._firebaseAuth, this._googleSignIn); // Update constructor if Firestore added

  // Expose auth state changes stream mapped to AppUser or null
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_appUserFromFirebase);
  }

  // Get current user synchronously (might be null)
  AppUser? get currentUser => _appUserFromFirebase(_firebaseAuth.currentUser);

  // Helper to convert FirebaseUser to AppUser (basic version)
  // Note: Full profile info including role requires Firestore fetch via UserRepository
  AppUser? _appUserFromFirebase(fb_auth.User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      // Role will be fetched separately by UserRepository
    );
  }

  // --- Authentication Methods ---

  Future<Result<fb_auth.User>> signUpWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return Success(credential.user!); // Return Success
    } on fb_auth.FirebaseAuthException catch (e) {
      print("FirebaseAuthException on Sign Up: Code=${e.code}, Message=${e.message}");
      return Failure(e); // Return Failure
    } catch (e) {
       print("Generic Exception on Sign Up: $e");
      return Failure(Exception(e.toString())); // Return Failure
    }
  }

   Future<Result<fb_auth.User>> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return Success(credential.user!); // Return Success
    } on fb_auth.FirebaseAuthException catch (e) {
       print("FirebaseAuthException on Sign In: Code=${e.code}, Message=${e.message}");
      return Failure(e); // Return Failure
    } catch (e) {
       print("Generic Exception on Sign In: $e");
       return Failure(Exception(e.toString())); // Return Failure
    }
  }

   Future<Result<fb_auth.User>> signInWithGoogle() async {
     try {
       // Trigger the authentication flow
       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

       // Obtain the auth details from the request
       if (googleUser == null) {
         // User cancelled the sign-in
         print("Google Sign-In cancelled by user.");
         return Failure(Exception("Google Sign-In cancelled by user.")); // Return Failure
       }
       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

       // Create a new credential
       final fb_auth.AuthCredential credential = fb_auth.GoogleAuthProvider.credential(
         accessToken: googleAuth.accessToken,
         idToken: googleAuth.idToken,
       );

       // Once signed in, return the UserCredential
       final userCredential = await _firebaseAuth.signInWithCredential(credential);
       return Success(userCredential.user!); // Return Success

     } on fb_auth.FirebaseAuthException catch (e) {
       print("FirebaseAuthException on Google Sign In: Code=${e.code}, Message=${e.message}");
       return Failure(e); // Return Failure
     } catch (e) {
        print("Generic Exception on Google Sign In: $e");
        return Failure(Exception(e.toString())); // Return Failure
     }
   }

   Future<void> sendPasswordResetEmail(String email) async {
     // Exceptions will propagate up if they occur
     await _firebaseAuth.sendPasswordResetEmail(email: email);
     print("Password reset email sent to $email");
   }


   Future<void> signOut() async {
     final bool isGoogleSignedIn = await _googleSignIn.isSignedIn();
     if (isGoogleSignedIn) {
        await _googleSignIn.signOut();
        print("Signed out from Google.");
     }
     await _firebaseAuth.signOut();
     print("Signed out from Firebase.");
   }
}

// --- Riverpod Providers ---

@Riverpod(keepAlive: true)
fb_auth.FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return fb_auth.FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(GoogleSignInRef ref) {
   // Consider adding scopes if needed: GoogleSignIn(scopes: ['email'])
   return GoogleSignIn();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  // Provide instances of FirebaseAuth and GoogleSignIn to the repository
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider)
  );
}

// Stream provider for auth state changes -> Firebase User? (Used by other providers)
@riverpod
Stream<fb_auth.User?> firebaseAuthStateChanges(FirebaseAuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider)._firebaseAuth.authStateChanges();
}


// Stream provider mapped to AppUser? (For UI or high-level logic)
@riverpod
Stream<AppUser?> authStateChangesMapped(AuthStateChangesMappedRef ref) {
  // Depends on the raw firebase user stream
  return ref.watch(firebaseAuthStateChangesProvider).map((firebaseUser) {
      // Basic mapping, doesn't include Firestore data like role
      if (firebaseUser == null) return null;
      return AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName
          // Role needs separate fetch
          );
    });
}