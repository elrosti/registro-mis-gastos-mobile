import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_event.dart';
import 'features/transactions/presentation/bloc/transaction_state.dart';
import 'features/transactions/presentation/pages/home_page.dart';
import 'features/transactions/presentation/pages/add_transaction_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'injection_container.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    authService.onTokenExpired.listen((_) {
      _authBloc.add(const AuthLogoutRequested());
    });
  }

  @override
  void dispose() {
    authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<TransactionBloc>(
          create: (_) =>
              sl<TransactionBloc>()..add(const TransactionFetchRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Registro Mis Gastos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashPage();
        }
        if (state is AuthAuthenticated) {
          return const MainNavigationPage();
        }
        return const LoginPage();
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessingInvoice = false;

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Agregar manualmente'),
                onTap: () {
                  Navigator.pop(context);
                  _onAddTransactionManual();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Subir imagen de factura'),
                onTap: () {
                  Navigator.pop(context);
                  _onPickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orange),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _onPickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddTransactionManual() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TransactionBloc>(),
          child: const AddTransactionPage(),
        ),
      ),
    );
  }

  Future<void> _onPickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() => _isProcessingInvoice = true);
        context.read<TransactionBloc>().add(
              InvoiceImageProcessRequested(
                filePath: image.path,
                fileName: image.name,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  void _onAddTransaction() {
    _showAddOptions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is InvoiceProcessingSuccess) {
          setState(() => _isProcessingInvoice = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is InvoiceProcessingError) {
          setState(() => _isProcessingInvoice = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TransactionOperationSuccess) {
          setState(() => _isProcessingInvoice = false);
        } else if (state is TransactionError) {
          setState(() => _isProcessingInvoice = false);
        } else if (state is TransactionLoaded) {
          setState(() => _isProcessingInvoice = false);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: const [
                HomePage(),
                ProfilePage(),
              ],
            ),
            if (_isProcessingInvoice)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Procesando imagen...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onAddTransaction,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
