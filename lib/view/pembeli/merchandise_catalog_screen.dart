import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/models/merchandise.dart';
import 'package:reusemart_mobile/view/pembeli/merchandise_detail_screen.dart';

class MerchandiseCatalogScreen extends StatefulWidget {
  const MerchandiseCatalogScreen({super.key});

  @override
  MerchandiseCatalogScreenState createState() => MerchandiseCatalogScreenState();
}

class MerchandiseCatalogScreenState extends State<MerchandiseCatalogScreen> {
  final ApiClient _apiClient = ApiClient();
  // Mengubah future untuk menangani status inisialisasi
  late Future<void> _initFuture; 
  int? _pembeliId;
  List<Merchandise> _merchandiseList = [];

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi inisialisasi yang akan menangani pemuatan data
    _initFuture = _initialize();
  }
  
  // Fungsi inisialisasi untuk memuat ID pengguna dan katalog
  Future<void> _initialize() async {
    try {
      // 1. Ambil ID Pengguna dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        // PERBAIKAN: Menggunakan kunci 'id_pembeli' yang benar
        _pembeliId = (userData['id_pembeli'] as num?)?.toInt(); 
      }

      // 2. Jika ID pengguna ada, ambil data katalog
      if (_pembeliId != null) {
        _merchandiseList = await _apiClient.getMerchandiseCatalog();
      } else {
        // Lemparkan error jika ID pengguna tidak ditemukan setelah login
        throw Exception('ID Pengguna tidak ditemukan. Silakan login ulang.');
      }
    } catch (e) {
      // Meneruskan error agar bisa ditangani oleh FutureBuilder
      throw Exception('Gagal memuat data: $e');
    }
  }
  
  // Fungsi untuk refresh data
  Future<void> _refreshData() async {
    setState(() {
      _initFuture = _initialize();
    });
  }


  // Fungsi untuk navigasi ke halaman detail
  void _navigateToDetail(Merchandise merch) {
    // Pada titik ini, _pembeliId sudah pasti tidak null karena UI sudah lolos pengecekan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchandiseDetailScreen(
          merchandiseId: merch.idMerchandise,
          pembeliId: _pembeliId!,
        ),
      ),
    ).then((_) {
      // Refresh data saat kembali untuk memperbarui stok
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Merchandise'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          // Tampilkan loading indicator selama proses inisialisasi berjalan
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Tampilkan pesan error jika inisialisasi gagal
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat data. Mohon coba lagi.\nError: ${snapshot.error}'),
              ),
            );
          }
          
          // Tampilkan pesan jika tidak ada merchandise setelah loading selesai
          if (_merchandiseList.isEmpty) {
            return const Center(child: Text('Tidak ada merchandise tersedia saat ini.'));
          }

          // Jika semua data siap, tampilkan GridView
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _merchandiseList.length,
              itemBuilder: (context, index) {
                final merch = _merchandiseList[index];
                return GestureDetector(
                  onTap: () => _navigateToDetail(merch),
                  child: Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: merch.gambarMerch.isNotEmpty
                              ? Image.network(
                                  '${ApiClient.storageBaseUrl}/gambar_merch/${merch.gambarMerch}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400])),
                                )
                              : Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merch.namaMerch,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${merch.poin} Poin',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stok: ${merch.stok}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
