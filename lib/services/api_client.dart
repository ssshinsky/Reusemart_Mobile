import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/barang.dart';
import '../models/kategori.dart';
import '../models/delivery.dart';

class ApiClient {
  static const String baseUrl = 'http://172.16.0.4:8000/api';
  String? _token;

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final combinedHeaders = {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
      ...(await _headers), // gabungkan dengan header dari token lokal jika ada
    };

    final response = await http.post(
      uri,
      headers: combinedHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode >= 400) {
      throw Exception(
          'POST $endpoint failed (${response.statusCode}): ${response.body}');
    }

    return response;
  }

  Future<void> _ensureTokenLoaded() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('user');
    _token = null;
  }

  Future<Map<String, String>> get _headers async {
    await _ensureTokenLoaded();
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<List<Barang>> getBarang() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produk/allProduct'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Barang.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load barang (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting barang: $e');
    }
  }

  Future<Barang> getBarangById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produk/detail/$id'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return Barang.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load barang (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting barang by ID: $e');
    }
  }

  Future<List<Kategori>> getKategori() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kategori'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Kategori.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load kategori (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting kategori: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      developer.log('API Response: ${response.body}', name: 'ApiClient');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await saveToken(data['token']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', data['role']);
          await prefs.setString('user', jsonEncode(data['user']));
          return {
            'token': data['token'],
            'role': data['role'],
            'user': data['user'],
          };
        } else {
          throw Exception('Token tidak ditemukan dalam respon');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(data['message'] ?? 'Login tidak valid');
      } else {
        throw Exception(
            'Login gagal: ${data['message'] ?? 'Terjadi kesalahan'}');
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  Future<void> addToCart(int idBarang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/keranjang/tambah/$idBarang'),
        headers: await _headers,
      );

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Gagal menambahkan ke keranjang');
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        await clearToken();
      } else {
        final body = jsonDecode(response.body);
        throw Exception(
            body['message'] ?? 'Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  Future<List<Delivery>> getDeliveryHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kurir/deliveries'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Delivery.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load delivery history (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting delivery history: $e');
    }
  }

  // New method: Update delivery status
  Future<void> updateDeliveryStatus(int deliveryId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kurir/deliveries/update'),
        headers: await _headers,
        body: jsonEncode({
          'delivery_id': deliveryId,
          'status': status,
        }),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update delivery status');
      }
    } catch (e) {
      throw Exception('Error updating delivery status: $e');
    }
  }
}
