import '../../domain/entities/draft_vendor_entity.dart';
import '../../domain/repositories/draft_repository.dart';
import '../datasources/local/draft_local_storage.dart';

class DraftRepositoryImpl implements DraftRepository {
  final DraftLocalStorage draftLocalStorage;

  DraftRepositoryImpl(this.draftLocalStorage);

  @override
  Future<void> saveDraft(DraftVendorEntity draft) async {
    await draftLocalStorage.saveDraft(draft);
  }

  @override
  Future<List<DraftVendorEntity>> getAllDrafts() async {
    return await draftLocalStorage.getAllDrafts();
  }

  @override
  Future<DraftVendorEntity?> getDraftById(String id) async {
    return await draftLocalStorage.getDraftById(id);
  }

  @override
  Future<void> deleteDraft(String id) async {
    await draftLocalStorage.deleteDraft(id);
  }

  @override
  Future<void> deleteAllDrafts() async {
    await draftLocalStorage.deleteAllDrafts();
  }

  @override
  Future<int> getDraftCount() async {
    return await draftLocalStorage.getDraftCount();
  }

  @override
  Future<DraftVendorEntity?> findDraftByVendorKey({
    required String businessName,
    required String mobile,
  }) async {
    return await draftLocalStorage.findDraftByVendorKey(
      businessName: businessName,
      mobile: mobile,
    );
  }
}
