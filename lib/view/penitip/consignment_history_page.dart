import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/penitip.dart';
import 'package:reusemart_mobile/services/api_client.dart';

class ConsignmentHistoryPage extends StatefulWidget {
  final ApiClient apiClient;
  final int penitipId;

  const ConsignmentHistoryPage({
    super.key,
    required this.apiClient,
    required this.penitipId,
  });

  @override
  State<ConsignmentHistoryPage> createState() => _ConsignmentHistoryPageState();
}

class _ConsignmentHistoryPageState extends State<ConsignmentHistoryPage> {
  List<ConsignmentHistory>? _history;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history =
          await widget.apiClient.getConsignmentHistoryById(widget.penitipId);
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _parseError(e.toString());
        _isLoading = false;
      });
    }
  }

  String _parseError(String error) {
    if (error.contains('404')) {
      return 'Riwayat tidak ditemukan';
    } else if (error.contains('Failed to connect') ||
        error.contains('SocketException')) {
      return 'Gagal terhubung ke server. Cek koneksi internet Anda.';
    } else {
      return 'Terjadi kesalahan: $error';
    }
  }

  String _formatDate(String? date) {
    return date ?? 'Tidak diketahui';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Penitipan',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadHistory,
            tooltip: 'Muat ulang',
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Memuat riwayat...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadHistory,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  )
                : _history == null || _history!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history_toggle_off,
                              color: Colors.grey,
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada riwayat penitipan',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.teal,
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          itemCount: _history!.length,
                          itemBuilder: (context, index) {
                            final transaction = _history![index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.02),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: transaction.barang.isNotEmpty
                                    ? () =>
                                        _showItemDetails(context, transaction)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: transaction.status == 'Selesai'
                                              ? Colors.green
                                              : transaction.status ==
                                                      'Dalam Proses'
                                                  ? Colors.orange
                                                  : Colors.redAccent,
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                            left: Radius.circular(8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction
                                                      .barang[0].namaBarang ??
                                                  'Barang Tidak Diketahui',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tanggal Penitipan: ${_formatDate(transaction.tanggalPenitipan)}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.grey.shade600,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                            Text(
                                              'Tanggal Berakhir: ${_formatDate(transaction.barang[0].tanggalBerakhir)}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.grey.shade600,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                            Text(
                                              'Perpanjangan: ${transaction.barang[0].perpanjangan == 1 ? 'Ya' : 'Tidak'}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.grey.shade600,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (transaction.barang.isNotEmpty)
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.teal,
                                          size: screenWidth * 0.06,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, ConsignmentHistory transaction) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  transaction.barang[0].namaBarang ?? 'Barang Tidak Diketahui',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (transaction.barang[0].gambar != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      // transaction.barang[0].gambar!,
                      'http://10.0.2.2:8000/storage/gambar/${transaction.barang[0].gambar}',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.teal.shade50,
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.teal),
                      ),
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : Container(
                                  height: 200,
                                  color: Colors.teal.shade50,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.teal),
                                    ),
                                  ),
                                ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported,
                        size: 50, color: Colors.teal),
                  ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  'Harga',
                  'Rp ${transaction.barang[0].hargaBarang?.toStringAsFixed(2) ?? '0.00'}',
                  screenWidth,
                ),
                _buildInfoRow(
                  context,
                  'Status',
                  transaction.barang[0].status ?? 'Tidak diketahui',
                  screenWidth,
                ),
                _buildInfoRow(
                  context,
                  'Tanggal Penitipan',
                  _formatDate(transaction.tanggalPenitipan),
                  screenWidth,
                ),
                _buildInfoRow(
                  context,
                  'Tanggal Berakhir',
                  _formatDate(transaction.barang[0].tanggalBerakhir),
                  screenWidth,
                ),
                _buildInfoRow(
                  context,
                  'Perpanjangan',
                  transaction.barang[0].perpanjangan == 1 ? 'Ya' : 'Tidak',
                  screenWidth,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, double screenWidth) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.035,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
