import 'package:flutter/material.dart';
import 'package:reusemart_mobile/services/api_client.dart'; 
import 'package:reusemart_mobile/models/merchandise.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 

class MerchandiseDetailScreen extends StatefulWidget {
  final int merchandiseId;

  MerchandiseDetailScreen({required this.merchandiseId});

  @override
  MerchandiseDetailScreenState createState() => MerchandiseDetailScreenState();
}

class MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<Merchandise> _merchandiseDetailFuture;
  int _currentPoinPembeli = 0; // Poin pembeli saat ini

  @override
  void initState() {
    super.initState();
    _fetchMerchandiseDetail();
    _fetchCurrentPoinPembeli(); // Ambil poin pembeli saat inisialisasi
  }

  // Mengambil detail merchandise
  Future<void> _fetchMerchandiseDetail() async {
    _merchandiseDetailFuture = _apiClient.getMerchandiseById(widget.merchandiseId); // Menggunakan getMerchandiseById
  }

  // Mengambil poin pembeli dari SharedPreferences
  Future<void> _fetchCurrentPoinPembeli() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final userData = Map<String, dynamic>.from(jsonDecode(userDataString));
      setState(() {
        _currentPoinPembeli = (userData['poin_pembeli'] as num?)?.toInt() ?? 0; // Pastikan 'poin_pembeli' ada di userData
      });
    }
  }

  // Fungsi untuk klaim merchandise
  void _claimMerchandise(Merchandise merchandise) async { // Parameter diubah menjadi 'merchandise'
    // Validasi poin di sisi client sebelum kirim ke API (backend juga validasi)
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda belum login. Silakan login terlebih dahulu.')),
        );
        return;
    }

    final userData = Map<String, dynamic>.from(jsonDecode(userDataString));
    final int pembeliId = (userData['id_pembeli'] as num?)?.toInt() ?? 0; // Pastikan id_pembeli ada

    if (pembeliId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID Pembeli tidak ditemukan. Silakan login ulang.')),
        );
        return;
    }
    if (_currentPoinPembeli < merchandise.poin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Poin Anda tidak cukup untuk mengklaim merchandise ini!')),
      );
      return;
    }
    if (merchandise.stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok merchandise ini habis.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Processing claim...')),
    );

    try {
      final response = await _apiClient.claimMerchandise(merchandise.idMerchandise, pembeliId);

      if (response['success']) {
        final newPoin = response['current_poin_pembeli'] as int; // Ambil poin terbaru dari respons backend

        // Update poin pembeli di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('userData');
        if (userDataString != null) {
          final userData = Map<String, dynamic>.from(jsonDecode(userDataString));
          userData['poin_pembeli'] = newPoin; // Update dengan poin baru
          await prefs.setString('userData', jsonEncode(userData));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Merchandise berhasil diklaim!')),
        );
        // Refresh tampilan
        setState(() {
          _currentPoinPembeli = newPoin; // Update UI poin
          _merchandiseDetailFuture = _apiClient.getMerchandiseById(widget.merchandiseId); // Refresh detail merch
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal mengklaim merchandise. Stok mungkin tidak cukup atau poin tidak valid.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      print('Claim error: $e');
    } finally {
      // Tidak ada setState((){}); di sini karena sudah di handle di success/error block
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Merchandise'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Merchandise>(
        future: _merchandiseDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Merchandise tidak ditemukan.'));
          }

          final merchandise = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Merchandise
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: merchandise.gambarMerch.isNotEmpty
                        ? Image.network(
                            '${ApiClient.storageBaseUrl}/gambar_merch/${merchandise.gambarMerch}', 
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400])),
                          )
                        : Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400])),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  merchandise.namaMerch,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Poin yang dibutuhkan: ${merchandise.poin} Poin',
                  style: TextStyle(fontSize: 18, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Stok tersedia: ${merchandise.stok}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'Poin Anda saat ini: $_currentPoinPembeli Poin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Tombol Klaim Merchandise
                Center(
                  child: ElevatedButton(
                    onPressed: merchandise.stok > 0 && _currentPoinPembeli >= merchandise.poin
                        ? () => _claimMerchandise(merchandise) // Panggil _claimMerchandise dengan objek merchandise
                        : null, // Tombol nonaktif jika stok habis atau poin tidak cukup
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Klaim Merchandise'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}