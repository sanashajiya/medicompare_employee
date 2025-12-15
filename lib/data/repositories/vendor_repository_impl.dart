import '../../core/constants/api_endpoints.dart';
import '../../domain/entities/vendor_entity.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/vendor_model.dart';

class VendorRepositoryImpl implements VendorRepository {
  final ApiService apiService;

  VendorRepositoryImpl(this.apiService);

  @override
  Future<VendorEntity> createVendor(VendorEntity vendor, String token) async {
    try {
      final vendorModel = VendorModel.fromEntity(vendor);
      
      // Convert to multipart fields and files
      final fields = await vendorModel.toMultipartFields();
      final files = await vendorModel.toMultipartFiles();

      print('🔍 Creating vendor with fields: $fields');
      print('🔍 Files count: ${files.length}');

      final response = await apiService.postMultipart(
        ApiEndpoints.createVendor,
        fields,
        files,
        token: token,
      );

      print('🔍 Vendor creation response: $response');
      print('🔍 Success field: ${response['success']}');
      print('🔍 Message field: ${response['message']}');
      print('🔍 VendorId field: ${response['vendorId']}');

      // Check if the vendor creation was successful
      if (response['success'] == true) {
        // Return the vendor with the response data
        return vendor.copyWith(
          vendorId: response['vendorId'],
          success: response['success'],
          message: response['message'],
        );
      } else {
        final errorMessage = response['message'] ?? 'Vendor creation failed';
        print('❌ Vendor creation failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      final errorString = e.toString();

      // Handle specific error cases
      if (errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup')) {
        throw Exception(
            'Unable to connect to server. Please check your internet connection.');
      } else if (errorString.contains('TimeoutException')) {
        throw Exception('Connection timed out. Please try again.');
      } else if (errorString.contains('FormatException')) {
        throw Exception('Invalid server response. Please try again later.');
      } else if (errorString.contains('API Error: 401')) {
        throw Exception('Unauthorized. Please login again.');
      } else if (errorString.contains('API Error: 404')) {
        throw Exception('Service not found. Please contact support.');
      } else if (errorString.contains('API Error: 500') ||
          errorString.contains('API Error: 502') ||
          errorString.contains('API Error: 503')) {
        throw Exception('Server error. Please try again later.');
      } else if (errorString.startsWith('Exception: ')) {
        // Already formatted exception, just rethrow
        rethrow;
      } else {
        throw Exception('Vendor creation failed. Please try again.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}

