import '../entities/vendor_entity.dart';

abstract class VendorRepository {
  Future<VendorEntity> createVendor(VendorEntity vendor, String token);
}

