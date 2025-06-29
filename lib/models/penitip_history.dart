int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
double parseDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0.0;

class PenitipHistory {
  final int idTransaksi;
  final String tanggalPenitipan;
  final List<BarangHistory> barang;

  PenitipHistory({
    required this.idTransaksi,
    required this.tanggalPenitipan,
    required this.barang,
  });

  factory PenitipHistory.fromJson(Map<String, dynamic> json) {
    return PenitipHistory(
      idTransaksi: parseInt(json['id_transaksi']),
      tanggalPenitipan: json['tanggal_penitipan']?.toString() ?? '',
      barang: (json['barang'] as List? ?? [])
          .map((i) => BarangHistory.fromJson(i))
          .toList(),
    );
  }
}

class BarangHistory {
  final int idBarang;
  final String namaBarang;
  final String statusBarang;
  final double hargaBarang;
  final String? gambar;

  BarangHistory({
    required this.idBarang,
    required this.namaBarang,
    required this.statusBarang,
    required this.hargaBarang,
    this.gambar,
  });

  factory BarangHistory.fromJson(Map<String, dynamic> json) {
    return BarangHistory(
      idBarang: parseInt(json['id_barang']),
      namaBarang: json['nama_barang']?.toString() ?? '',
      statusBarang: json['status_barang']?.toString() ?? '',
      hargaBarang: parseDouble(json['harga_barang']),
      gambar: json['gambar']?.toString(),
    );
  }
}