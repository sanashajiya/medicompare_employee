import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    super.id,
    required super.name,
    required super.employeeId,
    required super.department,
    required super.email,
    required super.mobileNumber,
    super.isMobileVerified,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      name: json['name'] ?? '',
      employeeId: json['employeeId'] ?? json['employee_id'] ?? '',
      department: json['department'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? json['mobile_number'] ?? '',
      isMobileVerified:
          json['isMobileVerified'] ?? json['is_mobile_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'employeeId': employeeId,
      'department': department,
      'email': email,
      'mobileNumber': mobileNumber,
      'isMobileVerified': isMobileVerified,
    };
  }

  factory EmployeeModel.fromEntity(EmployeeEntity entity) {
    return EmployeeModel(
      id: entity.id,
      name: entity.name,
      employeeId: entity.employeeId,
      department: entity.department,
      email: entity.email,
      mobileNumber: entity.mobileNumber,
      isMobileVerified: entity.isMobileVerified,
    );
  }
}
