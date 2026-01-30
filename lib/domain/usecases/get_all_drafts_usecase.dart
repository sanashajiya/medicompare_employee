import '../entities/draft_vendor_entity.dart';
import '../repositories/draft_repository.dart';

class GetAllDraftsUseCase {
  final DraftRepository repository;

  GetAllDraftsUseCase(this.repository);

  Future<List<DraftVendorEntity>> call() async {
    return await repository.getAllDrafts();
  }
}







