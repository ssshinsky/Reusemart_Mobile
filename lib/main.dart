// lib/main.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/models/barang.dart';
import 'package:reusemart_mobile/models/kategori.dart';
import 'package:reusemart_mobile/auth/login_screen.dart'; // Menggunakan yang ini
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:reusemart_mobile/hunter/hunter_dashboard_screen.dart';
import 'package:reusemart_mobile/hunter/commission_detail_screen.dart';
import 'package:reusemart_mobile/pembeli/merchandise_catalog_screen.dart';
import 'package:reusemart_mobile/pembeli/merchandise_detail_screen.dart';
import 'package:reusemart_mobile/models/top_seller.dart'; // Model baru dari russel-merge
import 'package:reusemart_mobile/view/penitip/consignment_history_page.dart'; // View baru dari russel-merge
import 'package:reusemart_mobile/view/penitip/penitip_profile_page.dart'; // View baru dari russel-merge
import 'package:reusemart_mobile/view/pembeli/pembeli_history_page.dart'; // View baru dari russel-merge
import 'package:reusemart_mobile/view/pembeli/pembeli_profile_page.dart'; // View baru dari russel-merge

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Tambahkan super.key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReuseMart Mobile',
      theme: ThemeData(
        primarySwatch: Colors.green, // Warna utama tetap hijau
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(), // Halaman awal aplikasi setelah merge
      routes: {
        '/login': (context) => LoginScreen(), // Rute untuk halaman Login

        // Rute untuk setiap jenis user setelah login - sebagian besar akan ditangani HomeScreen,
        // tapi rute ini masih relevan untuk navigasi `pushReplacementNamed` dari LoginScreen
        '/admin_dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final String userName = args?['nama_pegawai'] ?? 'Admin';
          return TempDashboardScreen(userType: 'Admin', userName: userName); // Tetap gunakan TempDashboardScreen untuk role non-penitip/pembeli yang belum diimplementasikan di bottom nav
        },
        '/home_pembeli': (context) {
          // Akan dialihkan ke HomeScreen dengan role pembeli
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return HomeScreen(role: 'pembeli', user: args);
        },
        '/home_penitip': (context) {
          // Akan dialihkan ke HomeScreen dengan role penitip
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return HomeScreen(role: 'penitip', user: args);
        },
        // Rute untuk role lain yang masih pakai TempDashboardScreen (sementara)
        '/home_kurir': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final String userName = args?['nama_pegawai'] ?? 'Kurir';
          return TempDashboardScreen(userType: 'Kurir', userName: userName);
        },
        '/home_organisasi': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final String userName = args?['nama_organisasi'] ?? 'Organisasi';
          return TempDashboardScreen(userType: 'Organisasi', userName: userName);
        },
        '/home_cs': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final String userName = args?['nama_pegawai'] ?? 'Customer Service';
          return TempDashboardScreen(userType: 'Customer Service', userName: userName);
        },
        '/home_gudang': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          final String userName = args?['nama_pegawai'] ?? 'Gudang';
          return TempDashboardScreen(userType: 'Gudang', userName: userName);
        },
        '/home_hunter': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return HunterDashboardScreen(userData: args ?? {});
        },
        '/commission_detail': (context) {
          final commissionId = ModalRoute.of(context)!.settings.arguments as int;
          return CommissionDetailScreen(commissionId: commissionId);
        },
        // Rute MerchandiseCatalogScreen dan MerchandiseDetailScreen tetap ada
        '/merchandise_catalog': (context) => MerchandiseCatalogScreen(), // Tambah rute eksplisit jika diperlukan
        '/merchandise_detail': (context) {
          final merchandiseId = ModalRoute.of(context)!.settings.arguments as int;
          return MerchandiseDetailScreen(merchandiseId: merchandiseId);
        },
      },
    );
  }
}

// Widget Placeholder untuk Dashboard Setelah Login (dari mobile_test, dipertahankan untuk role selain pembeli/penitip)
class TempDashboardScreen extends StatelessWidget {
  final String userType;
  final String userName;

