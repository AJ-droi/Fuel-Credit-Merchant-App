import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/models/support_models.dart';
import '../controllers/support_controller.dart';

class SupportTicketDetailPage extends StatefulWidget {
  const SupportTicketDetailPage({
    super.key,
    required this.controller,
    required this.ticketId,
  });

  final SupportController controller;
  final String ticketId;

  @override
  State<SupportTicketDetailPage> createState() => _SupportTicketDetailPageState();
}

class _SupportTicketDetailPageState extends State<SupportTicketDetailPage> {
  SupportController get _ctrl => widget.controller;
  final _replyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.loadTicket(widget.ticketId));
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final message = _replyCtrl.text.trim();
    if (message.length < 10) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Message must be at least 10 characters')),
        );
      return;
    }

    final ok = await _ctrl.sendFollowUp(ticketId: widget.ticketId, message: message);
    if (!mounted) return;

    if (ok) {
      _replyCtrl.clear();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Message sent')));
    } else if (_ctrl.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_ctrl.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final ticket = _ctrl.selectedTicket;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(ticket?.topicLabel ?? 'Support Request'),
          ),
          body: _buildBody(ticket),
        );
      },
    );
  }

  Widget _buildBody(SupportTicketModel? ticket) {
    if (_ctrl.loading && ticket == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ctrl.error != null && ticket == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _ctrl.error!,
                style: const TextStyle(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _ctrl.loadTicket(widget.ticketId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (ticket == null) {
      return const Center(child: Text('Ticket not found'));
    }

    final canReply = ticket.status != 'closed';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              _StatusHeader(ticket: ticket),
              const SizedBox(height: 16),
              ...ticket.messages.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MessageBubble(message: m),
                ),
              ),
            ],
          ),
        ),
        if (canReply)
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderStrong)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Add a follow-up message...',
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _ctrl.submitting ? null : _sendReply,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: _ctrl.submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(20),
            child: GlassCard(
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.muted, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This ticket is closed. Open a new request if you need further help.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.ticket});

  final SupportTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.subject,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Opened ${_formatDate(ticket.createdAt)} · ${ticket.messageCount} message${ticket.messageCount == 1 ? '' : 's'}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                ticket.status.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isFromAdmin;
    final bg = isAdmin ? AppColors.kpiSalesBg : AppColors.slate100;
    final accent = isAdmin ? AppColors.success : AppColors.primary;

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isAdmin ? 4 : 14),
            bottomRight: Radius.circular(isAdmin ? 14 : 4),
          ),
          border: Border.all(color: accent.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'Admin' : 'You',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(message.message, style: const TextStyle(fontSize: 14, height: 1.35)),
            const SizedBox(height: 6),
            Text(
              _formatTime(message.createdAt),
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
