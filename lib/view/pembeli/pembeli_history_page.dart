import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/pembeli.dart';
import 'package:reusemart_mobile/services/api_client.dart';

class PembeliHistoryPage extends StatefulWidget {
  final ApiClient apiClient;
  final int pembeliId;

  const PembeliHistoryPage({
    super.key,
    required this.apiClient,
    required this.pembeliId,
  });

  @override
  State<PembeliHistoryPage> createState() => _PembeliHistoryPageState();
}

class _PembeliHistoryPageState extends State<PembeliHistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Fungsi untuk format DateTime jadi dd-MM-yyyy
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Parsing tanggal dari yyyy-MM-dd
  DateTime? _parseApiDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return null;
      return DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = _formatDate(_startDate!);
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(_endDate!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pembelian',
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Mulai',
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Selesai',
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<PurchaseHistory>>(
                future:
                    widget.apiClient.getPurchaseHistoryById(widget.pembeliId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Gagal memuat riwayat: ${snapshot.error}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.redAccent,
                              fontSize: screenWidth * 0.04,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada riwayat pembelian',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    );
                  }

                  final historyList = snapshot.data!.where((history) {
                    if (_startDate == null && _endDate == null) return true;
                    final transDate =
                        _parseApiDate(history?.tanggalTransaksi ?? '');
                    if (transDate == null) return false;
                    bool afterStart = _startDate == null ||
                        transDate.isAfter(
                            _startDate!.subtract(const Duration(days: 1)));
                    bool beforeEnd = _endDate == null ||
                        transDate
                            .isBefore(_endDate!.add(const Duration(days: 1)));
                    return afterStart && beforeEnd;
                  }).toList();

                  if (historyList.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada transaksi pada periode ini',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final history = historyList[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transaksi #${history.idPembelian}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          history.statusTransaksi == 'selesai'
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      history.statusTransaksi ?? 'Unknown',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontSize: screenWidth * 0.03,
                                        color:
                                            history.statusTransaksi == 'selesai'
                                                ? Colors.green
                                                : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tanggal: ${history.tanggalTransaksi ?? 'Unknown'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Total: Rp ${history.totalHarga.toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Pengiriman: ${history.metodePengiriman ?? 'Unknown'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Item:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...history.items.map((item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: item.gambar != null
                                              ? Image.network(
                                                  item.gambar!,
                                                  width: screenWidth * 0.15,
                                                  height: screenWidth * 0.15,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Icon(
                                                    Icons.broken_image,
                                                    size: screenWidth * 0.15,
                                                    color: Colors.grey[400],
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.image_not_supported,
                                                  size: screenWidth * 0.15,
                                                  color: Colors.grey[400],
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.namaBarang ?? 'Unknown',
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontSize: screenWidth * 0.035,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'Rp ${item.hargaBarang.toStringAsFixed(0)}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontSize: screenWidth * 0.03,
                                                  color: Colors.teal,
                                                  fontWeight: FontWeight.w600,
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
