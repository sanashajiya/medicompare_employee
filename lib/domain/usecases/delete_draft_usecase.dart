import '../repositories/draft_repository.dart';

class DeleteDraftUseCase {
  final DraftRepository repository;

  DeleteDraftUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteDraft(id);
  }
}


