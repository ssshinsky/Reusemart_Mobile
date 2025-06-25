// lib/main.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/models/barang.dart';
import 'package:reusemart_mobile/models/kategori.dart';
import 'package:reusemart_mobile/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:reusemart_mobile/hunter/hunter_dashboard_screen.dart';
import 'package:reusemart_mobile/hunter/commission_detail_screen.dart';
import 'package:reusemart_mobile/pembeli/merchandise_catalog_screen.dart';
import 'package:reusemart_mobile/pembeli/merchandise_detail_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReuseMart Mobile',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: HomeScreen(), // Halaman awal aplikasi
      routes: {
        '/login': (context) => LoginScreen(), // Rute untuk halaman Login

        // Rute untuk setiap jenis user setelah login
        // Menggunakan closure untuk mengakses arguments dari ModalRoute
        '/admin_dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          // Kunci 'nama_pegawai' karena admin adalah jenis pegawai
          final String userName = args?['nama_pegawai'] ?? 'Admin';
          return TempDashboardScreen(userType: 'Admin', userName: userName);
        },
        '/home_pembeli': (context) {
          return MerchandiseCatalogScreen();
        },
        '/home_penitip': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          // Kunci 'nama_penitip'
          final String userName = args?['nama_penitip'] ?? 'Penitip';
          return TempDashboardScreen(userType: 'Penitip', userName: userName);
        },
        '/home_kurir': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          // Kunci 'nama_pegawai' karena kurir adalah jenis pegawai
          final String userName = args?['nama_pegawai'] ?? 'Kurir';
          return TempDashboardScreen(userType: 'Kurir', userName: userName);
        },
        '/home_organisasi': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          // Kunci 'nama_organisasi'
          final String userName = args?['nama_organisasi'] ?? 'Organisasi';
          return TempDashboardScreen(userType: 'Organisasi', userName: userName);
        },
        '/home_cs': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          // Kunci 'nama_pegawai' karena CS adalah jenis pegawai
          final String userName = args?['nama_pegawai'] ?? 'Customer Service';
          return TempDashboardScreen(userType: 'Customer Service', userName: userName);
        },
        '/home_gudang': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          // Kunci 'nama_pegawai' karena gudang adalah jenis pegawai
          final String userName = args?['nama_pegawai'] ?? 'Gudang';
          return TempDashboardScreen(userType: 'Gudang', userName: userName);
        },
        '/home_hunter': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          // Langsung arahkan ke HunterDashboardScreen
          return HunterDashboardScreen(userData: args ?? {});
        },
        '/commission_detail': (context) {
          final commissionId = ModalRoute.of(context)!.settings.arguments as int;
          return CommissionDetailScreen(commissionId: commissionId);
        },
      },
    );
  }
}

// Widget Placeholder untuk Dashboard Setelah Login
class TempDashboardScreen extends StatelessWidget {
  final String userType;
  final String userName;

