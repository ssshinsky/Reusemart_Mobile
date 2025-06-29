int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
double parseDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0.0;

class KomisiHistory {
  final int idKomisi;
  final double komisiDidapatkan;
  final String? tanggalPenitipan;
  final String? tanggalPembelian;
  final String namaBarang;
  final double hargaBarang;
  final String? gambarBarang;
  final String namaPenitip;
  final String statusBarangTerjual;

  KomisiHistory({
    required this.idKomisi,
    required this.komisiDidapatkan,
    this.tanggalPenitipan,
    this.tanggalPembelian,
    required this.namaBarang,
    required this.hargaBarang,
    this.gambarBarang,
    required this.namaPenitip,
    required this.statusBarangTerjual,
  });

  factory KomisiHistory.fromJson(Map<String, dynamic> json) {
    return KomisiHistory(
      idKomisi: parseInt(json['id_komisi']),
      komisiDidapatkan: parseDouble(json['komisi_didapatkan']),
      tanggalPenitipan: json['tanggal_penitipan']?.toString(),
      tanggalPembelian: json['tanggal_pembelian']?.toString(),
      namaBarang: json['nama_barang'] ?? '',
      hargaBarang: parseDouble(json['harga_barang']),
      gambarBarang: json['gambar_barang']?.toString(),
      namaPenitip: json['nama_penitip'] ?? '',
      statusBarangTerjual: json['status_barang_terjual'] ?? '',
    );
  }
}