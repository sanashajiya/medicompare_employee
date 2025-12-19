import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/auth_local_storage.dart';
import '../../data/datasources/local/draft_local_storage.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/draft_repository_impl.dart';
import '../../data/repositories/otp_repository_impl.dart';
import '../../data/repositories/vendor_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/draft_repository.dart';
import '../../domain/repositories/otp_repository.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../../domain/usecases/create_vendor_usecase.dart';
import '../../domain/usecases/delete_draft_usecase.dart';
import '../../domain/usecases/get_all_drafts_usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_draft_by_id_usecase.dart';
import '../../domain/usecases/get_draft_count_usecase.dart';
import '../../domain/usecases/get_vendor_list_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/save_draft_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/dashboard/dashboard_bloc.dart';
import '../../presentation/blocs/draft/draft_bloc.dart';
import '../../presentation/blocs/otp/otp_bloc.dart';
import '../../presentation/blocs/vendor_form/vendor_form_bloc.dart';
import '../../presentation/blocs/vendor_list/vendor_list_bloc.dart';
import '../../presentation/blocs/vendor_stepper/vendor_stepper_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // External
  sl.registerLazySingleton(() => http.Client());

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Data sources
  sl.registerLazySingleton(() => ApiService(client: sl()));
  sl.registerLazySingleton(() => AuthLocalStorage(sl()));

  // Draft Local Storage (initialize it)
  final draftLocalStorage = DraftLocalStorage();
  await draftLocalStorage.init();
  sl.registerLazySingleton(() => draftLocalStorage);

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<OtpRepository>(() => OtpRepositoryImpl(sl()));
  sl.registerLazySingleton<VendorRepository>(() => VendorRepositoryImpl(sl()));
  sl.registerLazySingleton<DraftRepository>(() => DraftRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => CreateVendorUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetVendorListUseCase(sl()));

  // Draft Use cases
  sl.registerLazySingleton(() => SaveDraftUseCase(sl<DraftRepository>()));
  sl.registerLazySingleton(() => GetAllDraftsUseCase(sl<DraftRepository>()));
  sl.registerLazySingleton(() => GetDraftByIdUseCase(sl<DraftRepository>()));
  sl.registerLazySingleton(() => DeleteDraftUseCase(sl<DraftRepository>()));
  sl.registerLazySingleton(() => GetDraftCountUseCase(sl<DraftRepository>()));

  // Blocs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(loginUseCase: sl<LoginUseCase>()),
  );
  sl.registerFactory(
    () => OtpBloc(sendOtpUseCase: sl(), verifyOtpUseCase: sl()),
  );
  sl.registerFactory(() => VendorFormBloc(createVendorUseCase: sl()));
  sl.registerFactory(
    () => DashboardBloc(
      authLocalStorage: sl<AuthLocalStorage>(),
      getDashboardStatsUseCase: sl<GetDashboardStatsUseCase>(),
    ),
  );
  sl.registerFactory(() => VendorStepperBloc());
  sl.registerFactory(
    () => VendorListBloc(getVendorListUseCase: sl<GetVendorListUseCase>()),
  );
  sl.registerFactory(
    () => DraftBloc(
      saveDraftUseCase: sl<SaveDraftUseCase>(),
      getAllDraftsUseCase: sl<GetAllDraftsUseCase>(),
      getDraftByIdUseCase: sl<GetDraftByIdUseCase>(),
      deleteDraftUseCase: sl<DeleteDraftUseCase>(),
      getDraftCountUseCase: sl<GetDraftCountUseCase>(),
    ),
  );
}
