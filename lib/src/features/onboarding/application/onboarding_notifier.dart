import 'package:masarat_alnur/src/features/auth/data/user_repository.dart'; // Import User Repo
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_notifier.g.dart'; // Riverpod generator

// Define states for onboarding UI
enum OnboardingUiState { idle, loading, success, error }

@riverpod // Use riverpod generator
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingUiState build() {
    return OnboardingUiState.idle; // Initial state
  }

  Future<void> saveNickname(String userId, String nickname) async {
    if (nickname.trim().isEmpty) {
      // Handle empty nickname case if needed, maybe return false or throw
      state = OnboardingUiState.error; // Example error state
      return;
    }
    state = OnboardingUiState.loading;
    try {
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.updateUserData(userId, displayName: nickname.trim());
      state = OnboardingUiState.success;
    } catch (e) {
      print("Error saving nickname: $e");
      state = OnboardingUiState.error;
    }
  }

   // Function to reset state back to idle after UI handles success/error
   void resetState() {
     state = OnboardingUiState.idle;
   }
}