import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masarat_alnur/src/features/auth/presentation/auth_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// Import AsyncValueUI helper if needed for error display

class SignUpView extends ConsumerStatefulWidget {
  final VoidCallback onGoToSignIn; // Callback to switch tabs

  const SignUpView({super.key, required this.onGoToSignIn});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
       if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
             const SnackBar(content: Text("\"Passwords do not match\"")) // TODO: Localize
          );
          return;
       }
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      // Call ViewModel method
      ref
          .read(authViewModelProvider.notifier)
          .signUpWithEmailPassword(email, password);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(authViewModelProvider);
    final bool isLoading = state is AuthUiLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const SizedBox(height: 20), // Add some top spacing

            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration( /* ... as in LoginView ... */ labelText: l10n.emailHint, prefixIcon: const Icon(Icons.email_outlined), border: const OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) { /* ... email validation ... */
                 if (value == null || value.isEmpty || !value.contains('@')) return 'Please enter a valid email'; return null; },
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration( /* ... as in LoginView ... */ labelText: l10n.passwordHint, prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder()),
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (value) { /* ... password length validation ... */
                 if (value == null || value.isEmpty || value.length < 6) return 'Password must be at least 6 characters'; return null; },
               enabled: !isLoading,
            ),
             const SizedBox(height: 16),

             // Confirm Password Field
             TextFormField(
               controller: _confirmPasswordController,
               decoration: InputDecoration(labelText: l10n.confirmPasswordHint, prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder()),
               obscureText: true,
               textInputAction: TextInputAction.done,
               validator: (value) {
                 if (value == null || value.isEmpty) {
                   return 'Please confirm your password'; // TODO: Localize
                 }
                 if (value != _passwordController.text) {
                    return 'Passwords do not match'; // TODO: Localize
                 }
                 return null;
               },
               enabled: !isLoading,
               onFieldSubmitted: (_) => isLoading ? null : _submit(),
             ),
            const SizedBox(height: 24),

            // SignUp Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.signupButton),
            ),
            const SizedBox(height: 32),

            // Go to Sign In Text Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text(l10n.haveAccountPrompt.split('?')[0] + '?'), // TODO: Improve string handling
                TextButton(
                  onPressed: isLoading ? null : widget.onGoToSignIn, // Call callback
                  child: Text(l10n.loginButton), // Use login button text as link
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}