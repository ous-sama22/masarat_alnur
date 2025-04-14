// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'38a6dd5bbf470a905629b5f18e606df31706d493';

/// See also [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = ProviderRef<fb_auth.FirebaseAuth>;
String _$googleSignInHash() => r'33e2d830c18590dbfdef7f4796eb1120b7e87104';

/// See also [googleSignIn].
@ProviderFor(googleSignIn)
final googleSignInProvider = Provider<GoogleSignIn>.internal(
  googleSignIn,
  name: r'googleSignInProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$googleSignInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoogleSignInRef = ProviderRef<GoogleSignIn>;
String _$authRepositoryHash() => r'd194f2ebd7a0ee2654292b86193bf77c2d8f59a2';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
String _$firebaseAuthStateChangesHash() =>
    r'e988cf1dd56a7103fcc308e37211446a70b66354';

/// See also [firebaseAuthStateChanges].
@ProviderFor(firebaseAuthStateChanges)
final firebaseAuthStateChangesProvider =
    AutoDisposeStreamProvider<fb_auth.User?>.internal(
      firebaseAuthStateChanges,
      name: r'firebaseAuthStateChangesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$firebaseAuthStateChangesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthStateChangesRef =
    AutoDisposeStreamProviderRef<fb_auth.User?>;
String _$authStateChangesMappedHash() =>
    r'1cfe4de146b3dd68e42fcca74348019ad7055614';

/// See also [authStateChangesMapped].
@ProviderFor(authStateChangesMapped)
final authStateChangesMappedProvider =
    AutoDisposeStreamProvider<AppUser?>.internal(
      authStateChangesMapped,
      name: r'authStateChangesMappedProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authStateChangesMappedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesMappedRef = AutoDisposeStreamProviderRef<AppUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
