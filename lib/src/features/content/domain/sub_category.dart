import 'package:equatable/equatable.dart';
import 'package:masarat_alnur/src/features/content/domain/content_status.dart';

class SubCategory extends Equatable {
  final String id;
  final String categoryId;
  final String title_ar;
  final String? imageUrl;
  final int order;
  final ContentStatus status;
  // final String? description_ar; // Add if needed

  const SubCategory({
    required this.id,
    this.categoryId = '',
    this.title_ar = '',
    this.imageUrl,
    this.order = 0,
    this.status = ContentStatus.PUBLISHED,
    // this.description_ar,
  });

   factory SubCategory.empty() => const SubCategory(id: '');

  @override
  List<Object?> get props => [id, categoryId, title_ar, imageUrl, order, status];

  @override
  bool get stringify => true;

  // copyWith
   SubCategory copyWith({
     String? id,
     String? categoryId,
     String? title_ar,
     String? imageUrl,
     bool clearImageUrl = false,
     int? order,
     ContentStatus? status,
   }) {
     return SubCategory(
       id: id ?? this.id,
       categoryId: categoryId ?? this.categoryId,
       title_ar: title_ar ?? this.title_ar,
       imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
       order: order ?? this.order,
       status: status ?? this.status,
     );
   }
}