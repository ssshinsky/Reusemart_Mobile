/// Utility functions for safer parsing
int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
double parseDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0.0;

/// Data model for Pembeli (Buyer)
class Pembeli {
  final int idPembeli;
  final String nama;
  final String email;
  final String nomorTelepon;
  final String? tanggalLahir;
  final int poin;
  final String? status;
  final String? profilPict;

  Pembeli({
    required this.idPembeli,
    required this.nama,
    required this.email,
    required this.nomorTelepon,
    this.tanggalLahir,
    required this.poin,
    this.status,
    this.profilPict,
  });

  factory Pembeli.fromJson(Map<String, dynamic> json) {
    return Pembeli(
      idPembeli: parseInt(json['id_pembeli']),
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nomorTelepon: json['nomor_telepon']?.toString() ?? '',
      tanggalLahir: json['tanggal_lahir']?.toString(),
      poin: parseInt(json['poin']),
      status: json['status']?.toString(),
      profilPict: json['profil_pict']?.toString(),
    );
  }
}

/// Data model for PurchaseHistory
class PurchaseHistory {
  final int idPembelian;
  final String? tanggalTransaksi;
  final double totalHarga;
  final double ongkir;
  final String? metodePengiriman;
  final String? statusTransaksi;
  final List<PurchaseItem> items;

  PurchaseHistory({
    required this.idPembelian,
    this.tanggalTransaksi,
    required this.totalHarga,
    required this.ongkir,
    this.metodePengiriman,
    this.statusTransaksi,
    required this.items,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      idPembelian: parseInt(json['id_pembelian']),
      tanggalTransaksi: json['tanggal_transaksi']?.toString(),
      totalHarga: parseDouble(json['total_harga']),
      ongkir: parseDouble(json['ongkir']),
      metodePengiriman: json['metode_pengiriman']?.toString(),
      statusTransaksi: json['status_transaksi']?.toString(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => PurchaseItem.fromJson(item))
          .toList(),
    );
  }
}

/// Data model for PurchaseItem
class PurchaseItem {
  final String? namaBarang;
  final double hargaBarang;
  final int? rating;
  final String? gambar;

  PurchaseItem({
    this.namaBarang,
    required this.hargaBarang,
    this.rating,
    this.gambar,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      namaBarang: json['nama_barang']?.toString(),
      hargaBarang: parseDouble(json['harga_barang']),
      rating: json['rating'] != null ? parseInt(json['rating']) : null,
      gambar: json['gambar']?.toString(),
    );
  }
}