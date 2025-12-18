import '../entities/draft_vendor_entity.dart';

abstract class DraftRepository {
  /// Save or update a draft
  Future<void> saveDraft(DraftVendorEntity draft);

  /// Get all drafts
  Future<List<DraftVendorEntity>> getAllDrafts();

  /// Get a draft by ID
  Future<DraftVendorEntity?> getDraftById(String id);

  /// Delete a draft by ID
  Future<void> deleteDraft(String id);

  /// Delete all drafts
  Future<void> deleteAllDrafts();

  /// Get the total count of drafts
  Future<int> getDraftCount();
}


