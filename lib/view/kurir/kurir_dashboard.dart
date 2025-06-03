import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reusemart_mobile/services/api_client.dart';
import 'package:reusemart_mobile/view/kurir/profile_screen.dart';
import 'package:reusemart_mobile/view/kurir/delivery_history.dart';
import 'package:reusemart_mobile/view/kurir/update_delivery.dart';
import 'package:reusemart_mobile/view/login.dart';

class KurirDashboardScreen extends StatelessWidget {
  final ApiClient _apiClient = ApiClient();

  KurirDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await _apiClient.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kurir Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
        shadowColor: Colors.green.withAlpha(25),
        actions: [
          TextButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome, Kurir!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your deliveries with ease.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              // Button List
              Expanded(
                child: ListView(
                  children: [
                    _buildDashboardButton(
                      context,
                      title: 'View Profile',
                      icon: Icons.person,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardButton(
                      context,
                      title: 'View Delivery History',
                      icon: Icons.history,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeliveryHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDashboardButton(
                      context,
                      title: 'Update Delivery Status',
                      icon: Icons.update,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpdateDeliveryStatusScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withAlpha(10),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2E7D32),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
