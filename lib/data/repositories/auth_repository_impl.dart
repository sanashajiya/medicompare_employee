import '../../core/constants/api_endpoints.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  
  AuthRepositoryImpl(this.apiService);
  
  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.login,
        {
          'username': username,
          'password': password,
        },
      );
      
      // For dummy API, simulate success response
      return UserModel.fromJson(response);
    } catch (e) {
      // For demo purposes, simulate a successful login with dummy data
      // In production, this should throw the actual error
      await Future.delayed(const Duration(seconds: 1));
      return const UserModel(
        id: '123',
        username: 'demo_user',
        token: 'dummy_token_123',
      );
    }
  }
}

