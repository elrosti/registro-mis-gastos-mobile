import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AmountInput extends StatefulWidget {
  final TextEditingController controller;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  final String? errorText;

  const AmountInput({
    super.key,
    required this.controller,
    required this.currency,
    required this.onCurrencyChanged,
    this.errorText,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.backgroundPaper,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            border: Border.all(
              color: widget.errorText != null
                  ? AppColors.errorMain
                  : _isFocused
                      ? AppColors.primaryMain
                      : AppColors.borderMain,
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showCurrencyPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDefault,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.currency == 'USD' ? '\$' : '\$U',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryMain,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primaryMain,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.amountLarge,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.errorMain,
            ),
          ),
        ],
      ],
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Peso Uruguayo (UYU)'),
              trailing: widget.currency == 'UYU'
                  ? const Icon(Icons.check, color: AppColors.primaryMain)
                  : null,
              onTap: () {
                widget.onCurrencyChanged('UYU');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dólar Estadounidense (USD)'),
              trailing: widget.currency == 'USD'
                  ? const Icon(Icons.check, color: AppColors.primaryMain)
                  : null,
              onTap: () {
                widget.onCurrencyChanged('USD');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
