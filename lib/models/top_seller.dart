class TopSeller {
  final int idPenitip;
  final String namaPenitip;
  final String? profilPict;
  final int jumlahBarang;
  final double totalPenjualan;
  final String bulan;

  TopSeller({
    required this.idPenitip,
    required this.namaPenitip,
    this.profilPict,
    required this.jumlahBarang,
    required this.totalPenjualan,
    required this.bulan,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) {
    return TopSeller(
      idPenitip: json['id_penitip'],
      namaPenitip: json['nama_penitip'],
      profilPict: json['profil_pict'],
      jumlahBarang: json['jumlah_barang'],
      totalPenjualan: double.parse(json['total_penjualan'].toString()),
      bulan: json['bulan'],
    );
  }
}
