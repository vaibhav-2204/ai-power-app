import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/progress_entry.dart';

class PrefService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Auth State ───
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('isLoggedIn', value);
  }

  static bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;

  static Future<void> setCurrentEmail(String email) async {
    await _prefs.setString('currentEmail', email);
  }

  static String? get currentEmail => _prefs.getString('currentEmail');

  // ─── User Registration & Login ───
  static Future<bool> registerUser(UserModel user) async {
    final existingUsers = _prefs.getStringList('registeredEmails') ?? [];
    if (existingUsers.contains(user.email)) {
      return false; // Email already exists
    }
    existingUsers.add(user.email);
    await _prefs.setStringList('registeredEmails', existingUsers);
    await _prefs.setString('user_${user.email}', user.toJson());
    return true;
  }

  static UserModel? loginUser(String email, String password) {
    final userJson = _prefs.getString('user_$email');
    if (userJson == null) return null;
    final user = UserModel.fromJson(userJson);
    if (user.password != password) return null;
    return user;
  }

  // ─── User Profile ───
  static Future<void> saveUserProfile(UserModel user) async {
    await _prefs.setString('user_${user.email}', user.toJson());
  }

  static UserModel? getCurrentUser() {
    final email = currentEmail;
    if (email == null) return null;
    final userJson = _prefs.getString('user_$email');
    if (userJson == null) return null;
    return UserModel.fromJson(userJson);
  }

  // ─── Progress Entries ───
  static Future<void> saveProgressEntries(List<ProgressEntry> entries) async {
    final email = currentEmail;
    if (email == null) return;
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setStringList('progress_$email', jsonList);
  }

  static List<ProgressEntry> getProgressEntries() {
    final email = currentEmail;
    if (email == null) return [];
    final jsonList = _prefs.getStringList('progress_$email') ?? [];
    return jsonList.map((e) => ProgressEntry.fromJson(e)).toList();
  }

  // ─── Saved Plans ───
  static Future<void> saveLastWorkoutPlan(String plan) async {
    final email = currentEmail;
    if (email == null) return;
    await _prefs.setString('workout_plan_$email', plan);
  }

  static String? getLastWorkoutPlan() {
    final email = currentEmail;
    if (email == null) return null;
    return _prefs.getString('workout_plan_$email');
  }

  static Future<void> saveLastDietPlan(String plan) async {
    final email = currentEmail;
    if (email == null) return;
    await _prefs.setString('diet_plan_$email', plan);
  }

  static String? getLastDietPlan() {
    final email = currentEmail;
    if (email == null) return null;
    return _prefs.getString('diet_plan_$email');
  }

  // ─── Logout ───
  static Future<void> logout() async {
    await _prefs.setBool('isLoggedIn', false);
    await _prefs.remove('currentEmail');
  }
}
