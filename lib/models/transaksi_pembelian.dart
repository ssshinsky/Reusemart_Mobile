int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
double parseDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0.0;

class TransaksiPembelian {
  final int idPembelian;
  final String statusTransaksi;
  final double totalHarga;
  final String tanggalPembelian;
  final String metodePengiriman;
  final String noResi;
  final int idKurir;

  const TransaksiPembelian({
    required this.idPembelian,
    required this.statusTransaksi,
    required this.totalHarga,
    required this.tanggalPembelian,
    required this.metodePengiriman,
    required this.noResi,
    required this.idKurir,
  });

  factory TransaksiPembelian.fromJson(Map<String, dynamic> json) {
    return TransaksiPembelian(
      idPembelian: parseInt(json['id_pembelian']),
      statusTransaksi: json['status_transaksi']?.toString() ?? '',
      totalHarga: parseDouble(json['total_harga']),
      tanggalPembelian: json['tanggal_pembelian']?.toString() ?? '',
      metodePengiriman: json['metode_pengiriman']?.toString() ?? '',
      noResi: json['no_resi']?.toString() ?? '',
      idKurir: parseInt(json['id_kurir']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pembelian': idPembelian,
      'status_transaksi': statusTransaksi,
      'total_harga': totalHarga,
      'tanggal_pembelian': tanggalPembelian,
      'metode_pengiriman': metodePengiriman,
      'no_resi': noResi,
      'id_kurir': idKurir,
    };
  }
}