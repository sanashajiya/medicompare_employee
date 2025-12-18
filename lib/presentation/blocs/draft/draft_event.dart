import '../../../domain/entities/draft_vendor_entity.dart';

abstract class DraftEvent {}

class DraftSaveRequested extends DraftEvent {
  final DraftVendorEntity draft;

  DraftSaveRequested(this.draft);
}

class DraftLoadAllRequested extends DraftEvent {}

class DraftLoadCountRequested extends DraftEvent {}

class DraftDeleteRequested extends DraftEvent {
  final String draftId;

  DraftDeleteRequested(this.draftId);
}

class DraftLoadByIdRequested extends DraftEvent {
  final String draftId;

  DraftLoadByIdRequested(this.draftId);
}


