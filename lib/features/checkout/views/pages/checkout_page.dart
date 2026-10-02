import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/checkout/controllers/checkout_controller.dart';
import 'package:shopsphere/features/checkout/views/widgets/checkout_address_step.dart';
import 'package:shopsphere/features/checkout/views/widgets/checkout_payment_step.dart';
import 'package:shopsphere/features/checkout/views/widgets/checkout_stepper.dart';
import 'package:shopsphere/features/checkout/views/widgets/checkout_summary_step.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int newStep) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        newStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(checkoutControllerProvider.select((s) => s.currentStep), (
      previous,
      next,
    ) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    final cartState = ref.watch(cartControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final checkoutNotifier = ref.read(checkoutControllerProvider.notifier);

    // If cart was emptied and not in middle of placing order / success
    if (cartState.isEmpty &&
        checkoutState.placedOrder == null &&
        !checkoutState.isPlacingOrder) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your Cart is Empty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add some items to your bag before proceeding to checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.explore_outlined, size: 18),
                  label: const Text('Explore Products'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final subtotal = cartState.subtotal;
    final totalAmount = checkoutState.calculateTotal(subtotal);

    return PopScope(
      canPop: checkoutState.currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && checkoutState.currentStep > 0) {
          final targetStep = checkoutState.currentStep - 1;
          checkoutNotifier.goToStep(targetStep);
          _onStepChanged(targetStep);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Express Checkout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (checkoutState.currentStep > 0) {
                final targetStep = checkoutState.currentStep - 1;
                checkoutNotifier.goToStep(targetStep);
                _onStepChanged(targetStep);
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            CheckoutStepper(
              currentStep: checkoutState.currentStep,
              onStepTapped: (step) {
                checkoutNotifier.goToStep(step);
                _onStepChanged(step);
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  CheckoutAddressStep(),
                  CheckoutPaymentStep(),
                  CheckoutSummaryStep(),
                ],
              ),
            ),
            _CheckoutBottomBar(
              currentStep: checkoutState.currentStep,
              totalAmount: totalAmount,
              isPlacingOrder: checkoutState.isPlacingOrder,
              canProceed: _canProceed(checkoutState),
              onNext: () async {
                if (checkoutState.currentStep == 0) {
                  checkoutNotifier.nextStep();
                  _onStepChanged(1);
                } else if (checkoutState.currentStep == 1) {
                  checkoutNotifier.nextStep();
                  _onStepChanged(2);
                } else {
                  // Place order
                  final order = await checkoutNotifier.placeOrder();
                  if (order != null && context.mounted) {
                    context.go('/checkout/success');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed(CheckoutState state) {
    if (state.currentStep == 0) {
      return state.isAddressValid;
    } else if (state.currentStep == 1) {
      return state.isPaymentValid;
    }
    return true;
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  final int currentStep;
  final double totalAmount;
  final bool isPlacingOrder;
  final bool canProceed;
  final VoidCallback onNext;

  const _CheckoutBottomBar({
    required this.currentStep,
    required this.totalAmount,
    required this.isPlacingOrder,
    required this.canProceed,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText;
    IconData buttonIcon;

    if (currentStep == 0) {
      buttonText = 'Deliver to this Address';
      buttonIcon = Icons.arrow_forward_rounded;
    } else if (currentStep == 1) {
      buttonText = 'Proceed to Summary';
      buttonIcon = Icons.arrow_forward_rounded;
    } else {
      buttonText = 'Place Order • ₹${totalAmount.toStringAsFixed(0)}';
      buttonIcon = Icons.lock_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: (canProceed && !isPlacingOrder) ? onNext : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isPlacingOrder
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Securing Order...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(buttonIcon, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
