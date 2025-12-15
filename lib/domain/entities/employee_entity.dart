import 'package:equatable/equatable.dart';

class EmployeeEntity extends Equatable {
  final String? id;
  final String name;
  final String employeeId;
  final String department;
  final String email;
  final String mobileNumber;
  final bool isMobileVerified;
  
  const EmployeeEntity({
    this.id,
    required this.name,
    required this.employeeId,
    required this.department,
    required this.email,
    required this.mobileNumber,
    this.isMobileVerified = false,
  });
  
  EmployeeEntity copyWith({
    String? id,
    String? name,
    String? employeeId,
    String? department,
    String? email,
    String? mobileNumber,
    bool? isMobileVerified,
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    employeeId,
    department,
    email,
    mobileNumber,
    isMobileVerified,
  ];
}

