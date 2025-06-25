import 'package:flutter/material.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/models/pembeli.dart';

class PembeliProfilePage extends StatelessWidget {
  final ApiClient apiClient;
  final int pembeliId;

  const PembeliProfilePage({
    super.key,
    required this.apiClient,
    required this.pembeliId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Pembeli',
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
        child: FutureBuilder<Pembeli>(
          future: apiClient.getPembeliById(pembeliId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
                      'Gagal memuat profil: ${snapshot.error}',
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
                  'Profil tidak ditemukan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              );
            }

            final pembeli = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: pembeli.profilPict != null
                                ? Image.network(
                                    pembeli.profilPict!,
                                    width: screenWidth * 0.25,
                                    height: screenWidth * 0.25,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        CircleAvatar(
                                      radius: screenWidth * 0.125,
                                      backgroundColor: Colors.teal.shade100,
                                      child: Text(
                                        pembeli.nama[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: screenWidth * 0.08,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: screenWidth * 0.125,
                                    backgroundColor: Colors.teal.shade100,
                                    child: Text(
                                      pembeli.nama[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.teal,
                                        fontSize: screenWidth * 0.08,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pembeli.nama,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            pembeli.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: pembeli.status == 'Active'
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              pembeli.status ?? 'Customer',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: pembeli.status == 'Active'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ],
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Profil',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildProfileRow(
                            icon: Icons.phone,
                            label: 'Nomor Telepon',
                            value: pembeli.nomorTelepon,
                            screenWidth: screenWidth,
                            theme: theme,
                          ),
                          const SizedBox(height: 8),
                          _buildProfileRow(
                            icon: Icons.cake,
                            label: 'Tanggal Lahir',
                            value: pembeli.tanggalLahir ?? 'Belum diatur',
                            screenWidth: screenWidth,
                            theme: theme,
                          ),
                          const SizedBox(height: 8),
                          _buildProfileRow(
                            icon: Icons.star,
                            label: 'Poin Reward',
                            value: '${pembeli.poin} poin',
                            screenWidth: screenWidth,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: screenWidth * 0.05, color: Colors.teal),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: screenWidth * 0.04,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}