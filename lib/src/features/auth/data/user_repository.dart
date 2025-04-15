import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import base Ref

import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart'; // For firebaseAuth provider
import 'package:masarat_alnur/src/features/auth/domain/app_user.dart';
import 'package:masarat_alnur/src/features/progress/domain/user_progress.dart';

part 'user_repository.g.dart'; // Riverpod generator

class UserRepository {
  final FirebaseFirestore _firestore;
  UserRepository(this._firestore);

  // Reference to 'users' collection
  CollectionReference<AppUser> _usersRef() =>
      _firestore.collection('users').withConverter<AppUser>(
            fromFirestore: (snapshot, _) => AppUser( // Simple fromFirestore for AppUser
               uid: snapshot.id,
               email: snapshot.data()?['email'] ?? '',
               displayName: snapshot.data()?['displayName'],
               role: snapshot.data()?['role'] ?? 'user',
            ),
            toFirestore: (user, _) => { // Simple toFirestore
              // Don't write UID to fields, it's the doc ID
              'email': user.email,
              if (user.displayName != null) 'displayName': user.displayName,
              'role': user.role,
              // Add other fields if necessary, like profileImageUrl
            },
          );

   // Reference to 'userProgress' collection
   CollectionReference<UserProgress> _progressRef() =>
       _firestore.collection('userProgress').withConverter<UserProgress>(
             fromFirestore: UserProgress.fromFirestore, // Use factory from model
             toFirestore: (progress, _) => progress.toFirestore(), // Use method from model
           );


  // --- User Profile Methods ---

  // Fetch user profile data once
  Future<AppUser?> fetchUser(String userId) async {
    try {
      final snapshot = await _usersRef().doc(userId).get();
      return snapshot.data(); // Returns AppUser?
    } catch (e) {
      print("Error fetching user $userId: $e");
      return null;
    }
  }

  // Stream user profile data
   Stream<AppUser?> watchUser(String userId) {
     return _usersRef()
         .doc(userId)
         .snapshots() // Listen to snapshot changes
         .map((snapshot) => snapshot.data()); // Map snapshot to AppUser?
   }

