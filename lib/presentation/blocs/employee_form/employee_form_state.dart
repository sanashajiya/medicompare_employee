import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee_entity.dart';

abstract class EmployeeFormState extends Equatable {
  const EmployeeFormState();
  
  @override
  List<Object?> get props => [];
}

class EmployeeFormInitial extends EmployeeFormState {}

class EmployeeFormSubmitting extends EmployeeFormState {}

class EmployeeFormSuccess extends EmployeeFormState {
  final EmployeeEntity employee;
  final String message;
  
  const EmployeeFormSuccess(this.employee, [this.message = 'Form submitted successfully']);
  
  @override
  List<Object?> get props => [employee, message];
}

class EmployeeFormFailure extends EmployeeFormState {
  final String error;
  
  const EmployeeFormFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}

