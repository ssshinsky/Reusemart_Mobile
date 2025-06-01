class Barang {
  final int idBarang;
  final int idKategori;
  final int idTransaksiPenitipan;
  final String kodeBarang;
  final String namaBarang;
  final double hargaBarang;
  final double beratBarang;
  final String deskripsiBarang;
  final String statusGaransi;
  final String statusBarang;
  final DateTime? tanggalGaransi;
  final DateTime? tanggalBerakhir;
  final int perpanjangan;
  final List<Gambar> gambar;
  final TransaksiPenitipan transaksiPenitipan;

  Barang({
    required this.idBarang,
    required this.idKategori,
    required this.idTransaksiPenitipan,
    required this.kodeBarang,
    required this.namaBarang,
    required this.hargaBarang,
    required this.beratBarang,
    required this.deskripsiBarang,
    required this.statusGaransi,
    required this.statusBarang,
    this.tanggalGaransi,
    this.tanggalBerakhir,
    required this.perpanjangan,
    required this.gambar,
    required this.transaksiPenitipan,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      idBarang: json['id_barang'],
      idKategori: json['id_kategori'],
      idTransaksiPenitipan: json['id_transaksi_penitipan'],
      kodeBarang: json['kode_barang'],
      namaBarang: json['nama_barang'],
      hargaBarang: (json['harga_barang'] as num).toDouble(),
      beratBarang: (json['berat_barang'] as num).toDouble(),
      deskripsiBarang: json['deskripsi_barang'],
      statusGaransi: json['status_garansi'],
      statusBarang: json['status_barang'],
      tanggalGaransi: json['tanggal_garansi'] != null ? DateTime.parse(json['tanggal_garansi']) : null,
      tanggalBerakhir: json['tanggal_berakhir'] != null ? DateTime.parse(json['tanggal_berakhir']) : null,
      perpanjangan: json['perpanjangan'],
      gambar: (json['gambar'] as List).map((g) => Gambar.fromJson(g)).toList(),
      transaksiPenitipan: TransaksiPenitipan.fromJson(json['transaksi_penitipan']),
    );
  }
}

class Gambar {
  final int idGambar;
  final int idBarang;
  final String gambarBarang;

  Gambar({
    required this.idGambar,
    required this.idBarang,
    required this.gambarBarang,
  });

  factory Gambar.fromJson(Map<String, dynamic> json) {
    return Gambar(
      idGambar: json['id_gambar'],
      idBarang: json['id_barang'],
      gambarBarang: json['gambar_barang'],
    );
  }
}

class TransaksiPenitipan {
  final int idTransaksiPenitipan;
  final int idQc;
  final int? idHunter;
  final int idPenitip;
  final DateTime tanggalPenitipan;
  final Penitip? penitip; // Bisa null

  TransaksiPenitipan({
    required this.idTransaksiPenitipan,
    required this.idQc,
    this.idHunter,
    required this.idPenitip,
    required this.tanggalPenitipan,
    this.penitip,
  });

  factory TransaksiPenitipan.fromJson(Map<String, dynamic> json) {
    return TransaksiPenitipan(
      idTransaksiPenitipan: json['id_transaksi_penitipan'],
      idQc: json['id_qc'],
      idHunter: json['id_hunter'],
      idPenitip: json['id_penitip'],
      tanggalPenitipan: DateTime.parse(json['tanggal_penitipan']),
      penitip: json['penitip'] != null ? Penitip.fromJson(json['penitip']) : null, // Handle null
    );
  }
}

class Penitip {
  final int idPenitip;
  final String nikPenitip;
  final String namaPenitip;
  final String emailPenitip;
  final String noTelp;
  final String alamat;
  final double rataRating;
  final String statusPenitip;
  final double saldoPenitip;

  Penitip({
    required this.idPenitip,
    required this.nikPenitip,
    required this.namaPenitip,
    required this.emailPenitip,
    required this.noTelp,
    required this.alamat,
    required this.rataRating,
    required this.statusPenitip,
    required this.saldoPenitip,
  });

  factory Penitip.fromJson(Map<String, dynamic> json) {
    return Penitip(
      idPenitip: json['id_penitip'],
      nikPenitip: json['nik_penitip'],
      namaPenitip: json['nama_penitip'],
      emailPenitip: json['email_penitip'],
      noTelp: json['no_telp'],
      alamat: json['alamat'],
      rataRating: (json['rata_rating'] as num).toDouble(),
      statusPenitip: json['status_penitip'],
      saldoPenitip: (json['saldo_penitip'] as num).toDouble(),
    );
  }
}