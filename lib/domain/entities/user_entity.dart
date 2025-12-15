import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String token;
  final String status;
  final String type;
  final String? roleName;
  
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.token,
    required this.status,
    required this.type,
    this.roleName,
  });
  
  @override
  List<Object?> get props => [id, name, email, mobile, token, status, type, roleName];
}

