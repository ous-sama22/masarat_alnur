import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masarat_alnur/src/features/auth/presentation/auth_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:masarat_alnur/src/utils/async_value_ui.dart'; // For snackbar helper

class LoginView extends ConsumerStatefulWidget {
  final VoidCallback onGoToSignUp; // Callback to switch tabs

  const LoginView({super.key, required this.onGoToSignUp});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      // Call ViewModel method
      ref
          .read(authViewModelProvider.notifier)
          .signInWithEmailPassword(email, password);
    }
  }

   Future<void> _submitGoogle() async {
     ref.read(authViewModelProvider.notifier).signInWithGoogle();
   }

   Future<void> _forgotPassword() async {
       final email = _emailController.text.trim();
       if (email.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)){
            // Show prompt to enter email first
            ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
                 const SnackBar(content: Text("\"Please enter a valid email address first.\"")) // TODO: Localize
             );
            return;
       }
        ref.read(authViewModelProvider.notifier).sendPasswordResetEmail(email);
   }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(authViewModelProvider); // Watch the state provider
    final bool isLoading = state is AuthUiLoading;

    // Listen for password reset success separately if needed
     ref.listen<AuthUiState>(authViewModelProvider, (_, next) {
        // Example: show specific message for password reset email sent
         next.showSnackbarOnPasswordResetSent(context, "\"Password reset email sent.\""); // TODO: Localize
         // Reset state after showing message?
         if (next is AuthUiPasswordResetSent) {
           Future.delayed(const Duration(milliseconds: 100), () {
              ref.read(authViewModelProvider.notifier).resetUiStateToIdle();
           });
         }
     });


    return SingleChildScrollView( // Allow scrolling on small screens
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
              decoration: InputDecoration(
                labelText: l10n.emailHint,
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email'; // TODO: Localize
                }
                return null;
              },
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.passwordHint,
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                // TODO: Add suffix icon for password visibility toggle
              ),
              obscureText: true, // Hide password
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return 'Password must be at least 6 characters'; // TODO: Localize
                }
                return null;
              },
               enabled: !isLoading,
               onFieldSubmitted: (_) => isLoading ? null : _submit(),
            ),
            const SizedBox(height: 8),

             // Forgot Password Link
             Align(
               alignment: AlignmentDirectional.centerEnd,
               child: TextButton(
                 onPressed: isLoading ? null : _forgotPassword,
                 child: Text(l10n.forgotPasswordPrompt),
               ),
             ),
            const SizedBox(height: 24),

            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: isLoading ? null : _submit,
              child: isLoading && state is! AuthUiPasswordResetSent // Show loading only for actual login attempt
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.loginButton),
            ),
            const SizedBox(height: 20),

             // Or Divider
             Row(children: <Widget>[
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("\"OR\"", style: Theme.of(context).textTheme.bodySmall), // TODO: Localize "OR"
                ),
                const Expanded(child: Divider()),
              ]),
             const SizedBox(height: 20),


            // Google Sign In Button
            OutlinedButton.icon(
               style: OutlinedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 12),
                   side: BorderSide(color: Colors.grey.shade300),
                 ),
              icon: Image.asset('assets/icons/google_logo.png', height: 20.0), // Add google logo asset
              label: Text(l10n.continueWithGoogle),
              onPressed: isLoading ? null : _submitGoogle,
            ),
            const SizedBox(height: 32),

            // Go to Sign Up Text Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${l10n.noAccountPrompt.split('?')[0]}?'), // TODO: Improve string splitting/handling
                TextButton(
                  onPressed: isLoading ? null : widget.onGoToSignUp, // Call callback
                  child: Text(l10n.signupButton), // Use signup button text as link text
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}