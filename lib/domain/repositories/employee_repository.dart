import '../entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<EmployeeEntity> submitEmployeeForm(EmployeeEntity employee);
}
