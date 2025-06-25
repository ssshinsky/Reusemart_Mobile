class Kategori {
  final int idKategori;
  final String namaKategori;

  Kategori({
    required this.idKategori,
    required this.namaKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      idKategori: json['id_kategori'],
      namaKategori: json['nama_kategori'],
    );
  }
}