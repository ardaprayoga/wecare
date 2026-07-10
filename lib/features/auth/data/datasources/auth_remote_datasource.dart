import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  // Mengambil baseUrl secara dinamis (localhost untuk Web, 10.0.2.2 untuk Emulator)
  final String baseUrl = ApiConstants.baseUrl;

  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return UserModel.fromJson(data['user']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Gagal terhubung ke server");
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      body: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!data['success']) {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Gagal terhubung ke server");
    }
  }
}
