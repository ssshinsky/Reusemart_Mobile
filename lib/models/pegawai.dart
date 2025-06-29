int parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

class Pegawai {
  final int idPegawai;
  final int idRole;
  final String namaPegawai;
  final String alamatPegawai;
  final String tanggalLahir;
  final String nomorTelepon;
  final String emailPegawai;
  final String? profilPict;

  Pegawai({
    required this.idPegawai,
    required this.idRole,
    required this.namaPegawai,
    required this.alamatPegawai,
    required this.tanggalLahir,
    required this.nomorTelepon,
    required this.emailPegawai,
    this.profilPict,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      idPegawai: parseInt(json['id_pegawai']),
      idRole: parseInt(json['id_role']),
      namaPegawai: json['nama_pegawai'] ?? '',
      alamatPegawai: json['alamat_pegawai'] ?? '',
      tanggalLahir: json['tanggal_lahir'] ?? '',
      nomorTelepon: json['nomor_telepon'] ?? '',
      emailPegawai: json['email_pegawai'] ?? '',
      profilPict: json['profil_pict'],
    );
  }
}