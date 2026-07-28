import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/login_header.dart';

class ResetPasswordArgs {
  const ResetPasswordArgs({
    this.email = '',
    this.token = '',
  });

  final String email;
  final String token;
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    this.email = '',
    this.initialToken = '',
  });

  final String email;
  final String initialToken;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final TextEditingController _tokenController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the reset token from your email.')),
      );
      return;
    }
    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters.')),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await AppServices.instance.authRepository.resetPassword(
      token: token,
      newPassword: newPassword,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case ApiSuccess<String> success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success.data.isEmpty
                  ? 'Password reset successful. Please sign in.'
                  : success.data,
            ),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.login,
          (_) => false,
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
    final emailHint = widget.email.isEmpty
        ? 'Paste the reset token from your email and choose a new password.'
        : 'We sent reset instructions to ${widget.email}. Paste the token below and choose a new password.';

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
                            Text('Reset password', style: textTheme.headlineSmall),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              emailHint,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _LabeledField(
                              label: 'RESET TOKEN',
                              child: TextField(
                                controller: _tokenController,
                                style: textTheme.bodyMedium,
                                cursorColor: AppColors.primary,
                                decoration: _inputDecoration(
                                  textTheme,
                                  hint: 'Paste token from email',
                                  icon: Icons.vpn_key_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _LabeledField(
                              label: 'NEW PASSWORD',
                              child: TextField(
                                controller: _newPasswordController,
                                obscureText: _obscureNew,
                                style: textTheme.bodyMedium,
                                cursorColor: AppColors.primary,
                                decoration: _inputDecoration(
                                  textTheme,
                                  hint: 'At least 8 characters',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscureNew = !_obscureNew),
                                    icon: Icon(
                                      _obscureNew
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _LabeledField(
                              label: 'CONFIRM PASSWORD',
                              child: TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirm,
                                style: textTheme.bodyMedium,
                                cursorColor: AppColors.primary,
                                decoration: _inputDecoration(
                                  textTheme,
                                  hint: 'Re-enter new password',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm,
                                    ),
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.muted,
                                    ),
                                  ),
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
                                  disabledBackgroundColor:
                                      AppColors.primaryContainer,
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
                                        'Reset password',
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
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRouter.login,
                                    (_) => false,
                                  );
                                },
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

  InputDecoration _inputDecoration(
    TextTheme textTheme, {
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
      prefixIcon: Icon(icon, color: AppColors.muted),
      suffixIcon: suffix,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
