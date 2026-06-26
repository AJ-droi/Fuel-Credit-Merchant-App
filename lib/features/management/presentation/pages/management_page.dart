import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../account/data/models/branch_model.dart';
import '../../data/models/seller_model.dart';
import '../widgets/management_bottom_nav.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<ApiResult<BranchesResponse>> _branchesFuture;
  late Future<ApiResult<SellersResponse>> _sellersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {});
        }
      });
    _branchesFuture = AppServices.instance.accountRepository.fetchBranches();
    _sellersFuture = AppServices.instance.managementRepository.fetchSellers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshBranches() {
    setState(() {
      _branchesFuture = AppServices.instance.accountRepository.fetchBranches();
    });
  }

  Future<void> _openCreateBranch() async {
    final created = await Navigator.of(context).pushNamed<bool>(
      AppRouter.createBranch,
    );
    if (created == true) {
      _refreshBranches();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onBranchesTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Branches'),
            Tab(text: 'Attendants'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [_buildBranchesTab(), _buildAttendantsTab()],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: ManagementBottomNav()),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: onBranchesTab ? _openCreateBranch : _showInviteAttendantDialog,
          icon: Icon(onBranchesTab ? Icons.add : Icons.person_add),
          label: Text(onBranchesTab ? 'Add Branch' : 'Invite'),
        ),
      ),
    );
  }

  Widget _buildBranchesTab() {
    return FutureBuilder<ApiResult<BranchesResponse>>(
      future: _branchesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data!;
        if (result case ApiSuccess<BranchesResponse> success) {
          final branches = success.data.data;
          if (branches.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 48,
                      color: AppColors.muted.withOpacity(0.6),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No branches yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Create your first branch to start assigning attendants.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: _openCreateBranch,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Branch'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              120,
            ),
            itemCount: branches.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final branch = branches[index];
              final subtitle = [
                if (branch.address.isNotEmpty) branch.address,
                if (branch.city.isNotEmpty) branch.city,
                if (branch.state.isNotEmpty) branch.state,
              ].join(' • ');

              return ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.storefront, color: AppColors.primaryContainer),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        branch.name,
                        style: const TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (branch.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            color: AppColors.primaryContainer,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle.isNotEmpty ? subtitle : 'No address provided',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
                trailing: _BranchStatusChip(status: branch.status),
              );
            },
          );
        }

        final failure = result as ApiFailure<BranchesResponse>;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                failure.error.message,
                style: const TextStyle(color: AppColors.onBackground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _refreshBranches,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendantsTab() {
    return FutureBuilder<ApiResult<SellersResponse>>(
      future: _sellersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data!;
        if (result case ApiSuccess<SellersResponse> success) {
          final sellers = success.data.data;
          if (sellers.isEmpty) {
            return const Center(
              child: Text(
                'No attendants found',
                style: TextStyle(color: AppColors.muted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              120,
            ),
            itemCount: sellers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final seller = sellers[index];
              final title = seller.fullName.isNotEmpty
                  ? seller.fullName
                  : seller.email;
              final subtitle = seller.branchName.isNotEmpty
                  ? 'Assigned to: ${seller.branchName}'
                  : 'No branch assigned';
              final caption = seller.phone.isNotEmpty
                  ? seller.phone
                  : seller.email;

              return ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: Icon(Icons.person, color: AppColors.primaryContainer),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: const TextStyle(color: AppColors.outline),
                    ),
                  ],
                ),
                trailing: const Chip(
                  label: Text(
                    'Active',
                    style: TextStyle(fontSize: 10, color: AppColors.success),
                  ),
                  backgroundColor: Color(0x1A5FAF7A),
                  side: BorderSide.none,
                ),
              );
            },
          );
        }

        final failure = result as ApiFailure<SellersResponse>;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                failure.error.message,
                style: const TextStyle(color: AppColors.onBackground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sellersFuture = AppServices.instance.managementRepository
                        .fetchSellers();
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showInviteAttendantDialog() async {
    final branchesResult = await _branchesFuture;
    if (!mounted) return;

    if (branchesResult is ApiFailure<BranchesResponse>) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(branchesResult.error.message)));
      return;
    }

    final branches = (branchesResult as ApiSuccess<BranchesResponse>).data.data;
    if (branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a branch before inviting attendants'),
        ),
      );
      return;
    }

    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var selectedBranchId = branches.first.id;
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            Future<void> submit() async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              setDialogState(() => isSubmitting = true);
              final result = await AppServices.instance.managementRepository
                  .inviteSeller(
                    firstName: firstNameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    branchId: selectedBranchId,
                  );
              setDialogState(() => isSubmitting = false);

              if (!mounted || !dialogBuilderContext.mounted) return;

              if (result is ApiSuccess<bool>) {
                Navigator.of(dialogBuilderContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendant invitation sent successfully'),
                  ),
                );
                setState(() {
                  _sellersFuture = AppServices.instance.managementRepository
                      .fetchSellers();
                });
              } else if (result is ApiFailure<bool>) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result.error.message)));
              }
            }

            return AlertDialog(
              title: const Text('Invite Pump Attendant'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _InviteTextField(
                          controller: firstNameController,
                          label: 'First Name',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'First name is required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InviteTextField(
                          controller: lastNameController,
                          label: 'Last Name',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Last name is required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InviteTextField(
                          controller: emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Email is required';
                            }
                            if (!trimmed.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InviteTextField(
                          controller: phoneController,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Phone number is required'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          value: selectedBranchId,
                          decoration: const InputDecoration(labelText: 'Branch'),
                          items: branches
                              .map(
                                (branch) => DropdownMenuItem<String>(
                                  value: branch.id,
                                  child: Text(
                                    branch.name.isNotEmpty
                                        ? branch.name
                                        : 'Unnamed branch',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isSubmitting
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setDialogState(
                                    () => selectedBranchId = value,
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Invite'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InviteTextField extends StatelessWidget {
  const _InviteTextField({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _BranchStatusChip extends StatelessWidget {
  const _BranchStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();
    final isActive = normalizedStatus == 'active';

    return Chip(
      label: Text(
        normalizedStatus.isEmpty ? 'Unknown' : normalizedStatus,
        style: TextStyle(
          fontSize: 10,
          color: isActive ? AppColors.success : AppColors.muted,
        ),
      ),
      backgroundColor: (isActive ? AppColors.primary : AppColors.muted)
          .withOpacity(0.1),
      side: BorderSide.none,
    );
  }
}
