import 'package:flutter/material.dart';
import 'package:expense_management/shared/widgets/app_text.dart';
import 'package:expense_management/shared/utils/currency_formatter.dart';
import 'package:expense_management/features/wallets/domain/entities/wallet.dart';

/// A card widget representing a user's wallet with custom gradient.
class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final LinearGradient gradient;
  final VoidCallback? onLongPress;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.gradient,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          gradient: gradient,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          children: [
            // Glassmorphism decor
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Wallet Name & Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        wallet.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Fake Mastercard Logo
                    SizedBox(
                      width: 40,
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Middle Row: Card Number & Cardholder
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('•••• 1122', fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                    SizedBox(height: 2),
                    AppText('Tên chủ thẻ', fontSize: 12, color: Colors.white70),
                  ],
                ),

                // Bottom Row: Balance & VISA text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText('SỐ DƯ', fontSize: 10, color: Colors.white70),
                        const SizedBox(height: 2),
                        AppText(
                          CurrencyFormatter.format(context, wallet.balance),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const AppText('VISA', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
