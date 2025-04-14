// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseFirestoreHash() => r'2e7f8bd195d91c027c5155f34b719187867bc113';

/// See also [firebaseFirestore].
@ProviderFor(firebaseFirestore)
final firebaseFirestoreProvider = Provider<FirebaseFirestore>.internal(
  firebaseFirestore,
  name: r'firebaseFirestoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$firebaseFirestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseFirestoreRef = ProviderRef<FirebaseFirestore>;
String _$userRepositoryHash() => r'bb46dbd1dece5adb6befe8d60db6c1998d18f411';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$userProfileStreamHash() => r'aa57370fe9e5ad99fe7dd175a306ac13ce27e9d9';

/// See also [userProfileStream].
@ProviderFor(userProfileStream)
final userProfileStreamProvider = AutoDisposeStreamProvider<AppUser?>.internal(
  userProfileStream,
  name: r'userProfileStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userProfileStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileStreamRef = AutoDisposeStreamProviderRef<AppUser?>;
String _$userProgressStreamHash() =>
    r'7b70fcd319b16eeaadcd720e00510f184bd257cb';

/// See also [userProgressStream].
@ProviderFor(userProgressStream)
final userProgressStreamProvider =
    AutoDisposeStreamProvider<UserProgress?>.internal(
      userProgressStream,
      name: r'userProgressStreamProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$userProgressStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProgressStreamRef = AutoDisposeStreamProviderRef<UserProgress?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
