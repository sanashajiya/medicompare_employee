import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/remote/api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/repositories/otp_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/otp_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/submit_employee_form_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/employee_form/employee_form_bloc.dart';
import '../../presentation/blocs/otp/otp_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  sl.registerLazySingleton(() => http.Client());
  
  // Data sources
  sl.registerLazySingleton(() => ApiService(client: sl()));
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<OtpRepository>(
    () => OtpRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl()),
  );
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => SubmitEmployeeFormUseCase(sl()));
  
  // Blocs
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
  sl.registerFactory(() => OtpBloc(
    sendOtpUseCase: sl(),
    verifyOtpUseCase: sl(),
  ));
  sl.registerFactory(() => EmployeeFormBloc(
    submitEmployeeFormUseCase: sl(),
  ));
}

