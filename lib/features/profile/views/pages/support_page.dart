import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/support_item.dart';
import 'package:shopsphere/features/profile/views/widgets/faq_accordion_item.dart';
import 'package:shopsphere/features/profile/views/widgets/live_chat_modal_sheet.dart';
import 'package:shopsphere/features/profile/views/widgets/submit_ticket_modal_sheet.dart';
import 'package:shopsphere/features/profile/views/widgets/support_channels_card.dart';
import 'package:shopsphere/features/profile/views/widgets/support_ticket_card.dart';

class SupportPage extends ConsumerStatefulWidget {
  const SupportPage({super.key});

  @override
  ConsumerState<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends ConsumerState<SupportPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(supportTicketsControllerProvider);
    final allFaqs = FaqItem.dummyFaqs();
    final categories = [
      'All',
      'Orders & Tracking',
      'Payments & Refunds',
      'Returns & Replacements',
      'Account & VIP Membership',
    ];

    final filteredFaqs = allFaqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'All' || faq.category == _selectedCategory;
      final q = _searchController.text.trim().toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Customer Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Channels Header Card
            SupportChannelsCard(
              onLiveChat: () => LiveChatModalSheet.show(context),
            ),

            const SizedBox(height: 20),

            // Search FAQs
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search help articles & FAQs...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: AppColors.primarySurface,
                      labelStyle: TextStyle(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSel ? AppColors.primary : AppColors.border,
                      ),
                      onSelected: (sel) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // FAQs Accordion List
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            if (filteredFaqs.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No matching questions found. Submit a ticket below!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...filteredFaqs.map((faq) => FaqAccordionItem(faq: faq)),

            const SizedBox(height: 20),

            // User's Submitted Support Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Support Tickets (${tickets.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => SubmitTicketModalSheet.show(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'New Ticket',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...tickets.map((t) => SupportTicketCard(ticket: t)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
