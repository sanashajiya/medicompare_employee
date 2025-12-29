import '../entities/vendor_list_item_entity.dart';
import '../repositories/vendor_repository.dart';

class GetVendorListUseCase {
  final VendorRepository repository;

  GetVendorListUseCase(this.repository);

  Future<List<VendorListItemEntity>> call(String token) async {
    return await repository.getVendorList(token);
  }
}
