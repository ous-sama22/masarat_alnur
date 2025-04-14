import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserProgress extends Equatable {
  // Use userId as document ID, not stored in fields
  final List<String> completedTopicIds;
  final Map<String, Timestamp> startedSubCategoryInfo;
  final List<String> completedSubCategoryIds;
  final Map<String, Timestamp> startedCategoryInfo;
  final List<String> completedCategoryIds;
  final Timestamp? lastUpdatedAt; // Allow null initially

  const UserProgress({
    this.completedTopicIds = const [],
    this.startedSubCategoryInfo = const {},
    this.completedSubCategoryIds = const [],
    this.startedCategoryInfo = const {},
    this.completedCategoryIds = const [],
    this.lastUpdatedAt,
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
       // Helper to safely convert map fields
       Map<String, Timestamp> mapFromFirestore(dynamic map) {
           return (map as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as Timestamp)) ?? {};
       }

       return UserProgress(
           completedTopicIds: listFromFirestore(data?['completedTopicIds']),
           startedSubCategoryInfo: mapFromFirestore(data?['startedSubCategoryInfo']),
           completedSubCategoryIds: listFromFirestore(data?['completedSubCategoryIds']),
           startedCategoryInfo: mapFromFirestore(data?['startedCategoryInfo']),
           completedCategoryIds: listFromFirestore(data?['completedCategoryIds']),
           lastUpdatedAt: data?['lastUpdatedAt'] as Timestamp?,
       );
   }

   Map<String, dynamic> toFirestore() {
       return {
           'completedTopicIds': completedTopicIds,
           'startedSubCategoryInfo': startedSubCategoryInfo,
           'completedSubCategoryIds': completedSubCategoryIds,
           'startedCategoryInfo': startedCategoryInfo,
           'completedCategoryIds': completedCategoryIds,
           // Use FieldValue for server timestamp on updates, null check might be needed
           'lastUpdatedAt': lastUpdatedAt ?? FieldValue.serverTimestamp(), // Use server timestamp if null
       };
   }


  @override
  List<Object?> get props => [
        completedTopicIds,
        startedSubCategoryInfo,
        completedSubCategoryIds,
        startedCategoryInfo,
        completedCategoryIds,
        lastUpdatedAt,
      ];

  @override
  bool get stringify => true;

   // copyWith method for immutable updates
   UserProgress copyWith({
     List<String>? completedTopicIds,
     Map<String, Timestamp>? startedSubCategoryInfo,
     List<String>? completedSubCategoryIds,
     Map<String, Timestamp>? startedCategoryInfo,
     List<String>? completedCategoryIds,
     Timestamp? lastUpdatedAt,
   }) {
     return UserProgress(
       completedTopicIds: completedTopicIds ?? this.completedTopicIds,
       startedSubCategoryInfo: startedSubCategoryInfo ?? this.startedSubCategoryInfo,
       completedSubCategoryIds: completedSubCategoryIds ?? this.completedSubCategoryIds,
       startedCategoryInfo: startedCategoryInfo ?? this.startedCategoryInfo,
       completedCategoryIds: completedCategoryIds ?? this.completedCategoryIds,
       lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
     );
   }
}