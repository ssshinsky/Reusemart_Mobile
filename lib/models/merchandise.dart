class Merchandise {
  final int idMerchandise;
  final int idPegawai;
  final String namaMerch;
  final int poin;
  final int stok;
  final String gambarMerch;

  Merchandise({
    required this.idMerchandise,
    required this.idPegawai,
    required this.namaMerch,
    required this.poin,
    required this.stok,
    required this.gambarMerch,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      idMerchandise: json['id_merchandise'],
      idPegawai: json['id_pegawai'],
      namaMerch: json['nama_merch'],
      poin: json['poin'],
      stok: json['stok'],
      gambarMerch: json['gambar_merch'],
    );
  }
}