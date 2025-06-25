class Penitipp {
  final int idPenitip;
  final String nama;
  final String email;
  final double saldo;
  final int poin;
  final double rataRating;
  final int banyakRating;
  final String? profilPict;

  Penitipp({
    required this.idPenitip,
    required this.nama,
    required this.email,
    required this.saldo,
    required this.poin,
    required this.rataRating,
    required this.banyakRating,
    this.profilPict,
  });

  factory Penitipp.fromJson(Map<String, dynamic> json) {
    return Penitipp(
      idPenitip: json['id_penitip'] as int,
      nama: json['nama'] as String,
      email: json['email'] as String,
      saldo: (json['saldo'] as num).toDouble(),
      poin: json['poin'] as int,
      rataRating: (json['rata_rating'] as num).toDouble(),
      banyakRating: json['banyak_rating'] as int,
      profilPict: json['profil_pict'] as String?,
    );
  }

  Penitipp copyWith({String? profilPict}) {
    return Penitipp(
      idPenitip: idPenitip,
      nama: nama,
      email: email,
      saldo: saldo,
      poin: poin,
      rataRating: rataRating,
      banyakRating: banyakRating,
      profilPict: profilPict,
    );
  }
}

class ConsignmentHistory {
  final int idTransaksi;
  final String? tanggalPenitipan;
  final String? status;
  final List<Barangg> barang;

  const ConsignmentHistory({
    required this.idTransaksi,
    this.tanggalPenitipan,
    this.status,
    required this.barang,
  });

  factory ConsignmentHistory.fromJson(Map<String, dynamic> json) {
    return ConsignmentHistory(
      idTransaksi: json['id_transaksi'] as int,
      tanggalPenitipan: json['tanggal_penitipan'] as String?,
      status: json['status'] as String?,
      barang: (json['barang'] as List<dynamic>?)
          ?.map((item) => Barangg.fromJson(item))
          .toList() ?? [],
    );
  }
}

class Barangg {
  final String? namaBarang;
  final double? hargaBarang;
  final String? status;
  final String? gambar;
  final String? tanggalBerakhir;
  final int? perpanjangan;

  const Barangg({
    this.namaBarang,
    this.hargaBarang,
    this.status,
    this.gambar,
    this.tanggalBerakhir,
    this.perpanjangan,
  });

  factory Barangg.fromJson(Map<String, dynamic> json) {
    return Barangg(
      namaBarang: json['nama_barang'] as String?,
      hargaBarang: (json['harga_barang'] as num?)?.toDouble(),
      status: json['status_barang'] as String?,
      gambar: json['gambar'] as String?,
      tanggalBerakhir: json['tanggal_berakhir'] as String?,
      perpanjangan: json['perpanjangan'] as int?,
    );
  }
}