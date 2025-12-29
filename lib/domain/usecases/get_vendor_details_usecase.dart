import '../entities/vendor_entity.dart';
import '../repositories/vendor_repository.dart';

class GetVendorDetailsUseCase {
  final VendorRepository repository;

  GetVendorDetailsUseCase(this.repository);

  Future<VendorEntity> call(String vendorId, String token) {
    return repository.getVendorDetails(vendorId, token);
  }
}

