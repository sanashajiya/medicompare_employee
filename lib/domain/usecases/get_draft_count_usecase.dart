import '../repositories/draft_repository.dart';

class GetDraftCountUseCase {
  final DraftRepository repository;

  GetDraftCountUseCase(this.repository);

  Future<int> call() async {
    return await repository.getDraftCount();
  }
}

