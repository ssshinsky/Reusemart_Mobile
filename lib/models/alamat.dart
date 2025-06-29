int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
bool parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

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
      idAlamat: parseInt(json['id_alamat']),
      idPembeli: parseInt(json['id_pembeli']),
      namaOrang: json['nama_orang'] ?? '',
      labelAlamat: json['label_alamat'] ?? '',
      alamatLengkap: json['alamat_lengkap'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      noTelepon: json['no_telepon'],
      kodePos: json['kode_pos'],
      isDefault: parseBool(json['is_default']),
      createdAt: (json['created_at'] != null && json['created_at'].toString().isNotEmpty)
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: (json['updated_at'] != null && json['updated_at'].toString().isNotEmpty)
          ? DateTime.tryParse(json['updated_at'].toString())
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