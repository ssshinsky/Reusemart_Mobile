import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/models/transaksi_pembelian.dart';

class DeliveryHistory extends StatefulWidget {
  const DeliveryHistory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DeliveryHistoryState createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  final ApiClient apiClient = ApiClient();
  Future<List<TransaksiPembelian>>? _transaksiFuture;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _transaksiFuture =
        apiClient.getTransaksiKurir(perPage: 10, page: _currentPage);
  }

  void _loadMore() {
    setState(() {
      _currentPage++;
      _transaksiFuture =
          apiClient.getTransaksiKurir(perPage: 10, page: _currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pengiriman',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 6,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<TransaksiPembelian>>(
              future: _transaksiFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada riwayat pengiriman'));
                }

                final transaksiList = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: transaksiList.length,
                  itemBuilder: (context, index) {
                    final transaksi = transaksiList[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesanan #${transaksi.noResi}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${transaksi.statusTransaksi}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Total Harga: Rp ${transaksi.totalHarga}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Tanggal: ${transaksi.tanggalPembelian}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_transaksiFuture != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _loadMore,
                child: Text(
                  'Muat Lebih Banyak',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
