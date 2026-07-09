import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_typography.dart';
import '../data/models/alert_model.dart';
import '../providers/alert_provider.dart';

class SendAlertSheet extends ConsumerStatefulWidget {
  final int tripId;
  const SendAlertSheet({super.key, required this.tripId});

  @override
  ConsumerState<SendAlertSheet> createState() => _SendAlertSheetState();
}

class _SendAlertSheetState extends ConsumerState<SendAlertSheet> {
  AlertType _selectedType = AlertType.delay;
  final _messageController = TextEditingController();
  bool _isSending = false;

  final List<String> _quickMessages = [
    'Heavy traffic — expect 10-15 min delay',
    'Bus breakdown — sending replacement',
    'Route blocked — taking alternate road',
    'Running ahead of schedule',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    final success = await ref
        .read(alertProvider.notifier)
        .sendAlert(
          type: _selectedType,
          message: _messageController.text.trim(),
          tripId: widget.tripId,
        );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Alert sent to all parents'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Send alert to parents',
            style: AppTypography.heading(color: scheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'All parents on this route will be notified immediately.',
            style: AppTypography.caption(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),

          const SizedBox(height: 20),

          // Alert type selector
          Row(
            children: [
              _TypeChip(
                label: 'Delay',
                icon: Icons.schedule_rounded,
                type: AlertType.delay,
                selected: _selectedType == AlertType.delay,
                scheme: scheme,
                onTap: () => setState(() => _selectedType = AlertType.delay),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Emergency',
                icon: Icons.warning_amber_rounded,
                type: AlertType.emergency,
                selected: _selectedType == AlertType.emergency,
                scheme: scheme,
                onTap: () =>
                    setState(() => _selectedType = AlertType.emergency),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Route Change',
                icon: Icons.alt_route_rounded,
                type: AlertType.routeChange,
                selected: _selectedType == AlertType.routeChange,
                scheme: scheme,
                onTap: () =>
                    setState(() => _selectedType = AlertType.routeChange),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick message chips
          Text(
            'Quick messages',
            style: AppTypography.caption(
              color: scheme.onSurface.withValues(alpha: 0.5),
              size: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _quickMessages.map((msg) {
              return GestureDetector(
                onTap: () => setState(() => _messageController.text = msg),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    msg,
                    style: AppTypography.caption(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      size: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Message text field
          TextFormField(
            controller: _messageController,
            maxLines: 3,
            style: AppTypography.body(color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Type your message to parents...',
              hintStyle: AppTypography.body(
                color: scheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Send button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == AlertType.emergency
                    ? scheme.error
                    : scheme.primary,
              ),
              child: _isSending
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(
                      'Send ${_selectedType.typeLabel} alert',
                      style: AppTypography.heading(
                        color: scheme.onPrimary,
                        size: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final AlertType type;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.type,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  Color get _activeColor {
    switch (type) {
      case AlertType.emergency:
        return scheme.error;
      default:
        return scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? _activeColor.withValues(alpha: 0.12)
              : scheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? _activeColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected
                  ? _activeColor
                  : scheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.caption(
                color: selected
                    ? _activeColor
                    : scheme.onSurface.withValues(alpha: 0.5),
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
