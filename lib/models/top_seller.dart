class TopSeller {
  final int idPenitip;
  final String namaPenitip;
  final String? profilPict;
  final int soldCount;
  final double totalSales;

  TopSeller({
    required this.idPenitip,
    required this.namaPenitip,
    this.profilPict,
    required this.soldCount,
    required this.totalSales,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) {
    return TopSeller(
      idPenitip: json['id_penitip'],
      namaPenitip: json['nama_penitip'],
      profilPict: json['profil_pict'],
      soldCount: json['sold_count'],
      totalSales: json['total_sales'].toDouble(),
    );
  }
}