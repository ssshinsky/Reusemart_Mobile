import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/pembeli.dart';

class PurchaseDetailPage extends StatelessWidget {
  final PurchaseHistory history;

  const PurchaseDetailPage({super.key, required this.history});

  // Format tanggal ke DD-MM-YYYY
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return 'Unknown';
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Format currency ke Rp
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  // Widget untuk timeline status
  Widget _buildStatusTimeline(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    final status = history.statusTransaksi?.toLowerCase() ?? 'unknown';
    final statuses = [
      {'label': 'Dipesan', 'completed': true},
      {
        'label': 'Dikemas',
        'completed': ['dikemas', 'dikirim', 'selesai'].contains(status)
      },
      {
        'label': 'Dikirim',
        'completed': ['dikirim', 'selesai'].contains(status)
      },
      {'label': 'Selesai', 'completed': status == 'selesai'},
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Pesanan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: List.generate(statuses.length * 2 - 1, (index) {
                    if (index.isEven) {
                      final statusIndex = index ~/ 2;
                      return CircleAvatar(
                        radius: screenWidth * 0.03,
                        backgroundColor: statuses[statusIndex]['completed'] as bool
                            ? Colors.teal
                            : Colors.grey[300],
                        child: Icon(
                          Icons.check,
                          size: screenWidth * 0.03,
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return Container(
                        width: 2,
                        height: screenWidth * 0.06,
                        color: statuses[(index + 1) ~/ 2]['completed'] as bool
                            ? Colors.teal
                            : Colors.grey[300],
                      );
                    }
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: statuses.asMap().entries.map((entry) {
                      final status = entry.value;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
                        child: Text(
                          status['label'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: screenWidth * 0.035,
                            color: status['completed'] as bool
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: status['completed'] as bool
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk detail transaksi
  Widget _buildTransactionInfo(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Transaksi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              screenWidth,
              'ID Transaksi',
              '#${history.idPembelian}',
            ),
            _buildInfoRow(
              context,
              screenWidth,
              'Tanggal Pembelian',
              _formatDate(history.tanggalTransaksi),
            ),
            _buildInfoRow(
              context,
              screenWidth,
              'Metode Pengiriman',
              history.metodePengiriman ?? 'Unknown',
            ),
            _buildInfoRow(
              context,
              screenWidth,
              'Alamat Pengiriman',
              'Belum tersedia', // Placeholder, tambah kalo ada di API
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk detail pembayaran
  Widget _buildPaymentInfo(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    final subtotal = history.totalHarga - history.ongkir;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pembayaran',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              screenWidth,
              'Subtotal',
              _formatCurrency(subtotal),
            ),
            _buildInfoRow(
              context,
              screenWidth,
              'Ongkos Kirim',
              _formatCurrency(history.ongkir),
            ),
            Divider(height: 20, thickness: 1, color: Colors.grey[300]),
            _buildInfoRow(
              context,
              screenWidth,
              'Total',
              _formatCurrency(history.totalHarga),
              isBold: true,
              valueColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk list item
  Widget _buildItemsList(BuildContext context, double screenWidth) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk Dibeli',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...history.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.gambar != null
                            ? Image.network(
                                item.gambar!,
                                width: screenWidth * 0.2,
                                height: screenWidth * 0.2,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.broken_image,
                                  size: screenWidth * 0.2,
                                  color: Colors.grey[400],
                                ),
                              )
                            : Icon(
                                Icons.image_not_supported,
                                size: screenWidth * 0.2,
                                color: Colors.grey[400],
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaBarang ?? 'Unknown',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(item.hargaBarang),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: screenWidth * 0.035,
                                color: Colors.teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Jumlah: 1', // Placeholder, tambah kalo ada quantity di API
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (item.rating != null)
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < item.rating!
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: screenWidth * 0.04,
                                    color: Colors.yellow[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Widget untuk baris info
  Widget _buildInfoRow(
    BuildContext context,
    double screenWidth,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: screenWidth * 0.035,
              color: valueColor ?? Colors.black87,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Transaksi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: screenWidth * 0.045,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusTimeline(context, screenWidth),
              const SizedBox(height: 16),
              _buildTransactionInfo(context, screenWidth),
              const SizedBox(height: 16),
              _buildPaymentInfo(context, screenWidth),
              const SizedBox(height: 16),
              _buildItemsList(context, screenWidth),
              const SizedBox(height: 16),
              Center(
                // child: ElevatedButton(
                //   onPressed: () {
                //     // Placeholder untuk aksi, misal lacak pengiriman
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('Fitur lacak pengiriman belum tersedia'),
                //       ),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.teal,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 24, vertical: 12),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     elevation: 5,
                //   ),
                //   child: Text(
                //     'Lacak Pengiriman',
                //     style: theme.textTheme.bodyMedium?.copyWith(
                //       color: Colors.white,
                //       fontSize: screenWidth * 0.04,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}