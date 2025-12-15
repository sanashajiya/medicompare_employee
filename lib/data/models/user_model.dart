import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.token,
    required super.status,
    required super.type,
    super.roleName,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested structure from API response
    final data = json['data'] ?? {};
    final user = data['user'] ?? {};
    final roleData = user['roleData'] ?? {};
    
    return UserModel(
      id: user['_id']?.toString() ?? user['id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      mobile: user['mobile']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
      status: user['status']?.toString() ?? 'active',
      type: user['type']?.toString() ?? 'employee',
      roleName: roleData['name']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'token': token,
      'status': status,
      'type': type,
      'roleName': roleName,
    };
  }
}

