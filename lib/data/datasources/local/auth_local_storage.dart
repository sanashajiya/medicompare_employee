import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_model.dart';

class AuthLocalStorage {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userDataKey = 'user_data';

  final SharedPreferences _prefs;

  AuthLocalStorage(this._prefs);

  /// Save login status and user data
  Future<void> saveLoginStatus(UserEntity user) async {
    await _prefs.setBool(_isLoggedInKey, true);
    final userJson = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      mobile: user.mobile,
      token: user.token,
      status: user.status,
      type: user.type,
      roleName: user.roleName,
    ).toJson();
    await _prefs.setString(_userDataKey, jsonEncode(userJson));
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get saved user data
  UserEntity? getSavedUser() {
    final userJsonString = _prefs.getString(_userDataKey);
    if (userJsonString == null) {
      return null;
    }

    try {
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      return UserModel(
        id: userJson['id']?.toString() ?? '',
        name: userJson['name']?.toString() ?? '',
        email: userJson['email']?.toString() ?? '',
        mobile: userJson['mobile']?.toString() ?? '',
        token: userJson['token']?.toString() ?? '',
        status: userJson['status']?.toString() ?? 'active',
        type: userJson['type']?.toString() ?? 'employee',
        roleName: userJson['roleName']?.toString(),
      );
    } catch (e) {
      print('Error parsing saved user data: $e');
      return null;
    }
  }

  /// Clear login status and user data (for logout)
  Future<void> clearLoginStatus() async {
    await _prefs.remove(_isLoggedInKey);
    await _prefs.remove(_userDataKey);
  }
}




