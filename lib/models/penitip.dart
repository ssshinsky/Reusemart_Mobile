// Utility functions for safe parsing
int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
double parseDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0.0;

/// Data model for Penitipp (Consignor)
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
      idPenitip: parseInt(json['id_penitip']),
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      saldo: parseDouble(json['saldo']),
      poin: parseInt(json['poin']),
      rataRating: parseDouble(json['rata_rating']),
      banyakRating: parseInt(json['banyak_rating']),
      profilPict: json['profil_pict']?.toString(),
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
      profilPict: profilPict ?? this.profilPict,
    );
  }
}

/// Data model for ConsignmentHistory
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
      idTransaksi: parseInt(json['id_transaksi']),
      tanggalPenitipan: json['tanggal_penitipan']?.toString(),
      status: json['status']?.toString(),
      barang: (json['barang'] as List<dynamic>? ?? [])
          .map((item) => Barangg.fromJson(item))
          .toList(),
    );
  }
}

/// Data model for Barangg (Consigned Item)
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
      namaBarang: json['nama_barang']?.toString(),
      hargaBarang: json['harga_barang'] != null ? parseDouble(json['harga_barang']) : null,
      status: json['status_barang']?.toString(),
      gambar: json['gambar']?.toString(),
      tanggalBerakhir: json['tanggal_berakhir']?.toString(),
      perpanjangan: json['perpanjangan'] != null ? parseInt(json['perpanjangan']) : null,
    );
  }
}