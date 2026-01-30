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
    try {
      print('💾 [AuthLocalStorage] Saving login status for user: ${user.email}');
      print('💾 [AuthLocalStorage] Token to save: ${user.token.substring(0, 20)}...');
      
      await _prefs.setBool(_isLoggedInKey, true);
      print('✅ [AuthLocalStorage] Login flag set to true');
      
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
      
      final userJsonString = jsonEncode(userJson);
      print('✅ [AuthLocalStorage] User JSON encoded: ${userJsonString.length} characters');
      
      await _prefs.setString(_userDataKey, userJsonString);
      print('✅ [AuthLocalStorage] User data saved to SharedPreferences');
      
      // Verify immediately after saving
      final saved = _prefs.getString(_userDataKey);
      if (saved != null) {
        print('✅ [AuthLocalStorage] Verification: Data exists in SharedPreferences (${saved.length} chars)');
      } else {
        print('❌ [AuthLocalStorage] Verification FAILED: Data not found after save!');
      }
    } catch (e) {
      print('❌ [AuthLocalStorage] Error saving login status: $e');
      rethrow;
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
    print('🔍 [AuthLocalStorage] isLoggedIn check: $isLoggedIn');
    return isLoggedIn;
  }

  /// Get saved user data
  UserEntity? getSavedUser() {
    print('🔍 [AuthLocalStorage] Retrieving saved user...');
    final userJsonString = _prefs.getString(_userDataKey);
    print('🔍 [AuthLocalStorage] Retrieved string: ${userJsonString != null ? userJsonString.length : "null"} chars');
    
    if (userJsonString == null) {
      print('⚠️  [AuthLocalStorage] No user data found in SharedPreferences');
      return null;
    }

    try {
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      print('✅ [AuthLocalStorage] JSON decoded successfully');
      print('✅ [AuthLocalStorage] User email: ${userJson['email']}');
      
      final user = UserModel(
        id: userJson['id']?.toString() ?? '',
        name: userJson['name']?.toString() ?? '',
        email: userJson['email']?.toString() ?? '',
        mobile: userJson['mobile']?.toString() ?? '',
        token: userJson['token']?.toString() ?? '',
        status: userJson['status']?.toString() ?? 'active',
        type: userJson['type']?.toString() ?? 'employee',
        roleName: userJson['roleName']?.toString(),
      );
      
      print('✅ [AuthLocalStorage] User model created: ${user.email}');
      print('✅ [AuthLocalStorage] Token: ${user.token.substring(0, 20)}...');
      return user;
    } catch (e) {
      print('❌ [AuthLocalStorage] Error parsing saved user data: $e');
      print('❌ [AuthLocalStorage] Raw data: $userJsonString');
      return null;
    }
  }

  /// Clear login status and user data (for logout)
  Future<void> clearLoginStatus() async {
    try {
      print('🗑️  [AuthLocalStorage] Clearing login status...');
      await _prefs.remove(_isLoggedInKey);
      await _prefs.remove(_userDataKey);
      print('✅ [AuthLocalStorage] Login status cleared successfully');
    } catch (e) {
      print('❌ [AuthLocalStorage] Error clearing login status: $e');
      rethrow;
    }
  }
}







