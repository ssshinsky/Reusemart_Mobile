class KomisiHistory {
  final int idKomisi;
  final double komisiDidapatkan;
  final String? tanggalPenitipan;
  final String? tanggalPembelian; // Tanggal terjual
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
      idKomisi: json['id_komisi'],
      komisiDidapatkan: (json['komisi_didapatkan'] as num).toDouble(),
      tanggalPenitipan: json['tanggal_penitipan'],
      tanggalPembelian: json['tanggal_pembelian'],
      namaBarang: json['nama_barang'],
      hargaBarang: (json['harga_barang'] as num).toDouble(),
      gambarBarang: json['gambar_barang'],
      namaPenitip: json['nama_penitip'],
      statusBarangTerjual: json['status_barang_terjual'],
    );
  }
}