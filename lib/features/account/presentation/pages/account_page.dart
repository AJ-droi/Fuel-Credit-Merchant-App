import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/profile_model.dart';
import '../widgets/account_bottom_nav.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<_AccountViewData> _accountFuture;

  @override
  void initState() {
    super.initState();
    _accountFuture = _loadAccountData();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _TopBar(textTheme: textTheme),
                Expanded(
                  child: FutureBuilder<_AccountViewData>(
                    future: _accountFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!;
                      if (data.profileResult
                          case ApiSuccess<ProfileResponse> success) {
                        final profile = success.data.data;
                        return _buildContent(
                          context,
                          textTheme,
                          profile,
                          data.primaryBranch,
                        );
                      }

                      final failure =
                          data.profileResult as ApiFailure<ProfileResponse>;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(failure.error.message),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _accountFuture = _loadAccountData();
                                });
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: AccountBottomNav()),
          ),
        ],
      ),
    );
  }

  Future<_AccountViewData> _loadAccountData() async {
    final profileResult = await AppServices.instance.accountRepository
        .fetchProfile();
    final branchesResult = await AppServices.instance.accountRepository
        .fetchBranches();

    BranchModel? primaryBranch;
    if (branchesResult case ApiSuccess<BranchesResponse> success) {
      final branches = success.data.data;
      primaryBranch = branches.cast<BranchModel?>().firstWhere(
        (branch) => branch?.isPrimary ?? false,
        orElse: () => branches.isNotEmpty ? branches.first : null,
      );
    }

    return _AccountViewData(
      profileResult: profileResult,
      primaryBranch: primaryBranch,
    );
  }

  Widget _buildContent(
    BuildContext context,
    TextTheme textTheme,
    ProfileModel profile,
    BranchModel? primaryBranch,
  ) {
    final branchName = primaryBranch?.name ?? profile.stationBranch;
    final branchLocation =
        primaryBranch?.locationLabel ?? profile.businessLocation;
    final branchAddress = primaryBranch?.address ?? profile.address;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        110,
      ),
      child: Column(
        children: [
          _ProfileHeader(
            textTheme: textTheme,
            profile: profile,
            branchName: branchName,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  title: 'Phone Number',
                  value: profile.phone,
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoTile(
                  title: 'Email',
                  value: profile.email,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  title: 'Primary Branch',
                  value: branchName.isNotEmpty
                      ? branchName
                      : profile.businessName,
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoTile(
                  title: 'Branch Location',
                  value: branchLocation.isNotEmpty
                      ? branchLocation
                      : branchAddress,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(title: 'Merchant Settings', color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          _ActionList(
            items: [
              _ActionItem(
                'Update Pump Price',
                Icons.speed_rounded,
                AppColors.primary,
                onTap: () => _showUpdatePriceDialog(context, profile),
              ),
              const _ActionItem(
                'Update Profile Details',
                Icons.edit_square,
                AppColors.secondary,
              ),
              _ActionItem(
                'Change Password',
                Icons.lock_reset,
                AppColors.muted,
                onTap: () => _showChangePasswordDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle(title: 'Support', color: AppColors.muted),
          const SizedBox(height: AppSpacing.sm),
          _ActionList(
            items: const [
              _ActionItem(
                'Help & Support',
                Icons.help_center_rounded,
                AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0x66FFB4AB)),
                backgroundColor: const Color(0x14690005),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, color: Color(0xFFFFB4AB)),
              label: Text(
                'Logout Session',
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFFFB4AB),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'FuelNode v2.4.1 Build 99',
            style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  void _showUpdatePriceDialog(BuildContext context, ProfileModel profile) {
    final controller = TextEditingController(
      text: profile.fuelPricePerLitre.toString(),
    );
    bool isSaving = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF010F1F),
              title: const Text(
                'Update Pump Price',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Price per Litre (₦)',
                      labelStyle: TextStyle(color: AppColors.muted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newPrice = double.tryParse(
                            controller.text.trim(),
                          );
                          if (newPrice == null || newPrice <= 0) return;

                          setState(() => isSaving = true);
                          final result = await AppServices
                              .instance
                              .accountRepository
                              .updateFuelPrice(newPrice);
                          setState(() => isSaving = false);

                          if (result is ApiSuccess) {
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pump price updated successfully',
                                  ),
                                ),
                              );
                              this.setState(() {
                                _accountFuture = _loadAccountData();
                              });
                            }
                          } else if (result is ApiFailure) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    (result as ApiFailure).error.message,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isSaving = false;
    var obscureCurrentPassword = true;
    var obscureNewPassword = true;
    var obscureConfirmPassword = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            Future<void> submit() async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              setDialogState(() => isSaving = true);
              final result = await AppServices.instance.authRepository
                  .changePassword(
                    currentPassword: currentPasswordController.text.trim(),
                    newPassword: newPasswordController.text.trim(),
                  );
              setDialogState(() => isSaving = false);

              if (!mounted || !dialogBuilderContext.mounted) return;

              if (result is ApiSuccess<bool>) {
                Navigator.of(dialogBuilderContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                  ),
                );
              } else if (result is ApiFailure<bool>) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result.error.message)));
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF010F1F),
              title: const Text(
                'Change Password',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PasswordField(
                          controller: currentPasswordController,
                          label: 'Current Password',
                          obscureText: obscureCurrentPassword,
                          onToggleVisibility: () {
                            setDialogState(
                              () => obscureCurrentPassword =
                                  !obscureCurrentPassword,
                            );
                          },
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Current password is required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PasswordField(
                          controller: newPasswordController,
                          label: 'New Password',
                          obscureText: obscureNewPassword,
                          onToggleVisibility: () {
                            setDialogState(
                              () => obscureNewPassword = !obscureNewPassword,
                            );
                          },
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'New password is required';
                            }
                            if (trimmed.length < 6) {
                              return 'New password must be at least 6 characters';
                            }
                            if (trimmed ==
                                currentPasswordController.text.trim()) {
                              return 'New password must be different';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PasswordField(
                          controller: confirmPasswordController,
                          label: 'Confirm New Password',
                          obscureText: obscureConfirmPassword,
                          onToggleVisibility: () {
                            setDialogState(
                              () => obscureConfirmPassword =
                                  !obscureConfirmPassword,
                            );
                          },
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Please confirm the new password';
                            }
                            if (trimmed != newPasswordController.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
                FilledButton(
                  onPressed: isSaving ? null : submit,
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AccountViewData {
  const _AccountViewData({
    required this.profileResult,
    required this.primaryBranch,
  });

  final ApiResult<ProfileResponse> profileResult;
  final BranchModel? primaryBranch;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: Color(0xCC051424),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'FuelCredit Merchant',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.textTheme,
    required this.profile,
    required this.branchName,
  });

  final TextTheme textTheme;
  final ProfileModel profile;
  final String branchName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x33C6C0FF), blurRadius: 24),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: const Icon(Icons.person, size: 54, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(profile.merchantName, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              branchName.isNotEmpty ? branchName : profile.businessName,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.textTheme,
  });

  final String title;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: color, letterSpacing: 1.1),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem(this.label, this.icon, this.iconColor, {this.onTap});

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.muted),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList({required this.items});

  final List<_ActionItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: items[i].onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: items[i].iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(items[i].icon, color: items[i].iconColor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(items[i].label, style: textTheme.bodyLarge),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.outline),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              const Divider(color: Colors.white10, height: 1),
          ],
        ],
      ),
    );
  }
}
