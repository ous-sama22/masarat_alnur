// Using Equatable for simpler value comparison if not using Freezed
import 'package:equatable/equatable.dart';


class AppUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName; // Nullable, presence indicates onboarding nickname step complete
  final String role; // Added role from previous discussion

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.role = 'user', // Default role
  });

  // Factory constructor for creating a default/empty user
  factory AppUser.empty() => const AppUser(uid: '', email: '', displayName: null, role: 'user');

   // --- If using Equatable ---
   @override
   List<Object?> get props => [uid, email, displayName, role];

   @override
   bool get stringify => true;
  // --- End Equatable ---


  // Helper method to check if nickname onboarding is done
  bool get isNicknameComplete => displayName != null && displayName!.isNotEmpty;

  // Copy method (provided by Freezed or Equatable, or implement manually)
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
     bool clearDisplayName = false, // Flag to explicitly set displayName to null
    String? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      // Handle clearing vs updating displayName
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      role: role ?? this.role,
    );
  }
}