class TransaksiPembelian {
  final int idPembelian;
  final String statusTransaksi;
  final double totalHarga;
  final String tanggalPembelian;
  final String metodePengiriman;
  final String noResi;

  const TransaksiPembelian({
    required this.idPembelian,
    required this.statusTransaksi,
    required this.totalHarga,
    required this.tanggalPembelian,
    required this.metodePengiriman,
    required this.noResi,
  });

  factory TransaksiPembelian.fromJson(Map<String, dynamic> json) {
    return TransaksiPembelian(
      idPembelian: _toInt(json['id_pembelian']),
      statusTransaksi: json['status_transaksi']?.toString() ?? '',
      totalHarga: (json['total_harga'] is int)
          ? (json['total_harga'] as int).toDouble()
          : double.parse(json['total_harga'].toString()),
      tanggalPembelian: json['tanggal_pembelian']?.toString() ?? '',
      metodePengiriman: json['metode_pengiriman']?.toString() ?? '',
      noResi: json['no_resi']?.toString() ?? '',
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
    };
  }

  // Helper untuk memastikan parsing int yang aman
  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
