import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class SubmitEmployeeFormUseCase {
  final EmployeeRepository repository;
  
  SubmitEmployeeFormUseCase(this.repository);
  
  Future<EmployeeEntity> call(EmployeeEntity employee) async {
    return await repository.submitEmployeeForm(employee);
  }
}

