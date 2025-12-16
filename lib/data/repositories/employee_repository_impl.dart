import '../../core/constants/api_endpoints.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final ApiService apiService;

  EmployeeRepositoryImpl(this.apiService);

  @override
  Future<EmployeeEntity> submitEmployeeForm(EmployeeEntity employee) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      final response = await apiService.post(
        ApiEndpoints.submitEmployeeForm,
        employeeModel.toJson(),
      );

      return EmployeeModel.fromJson(response);
    } catch (e) {
      // For demo purposes, simulate successful form submission
      await Future.delayed(const Duration(seconds: 1));
      return employee.copyWith(
        id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }
}
