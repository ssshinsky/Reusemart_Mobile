import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/view/kurir/profile_screen.dart';
import 'package:reusemart_mobile/view/kurir/delivery_history.dart';
import 'package:reusemart_mobile/view/login.dart';
import 'package:reusemart_mobile/models/pegawai.dart';
import 'package:reusemart_mobile/models/transaksi_pembelian.dart';

class KurirDashboard extends StatefulWidget {
  const KurirDashboard({super.key});

  @override
  State<KurirDashboard> createState() => _KurirDashboardState();
}

class _KurirDashboardState extends State<KurirDashboard> {
  final ApiClient apiClient = ApiClient();
  Pegawai? kurir;
  String? role;
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _checkRoleAndLoadProfile();
  }

  Future<void> _checkRoleAndLoadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('role');
    setState(() {
      role = userRole;
      isLoadingProfile = true;
    });

    if (role != 'kurir') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hanya kurir yang dapat mengakses halaman ini')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final profile = await apiClient.getProfile();
      setState(() {
        kurir = profile;
        isLoadingProfile = false;
      });
    } catch (e) {
      print('Gagal memuat profil: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: $e')),
      );
      setState(() {
        // ignore: prefer_typing_uninitialized_variables
        var idRole;
        kurir = Pegawai(
          idPegawai: prefs.getInt('id_pegawai') ?? 0,
          namaPegawai: 'Kurir Tidak Dikenal',
          profilPict: null,
          idRole: idRole,
          alamatPegawai: '',
          tanggalLahir: '',
          nomorTelepon: '',
          emailPegawai: '',
        );
        isLoadingProfile = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await apiClient.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      // Hapus token lokal meskipun server gagal
      await apiClient.clearToken();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal logout dari server: $e. Logout lokal dilakukan.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  Future<void> _refreshDeliveries() async {
    setState(() {}); // Trigger rebuild untuk memuat ulang FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoadingProfile
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)
              : kurir?.profilPict != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(kurir!.profilPict!))
                  : const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/40'),
                    ),
        ),
        title: Text(
          isLoadingProfile
              ? 'Memuat...'
              : kurir != null
                  ? 'Halo, ${kurir!.namaPegawai}'
                  : 'Courier Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 6,
        // ignore: deprecated_member_use
        shadowColor: Colors.green.withOpacity(0.3),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDeliveries,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengiriman Aktif',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<TransaksiPembelian>>(
                  future: apiClient.getActiveDeliveries(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print(
                          'Error di FutureBuilder: ${snapshot.error}'); // Debug log
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Gagal memuat pengiriman: ${snapshot.error}',
                              style: GoogleFonts.poppins(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: Text('Coba Lagi',
                                  style: GoogleFonts.poppins()),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      print('Data kosong: ${snapshot.data}'); // Debug log
                      return Center(
                        child: Text(
                          'Tidak ada pengiriman aktif',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final transaksiList = snapshot.data!;
                    print('Transaksi aktif: $transaksiList'); // Debug log

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transaksiList.length,
                      itemBuilder: (context, index) {
                        final transaksi = transaksiList[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pesanan #${transaksi.idPembelian}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    'Status', transaksi.statusTransaksi),
                                _buildDetailRow('No. Resi', transaksi.noResi),
                                _buildDetailRow('Total Harga',
                                    'Rp ${transaksi.totalHarga.toStringAsFixed(0)}'),
                                _buildDetailRow('Metode Pengiriman',
                                    transaksi.metodePengiriman),
                                _buildDetailRow('Tanggal Pembelian',
                                    transaksi.tanggalPembelian),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (transaksi.statusTransaksi ==
                                        'Sedang Dikirim')
                                      ElevatedButton(
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Konfirmasi',
                                                  style: GoogleFonts.poppins()),
                                              content: Text(
                                                'Ubah status pesanan #${transaksi.idPembelian} ke Selesai?',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: Text('Batal',
                                                      style: GoogleFonts
                                                          .poppins()),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text('Ya',
                                                      style: GoogleFonts
                                                          .poppins()),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await apiClient
                                                  .updateStatusTransaksi(
                                                      transaksi.idPembelian,
                                                      'Selesai');
                                              setState(() {});
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Status diubah ke Selesai')),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Gagal memperbarui: $e')),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2E7D32),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          'Tandai Selesai',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DeliveryHistory()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Pengiriman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[900]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}