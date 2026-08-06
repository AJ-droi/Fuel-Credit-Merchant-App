import 'package:flutter/material.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

/// Simple indicate-interest form — admin reaches out and onboards after checks.
class ApplyStationPage extends StatefulWidget {
  const ApplyStationPage({super.key});

  @override
  State<ApplyStationPage> createState() => _ApplyStationPageState();
}

class _ApplyStationPageState extends State<ApplyStationPage> {
  bool _loading = false;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _petrolStationName = TextEditingController();
  final _address = TextEditingController();
  final _cacNumber = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _petrolStationName.dispose();
    _address.dispose();
    _cacNumber.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final fields = <String, String>{
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'petrolStationName': _petrolStationName.text.trim(),
      'address': _address.text.trim(),
    };

    for (final e in fields.entries) {
      if (e.value.isEmpty) {
        _toast('Please fill in all fields.');
        return;
      }
    }

    final cac = _cacNumber.text.trim();
    if (cac.isNotEmpty) {
      fields['cacNumber'] = cac;
    }

    setState(() => _loading = true);

    final result = await AppServices.instance.apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.merchantApplications,
      data: fields,
      parser: (json) {
        if (json is Map<String, dynamic>) return json;
        return <String, dynamic>{};
      },
    );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case ApiSuccess(:final data):
        final payload = data['data'];
        final message = (payload is Map && payload['message'] is String)
            ? payload['message'] as String
            : (data['message'] as String? ??
                'Thanks! Our team will reach out using your contact details.');
        _toast(message);
        Navigator.pop(context);
      case ApiFailure(:final error):
        _toast(error.message.isEmpty ? 'Could not submit interest.' : error.message);
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
        title: const Text('Indicate interest'),
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
                  'Interested in joining Fuel Credit as a petrol station? '
                  'Share your details and our team will contact you. '
                  'You will only get app access after admin onboarding.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _field(_name, 'Your full name'),
                _field(_email, 'Email', type: TextInputType.emailAddress),
                _field(_phone, 'Phone number', type: TextInputType.phone),
                _field(_petrolStationName, 'Petrol station name'),
                _field(_address, 'Station address'),
                _field(_cacNumber, 'CAC / RC number (optional)'),
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
                      : const Text('Send interest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
