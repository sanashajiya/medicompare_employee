import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/draft_vendor_entity.dart';
import '../../models/draft_vendor_model.dart';

class DraftLocalStorage {
  static const String _boxName = 'draft_vendor_box';
  Box? _box;

  /// Initialize Hive box
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Ensure box is initialized
  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }

  /// Save or update a draft
  Future<void> saveDraft(DraftVendorEntity draft) async {
    await _ensureInitialized();
    final model = DraftVendorModel.fromEntity(draft);
    await _box!.put(draft.id, model.toMap());
  }

  /// Get all drafts
  Future<List<DraftVendorEntity>> getAllDrafts() async {
    await _ensureInitialized();
    final drafts = <DraftVendorEntity>[];

    for (var key in _box!.keys) {
      try {
        final map = _box!.get(key) as Map<dynamic, dynamic>;
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final stringMap = Map<String, dynamic>.from(
          map.map((k, v) => MapEntry(k.toString(), v)),
        );
        final model = DraftVendorModel.fromMap(stringMap);
        drafts.add(model);
      } catch (e) {
        print('Error parsing draft with key $key: $e');
        // Skip corrupted drafts
        continue;
      }
    }

    // Sort by updatedAt descending (newest first)
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  /// Get a draft by ID
  Future<DraftVendorEntity?> getDraftById(String id) async {
    await _ensureInitialized();
    if (!_box!.containsKey(id)) {
      return null;
    }

    try {
      final map = _box!.get(id) as Map<dynamic, dynamic>;
      final stringMap = Map<String, dynamic>.from(
        map.map((k, v) => MapEntry(k.toString(), v)),
      );
      return DraftVendorModel.fromMap(stringMap);
    } catch (e) {
      print('Error parsing draft with id $id: $e');
      return null;
    }
  }

  /// Delete a draft by ID
  Future<void> deleteDraft(String id) async {
    await _ensureInitialized();
    await _box!.delete(id);
  }

  /// Delete all drafts
  Future<void> deleteAllDrafts() async {
    await _ensureInitialized();
    await _box!.clear();
  }

  /// Get the total count of drafts
  Future<int> getDraftCount() async {
    await _ensureInitialized();
    return _box!.length;
  }

  /// Find existing draft by unique vendor key (business name + mobile)
  /// This prevents duplicate drafts for the same vendor
  Future<DraftVendorEntity?> findDraftByVendorKey({
    required String businessName,
    required String mobile,
  }) async {
    await _ensureInitialized();

    // Normalize the key for comparison (lowercase, trim)
    final normalizedBusinessName = businessName.trim().toLowerCase();
    final normalizedMobile = mobile.trim();

    if (normalizedBusinessName.isEmpty && normalizedMobile.isEmpty) {
      return null;
    }

    for (var key in _box!.keys) {
      try {
        final map = _box!.get(key) as Map<dynamic, dynamic>;
        final stringMap = Map<String, dynamic>.from(
          map.map((k, v) => MapEntry(k.toString(), v)),
        );
        final model = DraftVendorModel.fromMap(stringMap);

        // Compare normalized business name and mobile
        final draftBusinessName = model.businessName.trim().toLowerCase();
        final draftMobile = model.mobile.trim();

        // Match if both business name and mobile match
        if (normalizedBusinessName.isNotEmpty && normalizedMobile.isNotEmpty) {
          if (draftBusinessName == normalizedBusinessName &&
              draftMobile == normalizedMobile) {
            return model;
          }
        }
        // Fallback: match by mobile only if business name is empty
        else if (normalizedMobile.isNotEmpty &&
            draftMobile == normalizedMobile) {
          return model;
        }
      } catch (e) {
        print('Error parsing draft with key $key: $e');
        continue;
      }
    }

    return null;
  }

  /// Close the box (optional, for cleanup)
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }
}
