import 'package:flutter/material.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../account/data/models/branch_model.dart';
import '../widgets/management_bottom_nav.dart';

class CreateBranchPage extends StatefulWidget {
  const CreateBranchPage({super.key});

  @override
  State<CreateBranchPage> createState() => _CreateBranchPageState();
}

class _CreateBranchPageState extends State<CreateBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _lgaController = TextEditingController();
  final _stateController = TextEditingController();
  final _landmarkController = TextEditingController();
  var _isPrimary = false;
  var _isSubmitting = false;

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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await AppServices.instance.accountRepository.createBranch(
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
        const SnackBar(content: Text('Branch created successfully')),
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Branch'),
      ),
      body: Stack(
        children: [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branch details',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add a new fuel station branch to your merchant account.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BranchField(
                    controller: _nameController,
                    label: 'Branch name',
                    hint: 'e.g. Ikeja Main',
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'Branch name is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BranchField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'Street address',
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'Address is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BranchField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'e.g. Ikeja',
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'City is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BranchField(
                    controller: _lgaController,
                    label: 'LGA',
                    hint: 'Local government area',
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'LGA is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BranchField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'e.g. Lagos',
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'State is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BranchField(
                    controller: _landmarkController,
                    label: 'Landmark',
                    hint: 'Nearby landmark for directions',
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                        ? 'Landmark is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Set as primary branch',
                      style: textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                    subtitle: Text(
                      'Primary branch is shown on your profile',
                      style: textTheme.bodyMedium,
                    ),
                    value: _isPrimary,
                    activeColor: AppColors.primary,
                    onChanged: _isSubmitting
                        ? null
                        : (value) => setState(() => _isPrimary = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text('Create Branch'),
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
}

class _BranchField extends StatelessWidget {
  const _BranchField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
