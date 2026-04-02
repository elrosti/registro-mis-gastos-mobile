import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class InvoiceImagePreviewPage extends StatefulWidget {
  final String filePath;
  final String fileName;

  const InvoiceImagePreviewPage({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<InvoiceImagePreviewPage> createState() =>
      _InvoiceImagePreviewPageState();
}

class _InvoiceImagePreviewPageState extends State<InvoiceImagePreviewPage>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  final TransformationController _transformationController =
      TransformationController();
  bool _showControls = true;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );
    _controlsAnimationController.forward();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsAnimationController.forward();
      } else {
        _controlsAnimationController.reverse();
      }
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _onConfirm() {
    setState(() => _isProcessing = true);

    final bloc = context.read<TransactionBloc>();
    final state = bloc.state;
    TransactionFilters? filters;
    if (state is TransactionLoaded) {
      filters = state.filters;
    }

    bloc.add(
      InvoiceImageProcessRequested(
        filePath: widget.filePath,
        fileName: widget.fileName,
        type: filters?.type,
        startDate: filters?.startDate,
        endDate: filters?.endDate,
        categoryId: filters?.categoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionLoaded ||
            state is InvoiceProcessingSuccess ||
            state is InvoiceProcessingError) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: _showControls && !_isProcessing
            ? AppBar(
                backgroundColor: Colors.black.withValues(alpha: 0.7),
                elevation: 0,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.refresh, color: Colors.white),
                    ),
                    onPressed: _resetZoom,
                  ),
                ],
              )
            : null,
        body: GestureDetector(
          onTap: _isProcessing ? null : _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'invoice_image_${widget.filePath}',
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: Center(
                    child: Image.file(
                      File(widget.filePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              if (_showControls && !_isProcessing)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _controlsAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xxl,
                        AppSpacing.lg,
                        MediaQuery.of(context).padding.bottom > 0
                            ? MediaQuery.of(context).padding.bottom +
                                AppSpacing.md
                            : AppSpacing.xl,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.zoom_in,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'Toca para zoom',
                                    style: AppTypography.labelSmall.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: AppSpacing.buttonHeight,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color:
                                            Colors.white.withValues(alpha: 0.5),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMedium),
                                      ),
                                    ),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: AppSpacing.buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: _onConfirm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryMain,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMedium),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          size: 18,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        const Text('Procesar factura'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_isProcessing)
                Container(
                  color: Colors.black.withValues(alpha: 0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Analizando factura...',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Esto puede tomar unos segundos',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
