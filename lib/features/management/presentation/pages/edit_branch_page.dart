import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../account/data/models/branch_model.dart';
import '../widgets/management_bottom_nav.dart';

class EditBranchPage extends StatefulWidget {
  const EditBranchPage({super.key, required this.branchId});

  final String branchId;

  @override
  State<EditBranchPage> createState() => _EditBranchPageState();
}

class _EditBranchPageState extends State<EditBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _lgaController = TextEditingController();
  final _stateController = TextEditingController();
  final _landmarkController = TextEditingController();

  var _isPrimary = false;
  var _isLoading = true;
  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadBranch();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _lgaController.dispose();
    _stateController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _loadBranch() async {
    final result = await AppServices.instance.accountRepository.fetchBranchDetail(
      widget.branchId,
    );

    if (!mounted) return;

    if (result case ApiSuccess<BranchDetailModel> success) {
      final branch = success.data;
      _nameController.text = branch.name;
      _addressController.text = branch.address;
      _cityController.text = branch.city;
      _lgaController.text = branch.lga;
      _stateController.text = branch.state;
      _landmarkController.text = branch.landmark;
      setState(() {
        _isPrimary = branch.isPrimary;
        _isLoading = false;
      });
    } else if (result case ApiFailure<BranchDetailModel> failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.error.message)),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await AppServices.instance.accountRepository.updateBranch(
      branchId: widget.branchId,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      lga: _lgaController.text.trim(),
      state: _stateController.text.trim(),
      landmark: _landmarkController.text.trim(),
      isPrimary: _isPrimary,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result case ApiSuccess<BranchModel> _) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Branch updated successfully')),
      );
      Navigator.of(context).pop(true);
    } else if (result case ApiFailure<BranchModel> failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.error.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Branch')),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                120,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(_nameController, 'Branch name', 'e.g. Ikeja Main'),
                    const SizedBox(height: AppSpacing.md),
                    _field(_addressController, 'Address', 'Street address'),
                    const SizedBox(height: AppSpacing.md),
                    _field(_cityController, 'City', 'e.g. Ikeja'),
                    const SizedBox(height: AppSpacing.md),
                    _field(_lgaController, 'LGA', 'Local government area'),
                    const SizedBox(height: AppSpacing.md),
                    _field(_stateController, 'State', 'e.g. Lagos'),
                    const SizedBox(height: AppSpacing.md),
                    _field(_landmarkController, 'Landmark', 'Nearby landmark'),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Set as primary branch'),
                      value: _isPrimary,
                      onChanged: _isSubmitting
                          ? null
                          : (value) => setState(() => _isPrimary = value),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _field(TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label is required' : null,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
