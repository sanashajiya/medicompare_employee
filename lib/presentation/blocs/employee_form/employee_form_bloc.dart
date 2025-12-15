import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/submit_employee_form_usecase.dart';
import 'employee_form_event.dart';
import 'employee_form_state.dart';

class EmployeeFormBloc extends Bloc<EmployeeFormEvent, EmployeeFormState> {
  final SubmitEmployeeFormUseCase submitEmployeeFormUseCase;
  
  EmployeeFormBloc({
    required this.submitEmployeeFormUseCase,
  }) : super(EmployeeFormInitial()) {
    on<EmployeeFormSubmitted>(_onEmployeeFormSubmitted);
    on<EmployeeFormReset>(_onEmployeeFormReset);
  }
  
  Future<void> _onEmployeeFormSubmitted(
    EmployeeFormSubmitted event,
    Emitter<EmployeeFormState> emit,
  ) async {
    emit(EmployeeFormSubmitting());
    
    try {
      final employee = await submitEmployeeFormUseCase(event.employee);
      emit(EmployeeFormSuccess(employee, 'Employee form submitted successfully'));
    } catch (e) {
      emit(EmployeeFormFailure(e.toString()));
    }
  }
  
  void _onEmployeeFormReset(
    EmployeeFormReset event,
    Emitter<EmployeeFormState> emit,
  ) {
    emit(EmployeeFormInitial());
  }
}

