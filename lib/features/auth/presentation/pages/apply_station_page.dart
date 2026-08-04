import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class ApplyStationPage extends StatefulWidget {
  const ApplyStationPage({super.key});

  @override
  State<ApplyStationPage> createState() => _ApplyStationPageState();
}

class _ApplyStationPageState extends State<ApplyStationPage> {
  bool _loading = false;

  final _merchantName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _businessName = TextEditingController();
  final _businessLocation = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _stationBranch = TextEditingController();
  final _lga = TextEditingController();
  final _state = TextEditingController();
  final _landmark = TextEditingController();
  final _nin = TextEditingController();
  final _cacNumber = TextEditingController();

  XFile? _cacDocument;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _merchantName.dispose();
    _email.dispose();
    _phone.dispose();
    _businessName.dispose();
    _businessLocation.dispose();
    _address.dispose();
    _city.dispose();
    _stationBranch.dispose();
    _lga.dispose();
    _state.dispose();
    _landmark.dispose();
    _nin.dispose();
    _cacNumber.dispose();
    super.dispose();
  }

  Future<void> _pickCacDocument() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() => _cacDocument = file);
  }

  Future<void> _submit() async {
    final fields = <String, String>{
      'merchantName': _merchantName.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'businessName': _businessName.text.trim(),
      'businessLocation': _businessLocation.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
      'stationBranch': _stationBranch.text.trim(),
      'lga': _lga.text.trim(),
      'state': _state.text.trim(),
      'landmark': _landmark.text.trim(),
      'nin': _nin.text.trim().replaceAll(RegExp(r'\D'), ''),
    };

    for (final e in fields.entries) {
      if (e.value.isEmpty) {
        _toast('Please fill in all required fields.');
        return;
      }
    }
    if (fields['nin']!.length != 11) {
      _toast('NIN must be 11 digits.');
      return;
    }

    final cac = _cacNumber.text.trim();
    if (cac.isNotEmpty) {
      fields['cacNumber'] = cac;
    }

    setState(() => _loading = true);

    final map = <String, dynamic>{...fields};
    if (_cacDocument != null) {
      final bytes = await _cacDocument!.readAsBytes();
      map['cacDocument'] = MultipartFile.fromBytes(
        bytes,
        filename: _cacDocument!.name.isNotEmpty ? _cacDocument!.name : 'cac.jpg',
      );
    }

    final result = await AppServices.instance.apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.merchantApplications,
      data: FormData.fromMap(map),
      parser: (json) {
        if (json is Map<String, dynamic>) return json;
        return <String, dynamic>{};
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case ApiSuccess():
        _toast('Application submitted. We will email you after review.');
        Navigator.pop(context);
      case ApiFailure(:final error):
        _toast(error.message.isEmpty ? 'Could not submit application.' : error.message);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _field(TextEditingController c, String label, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply your fuel station'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Apply to onboard your station. NIN must match the contact person name. '
                  'Optional CAC details help verify the business. After admin approval, login details are emailed.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _field(_merchantName, 'Contact person full name'),
                _field(_email, 'Contact email (login)', type: TextInputType.emailAddress),
                _field(_phone, 'Contact phone', type: TextInputType.phone),
                _field(_businessName, 'Business / station name'),
                _field(_businessLocation, 'Business location'),
                _field(_address, 'Address'),
                _field(_city, 'City'),
                _field(_stationBranch, 'Station branch'),
                _field(_lga, 'LGA'),
                _field(_state, 'State'),
                _field(_landmark, 'Landmark'),
                _field(_nin, 'NIN (11 digits)', type: TextInputType.number),
                _field(_cacNumber, 'CAC / RC number (optional)'),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickCacDocument,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(
                    _cacDocument == null
                        ? 'Upload CAC document (optional)'
                        : 'CAC document: ${_cacDocument!.name}',
                  ),
                ),
                if (_cacDocument != null)
                  TextButton(
                    onPressed: _loading ? null : () => setState(() => _cacDocument = null),
                    child: const Text('Remove CAC document'),
                  ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit application'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
