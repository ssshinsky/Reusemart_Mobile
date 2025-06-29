int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

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
      idMerchandise: parseInt(json['id_merchandise']),
      idPegawai: parseInt(json['id_pegawai']),
      namaMerch: json['nama_merch'] ?? '',
      poin: parseInt(json['poin']),
      stok: parseInt(json['stok']),
      gambarMerch: json['gambar_merch'] ?? '',
    );
  }
}