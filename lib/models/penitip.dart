class Penitipp {
  final int id;
  final String nama;
  final String email;
  final double saldo;
  final int poin;
  final String? profilPict;
  final double rataRating;
  final int banyakRating;

  Penitipp({
    required this.id,
    required this.nama,
    required this.email,
    required this.saldo,
    required this.poin,
    this.profilPict,
    required this.rataRating,
    required this.banyakRating,
  });

  factory Penitipp.fromJson(Map<String, dynamic> json) {
    return Penitipp(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      saldo: (json['saldo'] as num).toDouble(),
      poin: json['poin'],
      profilPict: json['profil_pict'],
      rataRating: (json['rata_rating'] as num).toDouble(),
      banyakRating: json['banyak_rating'],
    );
  }
}

class ConsignmentHistory {
  final int idTransaksi;
  final String tanggalPenitipan;
  final String status;
  final List<BarangHistory> barang;

  ConsignmentHistory({
    required this.idTransaksi,
    required this.tanggalPenitipan,
    required this.status,
    required this.barang,
  });

  factory ConsignmentHistory.fromJson(Map<String, dynamic> json) {
    return ConsignmentHistory(
      idTransaksi: json['id_transaksi'],
      tanggalPenitipan: json['tanggal_penitipan'],
      status: json['status'],
      barang: (json['barang'] as List)
          .map((item) => BarangHistory.fromJson(item))
          .toList(),
    );
  }
}

class BarangHistory {
  final int idBarang;
  final String namaBarang;
  final double hargaBarang;
  final String statusBarang;
  final String? gambar;

  BarangHistory({
    required this.idBarang,
    required this.namaBarang,
    required this.hargaBarang,
    required this.statusBarang,
    this.gambar,
  });

  factory BarangHistory.fromJson(Map<String, dynamic> json) {
    return BarangHistory(
      idBarang: json['id_barang'],
      namaBarang: json['nama_barang'],
      hargaBarang: (json['harga_barang'] as num).toDouble(),
      statusBarang: json['status_barang'],
      gambar: json['gambar'],
    );
  }
}