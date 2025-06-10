import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reusemart_mobile/models/top_seller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_client.dart';
import 'models/barang.dart';
import 'models/kategori.dart';
import 'view/login.dart';
import 'view/penitip/consignment_history_page.dart';
import 'view/penitip/penitip_profile_page.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReuseMart Mobile',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

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

  final List<Widget> _pages = [
    const HomeContent(),
    ConsignmentHistoryPage(apiClient: ApiClient(), penitipId: 12),
    PenitipProfilePage(apiClient: ApiClient(), penitipId: 12),
  ];

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    final status = await _checkLoginStatus();
    if (mounted) {
      setState(() {
        _currentRole = status['role'];
        _currentUser = status['user'];
      });
    }
  }

  Future<Map<String, dynamic>> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final userJson = prefs.getString('user');
    final user = userJson != null ? jsonDecode(userJson) : null;

    return {
      'isLoggedIn': token != null,
      'role': role,
      'user': user,
    };
  }

  Future<void> _logout() async {
    await apiClient.clearToken();
    if (mounted) {
      setState(() {
        _currentRole = null;
        _currentUser = null;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
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

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            'https://via.placeholder.com/40',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.store,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          _currentUser != null
              ? 'Selamat Datang, ${_currentUser!['nama']}'
              : widget.user != null
                  ? 'Selamat Datang, ${widget.user!['nama']}'
                  : 'ReuseMart',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: screenWidth * 0.04,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_currentUser != null || widget.user != null) {
                await _logout();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            child: Text(
              _currentUser != null || widget.user != null ? 'Logout' : 'Login',
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
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _currentRole == 'penitip' && _currentUser != null
            ? _pages[_selectedIndex]
            : const HomeContent(),
      ),
      bottomNavigationBar: _currentRole == 'penitip' && _currentUser != null
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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final apiClient = ApiClient();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Top Seller Section
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<TopSeller?>(
                  future: apiClient.getTopSeller(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
                    } else if (!snapshot.hasData) {
                      return Text(
                        'Belum ada Top Seller untuk bulan ini.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }

                    final topSeller = snapshot.data!;
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: topSeller.profilPict != null
                              ? Image.network(
                                  topSeller.profilPict!,
                                  width: screenWidth * 0.15,
                                  height: screenWidth * 0.15,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
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
                                '#1 Top Seller: ${topSeller.bulan}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal,
                                ),
                              ),
                              Text(
                                topSeller.namaPenitip,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${topSeller.jumlahBarang} items sold | Rp ${topSeller.totalPenjualan.toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[600],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Top Seller',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
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
            // Carousel Banner
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CarouselSlider.builder(
                  itemCount: 3,
                  itemBuilder: (context, index, realIndex) {
                    final banner = {
                      0: {
                        'image': 'https://via.placeholder.com/400x150',
                        'title': 'Recycle for a Better Tomorrow',
                        'subtitle': 'From You, For All of Us',
                      },
                      1: {
                        'image': 'https://via.placeholder.com/400x150/FF5733',
                        'title': 'Big Sale 50% Off',
                        'subtitle': 'Grab your favorites now!',
                      },
                      2: {
                        'image': 'https://via.placeholder.com/400x150/33FF57',
                        'title': 'New Arrivals',
                        'subtitle': 'Check out the latest collections!',
                      },
                    }[index]!;
                    return Stack(
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
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner['subtitle']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
            ),
            const SizedBox(height: 20),
            // Kategori Section
            Text(
              'BROWSE BY CATEGORY',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Kategori>>(
              future: apiClient.getKategori(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
                        'Gagal memuat kategori.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.redAccent,
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'Tidak ada kategori',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  );
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
                          onTap: () {},
                          child: Card(
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
                                    backgroundColor: Colors.teal.shade100,
                                    child: Text(
                                      kategori.namaKategori[0],
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    kategori.namaKategori,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.teal,
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
            const SizedBox(height: 20),
            // Recommended Products Section
            Text(
              'RECOMMENDED PRODUCTS',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Barang>>(
              future: apiClient.getBarang(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
                        'Gagal memuat produk.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.redAccent,
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'Tidak ada barang',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  );
                }

                final barangList = snapshot.data!
                    .where((barang) => barang.statusBarang == 'tersedia')
                    .toList();
                if (barangList.isEmpty) {
                  return Text(
                    'Tidak ada barang tersedia',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontSize: screenWidth * 0.04,
                    ),
                    textAlign: TextAlign.center,
                  );
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
                            builder: (context) =>
                                BarangDetailScreen(id: barang.idBarang),
                          ),
                        );
                      },
                      child: Card(
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
                                        'http://192.168.100.65:8000/storage/${barang.gambar[0].gambarBarang}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(
                                              Icons.broken_image,
                                              size: screenWidth * 0.1,
                                              color: Colors.grey[400],
                                            ),
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
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${barang.hargaBarang.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.teal,
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
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

class BarangDetailScreen extends StatelessWidget {
  final int id;
  final ApiClient apiClient = ApiClient();

  BarangDetailScreen({super.key, required this.id});

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
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
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
              return const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Gagal memuat barang.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.redAccent,
                        fontSize: screenWidth * 0.04,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Text(
                  'Barang tidak ditemukan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              );
            }

            final barang = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          barang.gambar.isNotEmpty
                              ? Image.network(
                                  'http://192.168.100.65:8000/storage/${barang.gambar[0].gambarBarang}',
                                  fit: BoxFit.cover,
                                  height: 250,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 250,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.broken_image,
                                      size: screenWidth * 0.1,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 250,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: screenWidth * 0.1,
                                    color: Colors.grey[400],
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 100,
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
                            ),
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
                      color: Colors.black87,
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
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          barang.statusBarang,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        size: screenWidth * 0.05,
                        color: Colors.grey[600],
                      ),
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
                      color: Colors.black87,
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
                  if (barang.transaksiPenitipan.penitip != null) ...[
                    Text(
                      'Penitip',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.05,
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            barang.transaksiPenitipan.penitip!.namaPenitip[0],
                            style: TextStyle(
                              color: Colors.teal,
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
                              'Nama: ${barang.transaksiPenitipan.penitip!.namaPenitip}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: screenWidth * 0.04,
                                  color: Colors.yellow[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${barang.transaksiPenitipan.penitip!.rataRating}',
                                  style: theme.textTheme.bodySmall?.copyWith(
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
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