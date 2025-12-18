import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/delete_draft_usecase.dart';
import '../../../domain/usecases/get_all_drafts_usecase.dart';
import '../../../domain/usecases/get_draft_by_id_usecase.dart';
import '../../../domain/usecases/get_draft_count_usecase.dart';
import '../../../domain/usecases/save_draft_usecase.dart';
import 'draft_event.dart';
import 'draft_state.dart';

class DraftBloc extends Bloc<DraftEvent, DraftState> {
  final SaveDraftUseCase saveDraftUseCase;
  final GetAllDraftsUseCase getAllDraftsUseCase;
  final GetDraftByIdUseCase getDraftByIdUseCase;
  final DeleteDraftUseCase deleteDraftUseCase;
  final GetDraftCountUseCase getDraftCountUseCase;

  DraftBloc({
    required this.saveDraftUseCase,
    required this.getAllDraftsUseCase,
    required this.getDraftByIdUseCase,
    required this.deleteDraftUseCase,
    required this.getDraftCountUseCase,
  }) : super(DraftInitial()) {
    on<DraftSaveRequested>(_onSaveRequested);
    on<DraftLoadAllRequested>(_onLoadAllRequested);
    on<DraftLoadCountRequested>(_onLoadCountRequested);
    on<DraftDeleteRequested>(_onDeleteRequested);
    on<DraftLoadByIdRequested>(_onLoadByIdRequested);
  }

  Future<void> _onSaveRequested(
    DraftSaveRequested event,
    Emitter<DraftState> emit,
  ) async {
    try {
      await saveDraftUseCase(event.draft);
      emit(DraftSaved());
      // Refresh count after saving
      add(DraftLoadCountRequested());
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }

  Future<void> _onLoadAllRequested(
    DraftLoadAllRequested event,
    Emitter<DraftState> emit,
  ) async {
    emit(DraftLoading());
    try {
      final drafts = await getAllDraftsUseCase();
      emit(DraftListLoaded(drafts));
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }

  Future<void> _onLoadCountRequested(
    DraftLoadCountRequested event,
    Emitter<DraftState> emit,
  ) async {
    try {
      final count = await getDraftCountUseCase();
      emit(DraftCountLoaded(count));
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    DraftDeleteRequested event,
    Emitter<DraftState> emit,
  ) async {
    try {
      // Delete the draft
      await deleteDraftUseCase(event.draftId);

      // Emit DraftDeleted first so listener can show success message
      emit(DraftDeleted());

      // Immediately reload the list to reflect the deletion
      final drafts = await getAllDraftsUseCase();
      emit(DraftListLoaded(drafts));

      // Also refresh the count in the background
      add(DraftLoadCountRequested());
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }

  Future<void> _onLoadByIdRequested(
    DraftLoadByIdRequested event,
    Emitter<DraftState> emit,
  ) async {
    emit(DraftLoading());
    try {
      final draft = await getDraftByIdUseCase(event.draftId);
      if (draft != null) {
        emit(DraftLoaded(draft));
      } else {
        emit(DraftError('Draft not found'));
      }
    } catch (e) {
      emit(DraftError(e.toString()));
    }
  }
}

