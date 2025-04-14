import 'package:equatable/equatable.dart';
import 'package:masarat_alnur/src/features/content/domain/content_status.dart';

class Topic extends Equatable { // Represents a Quiz
  final String id;
  final String subCategoryId;
  final String title_ar;
  final String description_ar;
  final int order;
  final ContentStatus status;

  const Topic({
    required this.id,
    this.subCategoryId = '',
    this.title_ar = '',
    this.description_ar = '',
    this.order = 0,
    this.status = ContentStatus.PUBLISHED,
  });

   factory Topic.empty() => const Topic(id: '');

  @override
  List<Object?> get props => [id, subCategoryId, title_ar, description_ar, order, status];

  @override
  bool get stringify => true;

  // copyWith
   Topic copyWith({
     String? id,
     String? subCategoryId,
     String? title_ar,
     String? description_ar,
     int? order,
     ContentStatus? status,
   }) {
     return Topic(
       id: id ?? this.id,
       subCategoryId: subCategoryId ?? this.subCategoryId,
       title_ar: title_ar ?? this.title_ar,
       description_ar: description_ar ?? this.description_ar,
       order: order ?? this.order,
       status: status ?? this.status,
     );
   }
}