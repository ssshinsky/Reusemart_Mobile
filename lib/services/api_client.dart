// lib/services/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/barang.dart';
import '../models/kategori.dart';
import '../models/pegawai_profile.dart';
import '../models/komisi_history.dart';
import '../models/merchandise.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String storageBaseUrl = 'http://10.0.2.2:8000/storage';

  // Helper method to get the authentication token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    print('Attempting to login to: $url');
    print('Email: $email, Password: $password');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'],
          'token': responseBody['token'],
          'user_type': responseBody['user_type'],
          'user': responseBody['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Login failed. Unknown error.',
        };
      }
    } catch (e) {
      print('Error during login request: $e');
      return {
        'success': false,
        'message': 'Network error or unable to connect to server: $e',
      };
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
    final response = await http.get(Uri.parse('$baseUrl/kategori'));
    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Kategori.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load kategori: ${response.statusCode}');
    }
  }

  //hunter
  Future<PegawaiProfile> getHunterProfileAndTotalCommission() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('$baseUrl/hunter/profile-and-commission');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        return PegawaiProfile.fromJson(responseBody['profile'], responseBody['total_komisi']);
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to load hunter profile.');
      }
    } else {
      throw Exception('Failed to load hunter profile: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<KomisiHistory>> getCommissionHistory() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('$baseUrl/hunter/commission-history');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        List jsonList = responseBody['history'];
        return jsonList.map((json) => KomisiHistory.fromJson(json)).toList();
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to load commission history.');
      }
    } else {
      throw Exception('Failed to load commission history: ${response.statusCode} - ${response.body}');
    }
  }

  Future<KomisiHistory> getCommissionDetail(int commissionId) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('$baseUrl/hunter/commission-detail/$commissionId');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        return KomisiHistory.fromJson(responseBody['detail']);
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to load commission detail.');
      }
    } else {
      throw Exception('Failed to load commission detail: ${response.statusCode} - ${response.body}');
    }
  }
  
  Future<List<Merchandise>> getMerchandiseCatalog() async {
    final response = await http.get(Uri.parse('$baseUrl/merchandise'));
    print('Merchandise Catalog Response Status: ${response.statusCode}');
    print('Merchandise Catalog Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['data'];
      return jsonResponse.map((data) => Merchandise.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load merchandise catalog: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Merchandise> getMerchandiseById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/merchandise/$id'));
    if (response.statusCode == 200) {
      return Merchandise.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load merchandise detail: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> claimMerchandise(int merchandiseId, int pembeliId) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('$baseUrl/merchandise/claim'); // Sesuaikan dengan rute API di Laravel
    
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, int>{
          'merchandise_id': merchandiseId,
          'pembeli_id': pembeliId,
          // 'jumlah': 1, // Jika kamu ingin mengirim jumlah klaim, tapi di controller sudah hardcoded 1
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'],
          'current_poin_pembeli': responseBody['current_poin_pembeli'], // Dari respons backend
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to claim merchandise. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Claim merchandise error: $e');
      return {
        'success': false,
        'message': 'Network error or unable to connect to server: $e',
      };
    }
  }
}