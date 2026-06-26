import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../account/data/models/branch_model.dart';
import '../../../transactions/data/models/merchant_transaction.dart';
import '../../data/models/paginated_sales_model.dart';
import '../../data/models/seller_model.dart';
import '../widgets/management_bottom_nav.dart';

enum _SalesRange { all, today, week, month }

class StaffDetailPage extends StatefulWidget {
  const StaffDetailPage({super.key, required this.sellerId});

  final String sellerId;

  @override
  State<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  SellerModel? _seller;
  List<BranchModel> _branches = const [];
  final List<MerchantTransaction> _sales = [];
  var _isLoading = true;
  var _isLoadingSales = false;
  var _isSaving = false;
  var _page = 1;
  var _hasMore = false;
  _SalesRange _range = _SalesRange.all;
  String _sortBy = 'completedAt';
  String _sortOrder = 'desc';

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      AppServices.instance.managementRepository.fetchSeller(widget.sellerId),
      AppServices.instance.accountRepository.fetchBranches(),
    ]);

    if (!mounted) return;

    final sellerResult = results[0] as ApiResult<SellerModel>;
    final branchesResult = results[1] as ApiResult<BranchesResponse>;

    if (sellerResult case ApiSuccess<SellerModel> sellerSuccess) {
      final seller = sellerSuccess.data;
      _seller = seller;
      _firstNameController.text = seller.firstName;
      _lastNameController.text = seller.lastName;
      _phoneController.text = seller.phone;
      _selectedBranchId = seller.branchId.isNotEmpty ? seller.branchId : null;
    }

    if (branchesResult case ApiSuccess<BranchesResponse> branchesSuccess) {
      _branches = branchesSuccess.data.data;
    }

    setState(() => _isLoading = false);
    await _loadSales(reset: true);
  }

  ({String? fromDate, String? toDate}) _dateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_range) {
      case _SalesRange.all:
        return (fromDate: null, toDate: null);
      case _SalesRange.today:
        return (
          fromDate: today.toIso8601String(),
          toDate: today.add(const Duration(days: 1)).toIso8601String(),
        );
      case _SalesRange.week:
        return (
          fromDate: today.subtract(const Duration(days: 7)).toIso8601String(),
          toDate: now.toIso8601String(),
        );
      case _SalesRange.month:
        return (
          fromDate: today.subtract(const Duration(days: 30)).toIso8601String(),
          toDate: now.toIso8601String(),
        );
    }
  }

  Future<void> _loadSales({required bool reset}) async {
    if (_isLoadingSales) return;

    if (reset) {
      _page = 1;
      _sales.clear();
    }

    setState(() => _isLoadingSales = true);

    final range = _dateRange();
    final result = await AppServices.instance.managementRepository.fetchSellerSales(
      sellerId: widget.sellerId,
      page: _page,
      fromDate: range.fromDate,
      toDate: range.toDate,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    if (!mounted) return;

    if (result case ApiSuccess<PaginatedSalesResponse> success) {
      setState(() {
        _sales.addAll(success.data.items);
        _hasMore = success.data.hasMore;
        _isLoadingSales = false;
      });
    } else {
      setState(() => _isLoadingSales = false);
      if (result case ApiFailure<PaginatedSalesResponse> failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.error.message)),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving || _seller == null) return;

    setState(() => _isSaving = true);

    final result = await AppServices.instance.managementRepository.updateSeller(
      sellerId: widget.sellerId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      branchId: _selectedBranchId,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result case ApiSuccess<SellerModel> success) {
      setState(() => _seller = success.data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendant updated successfully')),
      );
    } else if (result case ApiFailure<SellerModel> failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.error.message)),
      );
    }
  }

  Future<void> _toggleStatus() async {
    if (_seller == null) return;

    final nextStatus = _seller!.isActive ? 'blocked' : 'active';
    final result = await AppServices.instance.managementRepository.updateSeller(
      sellerId: widget.sellerId,
      accountStatus: nextStatus,
    );

    if (!mounted) return;

    if (result case ApiSuccess<SellerModel> success) {
      setState(() => _seller = success.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus == 'active' ? 'Attendant activated' : 'Attendant deactivated',
          ),
        ),
      );
    } else if (result case ApiFailure<SellerModel> failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.error.message)),
      );
    }
  }

  Future<void> _removeStaff() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Attendant'),
        content: const Text(
          'This will revoke access for this attendant. They will no longer be able to sign in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await AppServices.instance.managementRepository.deactivateSeller(
      widget.sellerId,
    );

    if (!mounted) return;

    if (result case ApiSuccess<bool> _) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendant removed')),
      );
      Navigator.of(context).pop(true);
    } else if (result case ApiFailure<bool> failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendant Details'),
        actions: [
          IconButton(
            onPressed: _removeStaff,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_seller == null)
            const Center(child: Text('Attendant not found'))
          else
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                120,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _seller!.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    _statusChip(_seller!.accountStatus),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(_seller!.email, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: AppSpacing.lg),
                Text('Edit Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _selectedBranchId,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: _branches
                      .map(
                        (branch) => DropdownMenuItem<String>(
                          value: branch.id,
                          child: Text(branch.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBranchId = value),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _toggleStatus,
                        child: Text(_seller!.isActive ? 'Deactivate' : 'Activate'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text('Sales', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    DropdownButton<String>(
                      value: _sortOrder,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'desc', child: Text('Newest')),
                        DropdownMenuItem(value: 'asc', child: Text('Oldest')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _sortOrder = value);
                        _loadSales(reset: true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _SalesRange.values.map((range) {
                      final selected = _range == range;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          label: Text(_rangeLabel(range)),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _range = range);
                            _loadSales(reset: true);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_sales.isEmpty && !_isLoadingSales)
                  const Text(
                    'No sales recorded for this period.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  ..._sales.map(_saleTile),
                if (_isLoadingSales)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_hasMore)
                  TextButton(
                    onPressed: () {
                      _page += 1;
                      _loadSales(reset: false);
                    },
                    child: const Text('Load more'),
                  ),
              ],
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

  Widget _saleTile(MerchantTransaction sale) {
    final date = sale.createdAt;
    final dateLabel = date != null
        ? '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '—';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('₦${sale.amount.toStringAsFixed(0)}'),
      subtitle: Text('$dateLabel • ${sale.fuelLitres.toStringAsFixed(1)}L'),
      trailing: Text(
        sale.status,
        style: TextStyle(
          color: sale.isSuccessful ? AppColors.success : AppColors.muted,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.muted).withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _rangeLabel(_SalesRange range) {
    switch (range) {
      case _SalesRange.all:
        return 'All time';
      case _SalesRange.today:
        return 'Today';
      case _SalesRange.week:
        return '7 days';
      case _SalesRange.month:
        return '30 days';
    }
  }
}
