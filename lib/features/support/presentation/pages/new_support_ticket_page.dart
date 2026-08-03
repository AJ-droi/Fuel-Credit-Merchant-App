import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../controllers/support_controller.dart';

class NewSupportTicketPage extends StatefulWidget {
  const NewSupportTicketPage({super.key, required this.controller});

  final SupportController controller;

  @override
  State<NewSupportTicketPage> createState() => _NewSupportTicketPageState();
}

class _NewSupportTicketPageState extends State<NewSupportTicketPage> {
  SupportController get _ctrl => widget.controller;

  final _messageCtrl = TextEditingController();
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.loadTopics());
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final topic = _selectedTopic;
    final message = _messageCtrl.text.trim();

    if (topic == null || topic.isEmpty) {
      _showError('Please select a topic');
      return;
    }
    if (message.length < 10) {
      _showError('Message must be at least 10 characters');
      return;
    }

    final ok = await _ctrl.createTicket(topic: topic, message: message);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Your request has been sent to admin')),
        );
      Navigator.pushReplacementNamed(
        context,
        AppRouter.supportTicketDetail,
        arguments: {
          'controller': _ctrl,
          'ticketId': _ctrl.selectedTicket!.id,
        },
      );
    } else if (_ctrl.error != null) {
      _showError(_ctrl.error!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('New Support Request'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tell us what you need help with. Our admin team will respond as soon as possible.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 24),
              GlassCard(
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOPIC',
                        style: TextStyle(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedTopic,
                        decoration: const InputDecoration(
                          hintText: 'Select a topic',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        items: _ctrl.topics
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.value,
                                child: Text(t.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedTopic = v),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'MESSAGE',
                        style: TextStyle(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _messageCtrl,
                        maxLines: 6,
                        maxLength: 2000,
                        decoration: const InputDecoration(
                          hintText: 'Describe your issue in detail...',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _ctrl.submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _ctrl.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send to Admin',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
