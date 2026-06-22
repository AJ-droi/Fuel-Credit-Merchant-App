import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SafeArea(bottom: false, child: DashboardTopBar()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    180,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardKpiGrid(),
                      SizedBox(height: AppSpacing.lg),
                      DashboardTransactions(),
                      SizedBox(height: AppSpacing.lg),
                      // DashboardThroughput(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: DashboardBottomShell()),
          ),
        ],
      ),
    );
  }
}
