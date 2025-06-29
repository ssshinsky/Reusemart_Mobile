int parseInt(dynamic value) => int.tryParse(value.toString()) ?? 0;
double parseDouble(dynamic value) => double.tryParse(value.toString()) ?? 0.0;

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
      idBarang: parseInt(json['id_barang']),
      idKategori: parseInt(json['id_kategori']),
      idTransaksiPenitipan: parseInt(json['id_transaksi_penitipan']),
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      hargaBarang: parseDouble(json['harga_barang']),
      beratBarang: parseDouble(json['berat_barang']),
      deskripsiBarang: json['deskripsi_barang'] ?? '',
      statusGaransi: json['status_garansi'] ?? '',
      statusBarang: json['status_barang'] ?? '',
      tanggalGaransi: (json['tanggal_garansi'] != null && json['tanggal_garansi'].toString().isNotEmpty)
          ? DateTime.tryParse(json['tanggal_garansi'].toString())
          : null,
      tanggalBerakhir: (json['tanggal_berakhir'] != null && json['tanggal_berakhir'].toString().isNotEmpty)
          ? DateTime.tryParse(json['tanggal_berakhir'].toString())
          : null,
      perpanjangan: parseInt(json['perpanjangan']),
      gambar: (json['gambar'] as List?)
              ?.map((g) => Gambar.fromJson(g))
              .toList() ??
          [],
      transaksiPenitipan: TransaksiPenitipan.fromJson(json['transaksi_penitipan'] ?? {}),
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
      idGambar: parseInt(json['id_gambar']),
      idBarang: parseInt(json['id_barang']),
      gambarBarang: json['gambar_barang'] ?? '',
    );
  }
}

class TransaksiPenitipan {
  final int idTransaksiPenitipan;
  final int idQc;
  final int? idHunter;
  final int idPenitip;
  final DateTime tanggalPenitipan;
  final DateTime? tanggalBerakhir;
  final Penitip? penitip;

  TransaksiPenitipan({
    required this.idTransaksiPenitipan,
    required this.idQc,
    this.idHunter,
    required this.idPenitip,
    required this.tanggalPenitipan,
    this.tanggalBerakhir,
    this.penitip,
  });

  factory TransaksiPenitipan.fromJson(Map<String, dynamic> json) {
    return TransaksiPenitipan(
      idTransaksiPenitipan: parseInt(json['id_transaksi_penitipan']),
      idQc: parseInt(json['id_qc']),
      idHunter: json['id_hunter'] != null ? parseInt(json['id_hunter']) : null,
      idPenitip: parseInt(json['id_penitip']),
      tanggalPenitipan: DateTime.tryParse(json['tanggal_penitipan'].toString()) ?? DateTime(1970),
      tanggalBerakhir: (json['tanggal_berakhir'] != null && json['tanggal_berakhir'].toString().isNotEmpty)
          ? DateTime.tryParse(json['tanggal_berakhir'].toString())
          : null,
      penitip: json['penitip'] != null ? Penitip.fromJson(json['penitip']) : null,
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
      idPenitip: parseInt(json['id_penitip']),
      nikPenitip: json['nik_penitip'] ?? '',
      namaPenitip: json['nama_penitip'] ?? '',
      emailPenitip: json['email_penitip'] ?? '',
      noTelp: json['no_telp'] ?? '',
      alamat: json['alamat'] ?? '',
      rataRating: parseDouble(json['rata_rating']),
      statusPenitip: json['status_penitip'] ?? '',
      saldoPenitip: parseDouble(json['saldo_penitip']),
    );
  }
}