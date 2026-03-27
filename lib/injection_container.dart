import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/constants/api_constants.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      scopes: ['email', 'profile'],
      signInOption: SignInOption.standard,
    ),
  );

  // Core
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: ApiConstants.baseUrl),
  );

  // Auth - Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Auth - Use Cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => LoginWithGoogle(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetGoogleOAuthUrl(sl()));

  // Auth - BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );
}