  const TempDashboardScreen({super.key, required this.userType, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userType Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat datang,',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
              Text(
                '$userName!', // Menampilkan nama user
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Ini adalah halaman khusus untuk $userType.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('authToken');
                  await prefs.remove('userType');
                  await prefs.remove('userData');
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// HomeScreen dari russel-merge, diadaptasi
class HomeScreen extends StatefulWidget {
  final String? role;
  final Map<String, dynamic>? user;

  const HomeScreen({super.key, this.role, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient apiClient = ApiClient();
  String? _currentRole;
  Map<String, dynamic>? _currentUser;
  int _selectedIndex = 0;

  List<Widget> get _pages {
    final role = _currentRole ?? widget.role?.toLowerCase();
    final user = _currentUser ?? widget.user;

    // Menggunakan MerchandiseCatalogScreen untuk pembeli di Home
    if (role == 'pembeli' && user != null) {
      return [
        MerchandiseCatalogScreen(), // Halaman katalog merchandise
        PembeliHistoryPage(apiClient: apiClient, pembeliId: user['id_pembeli'] ?? 0), // Memastikan id_pembeli ada
        PembeliProfilePage(apiClient: apiClient, pembeliId: user['id_pembeli'] ?? 0),
      ];
    }
    // Menggunakan ConsignmentHistoryPage untuk penitip di Home
    if (role == 'penitip' && user != null) {
      return [
        const HomeContent(), // Tampilan default Home jika belum ada halaman spesifik untuk penitip
        ConsignmentHistoryPage(apiClient: apiClient, penitipId: user['id_penitip'] ?? 0), // Memastikan id_penitip ada
        PenitipProfilePage(apiClient: apiClient, penitipId: user['id_penitip'] ?? 0),
      ];
    }
    // Default untuk guest atau role lain yang tidak punya bottom nav
    return [const HomeContent()];
  }

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final status = await _checkLoginStatus();
    if (mounted) {
      setState(() {
        _currentRole = status['role']?.toLowerCase();
        _currentUser = status['user'];
      });
    }
  }

  Future<Map<String, dynamic>> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); // Menggunakan authToken
    final role = prefs.getString('userType'); // Menggunakan userType
    final userJson = prefs.getString('userData'); // Menggunakan userData
    final user = userJson != null ? jsonDecode(userJson) : null;

    return {
      'isLoggedIn': token != null,
      'role': role,
      'user': user,
    };
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userType');
    await prefs.remove('userData'); // Hapus juga data user

    if (mounted) {
      setState(() {
        _currentRole = null;
        _currentUser = null;
        _selectedIndex = 0; // Reset index ke home
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Kembali ke LoginScreen
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final role = _currentRole ?? widget.role?.toLowerCase();
    final user = _currentUser ?? widget.user;

    // Perbaikan AppBar untuk tampilan logo dan teks
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          // Menggunakan Image.asset dari mobile_test untuk logo
          child: Image.asset(
            'assets/images/logoNoBg.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.store,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          user != null ? 'Selamat Datang, ${user['nama_pegawai'] ?? user['nama_penitip'] ?? user['nama_pembeli'] ?? 'Pengguna'}' : 'ReuseMart', // Lebih dinamis
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: screenWidth * 0.04,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (user != null) {
                await _logout();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Panggil LoginScreen
                );
              }
            },
            child: Text(
              user != null ? 'Logout' : 'Login',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.035,
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.teal], // Warna green dan teal
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6, // Tetap gunakan elevation
        shadowColor: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.3), // Tetap gunakan shadowColor
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: (role == 'penitip' || role == 'pembeli') && user != null
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
              selectedItemColor: Colors.teal,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              backgroundColor: Colors.white,
              elevation: 5,
              type: BottomNavigationBarType.fixed,
            )
          : null,
    );
  }
}

// HomeContent dari russel-merge
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final apiClient = ApiClient();

    // Banners (tetap dari mobile_test untuk consistency)
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

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // TOP SELLER Section (dari russel-merge)
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: apiClient.getTopSeller(), // Memanggil API Top Seller
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.teal),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Gagal memuat Top Seller.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.redAccent,
                              fontSize: screenWidth * 0.04,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!['top_seller'] == null) {
                      return Text(
                        'Belum ada Top Seller untuk ${snapshot.data?['last_month'] ?? 'bulan ini'}.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }

                    final data = snapshot.data!;
                    final topSeller = data['top_seller'] as TopSeller;
                    final lastMonth = data['last_month'];

                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: topSeller.profilPict != null
                              ? Image.network(
                                  // Asumsi path gambar di storageBaseUrl/foto_penitip/
                                  '${ApiClient.storageBaseUrl}/foto_penitip/${topSeller.profilPict}',
                                  width: screenWidth * 0.15,
                                  height: screenWidth * 0.15,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      CircleAvatar(
                                    radius: screenWidth * 0.075,
                                    backgroundColor: Colors.teal.shade100,
                                    child: Text(
                                      topSeller.namaPenitip[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: screenWidth * 0.075,
                                  backgroundColor: Colors.teal.shade100,
                                  child: Text(
                                    topSeller.namaPenitip[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#1 Top Seller of Reusemart',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    topSeller.namaPenitip,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.military_tech,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Top Seller',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            fontSize: screenWidth * 0.03,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Carousel Banner (dari mobile_test)
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0), // Padding disesuaikan
              child: CarouselSlider.builder(
                itemCount: banners.length,
                itemBuilder: (context, index, realIndex) {
                  final banner = banners[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
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
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  banner['title']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05, // Menyesuaikan ukuran font
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner['subtitle']!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: screenWidth * 0.035, // Menyesuaikan ukuran font
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
                  autoPlayInterval: const Duration(seconds: 4),
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  enableInfiniteScroll: true,
                ),
              ),
            ),

            // Kategori Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0), // Padding disesuaikan
              child: Text(
                'BROWSE BY CATEGORY',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Kategori>>(
              future: apiClient.getKategori(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada kategori'));
                }

                final kategoriList = snapshot.data!;
                return SizedBox(
                  height: 120,
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
                          child: Card( // Menggunakan Card dari russel-merge
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: const Color(0xFF2E7D32), // Warna green
                                    child: Text(
                                      kategori.namaKategori[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    kategori.namaKategori,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2E7D32), // Warna green
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Recommended Products Section (dari mobile_test, disatukan dengan gaya russel-merge)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0), // Padding disesuaikan
              child: Text(
                'RECOMMENDED PRODUCTS',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Barang>>(
              future: apiClient.getBarang(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada barang'));
                }

                final barangList = snapshot.data!.where((barang) => barang.statusBarang == 'tersedia').toList(); // Filter 'tersedia'
                if (barangList.isEmpty) {
                  return const Center(child: Text('Tidak ada barang tersedia'));
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      child: Card( // Menggunakan Card dari russel-merge
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: barang.gambar.isNotEmpty
                                    ? Image.network(
                                        // Menggunakan ApiClient.storageBaseUrl untuk konsistensi
                                        '${ApiClient.storageBaseUrl}/gambar_barang/${barang.gambar[0].gambarBarang}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('Error loading image for ${barang.namaBarang}: $error');
                                          return Icon(Icons.broken_image, size: screenWidth * 0.1, color: Colors.grey[400]);
                                        },
                                      )
                                    : Icon(
                                        Icons.image_not_supported,
                                        size: screenWidth * 0.1,
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey[900],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${barang.hargaBarang.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF2E7D32), // Warna green
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.035,
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
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logika View All Recommendations
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), // Warna green
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'View All Recommendations',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// BarangDetailScreen dari mobile_test, diadaptasi dengan gaya russel-merge
class BarangDetailScreen extends StatelessWidget {
  final int id;
  final ApiClient apiClient = ApiClient();

  BarangDetailScreen({super.key, required this.id}); // Tambahkan super.key

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Barang',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: screenWidth * 0.045,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.teal], // Warna green dan teal
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6, // Tetap gunakan elevation
        shadowColor: Colors.green.withOpacity(0.3), // Tetap gunakan shadowColor
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Barang>(
          future: apiClient.getBarangById(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Barang tidak ditemukan'));
            }

            final barang = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card( // Menggunakan Card dari russel-merge
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          barang.gambar.isNotEmpty // Cek apakah ada gambar
                              ? CarouselSlider.builder( // Carousel dari mobile_test
                                  itemCount: barang.gambar.length,
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
                                    height: 250,
                                    autoPlay: barang.gambar.length > 1,
                                    autoPlayInterval: const Duration(seconds: 4),
                                    enlargeCenterPage: true,
                                    viewportFraction: 1.0,
                                    enableInfiniteScroll: barang.gambar.length > 1,
                                  ),
                                )
                              : Container( // Tampilkan placeholder jika tidak ada gambar sama sekali
                                  height: 250,
                                  color: Colors.grey[300],
                                  child: Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400])),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    barang.namaBarang,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900], // Warna tetap grey[900]
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${barang.hargaBarang.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: screenWidth * 0.05,
                          color: const Color(0xFF2E7D32), // Warna green
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          barang.statusBarang,
                          style: const TextStyle(
                            color: Color(0xFF2E7D32), // Warna green
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.security, size: screenWidth * 0.05, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Garansi: ${barang.statusGaransi}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Deskripsi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    barang.deskripsiBarang,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (barang.transaksiPenitipan?.penitip != null) ...[
                    Text(
                      'Penitip',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.05,
                          backgroundColor: const Color(0xFF2E7D32), // Warna green
                          child: Text(
                            barang.transaksiPenitipan!.penitip!.namaPenitip[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${barang.transaksiPenitipan!.penitip?.namaPenitip}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.grey[800],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, size: screenWidth * 0.04, color: Colors.yellow[700]),
                                const SizedBox(width: 4),
                                Text(
                                  '${barang.transaksiPenitipan!.penitip?.rataRating ?? 0.0}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
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
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Logika View Details
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32), // Warna green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'View Details',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}