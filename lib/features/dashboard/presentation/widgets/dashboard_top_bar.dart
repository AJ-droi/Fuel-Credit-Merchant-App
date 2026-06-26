import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/dashboard_models.dart';

class DashboardTopBar extends StatefulWidget {
  const DashboardTopBar({super.key});

  @override
  State<DashboardTopBar> createState() => _DashboardTopBarState();
}

class _DashboardTopBarState extends State<DashboardTopBar> {
  late Future<ApiResult<DashboardSummary>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = AppServices.instance.dashboardRepository.fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: FutureBuilder<ApiResult<DashboardSummary>>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          var businessName = 'FUELCREDIT Merchant';
          var merchantId = 'Merchant Dashboard';

          final result = snapshot.data;
          if (result is ApiSuccess<DashboardSummary>) {
            businessName = result.data.data.businessName;
            merchantId = result.data.data.merchantId;
          }

          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: const Icon(Icons.person, color: AppColors.onPrimary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FUELCREDIT',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            businessName.isEmpty ? merchantId : businessName,
                            style: textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
