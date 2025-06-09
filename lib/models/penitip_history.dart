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
    var barangList = json['barang'] as List;
    return PenitipHistory(
      idTransaksi: json['id_transaksi'],
      tanggalPenitipan: json['tanggal_penitipan'],
      barang: barangList.map((i) => BarangHistory.fromJson(i)).toList(),
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
      idBarang: json['id_barang'],
      namaBarang: json['nama_barang'],
      statusBarang: json['status_barang'],
      hargaBarang: (json['harga_barang'] as num).toDouble(),
      gambar: json['gambar'],
    );
  }
}