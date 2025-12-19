import '../../core/constants/api_endpoints.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/vendor_entity.dart';
import '../../domain/entities/vendor_list_item_entity.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/dashboard_stats_model.dart';
import '../models/vendor_model.dart';
import '../models/vendor_list_item_model.dart';

class VendorRepositoryImpl implements VendorRepository {
  final ApiService apiService;

  VendorRepositoryImpl(this.apiService);

  @override
  Future<VendorEntity> createVendor(VendorEntity vendor, String token) async {
    try {
      print(
        '\n╔══════════════════════════════════════════════════════════════╗',
      );
      print('║        🚀 VENDOR REPOSITORY - CREATE VENDOR                ║');
      print('╚══════════════════════════════════════════════════════════════╝');

      print('\n📋 Vendor Data Summary:');
      print('   Name: ${vendor.firstName} ${vendor.lastName}');
      print('   Email: ${vendor.email}');
      print('   Business: ${vendor.businessName}');
      print('   Front Images: ${vendor.frontimages.length}');
      print('   Back Images: ${vendor.backimages.length}');
      print('   signature: ${vendor.signature.length}');

      // 🔹 Entity → Model
      print('🔍 DEBUG: Converting VendorEntity to VendorModel');
      print('   Entity OTP: ${vendor.otp}');
      final vendorModel = VendorModel.fromEntity(vendor);
      print('   Model OTP: ${vendorModel.otp}');

      // 🔹 Multipart fields & files
      final fields = vendorModel.toMultipartFields();
      final arrayFields = vendorModel.toMultipartArrayFields();
      final files = await vendorModel.toMultipartFiles();

      print('\n📝 Multipart Fields: ${fields.length} fields');
      print('   Mobile: ${fields['mobile']}');
      print('   OTP: ${fields['otp'] ?? 'NOT PROVIDED'}');
      print('   Type: ${fields['type'] ?? 'NOT PROVIDED'}');
      print('   Usertype: ${fields['usertype'] ?? 'NOT PROVIDED'}');
      print('📋 Array Fields: ${arrayFields.length} array types');
      for (final entry in arrayFields.entries) {
        print('   ${entry.key}: ${entry.value.length} items');
      }
      print('📎 Multipart Files: ${files.length} files ready to send');

      final response = await apiService.postMultipart(
        ApiEndpoints.createVendor,
        fields,
        files,
        token: token,
        arrayFields: arrayFields,
      );

      print(
        '\n═══════════════════════════════════════════════════════════════',
      );
      print('✅ VENDOR CREATION RESPONSE:');
      print('═══════════════════════════════════════════════════════════════');
      print('Success: ${response['success']}');
      print('Message: ${response['message']}');
      print('Vendor ID: ${response['vendorId']}');
      print(
        '═══════════════════════════════════════════════════════════════\n',
      );

      // ✅ Always trust backend response
      return VendorModel.fromJson(response);
    } on Exception catch (e) {
      final errorString = e.toString();

      if (errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup')) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
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
      } else {
        throw Exception(
          errorString.startsWith('Exception: ')
              ? errorString.replaceFirst('Exception: ', '')
              : 'Vendor creation failed. Please try again.',
        );
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<DashboardStatsEntity> getDashboardStats(String token) async {
    try {
      print(
        '\n╔══════════════════════════════════════════════════════════════╗',
      );
      print('║        📊 VENDOR REPOSITORY - GET DASHBOARD STATS          ║');
      print('╚══════════════════════════════════════════════════════════════╝');

      final response = await apiService.get(
        ApiEndpoints.getDashboard,
        token: token,
      );

      print(
        '\n═══════════════════════════════════════════════════════════════',
      );
      print('✅ DASHBOARD STATS RESPONSE:');
      print('═══════════════════════════════════════════════════════════════');
      print('Success: ${response['success']}');
      print('Message: ${response['message']}');
      print(
        '═══════════════════════════════════════════════════════════════\n',
      );

      // Parse and return dashboard stats
      return DashboardStatsModel.fromJson(response);
    } on Exception catch (e) {
      final errorString = e.toString();

      if (errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup')) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
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
      } else {
        throw Exception(
          errorString.startsWith('Exception: ')
              ? errorString.replaceFirst('Exception: ', '')
              : 'Failed to fetch dashboard stats. Please try again.',
        );
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<List<VendorListItemEntity>> getVendorList(String token) async {
    try {
      print(
        '\n╔══════════════════════════════════════════════════════════════╗',
      );
      print('║        📋 VENDOR REPOSITORY - GET VENDOR LIST              ║');
      print('╚══════════════════════════════════════════════════════════════╝');

      final response = await apiService.get(
        ApiEndpoints.getVendorList,
        token: token,
      );

      print(
        '\n═══════════════════════════════════════════════════════════════',
      );
      print('✅ VENDOR LIST RESPONSE:');
      print('═══════════════════════════════════════════════════════════════');
      print('Success: ${response['success']}');
      print('Message: ${response['message']}');

      // Parse the response structure: { "success": true, "message": "...", "data": { "vendors": [...] } }
      final data = response['data'] as Map<String, dynamic>?;
      final vendorsJson = data?['vendors'] as List<dynamic>? ?? [];

      print('Vendors Count: ${vendorsJson.length}');
      print(
        '═══════════════════════════════════════════════════════════════\n',
      );

      // Convert JSON list to VendorListItemModel list
      final vendors = vendorsJson
          .map(
            (json) =>
                VendorListItemModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return vendors;
    } on Exception catch (e) {
      final errorString = e.toString();

      if (errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup')) {
        throw Exception(
          'Unable to connect to server. Please check your internet connection.',
        );
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
      } else {
        throw Exception(
          errorString.startsWith('Exception: ')
              ? errorString.replaceFirst('Exception: ', '')
              : 'Failed to fetch vendor list. Please try again.',
        );
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
