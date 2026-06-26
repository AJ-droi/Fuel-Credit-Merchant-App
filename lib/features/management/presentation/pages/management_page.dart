import 'package:flutter/material.dart';

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

class _ManagementPageState extends State<ManagementPage> {
  late Future<ApiResult<BranchesResponse>> _branchesFuture;
  late Future<ApiResult<SellersResponse>> _sellersFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = AppServices.instance.accountRepository.fetchBranches();
    _sellersFuture = AppServices.instance.managementRepository.fetchSellers();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xCC051424),
          title: const Text(
            'Management',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              Tab(text: 'Branches'),
              Tab(text: 'Attendants'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(children: [_buildBranchesTab(), _buildAttendantsTab()]),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(top: false, child: ManagementBottomNav()),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0), // Above the bottom nav
          child: FloatingActionButton.extended(
            onPressed: _showInviteAttendantDialog,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Invite', style: TextStyle(color: Colors.white)),
          ),
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
            return const Center(
              child: Text(
                'No branches found',
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
                tileColor: const Color(0x33C6C0FF).withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.storefront, color: AppColors.primary),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        branch.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (branch.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            color: AppColors.primary,
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
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  setState(() {
                    _branchesFuture = AppServices.instance.accountRepository
                        .fetchBranches();
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
                tileColor: const Color(0x33C6C0FF).withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: Icon(Icons.person, color: AppColors.secondary),
                ),
                title: Text(title, style: const TextStyle(color: Colors.white)),
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
                    style: TextStyle(fontSize: 10, color: Colors.greenAccent),
                  ),
                  backgroundColor: Color(0x1A69F0AE),
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
                style: const TextStyle(color: Colors.white),
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
        const SnackBar(content: Text('No branches available for assignment')),
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
              backgroundColor: const Color(0xFF010F1F),
              title: const Text(
                'Invite Pump Attendant',
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
                          dropdownColor: const Color(0xFF010F1F),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inviteDecoration('Branch'),
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.muted),
                  ),
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
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: _inviteDecoration(label),
    );
  }
}

InputDecoration _inviteDecoration(String label) {
  return const InputDecoration().copyWith(
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
  );
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
          color: isActive ? Colors.greenAccent : AppColors.muted,
        ),
      ),
      backgroundColor: (isActive ? Colors.greenAccent : Colors.white)
          .withOpacity(0.1),
      side: BorderSide.none,
    );
  }
}
