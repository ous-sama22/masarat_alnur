import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:masarat_alnur/src/features/content/domain/category.dart';
import 'package:masarat_alnur/src/features/content/domain/sub_category.dart';
import 'package:masarat_alnur/src/features/content/domain/content_status.dart';
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';

part 'content_repository.g.dart';

class ContentRepository {
  final FirebaseFirestore _firestore;
  
  ContentRepository(this._firestore);

  // Collection References
  CollectionReference<Category> _categoriesRef() =>
      _firestore.collection('categories').withConverter<Category>(
            fromFirestore: (snapshot, _) => Category(
              id: snapshot.id,
              title_ar: snapshot.data()?['title_ar'] ?? '',
              imageUrl: snapshot.data()?['imageUrl'],
              order: snapshot.data()?['order'] ?? 0,
              status: ContentStatus.values.firstWhere(
                (e) => e.name == (snapshot.data()?['status'] ?? 'PUBLISHED'),
                orElse: () => ContentStatus.PUBLISHED,
              ),
            ),
            toFirestore: (category, _) => {
              'title_ar': category.title_ar,
              if (category.imageUrl != null) 'imageUrl': category.imageUrl,
              'order': category.order,
              'status': category.status.name,
            },
          );

  CollectionReference<SubCategory> _subCategoriesRef() =>
      _firestore.collection('subCategories').withConverter<SubCategory>(
            fromFirestore: (snapshot, _) => SubCategory(
              id: snapshot.id,
              categoryId: snapshot.data()?['categoryId'] ?? '',
              title_ar: snapshot.data()?['title_ar'] ?? '',
              imageUrl: snapshot.data()?['imageUrl'],
              order: snapshot.data()?['order'] ?? 0,
              status: ContentStatus.values.firstWhere(
                (e) => e.name == (snapshot.data()?['status'] ?? 'PUBLISHED'),
                orElse: () => ContentStatus.PUBLISHED,
              ),
            ),
            toFirestore: (subCategory, _) => {
              'categoryId': subCategory.categoryId,
              'title_ar': subCategory.title_ar,
              if (subCategory.imageUrl != null) 'imageUrl': subCategory.imageUrl,
              'order': subCategory.order,
              'status': subCategory.status.name,
            },
          );

  // Fetch Methods
  Stream<List<Category>> watchCategories() {
    return _categoriesRef()
        .orderBy('order')
        .where('status', isEqualTo: ContentStatus.PUBLISHED.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<SubCategory>> watchSubCategories(String categoryId) {
    return _subCategoriesRef()
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('order')
        .where('status', isEqualTo: ContentStatus.PUBLISHED.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<SubCategory>> watchAllSubCategories() {
    return _subCategoriesRef()
        .orderBy('order')
        .where('status', isEqualTo: ContentStatus.PUBLISHED.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<Category?> fetchCategory(String categoryId) async {
    final doc = await _categoriesRef().doc(categoryId).get();
    return doc.data();
  }

  Future<List<Category>> fetchOngoingCategories(List<String> categoryIds) async {
    if (categoryIds.isEmpty) return [];
    final snapshot = await _categoriesRef()
        .where(FieldPath.documentId, whereIn: categoryIds)
        .where('status', isEqualTo: ContentStatus.PUBLISHED.name)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<SubCategory>> fetchOngoingSubCategories(List<String> subCategoryIds) async {
    if (subCategoryIds.isEmpty) return [];
    final snapshot = await _subCategoriesRef()
        .where(FieldPath.documentId, whereIn: subCategoryIds)
        .where('status', isEqualTo: ContentStatus.PUBLISHED.name)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}

@Riverpod(keepAlive: true)
ContentRepository contentRepository(ContentRepositoryRef ref) {
  return ContentRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Stream<List<Category>> categoriesStream(CategoriesStreamRef ref) {
  return ref.watch(contentRepositoryProvider).watchCategories();
}

@riverpod
Stream<List<SubCategory>> subCategoriesStream(SubCategoriesStreamRef ref, String categoryId) {
  return ref.watch(contentRepositoryProvider).watchSubCategories(categoryId);
}

@riverpod
Stream<List<Category>> ongoingCategoriesStream(OngoingCategoriesStreamRef ref) {
  final userProgressAsync = ref.watch(userProgressStreamProvider);
  final contentRepo = ref.watch(contentRepositoryProvider);
  
  return userProgressAsync.when(
    data: (progress) {
      final startedIds = progress?.startedCategoryInfo.toList() ?? [];
      if (startedIds.isEmpty) return Stream.value([]);
      return Stream.fromFuture(contentRepo.fetchOngoingCategories(startedIds));
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}

@riverpod
Stream<List<SubCategory>> ongoingSubCategoriesStream(OngoingSubCategoriesStreamRef ref) {
  final userProgressAsync = ref.watch(userProgressStreamProvider);
  final contentRepo = ref.watch(contentRepositoryProvider);
  
  return userProgressAsync.when(
    data: (progress) {
      final startedIds = progress?.startedSubCategoryInfo.toList() ?? [];
      if (startedIds.isEmpty) return Stream.value([]);
      return Stream.fromFuture(contentRepo.fetchOngoingSubCategories(startedIds));
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}