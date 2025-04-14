import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserProgress extends Equatable {
  // Use userId as document ID, not stored in fields
  final List<String> completedTopicIds;
  final List<String> startedSubCategoryInfo;
  final List<String> completedSubCategoryIds;
  final List<String> startedCategoryInfo;
  final List<String> completedCategoryIds;

  const UserProgress({
    this.completedTopicIds = const [],
    this.startedSubCategoryInfo = const [],
    this.completedSubCategoryIds = const [],
    this.startedCategoryInfo = const [],
    this.completedCategoryIds = const [],
    
  });

  // Factory constructor for default empty state
   factory UserProgress.empty() => const UserProgress();

  // Firestore conversion requires careful handling of Timestamps and potentially Lists/Maps
   factory UserProgress.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
       final data = snapshot.data();
       // Helper to safely convert list fields
       List<String> listFromFirestore(dynamic list) {
           return (list as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
       }

       return UserProgress(
           completedTopicIds: listFromFirestore(data?['completedTopicIds']),
           startedSubCategoryInfo: listFromFirestore(data?['startedSubCategoryInfo']),
           completedSubCategoryIds: listFromFirestore(data?['completedSubCategoryIds']),
           startedCategoryInfo: listFromFirestore(data?['startedCategoryInfo']),
           completedCategoryIds: listFromFirestore(data?['completedCategoryIds']),
       );
   }

   Map<String, dynamic> toFirestore() {
       return {
           'completedTopicIds': completedTopicIds,
           'startedSubCategoryInfo': startedSubCategoryInfo,
           'completedSubCategoryIds': completedSubCategoryIds,
           'startedCategoryInfo': startedCategoryInfo,
           'completedCategoryIds': completedCategoryIds,
       };
   }


  @override
  List<Object?> get props => [
        completedTopicIds,
        startedSubCategoryInfo,
        completedSubCategoryIds,
        startedCategoryInfo,
        completedCategoryIds,
      ];

  @override
  bool get stringify => true;

   // copyWith method for immutable updates
   UserProgress copyWith({
     List<String>? completedTopicIds,
     List<String>? startedSubCategoryInfo,
     List<String>? completedSubCategoryIds,
     List<String>? startedCategoryInfo,
     List<String>? completedCategoryIds,
   }) {
     return UserProgress(
       completedTopicIds: completedTopicIds ?? this.completedTopicIds,
       startedSubCategoryInfo: startedSubCategoryInfo ?? this.startedSubCategoryInfo,
       completedSubCategoryIds: completedSubCategoryIds ?? this.completedSubCategoryIds,
       startedCategoryInfo: startedCategoryInfo ?? this.startedCategoryInfo,
       completedCategoryIds: completedCategoryIds ?? this.completedCategoryIds,
     );
   }
}