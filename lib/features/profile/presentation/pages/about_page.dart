import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryMain.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: AppColors.primaryMain,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Registro Mis Gastos',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                'www.registromisgastos.com',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primaryMain,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
