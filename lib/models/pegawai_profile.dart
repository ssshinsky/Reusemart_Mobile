class PegawaiProfile {
  final int idPegawai;
  final String namaPegawai;
  final String emailPegawai;
  final String nomorTelepon;
  final String alamatPegawai;
  final String tanggalLahir;
  final String? profilPict;
  final double totalKomisi;

  PegawaiProfile({
    required this.idPegawai,
    required this.namaPegawai,
    required this.emailPegawai,
    required this.nomorTelepon,
    required this.alamatPegawai,
    required this.tanggalLahir,
    this.profilPict,
    required this.totalKomisi,
  });

  factory PegawaiProfile.fromJson(Map<String, dynamic> json, dynamic totalKomisiJson) { 
    double parsedTotalKomisi;
    if (totalKomisiJson is int) {
      parsedTotalKomisi = totalKomisiJson.toDouble();
    } else if (totalKomisiJson is double) {
      parsedTotalKomisi = totalKomisiJson;
    } else if (totalKomisiJson == null) {
      parsedTotalKomisi = 0.0; 
    } else {
      try {
        parsedTotalKomisi = (totalKomisiJson as num).toDouble();
      } catch (e) {
        print('Warning: Could not parse totalKomisi: $totalKomisiJson. Error: $e');
        parsedTotalKomisi = 0.0;
      }
    }

    return PegawaiProfile(
      idPegawai: json['id_pegawai'],
      namaPegawai: json['nama_pegawai'],
      emailPegawai: json['email_pegawai'],
      nomorTelepon: json['nomor_telepon'],
      alamatPegawai: json['alamat_pegawai'],
      tanggalLahir: json['tanggal_lahir'],
      profilPict: json['profil_pict'],
      totalKomisi: parsedTotalKomisi,
    );
  }
}