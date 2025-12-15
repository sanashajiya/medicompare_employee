import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee_entity.dart';

abstract class EmployeeFormEvent extends Equatable {
  const EmployeeFormEvent();
  
  @override
  List<Object?> get props => [];
}

class EmployeeFormSubmitted extends EmployeeFormEvent {
  final EmployeeEntity employee;
  
  const EmployeeFormSubmitted(this.employee);
  
  @override
  List<Object?> get props => [employee];
}

class EmployeeFormReset extends EmployeeFormEvent {}

