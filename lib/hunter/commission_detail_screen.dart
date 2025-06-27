import 'package:flutter/material.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/models/komisi_history.dart'; 

class CommissionDetailScreen extends StatefulWidget {
  final int hunterId;
  final int commissionId;

  CommissionDetailScreen({required this.hunterId, required this.commissionId});

  @override
  CommissionDetailScreenState createState() => CommissionDetailScreenState();
}

class CommissionDetailScreenState extends State<CommissionDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<KomisiHistory> _commissionDetailFuture;

  @override
  void initState() {
    super.initState();
    _commissionDetailFuture = _apiClient.getCommissionDetail(widget.hunterId, widget.commissionId);
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Komisi'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<KomisiHistory>(
        future: _commissionDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading detail: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Detail komisi tidak ditemukan.'));
          }

          final detail = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Barang
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: detail.gambarBarang != null
                        ? Image.network(
                            '${ApiClient.storageBaseUrl}/gambar/${detail.gambarBarang}', // Sesuaikan subfolder jika perlu
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[300], child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400])),
                          )
                        : Container(color: Colors.grey[300], child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400])),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  detail.namaBarang,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  _formatCurrency(detail.hargaBarang),
                  style: TextStyle(fontSize: 20, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 16),
                _buildInfoRow(Icons.monetization_on, 'Komisi Didapatkan', _formatCurrency(detail.komisiDidapatkan)),
                _buildInfoRow(Icons.person, 'Penitip', detail.namaPenitip),
                _buildInfoRow(Icons.date_range, 'Tanggal Penitipan', detail.tanggalPenitipan ?? 'N/A'),
                _buildInfoRow(Icons.shopping_cart, 'Tanggal Terjual', detail.tanggalPembelian ?? 'N/A',
                    trailing: Text(detail.statusBarangTerjual, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}