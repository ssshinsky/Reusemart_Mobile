class Alamat {
  final int idAlamat;
  final int idPembeli;
  final String namaOrang;
  final String labelAlamat;
  final String alamatLengkap;
  final String kecamatan;
  final String kabupaten;
  final String? noTelepon;
  final String? kodePos;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Alamat({
    required this.idAlamat,
    required this.idPembeli,
    required this.namaOrang,
    required this.labelAlamat,
    required this.alamatLengkap,
    required this.kecamatan,
    required this.kabupaten,
    this.noTelepon,
    this.kodePos,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory Alamat.fromJson(Map<String, dynamic> json) {
    return Alamat(
      idAlamat: json['id_alamat'] is String
          ? int.parse(json['id_alamat'])
          : json['id_alamat'] ?? 0,
      idPembeli: json['id_pembeli'] is String
          ? int.parse(json['id_pembeli'])
          : json['id_pembeli'] ?? 0,
      namaOrang: json['nama_orang'] ?? '',
      labelAlamat: json['label_alamat'] ?? '',
      alamatLengkap: json['alamat_lengkap'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      noTelepon: json['no_telepon'],
      kodePos: json['kode_pos'],
      isDefault: (json['is_default'] is int
              ? json['is_default'] == 1
              : json['is_default']) ??
          false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alamat': idAlamat,
      'id_pembeli': idPembeli,
      'nama_orang': namaOrang,
      'label_alamat': labelAlamat,
      'alamat_lengkap': alamatLengkap,
      'kecamatan': kecamatan,
      'kabupaten': kabupaten,
      'no_telepon': noTelepon,
      'kode_pos': kodePos,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