  TempDashboardScreen({required this.userType, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userType Dashboard'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat datang,',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              Text(
                '$userName!', // Menampilkan nama user
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                'Ini adalah halaman khusus untuk $userType.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  // Logika logout
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('authToken');
                  await prefs.remove('userType');
                  await prefs.remove('userData'); // Hapus juga data user

                  // Navigasi kembali ke halaman login atau home screen awal
                  Navigator.of(context).pushReplacementNamed('/login');
                  // Atau bisa juga: Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(builder: (context) => LoginScreen()),
                  //   (Route<dynamic> route) => false,
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Warna tombol logout
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- Kode HomeScreen dan BarangDetailScreen Anda yang lain (Tidak berubah) ---
class HomeScreen extends StatelessWidget {
  final ApiClient apiClient = ApiClient();

  final List<Map<String, String>> banners = [
    {
      'image': 'https://via.placeholder.com/400x150',
      'title': 'Recycle for a Better Tomorrow',
      'subtitle': 'From You, For All of Us',
    },
    {
      'image': 'https://via.placeholder.com/400x150/FF5733',
      'title': 'Big Sale 50% Off',
      'subtitle': 'Grab your favorites now!',
    },
    {
      'image': 'https://via.placeholder.com/400x150/33FF57',
      'title': 'New Arrivals',
      'subtitle': 'Check out the latest collections!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logoNoBg.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'ReuseMart',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Color(0xFF2E7D32),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(
              'Login',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Banner
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: CarouselSlider.builder(
                itemCount: banners.length,
                itemBuilder: (context, index, realIndex) {
                  final banner = banners[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            banner['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[300]),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  banner['title']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  banner['subtitle']!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 4),
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  enableInfiniteScroll: true,
                ),
              ),
            ),

            // Kategori Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'BROWSE BY CATEGORY',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            FutureBuilder<List<Kategori>>(
              future: apiClient.getKategori(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada kategori'));
                }

                final kategoriList = snapshot.data!;
                return Container(
                  height: 120,
                  margin: EdgeInsets.symmetric(vertical: 12.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kategoriList.length,
                    itemBuilder: (context, index) {
                      final kategori = kategoriList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            // Logika klik kategori
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 100,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    'https://via.placeholder.com/50', // Ganti dengan URL gambar kategori
                                  ),
                                  child: Text(
                                    kategori.namaKategori[0],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: Color(0xFF2E7D32),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  kategori.namaKategori,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // For You Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'RECOMMENDED PRODUCTS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            FutureBuilder<List<Barang>>(
              future: apiClient.getBarang(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada barang'));
                }

                final barangList = snapshot.data!.where((barang) => barang.statusBarang == 'Sold').toList();
                if (barangList.isEmpty) {
                  return Center(child: Text('Tidak ada barang tersedia'));
                }

                return Container(
                  padding: EdgeInsets.all(8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: barangList.length,
                    itemBuilder: (context, index) {
                      final barang = barangList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarangDetailScreen(id: barang.idBarang),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: barang.gambar.isNotEmpty
                                      ? Image.network(
                                          '${ApiClient.storageBaseUrl}/gambar_barang/${barang.gambar[0].gambarBarang}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Error loading image for ${barang.namaBarang}: $error');
                                            return Icon(Icons.broken_image, size: 50, color: Colors.grey[400]);
                                          },
                                        )
                                      : Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey[400],
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      barang.namaBarang,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[900],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Rp ${barang.hargaBarang.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
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
                );
              },
            ),
            // SizedBox(height: 16),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // Logika View All
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Color(0xFF2E7D32),
            //       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //     ),
            //     child: Text(
            //       'View All Recommendations',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 16,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class BarangDetailScreen extends StatelessWidget {
  final int id;
  final ApiClient apiClient = ApiClient();

  BarangDetailScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Barang',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 6,
        shadowColor: Colors.green.withOpacity(0.3),
      ),
      body: FutureBuilder<Barang>(
        future: apiClient.getBarangById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Barang tidak ditemukan'));
          }

          final barang = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: barang.gambar.isNotEmpty // Cek apakah ada gambar
                        ? CarouselSlider.builder(
                            itemCount: barang.gambar.length, // Jumlah gambar yang tersedia
                            itemBuilder: (context, index, realIndex) {
                              final gambar = barang.gambar[index];
                              return Image.network(
                                '${ApiClient.storageBaseUrl}/gambar_barang/${gambar.gambarBarang}',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading carousel image for ${barang.namaBarang} - ${gambar.gambarBarang}: $error');
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                                  );
                                },
                              );
                            },
                            options: CarouselOptions(
                              height: 250, // Sesuaikan tinggi dengan container
                              autoPlay: barang.gambar.length > 1, // Auto-play jika lebih dari 1 gambar
                              autoPlayInterval: Duration(seconds: 4),
                              enlargeCenterPage: true,
                              viewportFraction: 1.0, // Tampilkan 1 gambar penuh
                              enableInfiniteScroll: barang.gambar.length > 1,
                            ),
                          )
                        : Container( // Tampilkan placeholder jika tidak ada gambar sama sekali
                            color: Colors.grey[300],
                            child: Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400])),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  barang.namaBarang,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${barang.hargaBarang.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        barang.statusBarang,
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.security, size: 20, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      'Garansi: ${barang.statusGaransi}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  barang.deskripsiBarang,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 20),
                if (barang.transaksiPenitipan?.penitip != null) ...[
                  Text(
                    'Penitip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF2E7D32),
                        child: Text(
                          barang.transaksiPenitipan!.penitip!.namaPenitip[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${barang.transaksiPenitipan!.penitip?.namaPenitip}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star,
                                  size: 16, color: Colors.yellow[700]),
                              SizedBox(width: 4),
                              Text(
                                '${barang.transaksiPenitipan!.penitip?.rataRating ?? 0.0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Penitip: Tidak tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika View Details
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}