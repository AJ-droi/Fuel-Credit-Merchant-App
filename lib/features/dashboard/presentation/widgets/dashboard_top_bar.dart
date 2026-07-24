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
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.sm, 16),
          child: FutureBuilder<ApiResult<DashboardSummary>>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              var businessName = 'Merchant';
              var merchantId = '';

              final result = snapshot.data;
              if (result is ApiSuccess<DashboardSummary>) {
                businessName = result.data.data.businessName;
                merchantId = result.data.data.merchantId;
              }

              final title = businessName.isNotEmpty ? businessName : 'FUELCREDIT Merchant';

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
                    child: const Icon(Icons.local_gas_station_rounded, color: AppColors.accent, size: 22),
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
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (merchantId.isNotEmpty)
                          Text(
                            merchantId,
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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.accent),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
