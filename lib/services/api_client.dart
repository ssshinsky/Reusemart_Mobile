import 'dart:convert';
import 'dart:developer' as developer; // Digunakan untuk logging yang lebih baik
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import semua model yang digunakan oleh kedua versi
import '../models/barang.dart';
import '../models/kategori.dart';
import '../models/pembeli.dart'; // Dari russel-merge
import '../models/penitip.dart'; // Dari russel-merge
import '../models/pegawai.dart'; // Dari russel-merge
import '../models/top_seller.dart'; // Dari russel-merge
import '../models/transaksi_pembelian.dart'; // Dari russel-merge
import '../models/pegawai_profile.dart'; // Dari mobile_test
import '../models/komisi_history.dart'; // Dari mobile_test
import '../models/merchandise.dart'; // Dari mobile_test


class ApiClient {
  // Base URL dari russel-merge
  static const String baseUrl = 'http://10.34.248.196:8000/api';
  // storageBaseUrl dari mobile_test, penting untuk gambar
  static const String storageBaseUrl = 'http://10.34.248.196:8000/storage';

  String? _token; // Private variable untuk menyimpan token

  // Helper method untuk memastikan token sudah di-load
  Future<void> _ensureTokenLoaded() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token'); // Menggunakan 'token' dari russel-merge
    }
  }

  // Method untuk menyimpan token (dari russel-merge)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
  }

  // Method untuk menghapus token dan data login (dari russel-merge)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role'); // dari russel-merge
    await prefs.remove('user'); // dari russel-merge
    await prefs.remove('authToken'); // dari mobile_test, untuk kompatibilitas
    await prefs.remove('userType'); // dari mobile_test, untuk kompatibilitas
    await prefs.remove('userData'); // dari mobile_test, untuk kompatibilitas
    await prefs.remove('id_pegawai'); // dari russel-merge
    _token = null;
  }

  // Helper method untuk mendapatkan headers dengan token (dari russel-merge)
  Future<Map<String, String>> get _headers async {
    await _ensureTokenLoaded();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Login (menggabungkan logika dan logging dari russel-merge dengan respons mobile_test)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    developer.log('Attempting to login to: $url', name: 'ApiClient');
    developer.log('Email: $email, Password: $password', name: 'ApiClient');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json', // Tambahkan Accept dari russel-merge
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      developer.log('Response status: ${response.statusCode}', name: 'ApiClient');
      developer.log('Response body: ${response.body}', name: 'ApiClient');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['token'] != null) {
          // Simpan token dengan metode saveToken
          await saveToken(responseBody['token']);
          // Simpan role dan user data yang sesuai dengan respons
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userType', responseBody['user_type']); // Sesuaikan dengan key dari mobile_test
          await prefs.setString('userData', jsonEncode(responseBody['user'])); // Sesuaikan dengan key dari mobile_test

          // Tambahan logika untuk id_pegawai dari russel-merge
          if (responseBody['user_type'] == 'kurir' && responseBody['user']['id'] != null) {
            await prefs.setInt('id_pegawai', responseBody['user']['id']);
          } else {
            await prefs.remove('id_pegawai');
          }

          return {
            'success': true,
            'message': responseBody['message'],
            'token': responseBody['token'],
            'user_type': responseBody['user_type'],
            'user': responseBody['user'],
          };
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Login failed. Unknown error.',
        };
      }
    } catch (e) {
      developer.log('Error during login request: $e', name: 'ApiClient');
      return {
        'success': false,
        'message': 'Network error or unable to connect to server: $e',
      };
    }
  }

  // Logout (dari russel-merge)
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

  // Top Seller (dari russel-merge)
  Future<Map<String, dynamic>> getTopSeller() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top-seller'),
        headers: await _headers,
      );

      developer.log(
        'Top Seller Response: ${response.statusCode} - ${response.body}',
        name: 'ApiClient',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'last_month': data['last_month'],
          'top_seller': data['top_seller'] != null
              ? TopSeller.fromJson(data['top_seller'])
              : null,
        };
      } else {
        throw Exception('Failed to load top seller: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Top Seller Error: $e', name: 'ApiClient');
      throw Exception('Error fetching top seller: $e');
    }
  }

  // Get Barang (menggunakan try-catch dari russel-merge, header token)
  Future<List<Barang>> getBarang() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barang'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        List jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((data) => Barang.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting barang: $e');
    }
  }

  // Get Barang by ID (menggunakan try-catch dari russel-merge, header token)
  Future<Barang> getBarangById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barang/$id'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return Barang.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load barang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting barang: $e');
    }
  }

  // Get Kategori (menggunakan try-catch dari russel-merge, header token)
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

  // Add to Cart (dari russel-merge)
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

  // Get Penitip by ID (dari russel-merge)
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

  // Get Penitip Profile (dari russel-merge)
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

  // Get Consignment History by ID (dari russel-merge)
  Future<List<ConsignmentHistory>> getConsignmentHistoryById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/penitip/$id/history'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((data) => ConsignmentHistory.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to load history (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting consignment history: $e');
    }
  }

  // Get Consignment History (tanpa ID, dari russel-merge)
  Future<List<ConsignmentHistory>> getConsignmentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/penitip/history'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((data) => ConsignmentHistory.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to load history (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting consignment history: $e');
    }
  }

  // Get Pembeli by ID (dari russel-merge)
  Future<Pembeli> getPembeliById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pembeli/$id'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return Pembeli.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load pembeli (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting pembeli: $e');
    }
  }

  // Get Pembeli Profile (dari russel-merge)
  Future<Pembeli> getPembeliProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pembeli/profile'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        return Pembeli.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load profile (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting profile: $e');
    }
  }

  // Get Purchase History by ID (dari russel-merge)
  Future<List<PurchaseHistory>> getPurchaseHistoryById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pembeli/$id/history'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((data) => PurchaseHistory.fromJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to load purchase history (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting purchase history: $e');
    }
  }

  // Get Purchase History (tanpa ID, dari russel-merge)
  Future<List<PurchaseHistory>> getPurchaseHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pembeli/history'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final List jsonResponse = jsonDecode(response.body);
        return jsonResponse
            .map((data) => PurchaseHistory.fromJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to load purchase history (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error getting purchase history: $e');
    }
  }

  // Get Pegawai Profile (untuk Kurir, dari russel-merge)
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

  // Get Transaksi Kurir (dari russel-merge)
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
    final headers = await _headers; // Menggunakan _headers dengan token

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

  // Get Active Deliveries (dari russel-merge)
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

    final headers = await _headers; // Menggunakan _headers dengan token
    final url = Uri.parse('$baseUrl/kurir/active-deliveries/$pegawaiId');

    developer.log('Permintaan: GET $url', name: 'ApiClient');
    developer.log('Header: $headers', name: 'ApiClient');
    developer.log('id_pegawai: $pegawaiId', name: 'ApiClient');

    try {
      final response = await http.get(url, headers: headers).timeout(
            const Duration(seconds: 30),
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

  // Update Status Transaksi (dari russel-merge)
  Future<void> updateStatusTransaksi(int idPembelian, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final idPegawai = prefs.getInt('id_pegawai') ?? 0;

    if (idPegawai == 0) {
      developer.log('Invalid id_pegawai', name: 'ApiClient');
      throw Exception('ID Pegawai tidak valid');
    }

    final url = Uri.parse(
        '$baseUrl/kurir/transaksi-pembelian/$idPembelian/status/transaksi');
    final headers = await _headers; // Menggunakan _headers dengan token
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
            'HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Exception in updateStatusTransaksi: $e',
          name: 'ApiClient');
      throw Exception('Gagal memperbarui status transaksi: $e');
    }
  }


  // Hunter APIs (dari mobile_test)
  Future<PegawaiProfile> getHunterProfileAndTotalCommission() async {
    final token = await _getAuthToken(); // Menggunakan _getAuthToken dari versi mobile_test
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
    final token = await _getAuthToken(); // Menggunakan _getAuthToken
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
    final token = await _getAuthToken(); // Menggunakan _getAuthToken
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

  // Merchandise APIs (dari mobile_test)
  Future<List<Merchandise>> getMerchandiseCatalog() async {
    // Tidak ada autentikasi di sini pada mobile_test, menggunakan _headers untuk konsistensi
    final response = await http.get(Uri.parse('$baseUrl/merchandise'), headers: await _headers);
    developer.log('Merchandise Catalog Response Status: ${response.statusCode}', name: 'ApiClient');
    developer.log('Merchandise Catalog Response Body: ${response.body}', name: 'ApiClient');

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body)['data'];
      return jsonResponse.map((data) => Merchandise.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load merchandise catalog: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Merchandise> getMerchandiseById(int id) async {
    // Tidak ada autentikasi di sini pada mobile_test, menggunakan _headers untuk konsistensi
    final response = await http.get(Uri.parse('$baseUrl/merchandise/$id'), headers: await _headers);
    if (response.statusCode == 200) {
      return Merchandise.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load merchandise detail: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> claimMerchandise(int merchandiseId, int pembeliId) async {
    // Autentikasi dikomen di mobile_test, tetapi di sini saya sertakan `_headers` untuk keamanannya.
    // Jika backend TIDAK memerlukan token untuk ini, Anda bisa menghapus `headers: await _headers`
    // atau mengubahnya menjadi `headers: {'Content-Type': 'application/json; charset=UTF-8'}`.
    final url = Uri.parse('$baseUrl/merchandise/claim');

    try {
      final response = await http.post(
        url,
        headers: await _headers, // Menggunakan headers terpusat dengan token
        body: jsonEncode(<String, int>{
          'merchandise_id': merchandiseId,
          'pembeli_id': pembeliId,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'],
          'current_poin_pembeli': responseBody['current_poin_pembeli'],
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to claim merchandise. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      developer.log('Claim merchandise error: $e', name: 'ApiClient');
      return {
        'success': false,
        'message': 'Network error or unable to connect to server: $e',
      };
    }
  }
}