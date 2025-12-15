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
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.login,
        {
          'email': email,
          'password': password,
        },
      );
      
      print('🔍 Login API Response: $response');
      print('🔍 Success field: ${response['success']}');
      print('🔍 Data field: ${response['data']}');
      
      // Check if the login was successful
      if (response['success'] == true) {
        final user = UserModel.fromJson(response);
        print('✅ User parsed successfully: ${user.email}');
        return user;
      } else {
        final errorMessage = response['message'] ?? 'Login failed';
        print('❌ Login failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      final errorString = e.toString();
      
      // Handle specific error cases
      if (errorString.contains('SocketException') || 
          errorString.contains('Failed host lookup')) {
        throw Exception('Unable to connect to server. Please check your internet connection.');
      } else if (errorString.contains('TimeoutException')) {
        throw Exception('Connection timed out. Please try again.');
      } else if (errorString.contains('FormatException')) {
        throw Exception('Invalid server response. Please try again later.');
      } else if (errorString.contains('API Error: 401')) {
        throw Exception('Invalid email or password.');
      } else if (errorString.contains('API Error: 404')) {
        throw Exception('Login service not found. Please contact support.');
      } else if (errorString.contains('API Error: 500') || 
                 errorString.contains('API Error: 502') ||
                 errorString.contains('API Error: 503')) {
        throw Exception('Server error. Please try again later.');
      } else if (errorString.startsWith('Exception: ')) {
        // Already formatted exception, just rethrow
        rethrow;
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}

