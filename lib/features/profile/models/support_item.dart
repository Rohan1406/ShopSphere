class FaqItem {
  final String category;
  final String question;
  final String answer;

  const FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });

  static List<FaqItem> dummyFaqs() {
    return const [
      FaqItem(
        category: 'Orders & Tracking',
        question: 'How do I track my active order?',
        answer:
            'You can track your order in real-time by going to My Profile > My Orders and tapping on any active order to view the full shipment milestone timeline.',
      ),
      FaqItem(
        category: 'Orders & Tracking',
        question: 'Can I cancel or modify an order after placing it?',
        answer:
            'Orders in the "Processing" stage can be instantly cancelled directly from the Order Details page with full immediate refund. Once an order is Dispatched, you can initiate a return after doorstep delivery.',
      ),
      FaqItem(
        category: 'Payments & Refunds',
        question: 'What payment options are supported on ShopSphere?',
        answer:
            'We support all major Credit/Debit Cards (Visa, Mastercard, RuPay, Amex), UPI Apps (Google Pay, PhonePe, Paytm, BHIM), Net Banking across 50+ banks, and Cash on Delivery (COD).',
      ),
      FaqItem(
        category: 'Payments & Refunds',
        question: 'How long do refunds take to reflect?',
        answer:
            'UPI and wallet refunds are processed within 2-4 hours. Credit & Debit card refunds typically settle in 3-5 business days depending on your issuing bank.',
      ),
      FaqItem(
        category: 'Returns & Replacements',
        question: 'What is ShopSphere\'s return and exchange policy?',
        answer:
            'We offer a hassle-free 7-day doorstep replacement or return guarantee on eligible products. Items must be unused in original brand packaging with all tags attached.',
      ),
      FaqItem(
        category: 'Returns & Replacements',
        question: 'How do I schedule a doorstep pickup for returns?',
        answer:
            'Open your delivered order from My Orders, tap "Return / Exchange", select your reason and preferred time slot. Our courier partner will pick up the package from your address.',
      ),
      FaqItem(
        category: 'Account & VIP Membership',
        question: 'What are the benefits of VIP Gold Membership?',
        answer:
            'VIP Gold Members enjoy Free Express Delivery on all orders, early access to lightning sales, dedicated 24/7 priority customer support, and exclusive 50% discount vouchers.',
      ),
      FaqItem(
        category: 'Account & VIP Membership',
        question: 'How do I earn and redeem reward points?',
        answer:
            'You earn 10 reward points for every ₹100 spent. Points can be redeemed at checkout for instant cash discounts on your cart total.',
      ),
    ];
  }
}

class SupportTicket {
  final String id;
  final String subject;
  final String category;
  final String status;
  final String createdAt;
  final String description;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    this.status = 'Open',
    required this.createdAt,
    required this.description,
  });

  static List<SupportTicket> dummyTickets() {
    return [
      const SupportTicket(
        id: 'TCK-8821',
        subject:
            'Inquiry regarding express delivery timeline for order #SHP-9812',
        category: 'Delivery',
        status: 'In Progress',
        createdAt: 'Today, 09:30 AM',
        description:
            'Requested priority evening delivery slot between 5 PM and 7 PM at Indiranagar address.',
      ),
      const SupportTicket(
        id: 'TCK-7619',
        subject: 'Invoice copy request for leather backpack purchase',
        category: 'Billing',
        status: 'Resolved',
        createdAt: 'Oct 22, 2026',
        description:
            'GST invoice sent to registered email demo@shopsphere.com.',
      ),
    ];
  }
}
