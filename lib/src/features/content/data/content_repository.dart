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

  Future<SubCategory?> fetchSubCategory(String subCategoryId) async {
    final doc = await _subCategoriesRef().doc(subCategoryId).get();
    return doc.data();
  }

  Future<void> generateSampleData() async {
    // Create العقيدة (Aqeedah) category with subcategories and topics
    final aqeedahCategoryId = _firestore.collection('categories').doc().id;
    await _categoriesRef().doc(aqeedahCategoryId).set(Category(
          id: aqeedahCategoryId,
          title_ar: 'العقيدة',
          imageUrl: 'https://cdn.pixabay.com/photo/2015/08/11/16/27/islam-884825_640.jpg',
          order: 1,
        ));

    // التوحيد subcategory
    final tawheedSubCatId = _firestore.collection('subcategories').doc().id;
    await _subCategoriesRef().doc(tawheedSubCatId).set(SubCategory(
          id: tawheedSubCatId,
          categoryId: aqeedahCategoryId,
          title_ar: 'التوحيد',
          imageUrl: 'https://hips.hearstapps.com/hmg-prod/images/prophet-muhammad-in-islamic-calligraphy-royalty-free-illustration-1676318571.jpg',
          order: 1,
        ));

    // أنواع التوحيد topic
    final tawheedTypesTopicId = _firestore.collection('topics').doc().id;
    await _firestore.collection('topics').doc(tawheedTypesTopicId).set({
      'id': tawheedTypesTopicId,
      'subCategoryId': tawheedSubCatId,
      'title_ar': 'أنواع التوحيد',
      'description_ar': 'تعلم عن أنواع التوحيد الثلاثة: توحيد الربوبية، توحيد الألوهية، وتوحيد الأسماء والصفات',
      'order': 1,
      'status': 'PUBLISHED',
    });

    // Add questions for أنواع التوحيد topic
    await _firestore.collection('questions').add({
      'topicId': tawheedTypesTopicId,
      'question_ar': 'ما هي أنواع التوحيد الرئيسية في الإسلام؟',
      'options_ar': [
        'توحيد الربوبية والألوهية والأسماء والصفات',
        'توحيد الذات والصفات والأفعال',
        'توحيد العبادة والطاعة والولاء',
        'توحيد القول والعمل والاعتقاد'
      ],
      'correctOptionIndex': 0,
      'order': 1,
      'explanation_ar': 'أنواع التوحيد الرئيسية هي: توحيد الربوبية (الإيمان بأن الله هو الخالق والمدبر)، توحيد الألوهية (إفراد الله بالعبادة)، وتوحيد الأسماء والصفات (الإيمان بأسماء الله وصفاته كما وردت)',
    });

    // Create الفقه (Fiqh) category with subcategories and topics
    final fiqhCategoryId = _firestore.collection('categories').doc().id;
    await _categoriesRef().doc(fiqhCategoryId).set(Category(
          id: fiqhCategoryId,
          title_ar: 'الفقه',
          imageUrl: '',
          order: 2,
        ));

    // الطهارة subcategory
    final taharahSubCatId = _firestore.collection('subcategories').doc().id;
    await _subCategoriesRef().doc(taharahSubCatId).set(SubCategory(
          id: taharahSubCatId,
          categoryId: fiqhCategoryId,
          title_ar: 'الطهارة',
          imageUrl: 'https://images.pexels.com/photos/36704/pexels-photo.jpg',
          order: 1,
        ));

    // أحكام الوضوء topic
    final wudhuTopicId = _firestore.collection('topics').doc().id;
    await _firestore.collection('topics').doc(wudhuTopicId).set({
      'id': wudhuTopicId,
      'subCategoryId': taharahSubCatId,
      'title_ar': 'أحكام الوضوء',
      'description_ar': 'تعلم عن فرائض وسنن الوضوء وكيفيته',
      'order': 1,
      'status': 'PUBLISHED',
    });

    // Add questions for أحكام الوضوء topic
    await _firestore.collection('questions').add({
      'topicId': wudhuTopicId,
      'question_ar': 'ما هي فرائض الوضوء؟',
      'options_ar': [
        'غسل الوجه واليدين والمسح على الرأس وغسل الرجلين',
        'غسل اليدين والوجه والرجلين فقط',
        'المضمضة والاستنشاق وغسل الوجه واليدين',
        'غسل القدمين والمسح على الخفين'
      ],
      'correctOptionIndex': 0,
      'order': 1,
      'explanation_ar': 'فرائض الوضوء هي: غسل الوجه، وغسل اليدين إلى المرفقين، والمسح على الرأس، وغسل الرجلين إلى الكعبين',
    });

    await _firestore.collection('questions').add({
      'topicId': wudhuTopicId,
      'question_ar': 'متى يجب الوضوء؟',
      'options_ar': [
        'قبل الصلاة وبعد خروج الريح',
        'قبل النوم فقط',
        'بعد الأكل فقط',
        'قبل قراءة القرآن فقط'
      ],
      'correctOptionIndex': 0,
      'order': 2,
      'explanation_ar': 'يجب الوضوء قبل الصلاة وبعد نواقض الوضوء مثل خروج الريح أو البول أو الغائط',
    });

    // Create سيرة النبي (Prophet's Biography) category
    final seerahCategoryId = _firestore.collection('categories').doc().id;
    await _categoriesRef().doc(seerahCategoryId).set(Category(
          id: seerahCategoryId,
          title_ar: 'السيرة النبوية',
          imageUrl: 'https://cdn.pixabay.com/photo/2015/08/11/16/27/islam-884825_640.jpg',
          order: 3,
        ));

    // مكة المكرمة subcategory
    final makkahSubCatId = _firestore.collection('subcategories').doc().id;
    await _subCategoriesRef().doc(makkahSubCatId).set(SubCategory(
          id: makkahSubCatId,
          categoryId: seerahCategoryId,
          title_ar: 'الفترة المكية',
          imageUrl: 'https://images.pexels.com/photos/36704/pexels-photo.jpg',
          order: 1,
        ));

    // نزول الوحي topic
    final wahyTopicId = _firestore.collection('topics').doc().id;
    await _firestore.collection('topics').doc(wahyTopicId).set({
      'id': wahyTopicId,
      'subCategoryId': makkahSubCatId,
      'title_ar': 'نزول الوحي',
      'description_ar': 'قصة نزول الوحي على النبي محمد صلى الله عليه وسلم',
      'order': 1,
      'status': 'PUBLISHED',
    });

    // Add questions for نزول الوحي topic
    await _firestore.collection('questions').add({
      'topicId': wahyTopicId,
      'question_ar': 'أين نزل الوحي لأول مرة على النبي صلى الله عليه وسلم؟',
      'options_ar': [
        'غار حراء',
        'المسجد الحرام',
        'غار ثور',
        'المدينة المنورة'
      ],
      'correctOptionIndex': 0,
      'order': 1,
      'explanation_ar': 'نزل الوحي لأول مرة على النبي محمد صلى الله عليه وسلم في غار حراء، وكان ذلك في شهر رمضان',
    });
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