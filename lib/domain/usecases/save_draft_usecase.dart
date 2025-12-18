import '../entities/draft_vendor_entity.dart';
import '../repositories/draft_repository.dart';

class SaveDraftUseCase {
  final DraftRepository repository;

  SaveDraftUseCase(this.repository);

  Future<void> call(DraftVendorEntity draft) async {
    return await repository.saveDraft(draft);
  }
}



