class Kategori {
  final int idKategori;
  final String namaKategori;

  Kategori({
    required this.idKategori,
    required this.namaKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      idKategori: int.parse((json['id_kategori'].toString())),
      namaKategori: json['nama_kategori'],
    );
  }
}