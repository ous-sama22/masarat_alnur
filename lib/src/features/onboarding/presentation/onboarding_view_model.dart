import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masarat_alnur/src/features/auth/data/auth_repository.dart'; // For user ID
import 'package:masarat_alnur/src/features/auth/data/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_view_model.g.dart';

@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {

  // Build returns the initial state, can be void if no data needed initially
  @override
  FutureOr<void> build() {
    // No initial async work needed for this simple state
    return null; // Or return Future.value(null);
  }

  // Get user repo dependency
  UserRepository get _userRepository => ref.read(userRepositoryProvider);
  // Get auth repo to find current user ID
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  Future<bool> saveNickname(String nickname) async {
    // Use AsyncValue to represent state: loading, error, data (void means success)
    state = const AsyncLoading();
    final userId = _authRepository.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      state = AsyncError('User not logged in to save nickname.', StackTrace.current);
      return false;
    }
    if (nickname.trim().isEmpty || nickname.length < 3) {
        state = AsyncError('Invalid nickname provided.', StackTrace.current);
        return false;
    }

    try {
      await _userRepository.updateUserData(userId, displayName: nickname.trim());
       print("OnboardingViewModel: Nickname saved successfully.");
      // Set state to data to indicate success, observers can react
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      print("OnboardingViewModel: Error saving nickname: $e");
      state = AsyncError(e, st);
      return false;
    }
  }
}