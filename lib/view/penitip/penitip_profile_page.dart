import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/penitip.dart';
import 'package:reusemart_mobile/services/api_client.dart';

class PenitipProfilePage extends StatefulWidget {
  final ApiClient apiClient;
  final int penitipId;

  const PenitipProfilePage({
    super.key,
    required this.apiClient,
    required this.penitipId,
  });

  @override
  State<PenitipProfilePage> createState() => _PenitipProfilePageState();
}

class _PenitipProfilePageState extends State<PenitipProfilePage> {
  Penitipp? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.apiClient.getPenitipById(widget.penitipId);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _parseError(e.toString());
        _isLoading = false;
      });
    }
  }

  String _parseError(String error) {
    if (error.contains('404')) {
      return 'Penitip tidak ditemukan';
    } else if (error.contains('Failed to connect') || error.contains('SocketException')) {
      return 'Gagal terhubung ke server. Cek koneksi internet Anda.';
    } else {
      return 'Terjadi kesalahan: $error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Penitip',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Memuat profil...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadProfile,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  )
                : _profile == null
                    ? Center(
                        child: Text(
                          'Data tidak tersedia',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _profile!.profilPict != null
                                    ? CircleAvatar(
                                        radius: screenWidth * 0.15,
                                        backgroundColor: Colors.teal.shade100,
                                        backgroundImage: NetworkImage(_profile!.profilPict!),
                                        onBackgroundImageError: (_, __) => setState(() {
                                          _profile = _profile!.copyWith(profilPict: null);
                                        }),
                                      )
                                    : CircleAvatar(
                                        radius: screenWidth * 0.15,
                                        backgroundColor: Colors.teal.shade100,
                                        child: Icon(
                                          Icons.person,
                                          size: screenWidth * 0.1,
                                          color: Colors.teal,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 20),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildProfileItem(
                                        icon: Icons.person,
                                        label: 'Nama',
                                        value: _profile!.nama,
                                        theme: theme,
                                        screenWidth: screenWidth,
                                      ),
                                      const Divider(height: 20),
                                      _buildProfileItem(
                                        icon: Icons.email,
                                        label: 'Email',
                                        value: _profile!.email,
                                        theme: theme,
                                        screenWidth: screenWidth,
                                      ),
                                      const Divider(height: 20),
                                      _buildProfileItem(
                                        icon: Icons.account_balance_wallet,
                                        label: 'Saldo',
                                        value: 'Rp ${_profile!.saldo.toStringAsFixed(2)}',
                                        theme: theme,
                                        screenWidth: screenWidth,
                                      ),
                                      const Divider(height: 20),
                                      _buildProfileItem(
                                        icon: Icons.star,
                                        label: 'Poin',
                                        value: _profile!.poin.toString(),
                                        theme: theme,
                                        screenWidth: screenWidth,
                                      ),
                                      const Divider(height: 20),
                                      _buildProfileItem(
                                        icon: Icons.rate_review,
                                        label: 'Rating',
                                        value: '${_profile!.rataRating} (dari ${_profile!.banyakRating} ulasan)',
                                        theme: theme,
                                        screenWidth: screenWidth,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required double screenWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.teal,
          size: screenWidth * 0.06,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}