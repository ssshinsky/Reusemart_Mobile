import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/merchandise.dart';
import 'package:reusemart_mobile/models/pembeli.dart'; // Impor model Pembeli
import 'package:reusemart_mobile/services/api_client.dart';

class MerchandiseDetailScreen extends StatefulWidget {
  final int merchandiseId;
  final int pembeliId; // Parameter untuk ID pembeli yang sedang login

  const MerchandiseDetailScreen({
    super.key,
    required this.merchandiseId,
    required this.pembeliId, // Wajib diisi saat navigasi ke halaman ini
  });

  @override
  MerchandiseDetailScreenState createState() => MerchandiseDetailScreenState();
}

class MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<dynamic>> _dataFuture; // Future untuk menampung kedua data

  @override
  void initState() {
    super.initState();
    // Inisialisasi pengambilan data dari API
    _dataFuture = _fetchData();
  }
  
  // Fungsi untuk mengambil/refresh data dari API
  Future<List<dynamic>> _fetchData() {
    // Gunakan Future.wait untuk menjalankan kedua API call secara bersamaan
    return Future.wait([
      _apiClient.getMerchandiseById(widget.merchandiseId),
      _apiClient.getPembeliById(widget.pembeliId),
    ]);
  }

  // Fungsi untuk klaim merchandise
  void _claimMerchandise(Merchandise merchandise, int currentPoin) async {
    if (currentPoin < merchandise.poin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poin Anda tidak cukup untuk mengklaim!')),
      );
      return;
    }
    if (merchandise.stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maaf, stok merchandise ini telah habis.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memproses klaim...')),
    );

    try {
      final response = await _apiClient.claimMerchandise(
          merchandise.idMerchandise, widget.pembeliId);

      if (mounted && response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'Merchandise berhasil diklaim!')),
        );
        // Refresh data dengan memanggil ulang _fetchData
        setState(() {
          _dataFuture = _fetchData();
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  response['message'] ?? 'Gagal mengklaim merchandise.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
      print('Claim error: $e');
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
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.length < 2) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final merchandise = snapshot.data![0] as Merchandise;
          final pembeli = snapshot.data![1] as Pembeli;
          final currentPoinPembeli = pembeli.poin;

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
                  'Poin Anda saat ini: $currentPoinPembeli Poin',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: merchandise.stok > 0 && currentPoinPembeli >= merchandise.poin
                        ? () => _claimMerchandise(merchandise, currentPoinPembeli)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(merchandise.stok > 0 ? (currentPoinPembeli >= merchandise.poin ? 'Klaim Merchandise' : 'Poin Tidak Cukup') : 'Stok Habis'),
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
