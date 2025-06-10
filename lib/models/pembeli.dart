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
      idPembeli: json['id_pembeli'] as int,
      nama: json['nama'] as String,
      email: json['email'] as String,
      nomorTelepon: json['nomor_telepon'] as String,
      tanggalLahir: json['tanggal_lahir'] as String?,
      poin: json['poin'] as int,
      status: json['status'] as String?,
      profilPict: json['profil_pict'] as String?,
    );
  }
}

class PurchaseHistory {
  final int idPembelian;
  final String? tanggalTransaksi;
  final double totalHarga;
  final String? metodePengiriman;
  final String? statusTransaksi;
  final List<PurchaseItem> items;

  PurchaseHistory({
    required this.idPembelian,
    this.tanggalTransaksi,
    required this.totalHarga,
    this.metodePengiriman,
    this.statusTransaksi,
    required this.items,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      idPembelian: json['id_pembelian'] as int,
      tanggalTransaksi: json['tanggal_transaksi'] as String?,
      totalHarga: (json['total_harga'] as num).toDouble(),
      metodePengiriman: json['metode_pengiriman'] as String?,
      statusTransaksi: json['status_transaksi'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => PurchaseItem.fromJson(item))
          .toList(),
    );
  }
}

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
      namaBarang: json['nama_barang'] as String?,
      hargaBarang: (json['harga_barang'] as num).toDouble(),
      rating: json['rating'] as int?,
      gambar: json['gambar'] as String?,
    );
  }
}