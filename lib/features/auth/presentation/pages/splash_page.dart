import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryMain,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryContrast,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: AppColors.primaryMain,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Registro Mis Gastos',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primaryContrast,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryContrast),
            ),
          ],
        ),
      ),
    );
  }
}
