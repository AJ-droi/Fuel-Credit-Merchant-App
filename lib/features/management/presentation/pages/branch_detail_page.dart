import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../account/data/models/branch_model.dart';
import '../widgets/management_bottom_nav.dart';

class BranchDetailPage extends StatefulWidget {
  const BranchDetailPage({super.key, required this.branchId});

  final String branchId;

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  late Future<ApiResult<BranchDetailModel>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    setState(() {
      _detailFuture = AppServices.instance.accountRepository.fetchBranchDetail(
        widget.branchId,
      );
    });
  }

  Future<void> _toggleStatus(BranchDetailModel branch) async {
    final nextStatus = branch.status.toLowerCase() == 'active' ? 'inactive' : 'active';
    final result = await AppServices.instance.accountRepository.updateBranch(
      branchId: branch.id,
      status: nextStatus,
    );

    if (!mounted) return;

    if (result case ApiSuccess<BranchModel> _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus == 'active' ? 'Branch activated' : 'Branch deactivated',
          ),
        ),
      );
      _loadDetail();
    } else if (result case ApiFailure<BranchModel> failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.error.message)),
      );
    }
  }

  Future<void> _openEdit(BranchDetailModel branch) async {
    final updated = await Navigator.of(context).pushNamed<bool>(
      AppRouter.editBranch,
      arguments: branch.id,
    );
    if (updated == true) {
      _loadDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Details'),
        actions: [
          IconButton(
            onPressed: () => _loadDetail(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<ApiResult<BranchDetailModel>>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final result = snapshot.data!;
              if (result case ApiSuccess<BranchDetailModel> success) {
                final branch = success.data;
                final location = [
                  if (branch.address.isNotEmpty) branch.address,
                  if (branch.city.isNotEmpty) branch.city,
                  if (branch.state.isNotEmpty) branch.state,
                ].join(' • ');

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    120,
                  ),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            branch.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        if (branch.isPrimary) _badge('Primary', AppColors.primaryContainer),
                        const SizedBox(width: AppSpacing.xs),
                        _badge(
                          branch.status,
                          branch.status.toLowerCase() == 'active'
                              ? AppColors.success
                              : AppColors.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      location.isNotEmpty ? location : 'No address provided',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    if (branch.landmark.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Landmark: ${branch.landmark}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Staff',
                            branch.staffCount.toString(),
                            Icons.people_outline,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _statCard(
                            'Sales',
                            branch.salesCount.toString(),
                            Icons.receipt_long_outlined,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _statCard(
                            'Revenue',
                            _formatCurrency(branch.grossAmount),
                            Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openEdit(branch),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Branch'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _toggleStatus(branch),
                            icon: Icon(
                              branch.status.toLowerCase() == 'active'
                                  ? Icons.block
                                  : Icons.check_circle_outline,
                            ),
                            label: Text(
                              branch.status.toLowerCase() == 'active'
                                  ? 'Deactivate'
                                  : 'Activate',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Assigned Staff',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (branch.staff.isEmpty)
                      const Text(
                        'No attendants assigned to this branch yet.',
                        style: TextStyle(color: AppColors.muted),
                      )
                    else
                      ...branch.staff.map(
                        (member) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(member.fullName),
                          subtitle: Text(member.email),
                          trailing: _badge(
                            member.accountStatus,
                            member.accountStatus.toLowerCase() == 'active'
                                ? AppColors.success
                                : AppColors.muted,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.staffDetail,
                              arguments: member.id,
                            );
                          },
                        ),
                      ),
                  ],
                );
              }

              final failure = result as ApiFailure<BranchDetailModel>;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(failure.error.message, textAlign: TextAlign.center),
                    TextButton(onPressed: _loadDetail, child: const Text('Retry')),
                  ],
                ),
              );
            },
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: ManagementBottomNav()),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.onBackground,
            ),
          ),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    )}';
  }
}
