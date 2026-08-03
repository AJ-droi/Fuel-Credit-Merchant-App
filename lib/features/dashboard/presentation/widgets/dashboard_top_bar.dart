import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../account/data/models/profile_model.dart';
import '../../data/models/dashboard_models.dart';

class DashboardTopBar extends StatefulWidget {
  const DashboardTopBar({super.key});

  @override
  State<DashboardTopBar> createState() => _DashboardTopBarState();
}

class _DashboardTopBarState extends State<DashboardTopBar> {
  late Future<_TopBarData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.notificationController.bootstrap();
    });
  }

  Future<_TopBarData> _load() async {
    final storage = TokenStorage.instance;
    var name = await storage.getUserDisplayName();
    final role = await storage.getUserRole();
    final email = await storage.getUserEmail();
    final summaryResult =
        await AppServices.instance.dashboardRepository.fetchSummary();

    var businessName = '';
    if (summaryResult is ApiSuccess<DashboardSummary>) {
      businessName = summaryResult.data.data.businessName;
    }

    if (name == null || name.isEmpty) {
      final profileResult =
          await AppServices.instance.accountRepository.fetchProfile();
      if (profileResult is ApiSuccess<ProfileResponse>) {
        final profile = profileResult.data.data;
        if (profile.merchantName.isNotEmpty) {
          name = profile.merchantName;
        } else if (profile.businessName.isNotEmpty) {
          name = profile.businessName;
        }
      }
    }

    return _TopBarData(
      userName: (name != null && name.isNotEmpty) ? name : 'Merchant',
      role: role ?? '',
      email: email ?? '',
      businessName: businessName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.sm, 16),
          child: FutureBuilder<_TopBarData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              final data = snapshot.data;
              final userName = data?.userName ?? 'Merchant';
              final subtitle = () {
                if (data == null) return '';
                if (data.businessName.isNotEmpty) return data.businessName;
                if (data.role.isNotEmpty) return data.role;
                return data.email;
              }();

              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.emeraldMuted,
                          ),
                        ),
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: AppRouter.notificationController,
                    builder: (context, _) {
                      final unread = AppRouter.notificationController.unreadCount;
                      return IconButton(
                        tooltip: 'Notifications',
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRouter.notifications);
                        },
                        icon: Badge(
                          isLabelVisible: unread > 0,
                          label: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: AppColors.accent,
                          textColor: AppColors.primary,
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.accent,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Log out',
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Log out?',
            style: TextStyle(color: AppColors.onBackground),
          ),
          content: const Text(
            'You will need to sign in again to manage this station.',
            style: TextStyle(color: AppColors.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await AppServices.instance.authRepository.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.login,
      (route) => false,
    );
  }
}

class _TopBarData {
  const _TopBarData({
    required this.userName,
    required this.role,
    required this.email,
    required this.businessName,
  });

  final String userName;
  final String role;
  final String email;
  final String businessName;
}
