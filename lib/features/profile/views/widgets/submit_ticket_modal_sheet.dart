import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';

class SubmitTicketModalSheet extends ConsumerStatefulWidget {
  const SubmitTicketModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SubmitTicketModalSheet(),
    );
  }

  @override
  ConsumerState<SubmitTicketModalSheet> createState() =>
      _SubmitTicketModalSheetState();
}

class _SubmitTicketModalSheetState
    extends ConsumerState<SubmitTicketModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _descCtrl;
  String _category = 'Order Issue';

  @override
  void initState() {
    super.initState();
    _subjectCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(supportTicketsControllerProvider.notifier)
        .submitTicket(
          subject: _subjectCtrl.text.trim(),
          category: _category,
          description: _descCtrl.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support ticket submitted! Ticket ID assigned.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Submit Support Ticket',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const Divider(height: 20, color: AppColors.border),

            // Category
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                    'Order Issue',
                    'Payment',
                    'Returns',
                    'Account',
                    'Feedback',
                  ].map((cat) {
                    final isSel = _category == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: AppColors.primarySurface,
                      labelStyle: TextStyle(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (sel) {
                        if (sel) setState(() => _category = cat);
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                hintText: 'Brief summary of the issue',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter subject' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Provide detailed details...',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter description' : null,
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Ticket',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
