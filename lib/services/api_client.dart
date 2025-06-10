import 'dart:convert';
import 'dart:developer' as developer; // Added import
import 'package:http/http.dart' as http;
import 'package:reusemart_mobile/models/penitip.dart';
// import 'package:reusemart_mobile/models/penitip_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/barang.dart';
import '../models/kategori.dart';
import '../models/top_seller.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.100.65:8000/api';
  String? _token;

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

  Future<TopSeller?> getTopSeller() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top-seller'),
        headers: {'Accept': 'application/json'},
      );

      developer.log('Top Seller Response: ${response.statusCode} - ${response.body}', name: 'ApiClient');

      if (response.statusCode == 200) {
        return TopSeller.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load top seller: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Top Seller Error: $e', name: 'ApiClient');
      throw Exception('Error fetching top seller: $e');
    }
  }

  Future<List<Barang>> getBarang() async {
    final response = await http.get(Uri.parse('$baseUrl/barang'));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Barang.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load barang: ${response.statusCode}');
    }
  }

  Future<Barang> getBarangById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/barang/$id'));
    if (response.statusCode == 200) {
      return Barang.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load barang: ${response.statusCode}');
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
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      developer.log('API Response: ${response.body}', name: 'ApiClient');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await saveToken(data['token']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', data['role']);
          await prefs.setString('user', jsonEncode(data['user']));
           if (data['role'] == 'Kurir' && data['user']['id'] != null) {
            await prefs.setInt('id_pegawai', data['user']['id']);
          } else {
            await prefs.remove('id_pegawai');
          }
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

  // Method baru buat ngambil penitip by ID
      Future<Penitipp> getPenitipById(int id) async {
          try {
              final response = await http.get(
                  Uri.parse('$baseUrl/penitip/$id'),
                  headers: await _headers,
              );
              if (response.statusCode == 200) {
                  return Penitipp.fromJson(jsonDecode(response.body));
              } else {
                  throw Exception('Failed to load penitip (${response.statusCode})');
              }
          } catch (e) {
              throw Exception('Error getting penitip: $e');
          }
      }

  Future<Penitipp> getPenitipProfile() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/penitip/profile'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      return Penitipp.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile (${response.statusCode})');
    }
  } catch (e) {
    throw Exception('Error getting profile: $e');
  }
}

Future<List<ConsignmentHistory>> getConsignmentHistoryById(int id) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/penitip/$id/history'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ConsignmentHistory.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load history (${response.statusCode})');
    }
  } catch (e) {
    throw Exception('Error getting consignment history: $e');
  }
}

Future<List<ConsignmentHistory>> getConsignmentHistory() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/penitip/history'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ConsignmentHistory.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load history (${response.statusCode})');
    }
  } catch (e) {
    throw Exception('Error getting consignment history: $e');
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
}
