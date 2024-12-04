import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vila_tour_pmdm/src/prefs/user_preferences.dart';
import 'package:vila_tour_pmdm/src/utils/result.dart';

import '../models/models.dart';

class LoginService extends ChangeNotifier {
  final String _baseUrl = 'http://10.0.2.2:8080';

  bool isLoading = true;

  Future<Result> login(String username, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/login');

      final response = await http.post(
        url,
        body: json.encode({"username": username, "password": password}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Guardar el token si el login es exitoso
        await UserPreferences.instance
            .writeData('token', responseData['token']);
        return Result.success;
      } else if (response.statusCode == 401) {
        // Credenciales incorrectas
        return Result.invalidCredentials;
      } else if (response.statusCode >= 500) {
        // Error en el servidor
        return Result.serverError;
      } else {
        // Cualquier otro error no previsto
        return Result.unexpectedError;
      }
    } catch (e) {
      // Error de conexión (sin respuesta del servidor)
      return Result.noConnection;
    }
  }

  Future<void> logout(String token) async {
    final url = Uri.parse('$_baseUrl/auth/singout');

    final response = await http.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Logout failed: ${response.body}');
    }
  }

  Future<Result> register(
      String username, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.parse('$_baseUrl/auth/register');

      final resp = await http.post(
        url,
        body: json.encode(
            {"username": username, "email": email, "password": password}),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );

      isLoading = false;
      notifyListeners();

      if (resp.statusCode == 201) {
        // Registro exitoso, intentar iniciar sesión automáticamente
        final loginResult = await this.login(username, password);
        return loginResult == Result.success ? Result.success : loginResult;
      } else if (resp.statusCode == 400) {
        final responseData = json.decode(resp.body);
        if (responseData['error'] == 'email_already_in_use') {
          return Result
              .invalidCredentials; // Cambia esto si tienes un valor más específico
        } else {
          return Result.invalidData; // Si el error no es específico
        }
      } else if (resp.statusCode >= 500) {
        return Result.serverError;
      } else {
        return Result.unexpectedError;
      }
    } on SocketException {
      return Result.noConnection;
    } catch (e) {
      return Result.unexpectedError;
    }
  }
}
