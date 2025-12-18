import '../entities/draft_vendor_entity.dart';
import '../repositories/draft_repository.dart';

class GetDraftByIdUseCase {
  final DraftRepository repository;

  GetDraftByIdUseCase(this.repository);

  Future<DraftVendorEntity?> call(String id) async {
    return await repository.getDraftById(id);
  }
}


