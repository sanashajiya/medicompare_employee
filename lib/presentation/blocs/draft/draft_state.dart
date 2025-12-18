import '../../../domain/entities/draft_vendor_entity.dart';

abstract class DraftState {}

class DraftInitial extends DraftState {}

class DraftLoading extends DraftState {}

class DraftCountLoaded extends DraftState {
  final int count;

  DraftCountLoaded(this.count);
}

class DraftListLoaded extends DraftState {
  final List<DraftVendorEntity> drafts;

  DraftListLoaded(this.drafts);
}

class DraftLoaded extends DraftState {
  final DraftVendorEntity draft;

  DraftLoaded(this.draft);
}

class DraftSaved extends DraftState {}

class DraftDeleted extends DraftState {}

class DraftError extends DraftState {
  final String message;

  DraftError(this.message);
}



