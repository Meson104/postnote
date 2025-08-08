import 'dart:convert';

import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/shared_prefs_services.dart';
import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final sharedPrefsService = SharedPrefsServices();

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode != 201) {
        throw jsonDecode(response.body)['error'];
      }
      return UserModel.fromJson(response.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['error'];
      }
      return UserModel.fromJson(response.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await sharedPrefsService.getToken();
      if (token == null) return null;
      final response = await http.get(
        Uri.parse('${Constants.backendUri}/auth/tokenIsValid'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (response.statusCode != 200 || jsonDecode(response.body) == false) {
        return null;
      }

      final userRes = await http.get(
        Uri.parse('${Constants.backendUri}/auth'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (userRes.statusCode != 200) {
        throw jsonDecode(userRes.body)['error'];
      }

      return UserModel.fromJson(userRes.body);
    } catch (e) {
      return null;
    }
  }
}
