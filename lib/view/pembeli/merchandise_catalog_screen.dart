import 'package:flutter/material.dart';
import 'package:reusemart_mobile/services/api_client.dart'; 
import 'package:reusemart_mobile/models/merchandise.dart'; 
import 'package:reusemart_mobile/view/pembeli/merchandise_detail_screen.dart'; 

class MerchandiseCatalogScreen extends StatefulWidget {
  final int pembeliId; 
  const MerchandiseCatalogScreen({super.key, required this.pembeliId}); 

  @override
  MerchandiseCatalogScreenState createState() => MerchandiseCatalogScreenState();
}

class MerchandiseCatalogScreenState extends State<MerchandiseCatalogScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<Merchandise>> _merchandiseFuture;

  @override
  void initState() {
    super.initState();
    _merchandiseFuture = _apiClient.getMerchandiseCatalog();
  }

  String _formatPoin(int poin) {
    return '$poin Poin';
  }

  // Fungsi untuk refresh data saat pull-to-refresh
  Future<void> _refreshCatalog() async {
    setState(() {
      _merchandiseFuture = _apiClient.getMerchandiseCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katalog Merchandise'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Merchandise>>(
        future: _merchandiseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading merchandise: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada merchandise tersedia.'));
          }

          final merchandiseList = snapshot.data!;
          // Tambahkan RefreshIndicator untuk pull-to-refresh
          return RefreshIndicator(
            onRefresh: _refreshCatalog,
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              itemCount: merchandiseList.length,
              itemBuilder: (context, index) {
                final merch = merchandiseList[index];
                // ===============================================
                // >>>>>> KESALAHAN ADA DI SINI <<<<<<
                // Tambahkan 'return' untuk mengembalikan widget
                return GestureDetector(
                // ===============================================
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MerchandiseDetailScreen(
                          merchandiseId: merch.idMerchandise,
                          pembeliId: widget.pembeliId,
                        ),
                      ),
                    ).then((value) {
                      // Refresh katalog saat kembali dari detail
                      _refreshCatalog();
                    });
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: merch.gambarMerch.isNotEmpty
                                ? Image.network(
                                    '${ApiClient.storageBaseUrl}/gambar_merch/${merch.gambarMerch}', 
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400])),
                                  )
                                : Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400])),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merch.namaMerch,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatPoin(merch.poin),
                                style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
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