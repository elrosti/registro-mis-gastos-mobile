import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/text_input_field.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/amount_input.dart';
import '../widgets/category_selector.dart';

class AddTransactionPage extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionPage({
    super.key,
    this.transaction,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'EXPENSE';
  String _currency = 'UYU';
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get isEditing => widget.transaction != null;

  final List<Category> _mockCategories = [
    const Category(
        id: '1',
        name: 'Comida',
        type: 'EXPENSE',
        icon: 'restaurant',
        color: '#FF6B6B'),
    const Category(
        id: '2',
        name: 'Transporte',
        type: 'EXPENSE',
        icon: 'directions_car',
        color: '#4ECDC4'),
    const Category(
        id: '3',
        name: 'Hogar',
        type: 'EXPENSE',
        icon: 'home',
        color: '#45B7D1'),
    const Category(
        id: '4',
        name: 'Salud',
        type: 'EXPENSE',
        icon: 'local_hospital',
        color: '#96CEB4'),
    const Category(
        id: '5',
        name: 'Entretenimiento',
        type: 'EXPENSE',
        icon: 'entertainment',
        color: '#DDA0DD'),
    const Category(
        id: '6',
        name: 'Compras',
        type: 'EXPENSE',
        icon: 'shopping_cart',
        color: '#98D8C8'),
    const Category(
        id: '7',
        name: 'Salario',
        type: 'INCOME',
        icon: 'work',
        color: '#22C55E'),
    const Category(
        id: '8',
        name: 'Freelance',
        type: 'INCOME',
        icon: 'laptop',
        color: '#3B82F6'),
    const Category(
        id: '9',
        name: 'Inversiones',
        type: 'INCOME',
        icon: 'trending_up',
        color: '#8B5CF6'),
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.transaction!;
      _nameController.text = t.shortName;
      _amountController.text = t.amount.toString();
      _descriptionController.text = t.description ?? '';
      _type = t.type;
      _currency = t.currency;
      _selectedDate = t.transactionDate;
      _selectedCategoryId = t.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: AppColors.errorMain,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto debe ser mayor a 0'),
          backgroundColor: AppColors.errorMain,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (isEditing) {
      context.read<TransactionBloc>().add(
            TransactionUpdateRequested(
              id: widget.transaction!.id,
              type: _type,
              shortName: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              amount: amount,
              currency: _currency,
              transactionDate: _selectedDate,
              categoryId: _selectedCategoryId,
            ),
          );
      Navigator.of(context).pop(true);
    } else {
      context.read<TransactionBloc>().add(
            TransactionCreateRequested(
              type: _type,
              shortName: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              amount: amount,
              currency: _currency,
              transactionDate: _selectedDate,
              categoryId: _selectedCategoryId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Transacción' : 'Nueva Transacción'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorMain,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TypeSelector(
                  selectedType: _type,
                  onTypeChanged: (type) {
                    setState(() {
                      _type = type;
                      _selectedCategoryId = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AmountInput(
                  controller: _amountController,
                  currency: _currency,
                  onCurrencyChanged: (currency) {
                    setState(() => _currency = currency);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Nombre',
                  hint: 'Ej: Almuerzo, Uber, Supermercado',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Descripción (opcional)',
                  hint: 'Agrega más detalles',
                  controller: _descriptionController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.lg),
                _DateSelector(
                  selectedDate: _selectedDate,
                  onDateChanged: (date) {
                    setState(() => _selectedDate = date);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                CategorySelector(
                  categories:
                      _mockCategories.where((c) => c.type == _type).toList(),
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategoryId = category.id);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  text: isEditing ? 'Guardar Cambios' : 'Crear Transacción',
                  onPressed: _onSave,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const _TypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPaper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.borderMain),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged('EXPENSE'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selectedType == 'EXPENSE'
                      ? AppColors.errorMain.withAlpha(25)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium - 2),
                ),
                child: Text(
                  'Gasto',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge.copyWith(
                    color: selectedType == 'EXPENSE'
                        ? AppColors.errorMain
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged('INCOME'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selectedType == 'INCOME'
                      ? AppColors.successMain.withAlpha(25)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium - 2),
                ),
                child: Text(
                  'Ingreso',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge.copyWith(
                    color: selectedType == 'INCOME'
                        ? AppColors.successMain
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              onDateChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundPaper,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              border: Border.all(color: AppColors.borderMain),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Text(
                  DateFormatter.formatDate(selectedDate),
                  style: AppTypography.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
