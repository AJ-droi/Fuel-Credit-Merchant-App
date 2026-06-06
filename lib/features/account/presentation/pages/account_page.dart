import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/account_bottom_nav.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 110),
                    child: Column(
                      children: [
                        _ProfileHeader(textTheme: textTheme),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoTile(
                                title: 'Phone Number',
                                value: '+234 803 456 7890',
                                textTheme: textTheme,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _InfoTile(
                                title: 'Email',
                                value: 'c.okoro@fuelops.ng',
                                textTheme: textTheme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SectionTitle(title: 'Merchant Settings', color: AppColors.primary),
                        const SizedBox(height: AppSpacing.sm),
                        _ActionList(
                          items: const [
                            _ActionItem('Update Pump Price', Icons.speed_rounded, AppColors.primary),
                            _ActionItem('Update Profile Details', Icons.edit_square, AppColors.secondary),
                            _ActionItem('Change Password', Icons.lock_reset, AppColors.muted),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionTitle(title: 'Support', color: AppColors.muted),
                        const SizedBox(height: AppSpacing.sm),
                        _ActionList(
                          items: const [
                            _ActionItem('Help & Support', Icons.help_center_rounded, AppColors.muted),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context)
                                .pushNamedAndRemoveUntil(AppRouter.login, (route) => false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0x66FFB4AB)),
                              backgroundColor: const Color(0x14690005),
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            'FuelNode Merchant',
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
  const _ProfileHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            boxShadow: const [BoxShadow(color: Color(0x33C6C0FF), blurRadius: 24)],
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
            child: const Icon(Icons.person, size: 54, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Chidi Okoro', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Victoria Island Station #04',
              style: textTheme.labelSmall?.copyWith(color: AppColors.muted, letterSpacing: 0.6),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value, required this.textTheme});

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
          Text(title.toUpperCase(), style: textTheme.labelSmall?.copyWith(color: AppColors.outline)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, letterSpacing: 1.1),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem(this.label, this.icon, this.iconColor);

  final String label;
  final IconData icon;
  final Color iconColor;
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
              onTap: () {},
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
                    Expanded(child: Text(items[i].label, style: textTheme.bodyLarge)),
                    const Icon(Icons.chevron_right, color: AppColors.outline),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1) const Divider(color: Colors.white10, height: 1),
          ],
        ],
      ),
    );
  }
}
