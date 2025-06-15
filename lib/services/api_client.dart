import 'dart:convert';
import 'dart:developer' as developer; // Added import
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/barang.dart';
import '../models/pegawai.dart';
import '../models/kategori.dart';
import '../models/transaksi_pembelian.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.170.241:8000/api';
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

  Future<List<Barang>> getBarang() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barang/allProduct'),
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
        Uri.parse('$baseUrl/barang/detail/$id'),
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

  Future<Pegawai> getProfile() async {
    final headers = await _headers;
    final response = await http.get(
      Uri.parse('$baseUrl/kurir/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Pegawai.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal memuat profil');
  }

  Future<List<TransaksiPembelian>> getTransaksiKurir({
    int perPage = 10,
    int page = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final idPegawai = prefs.getInt('id_pegawai') ?? 0;

    if (idPegawai == 0) {
      developer.log('Invalid id_pegawai', name: 'ApiClient');
      throw Exception('ID Pegawai tidak valid');
    }

    final url = Uri.parse('$baseUrl/kurir/kelola-transaksi/kurir/$idPegawai');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      developer.log('Response: ${response.statusCode}', name: 'ApiClient');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'] ?? [];

          return data.map((item) => TransaksiPembelian.fromJson(item)).toList();
        } else {
          throw Exception('Gagal: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Exception in getTransaksiKurir',
          error: e, name: 'ApiClient');
      throw Exception('Gagal memuat data transaksi kurir: $e');
    }
  }

  Future<List<TransaksiPembelian>> getActiveDeliveries(
      {int idPegawai = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final pegawaiId =
        idPegawai != 0 ? idPegawai : (prefs.getInt('id_pegawai') ?? 0);

    if (pegawaiId == 0) {
      developer.log('Kesalahan: id_pegawai tidak valid',
          name: 'ApiClient', error: {'id_pegawai': pegawaiId});
      throw Exception('ID Pegawai tidak valid. Silakan login ulang.');
    }

    final headers = {'Content-Type': 'application/json'};
    final url = Uri.parse('$baseUrl/kurir/active-deliveries/$pegawaiId');

    developer.log('Permintaan: GET $url', name: 'ApiClient');
    developer.log('Header: $headers', name: 'ApiClient');
    developer.log('id_pegawai: $pegawaiId', name: 'ApiClient');

    try {
      final response = await http.get(url, headers: headers).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          developer.log('Kesalahan: Permintaan timeout setelah 30 detik',
              name: 'ApiClient');
          throw Exception(
              'Permintaan ke server terlalu lama. Silakan coba lagi nanti.');
        },
      );

      developer.log(
          'Respons: ${response.statusCode} - ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}',
          name: 'ApiClient');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        developer.log('JSON Terurai: $jsonResponse', name: 'ApiClient');
        if (jsonResponse['status'] != 'success') {
          developer.log('Kesalahan: Status respons tidak valid',
              name: 'ApiClient', error: jsonResponse['message']);
          throw Exception(
              'Respons tidak valid: ${jsonResponse['message'] ?? 'Kesalahan tidak diketahui'}');
        }
        final List<dynamic> data = jsonResponse['data'] ?? [];
        if (data.isEmpty) {
          developer.log('Peringatan: Tidak ada transaksi ditemukan',
              name: 'ApiClient');
          return [];
        }
        return data.map((json) => TransaksiPembelian.fromJson(json)).toList();
      } else {
        developer.log('Kesalahan: Respons non-200',
            name: 'ApiClient',
            error: {'statusCode': response.statusCode, 'body': response.body});
        throw Exception(
            'Gagal memuat transaksi aktif: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Kesalahan: Gagal mengambil transaksi aktif',
          name: 'ApiClient', error: e.toString());
      rethrow;
    }
  }

  Future<void> updateStatusTransaksi(int idPembelian, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final idPegawai = prefs.getInt('id_pegawai') ?? 0;

    if (idPegawai == 0) {
      developer.log('Invalid id_pegawai', name: 'ApiClient');
      throw Exception('ID Pegawai tidak valid');
    }

    final url = Uri.parse(
        '$baseUrl/kurir/transaksi-pembelian/$idPembelian/status/transaksi');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'status_transaksi': status,
      'id_pegawai': idPegawai,
    });

    developer.log('Permintaan: PUT $url', name: 'ApiClient');
    developer.log('Body: $body', name: 'ApiClient');

    try {
      final response = await http
          .put(
            url,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      developer.log(
        'Response: ${response.statusCode} - ${response.body}',
        name: 'ApiClient',
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] != 'success') {
          throw Exception(
              'Gagal: ${jsonResponse['message'] ?? 'Respons tidak valid'}');
        }
        return;
      } else {
        throw Exception(
          'HTTP Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      developer.log('Exception in updateStatusTransaksi: $e',
          name: 'ApiClient');
      throw Exception('Gagal memperbarui status transaksi: $e');
    }
  }
}
