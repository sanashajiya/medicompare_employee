import '../entities/vendor_entity.dart';
import '../repositories/vendor_repository.dart';

class CreateVendorUseCase {
  final VendorRepository repository;

  CreateVendorUseCase(this.repository);

  Future<VendorEntity> call(VendorEntity vendor, String token) async {
    return await repository.createVendor(vendor, token);
  }
}

