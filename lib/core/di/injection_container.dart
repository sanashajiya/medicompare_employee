import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/auth_local_storage.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/otp_repository_impl.dart';
import '../../data/repositories/vendor_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/otp_repository.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../../domain/usecases/create_vendor_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/dashboard/dashboard_bloc.dart';
import '../../presentation/blocs/otp/otp_bloc.dart';
import '../../presentation/blocs/vendor_form/vendor_form_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton(() => http.Client());

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Data sources
  sl.registerLazySingleton(() => ApiService(client: sl()));
  sl.registerLazySingleton(() => AuthLocalStorage(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<OtpRepository>(() => OtpRepositoryImpl(sl()));
  sl.registerLazySingleton<VendorRepository>(() => VendorRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => CreateVendorUseCase(sl()));

  // Blocs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(loginUseCase: sl<LoginUseCase>()),
  );
  sl.registerFactory(
    () => OtpBloc(sendOtpUseCase: sl(), verifyOtpUseCase: sl()),
  );
  sl.registerFactory(() => VendorFormBloc(createVendorUseCase: sl()));
  sl.registerFactory(
    () => DashboardBloc(authLocalStorage: sl<AuthLocalStorage>()),
  );
}
