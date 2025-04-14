import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masarat_alnur/src/features/auth/presentation/auth_view_model.dart'; // Import AuthUiState and related types

extension AsyncValueUI on AsyncValue<dynamic> { // Use dynamic or specific type if needed
  /// Shows a Snackbar when the AsyncValue is an error, does nothing otherwise.
  void showSnackbarOnError(BuildContext context) {
    if (!isLoading && hasError && !hasValue) { // Ensure it's an error state
      final message = error is Exception
          ? (error as Exception).toString() // Show exception message
          : error?.toString() ?? 'An unknown error occurred'; // Fallback

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar() // Hide previous snackbar if any
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }
   // Helper to show a success snackbar if needed (example)
    void showSnackbarOnSuccess(BuildContext context, String message) {
       if (!isLoading && !hasError && hasValue) {
           ScaffoldMessenger.of(context)
               ..hideCurrentSnackBar()
               ..showSnackBar(SnackBar(content: Text(message)));
       }
    }
}

// Extension for AuthUiState
extension AuthUiStateUI on AuthUiState {
   void showSnackBarOnError(BuildContext context) {
       if (this is AuthUiError) {
          final errorState = this as AuthUiError;
          ScaffoldMessenger.of(context)
             ..hideCurrentSnackBar()
             ..showSnackBar(
                SnackBar(
                   content: Text(errorState.message),
                   backgroundColor: Theme.of(context).colorScheme.error,
                 ),
              );
       }
   }

    void showSnackbarOnPasswordResetSent(BuildContext context, String message) {
       if (this is AuthUiPasswordResetSent) {
          ScaffoldMessenger.of(context)
             ..hideCurrentSnackBar()
             ..showSnackBar(SnackBar(content: Text(message)));
       }
    }
}