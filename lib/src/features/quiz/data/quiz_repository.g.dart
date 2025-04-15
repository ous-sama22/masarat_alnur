// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quizRepositoryHash() => r'd2e7c0557e1cedfdaa0308e6a4d536aa0ac4adb0';

/// See also [quizRepository].
@ProviderFor(quizRepository)
final quizRepositoryProvider = Provider<QuizRepository>.internal(
  quizRepository,
  name: r'quizRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$quizRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef QuizRepositoryRef = ProviderRef<QuizRepository>;
String _$topicsStreamHash() => r'c451f210776464eb26e4f97d9c0d187b3c3d79a4';

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

/// See also [topicsStream].
@ProviderFor(topicsStream)
const topicsStreamProvider = TopicsStreamFamily();

/// See also [topicsStream].
class TopicsStreamFamily extends Family<AsyncValue<List<Topic>>> {
  /// See also [topicsStream].
  const TopicsStreamFamily();

  /// See also [topicsStream].
  TopicsStreamProvider call(String subCategoryId) {
    return TopicsStreamProvider(subCategoryId);
  }

  @override
  TopicsStreamProvider getProviderOverride(
    covariant TopicsStreamProvider provider,
  ) {
    return call(provider.subCategoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'topicsStreamProvider';
}

/// See also [topicsStream].
class TopicsStreamProvider extends AutoDisposeStreamProvider<List<Topic>> {
  /// See also [topicsStream].
  TopicsStreamProvider(String subCategoryId)
    : this._internal(
        (ref) => topicsStream(ref as TopicsStreamRef, subCategoryId),
        from: topicsStreamProvider,
        name: r'topicsStreamProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$topicsStreamHash,
        dependencies: TopicsStreamFamily._dependencies,
        allTransitiveDependencies:
            TopicsStreamFamily._allTransitiveDependencies,
        subCategoryId: subCategoryId,
      );

  TopicsStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subCategoryId,
  }) : super.internal();

  final String subCategoryId;

  @override
  Override overrideWith(
    Stream<List<Topic>> Function(TopicsStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TopicsStreamProvider._internal(
        (ref) => create(ref as TopicsStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subCategoryId: subCategoryId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Topic>> createElement() {
    return _TopicsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicsStreamProvider &&
        other.subCategoryId == subCategoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subCategoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TopicsStreamRef on AutoDisposeStreamProviderRef<List<Topic>> {
  /// The parameter `subCategoryId` of this provider.
  String get subCategoryId;
}

class _TopicsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<Topic>>
    with TopicsStreamRef {
  _TopicsStreamProviderElement(super.provider);

  @override
  String get subCategoryId => (origin as TopicsStreamProvider).subCategoryId;
}

String _$questionsStreamHash() => r'e16689c6ad0a57167130e20a42f7dfd816e0bd34';

/// See also [questionsStream].
@ProviderFor(questionsStream)
const questionsStreamProvider = QuestionsStreamFamily();

/// See also [questionsStream].
class QuestionsStreamFamily extends Family<AsyncValue<List<QuizQuestion>>> {
  /// See also [questionsStream].
  const QuestionsStreamFamily();

  /// See also [questionsStream].
  QuestionsStreamProvider call(String topicId) {
    return QuestionsStreamProvider(topicId);
  }

  @override
  QuestionsStreamProvider getProviderOverride(
    covariant QuestionsStreamProvider provider,
  ) {
    return call(provider.topicId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'questionsStreamProvider';
}

/// See also [questionsStream].
class QuestionsStreamProvider
    extends AutoDisposeStreamProvider<List<QuizQuestion>> {
  /// See also [questionsStream].
  QuestionsStreamProvider(String topicId)
    : this._internal(
        (ref) => questionsStream(ref as QuestionsStreamRef, topicId),
        from: questionsStreamProvider,
        name: r'questionsStreamProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$questionsStreamHash,
        dependencies: QuestionsStreamFamily._dependencies,
        allTransitiveDependencies:
            QuestionsStreamFamily._allTransitiveDependencies,
        topicId: topicId,
      );

  QuestionsStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.topicId,
  }) : super.internal();

  final String topicId;

  @override
  Override overrideWith(
    Stream<List<QuizQuestion>> Function(QuestionsStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuestionsStreamProvider._internal(
        (ref) => create(ref as QuestionsStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        topicId: topicId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<QuizQuestion>> createElement() {
    return _QuestionsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionsStreamProvider && other.topicId == topicId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, topicId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuestionsStreamRef on AutoDisposeStreamProviderRef<List<QuizQuestion>> {
  /// The parameter `topicId` of this provider.
  String get topicId;
}

class _QuestionsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<QuizQuestion>>
    with QuestionsStreamRef {
  _QuestionsStreamProviderElement(super.provider);

  @override
  String get topicId => (origin as QuestionsStreamProvider).topicId;
}

String _$quizProgressStreamHash() =>
    r'17cf72d82c0b10dd9730c1b7ddd29bf0be9dc936';

/// See also [quizProgressStream].
@ProviderFor(quizProgressStream)
const quizProgressStreamProvider = QuizProgressStreamFamily();

/// See also [quizProgressStream].
class QuizProgressStreamFamily extends Family<AsyncValue<QuizProgress?>> {
  /// See also [quizProgressStream].
  const QuizProgressStreamFamily();

  /// See also [quizProgressStream].
  QuizProgressStreamProvider call(String userId, String topicId) {
    return QuizProgressStreamProvider(userId, topicId);
  }

  @override
  QuizProgressStreamProvider getProviderOverride(
    covariant QuizProgressStreamProvider provider,
  ) {
    return call(provider.userId, provider.topicId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quizProgressStreamProvider';
}

/// See also [quizProgressStream].
class QuizProgressStreamProvider
    extends AutoDisposeStreamProvider<QuizProgress?> {
  /// See also [quizProgressStream].
  QuizProgressStreamProvider(String userId, String topicId)
    : this._internal(
        (ref) =>
            quizProgressStream(ref as QuizProgressStreamRef, userId, topicId),
        from: quizProgressStreamProvider,
        name: r'quizProgressStreamProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$quizProgressStreamHash,
        dependencies: QuizProgressStreamFamily._dependencies,
        allTransitiveDependencies:
            QuizProgressStreamFamily._allTransitiveDependencies,
        userId: userId,
        topicId: topicId,
      );

  QuizProgressStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.topicId,
  }) : super.internal();

  final String userId;
  final String topicId;

  @override
  Override overrideWith(
    Stream<QuizProgress?> Function(QuizProgressStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuizProgressStreamProvider._internal(
        (ref) => create(ref as QuizProgressStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        topicId: topicId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<QuizProgress?> createElement() {
    return _QuizProgressStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizProgressStreamProvider &&
        other.userId == userId &&
        other.topicId == topicId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, topicId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuizProgressStreamRef on AutoDisposeStreamProviderRef<QuizProgress?> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `topicId` of this provider.
  String get topicId;
}

class _QuizProgressStreamProviderElement
    extends AutoDisposeStreamProviderElement<QuizProgress?>
    with QuizProgressStreamRef {
  _QuizProgressStreamProviderElement(super.provider);

  @override
  String get userId => (origin as QuizProgressStreamProvider).userId;
  @override
  String get topicId => (origin as QuizProgressStreamProvider).topicId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
