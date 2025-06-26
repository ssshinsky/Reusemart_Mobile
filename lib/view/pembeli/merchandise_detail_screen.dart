import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/pembeli.dart'; // <<< Tambahkan import model Pembeli
import 'package:reusemart_mobile/services/api_client.dart'; 
import 'package:reusemart_mobile/models/merchandise.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 

class MerchandiseDetailScreen extends StatefulWidget {
  final int merchandiseId;
  final int pembeliId; 

  MerchandiseDetailScreen({
    super.key,
    required this.merchandiseId, 
    required this.pembeliId 
  });

  @override
  MerchandiseDetailScreenState createState() => MerchandiseDetailScreenState();
}

class MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<Merchandise> _merchandiseDetailFuture;
  late Future<Pembeli> _pembeliFuture; // <<< GANTI: Future untuk data pembeli
  Pembeli? _currentPembeli; // <<< GANTI: Untuk menyimpan data pembeli saat ini

  @override
  void initState() {
    super.initState();
    // Memuat data merchandise dan data pembeli secara bersamaan
    _loadData();
  }

  // Fungsi untuk memuat semua data yang diperlukan
  Future<void> _loadData() async {
    setState(() {
      _merchandiseDetailFuture = _apiClient.getMerchandiseById(widget.merchandiseId);
      _pembeliFuture = _apiClient.getPembeliById(widget.pembeliId);
    });
  }

  // Fungsi untuk klaim merchandise
  void _claimMerchandise(Merchandise merchandise) async {
    // Validasi sekarang lebih sederhana karena kita sudah punya data pembeli
    if (_currentPembeli == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pembeli tidak dapat dimuat. Coba lagi.')),
      );
      return;
    }

    if (_currentPembeli!.poin < merchandise.poin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poin Anda tidak cukup untuk mengklaim merchandise ini!')),
      );
      return;
    }
    
    if (merchandise.stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok merchandise ini habis.')),
      );
      return;
    }

    // Tampilkan loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memproses klaim...')),
    );

    try {
      // Gunakan widget.pembeliId yang sudah pasti benar
      final response = await _apiClient.claimMerchandise(merchandise.idMerchandise, widget.pembeliId);

      if (response['success']) {
        final newPoin = response['current_poin_pembeli'] as int;

        // Update poin pembeli di SharedPreferences (langkah ini tetap penting)
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('userData');
        if (userDataString != null) {
          final userData = Map<String, dynamic>.from(jsonDecode(userDataString));
          userData['poin'] = newPoin; // Key di JSON login mungkin 'poin' bukan 'poin_pembeli'
          await prefs.setString('userData', jsonEncode(userData));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Merchandise berhasil diklaim!')),
        );
        
        // Refresh semua data di halaman
        await _loadData();

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal mengklaim merchandise.')),
        );
         // Refresh data untuk mendapatkan info stok/poin terbaru jika gagal
        await _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Merchandise'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      // Gunakan FutureBuilder ganda untuk memuat merchandise dan pembeli
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_merchandiseDetailFuture, _pembeliFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error memuat data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.length < 2) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final merchandise = snapshot.data![0] as Merchandise;
          // Simpan data pembeli saat ini setelah berhasil dimuat
          _currentPembeli = snapshot.data![1] as Pembeli;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 20),
                Text(
                  merchandise.namaMerch,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Poin yang dibutuhkan: ${merchandise.poin} Poin',
                  style: const TextStyle(fontSize: 18, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stok tersedia: ${merchandise.stok}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  // Ambil poin dari objek _currentPembeli yang sudah dimuat
                  'Poin Anda saat ini: ${_currentPembeli?.poin ?? 0} Poin',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    // Logika pengecekan menjadi lebih andal
                    onPressed: _currentPembeli != null && merchandise.stok > 0 && _currentPembeli!.poin >= merchandise.poin
                        ? () => _claimMerchandise(merchandise)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Klaim Merchandise'),
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
