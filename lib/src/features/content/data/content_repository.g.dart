// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contentRepositoryHash() => r'138c4315cdb92f02cec9895a1bcad327a24d1f34';

/// See also [contentRepository].
@ProviderFor(contentRepository)
final contentRepositoryProvider = Provider<ContentRepository>.internal(
  contentRepository,
  name: r'contentRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContentRepositoryRef = ProviderRef<ContentRepository>;
String _$categoriesStreamHash() => r'f6b402920f8ad9598b6f06b65211aaadd1585448';

/// See also [categoriesStream].
@ProviderFor(categoriesStream)
final categoriesStreamProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
      categoriesStream,
      name: r'categoriesStreamProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$categoriesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesStreamRef = AutoDisposeStreamProviderRef<List<Category>>;
String _$subCategoriesStreamHash() =>
    r'615a568765078e77acb3cb6f7bf54bc61624ce45';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [subCategoriesStream].
@ProviderFor(subCategoriesStream)
const subCategoriesStreamProvider = SubCategoriesStreamFamily();

/// See also [subCategoriesStream].
class SubCategoriesStreamFamily extends Family<AsyncValue<List<SubCategory>>> {
  /// See also [subCategoriesStream].
  const SubCategoriesStreamFamily();

  /// See also [subCategoriesStream].
  SubCategoriesStreamProvider call(String categoryId) {
    return SubCategoriesStreamProvider(categoryId);
  }

  @override
  SubCategoriesStreamProvider getProviderOverride(
    covariant SubCategoriesStreamProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subCategoriesStreamProvider';
}

/// See also [subCategoriesStream].
class SubCategoriesStreamProvider
    extends AutoDisposeStreamProvider<List<SubCategory>> {
  /// See also [subCategoriesStream].
  SubCategoriesStreamProvider(String categoryId)
    : this._internal(
        (ref) => subCategoriesStream(ref as SubCategoriesStreamRef, categoryId),
        from: subCategoriesStreamProvider,
        name: r'subCategoriesStreamProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$subCategoriesStreamHash,
        dependencies: SubCategoriesStreamFamily._dependencies,
        allTransitiveDependencies:
            SubCategoriesStreamFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  SubCategoriesStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    Stream<List<SubCategory>> Function(SubCategoriesStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubCategoriesStreamProvider._internal(
        (ref) => create(ref as SubCategoriesStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SubCategory>> createElement() {
    return _SubCategoriesStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubCategoriesStreamProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubCategoriesStreamRef
    on AutoDisposeStreamProviderRef<List<SubCategory>> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _SubCategoriesStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<SubCategory>>
    with SubCategoriesStreamRef {
  _SubCategoriesStreamProviderElement(super.provider);

  @override
  String get categoryId => (origin as SubCategoriesStreamProvider).categoryId;
}

String _$ongoingCategoriesStreamHash() =>
    r'efadecb76a0cec32d7749a963e4740b2901002f6';

/// See also [ongoingCategoriesStream].
@ProviderFor(ongoingCategoriesStream)
final ongoingCategoriesStreamProvider =
    AutoDisposeStreamProvider<List<Category>>.internal(
      ongoingCategoriesStream,
      name: r'ongoingCategoriesStreamProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$ongoingCategoriesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OngoingCategoriesStreamRef =
    AutoDisposeStreamProviderRef<List<Category>>;
String _$ongoingSubCategoriesStreamHash() =>
    r'3a41a5082296068a265c1808bc54c8f5573bd86c';

/// See also [ongoingSubCategoriesStream].
@ProviderFor(ongoingSubCategoriesStream)
final ongoingSubCategoriesStreamProvider =
    AutoDisposeStreamProvider<List<SubCategory>>.internal(
      ongoingSubCategoriesStream,
      name: r'ongoingSubCategoriesStreamProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$ongoingSubCategoriesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OngoingSubCategoriesStreamRef =
    AutoDisposeStreamProviderRef<List<SubCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