  // Create user document (only if it doesn't exist)
  Future<void> createUserDocument(fb_auth.User firebaseUser) async {
    final userDocRef = _usersRef().doc(firebaseUser.uid);
    final snapshot = await userDocRef.get();

    if (!snapshot.exists) {
       print("Creating user document for ${firebaseUser.uid}");
      // Generate display name from email (everything before @)
      final displayName = firebaseUser.email?.split('@')[0] ?? 'User';
      
      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: displayName, // Use generated display name
        role: 'user',
      );
      await userDocRef.set(newUser);
    } else {
       print("User document already exists for ${firebaseUser.uid}");
       // Optionally update existing doc with latest email from Firebase
       await userDocRef.update({'email': firebaseUser.email});
    }
  }

  // Update specific user data (like displayName)
   Future<void> updateUserData(String userId, {String? displayName}) async {
      final Map<String, dynamic> dataToUpdate = {};
      if (displayName != null) {
        dataToUpdate['displayName'] = displayName;
      }
       // Add other updatable fields here if needed
      if (dataToUpdate.isNotEmpty) {
        await _usersRef().doc(userId).update(dataToUpdate);
      }
   }

  Future<bool> isAdmin(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final userDoc = await _usersRef().doc(userId).get();
      final userData = userDoc.data();
      return userData?.role == 'admin';
    } catch (e) {
      print("Error checking admin status for $userId: $e");
      return false;
    }
  }


  // --- User Progress Methods ---
  
   Stream<UserProgress?> watchUserProgress(String userId) {
     if (userId.isEmpty) return Stream.value(null);
     return _progressRef()
         .doc(userId)
         .snapshots()
         .map((snapshot) => snapshot.data())
         .handleError((error) { // Handle errors in the stream
           print("Error watching user progress for $userId: $error");
           return null; // Emit null on error
         });
   }

   Future<UserProgress?> fetchUserProgressOnce(String userId) async {
      if (userId.isEmpty) return null;
      try {
        final snapshot = await _progressRef().doc(userId).get();
        return snapshot.data();
      } catch (e) {
        print("Error fetching user progress once for $userId: $e");
        return null;
      }
   }

    Future<void> createInitialUserProgress(String userId) async {
      if (userId.isEmpty) return;
      final progressDocRef = _progressRef().doc(userId);
      final snapshot = await progressDocRef.get();
      if (!snapshot.exists) {
        print("Creating initial UserProgress for $userId");
        await progressDocRef.set(UserProgress.empty()); // Create empty progress doc
      }
    }

    Future<void> markTopicAsComplete(String userId, String topicId) async {
      if (userId.isEmpty || topicId.isEmpty) return;
      await _progressRef().doc(userId).update({
        'completedTopicIds': FieldValue.arrayUnion([topicId]),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    }

   Future<void> updateSubCategoryStarted(String userId, String subCategoryId) async {
       if (userId.isEmpty || subCategoryId.isEmpty) return;
       // Use dot notation with update to set a specific field within the map
       // This avoids overwriting other entries in startedSubCategoryInfo
       final fieldPath = 'startedSubCategoryInfo.$subCategoryId';
       await _progressRef().doc(userId).update({
         fieldPath: FieldValue.serverTimestamp(), // Set start time for this specific subCategory
         'lastUpdatedAt': FieldValue.serverTimestamp(),
       });
     }

    Future<void> markSubCategoryAsComplete(String userId, String subCategoryId) async {
      if (userId.isEmpty || subCategoryId.isEmpty) return;
      await _progressRef().doc(userId).update({
        'completedSubCategoryIds': FieldValue.arrayUnion([subCategoryId]),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    }

   Future<void> updateCategoryStarted(String userId, String categoryId) async {
       if (userId.isEmpty || categoryId.isEmpty) return;
       // Use dot notation with update for nested map field
       final fieldPath = 'startedCategoryInfo.$categoryId';
       await _progressRef().doc(userId).update({
         fieldPath: FieldValue.serverTimestamp(), // Set start time for this specific category
         'lastUpdatedAt': FieldValue.serverTimestamp(),
       });
     }

    Future<void> markCategoryAsComplete(String userId, String categoryId) async {
       if (userId.isEmpty || categoryId.isEmpty) return;
       await _progressRef().doc(userId).update({
         'completedCategoryIds': FieldValue.arrayUnion([categoryId]),
         'lastUpdatedAt': FieldValue.serverTimestamp(),
       });
     }
}


// --- Riverpod Providers (Fixing Deprecation Warnings) ---
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) { // Keep specific Ref here for generator
  return FirebaseFirestore.instance;
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) { // Keep specific Ref here for generator
  return UserRepository(ref.watch(firebaseFirestoreProvider));
}

// Provider to watch the current logged-in user's AppUser profile from Firestore
@riverpod
Stream<AppUser?> userProfileStream(Ref ref) { // Use generic Ref
   final authRepo = ref.watch(authRepositoryProvider);
   final userRepo = ref.watch(userRepositoryProvider);
   return authRepo.authStateChanges().asyncMap((firebaseUser) {
      if (firebaseUser != null) {
         return userRepo.fetchUser(firebaseUser.uid); // Fetch profile on auth change
      } else {
         return null;
      }
   });
}


// Provider to watch the current user's progress document
@riverpod
Stream<UserProgress?> userProgressStream(Ref ref) { // Use generic Ref
   // Watch the auth state directly to get the UID reactively
   final asyncUser = ref.watch(authStateChangesProvider);
   final userId = asyncUser.value?.uid; // Safely get UID from AsyncValue

   if (userId != null && userId.isNotEmpty) {
      // Use watch instead of read if you want userRepo dependency to be tracked
      return ref.watch(userRepositoryProvider).watchUserProgress(userId);
   } else {
      return Stream.value(null); // No user logged in
   }
}

// Provider to check if the current user is an admin
@riverpod
Future<bool> isCurrentUserAdmin(Ref ref) async {
  final asyncUser = ref.watch(authStateChangesProvider);
  final userId = asyncUser.value?.uid;
  if (userId == null) return false;
  
  return ref.watch(userRepositoryProvider).isAdmin(userId);
}