import 'package:equatable/equatable.dart';
import 'package:masarat_alnur/src/features/content/domain/content_status.dart'; // Import enum

// Using Equatable
class Category extends Equatable {
  final String id;
  final String title_ar;
  final String? imageUrl;
  final int order;
  final ContentStatus status;

  const Category({
    required this.id, // ID usually populated from Firestore document ID
    this.title_ar = '',
    this.imageUrl,
    this.order = 0,
    this.status = ContentStatus.PUBLISHED,
  });

  factory Category.empty() => const Category(id: '');

  @override
  List<Object?> get props => [id, title_ar, imageUrl, order, status];

  @override
  bool get stringify => true;

   Category copyWith({
     String? id,
     String? title_ar,
     String? imageUrl,
     bool clearImageUrl = false,
     int? order,
     ContentStatus? status,
   }) {
     return Category(
       id: id ?? this.id,
       title_ar: title_ar ?? this.title_ar,
       imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
       order: order ?? this.order,
       status: status ?? this.status,
     );
   }
}