import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/login_header.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController _emailController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await AppServices.instance.authRepository.forgotPassword(
      email: email,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case ApiSuccess<String> success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success.data)),
        );
        Navigator.of(context).pushNamed(
          AppRouter.resetPassword,
          arguments: ResetPasswordArgs(email: email),
        );
      case ApiFailure<String> failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.error.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          const ColoredBox(color: AppColors.background),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: AppSpacing.xl),
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Forgot password', style: textTheme.headlineSmall),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Enter the email for your merchant account. We will send a reset link and token.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'EMAIL',
                              style: textTheme.labelSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              style: textTheme.bodyMedium,
                              cursorColor: AppColors.primary,
                              decoration: InputDecoration(
                                hintText: 'Email address',
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.muted,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.muted,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _isSubmitting ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  disabledBackgroundColor: AppColors.primaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Send reset instructions',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: AppColors.onPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Back to sign in',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
