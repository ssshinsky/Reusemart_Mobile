import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/penitip.dart';
import 'package:reusemart_mobile/services/api_client.dart';

class ConsignmentHistoryPage extends StatefulWidget {
  final ApiClient apiClient;

  const ConsignmentHistoryPage({super.key, required this.apiClient});

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
      final history = await widget.apiClient.getConsignmentHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penitipan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _history!.length,
                  itemBuilder: (context, index) {
                    final transaction = _history![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Transaksi #${transaction.idTransaksi}'),
                        subtitle: Text('Tanggal: ${transaction.tanggalPenitipan}\nStatus: ${transaction.status}'),
                        onTap: () {
                          // Detail bisa ditambah di sini
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(transaction.barang[0].namaBarang),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (transaction.barang[0].gambar != null)
                                    Image.network(transaction.barang[0].gambar!),
                                  Text('Harga: Rp ${transaction.barang[0].hargaBarang.toStringAsFixed(2)}'),
                                  Text('Status: ${transaction.barang[0].statusBarang}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
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