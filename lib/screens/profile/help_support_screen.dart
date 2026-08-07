import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: AppTypography.heading(color: scheme.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Contact card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: scheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need help?',
                        style: AppTypography.heading(
                          color: scheme.onSurface,
                          size: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Contact your school administrator or reach us at support@saferidenepal.com',
                        style: AppTypography.caption(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Frequently asked questions',
            style: AppTypography.heading(color: scheme.onSurface, size: 15),
          ),
          const SizedBox(height: 12),

          // FAQ items
          ...[
            _FaqItem(
              question: 'How do I start a trip?',
              answer:
                  'Go to the Trip tab and tap "Start trip". The app will begin broadcasting your GPS location to parents automatically. Make sure location permission is granted.',
              scheme: scheme,
            ),
            _FaqItem(
              question: 'What happens if GPS stops working?',
              answer:
                  'If your GPS signal is lost, the app will continue trying to reconnect automatically. Parents will see the last known location until signal is restored. Ensure mobile data is turned on.',
              scheme: scheme,
            ),
            _FaqItem(
              question: 'How do I mark a student as boarded?',
              answer:
                  'During an active trip, tap the green check button next to the student\'s name at each stop. Tap the red X to mark them absent. Parents receive an instant notification for each action.',
              scheme: scheme,
            ),
            _FaqItem(
              question: 'How do I send a delay alert?',
              answer:
                  'Tap the megaphone icon in the top-right corner of the Trip screen during an active trip, or use the "Send alert to parents" button on the Home screen. Select the alert type and write a message.',
              scheme: scheme,
            ),
            _FaqItem(
              question: 'Can I use the app without internet?',
              answer:
                  'No — SafeRide Nepal requires an active internet connection to broadcast GPS, send attendance events, and notify parents in real time. Use mobile data if WiFi is unavailable.',
              scheme: scheme,
            ),
            _FaqItem(
              question: 'Why is my trip not showing student data?',
              answer:
                  'Student lists are assigned by your school administrator. If the list is empty, contact your admin to ensure students are assigned to your route for the current day.',
              scheme: scheme,
              isLast: true,
            ),
          ],

          const SizedBox(height: 24),

          Text(
            'App information',
            style: AppTypography.heading(color: scheme.onSurface, size: 15),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _InfoRow(label: 'App version', value: '1.0.0', scheme: scheme),
                _InfoRow(label: 'Platform', value: 'Android', scheme: scheme),
                _InfoRow(
                  label: 'Developed by',
                  value: 'SafeRide Nepal Team',
                  scheme: scheme,
                ),
                _InfoRow(
                  label: 'Institution',
                  value: 'Pokhara University — NCIT',
                  scheme: scheme,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final ColorScheme scheme;
  final bool isLast;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.scheme,
    this.isLast = false,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTypography.body(
                        color: widget.scheme.onSurface,
                        size: 14,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: widget.scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Container(
                  height: 0.5,
                  color: widget.scheme.outline.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.answer,
                  style: AppTypography.caption(
                    color: widget.scheme.onSurface.withValues(alpha: 0.65),
                    size: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme scheme;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.scheme,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: scheme.outline.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body(
                color: scheme.onSurface.withValues(alpha: 0.6),
                size: 13,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.caption(
              color: scheme.onSurface.withValues(alpha: 0.5),
              size: 13,
            ),
          ),
        ],
      ),
    );
  }
}
