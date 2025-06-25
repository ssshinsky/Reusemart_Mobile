// lib/hunter/hunter_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/models/pegawai_profile.dart'; // Pastikan file ini ada di lib/models/
import 'package:reusemart_mobile/models/komisi_history.dart'; // Pastikan file ini ada di lib/models/
import 'package:reusemart_mobile/hunter/commission_detail_screen.dart'; 
import 'package:intl/intl.dart';

class HunterDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  HunterDashboardScreen({required this.userData});

  @override
  HunterDashboardScreenState createState() => HunterDashboardScreenState();
}

class HunterDashboardScreenState extends State<HunterDashboardScreen> {
  final ApiClient apiClient = ApiClient();
  // Gunakan underscore di sini agar konsisten dengan inisialisasi di initState
  late Future<PegawaiProfile> _hunterProfileFuture; 
  late Future<List<KomisiHistory>> _commissionHistoryFuture;

  @override
  void initState() {
    super.initState();
    // Inisialisasi variabel dengan underscore
    _hunterProfileFuture = apiClient.getHunterProfileAndTotalCommission(); 
    _commissionHistoryFuture = apiClient.getCommissionHistory();
  }

  String _formatCurrency(double amount) {
    // Format mata uang Rupiah
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hunter Dashboard'),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Profil Hunter
            FutureBuilder<PegawaiProfile>(
              future: _hunterProfileFuture, // Gunakan yang dengan underscore
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading profile: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('Profile not found.'));
                }

                final profile = snapshot.data!;
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Color(0xFF2E7D32),
                              backgroundImage: profile.profilPict != null
                                  ? NetworkImage('${ApiClient.storageBaseUrl}/foto_pegawai/${profile.profilPict}') // Asumsi folder foto_pegawai
                                  : null,
                              child: profile.profilPict == null
                                  ? Icon(Icons.person, color: Colors.white, size: 40)
                                  : null,
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.namaPegawai,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  profile.emailPegawai,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Alamat: ${profile.alamatPegawai}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Telepon: ${profile.nomorTelepon}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.cake, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Lahir: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(profile.tanggalLahir))}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Total Komisi',
                                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                              ),
                              Text(
                                _formatCurrency(profile.totalKomisi),
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // Bagian Riwayat Komisi
            Text(
              'Riwayat Komisi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
            SizedBox(height: 16),
            FutureBuilder<List<KomisiHistory>>(
              future: _commissionHistoryFuture, // Gunakan yang dengan underscore
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading history: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada riwayat komisi.'));
                }

                final historyList = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final commission = historyList[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: commission.gambarBarang != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '${ApiClient.storageBaseUrl}/gambar_barang/${commission.gambarBarang}', // Sesuaikan subfolder jika perlu
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 40, color: Colors.grey[400]),
                                ),
                              )
                            : Icon(Icons.image, size: 40, color: Colors.grey[400]),
                        title: Text(
                          '${commission.namaBarang}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal Penitipan: ${commission.tanggalPenitipan ?? 'N/A'}'),
                            Text('Komisi: ${_formatCurrency(commission.komisiDidapatkan)}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommissionDetailScreen(commissionId: commission.idKomisi),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}