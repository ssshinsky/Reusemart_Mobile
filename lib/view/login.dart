import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../services/api_client.dart';
import 'penitip/penitip_profile_page.dart';
import 'pembeli/pembeli_profile_page.dart';
import 'kurir/kurir_dashboard.dart';
import 'package:reusemart_mobile/hunter/hunter_dashboard_screen.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? selectedRole = 'Pembeli';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final ApiClient _apiClient = ApiClient();

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiClient.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final role = result['role'];
      final user = result['user'];

      String computedRole = role.toLowerCase();
      if (computedRole == 'pegawai' && user != null && user['id_role'] != null) {
        if (user['id_role'].toString() == '5') {
          computedRole = 'kurir';
        } else if (user['id_role'].toString() == '6') {
          computedRole = 'hunter';
        } else {
          throw Exception('Akun pegawai ini tidak memiliki akses aplikasi mobile');
        }
      }

      // Pakai computedRole untuk validasi
      if ((selectedRole == 'Kurir' && computedRole != 'kurir') ||
          (selectedRole == 'Pembeli' && computedRole != 'pembeli') ||
          (selectedRole == 'Penitip' && computedRole != 'penitip') ||
          (selectedRole == 'Hunter' && computedRole != 'hunter')) {
        throw Exception('Role tidak sesuai dengan kredensial');
      }
      
      if (mounted) {
        developer.log(
          'Login berhasil: Email=${_emailController.text}, Role=$computedRole',
          name: 'LoginPage',
        );

        if (computedRole == 'kurir') {
          final prefs = await SharedPreferences.getInstance();
          final idKurirLogin = prefs.getInt('id_pegawai');
          await prefs.setString('role', computedRole);
          if (computedRole == 'kurir' || computedRole == 'hunter') {
            final idPegawai = user['id'];
            await prefs.setInt('id_pegawai', int.parse(idPegawai.toString()));
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const KurirDashboard()),
          );
        } else if (computedRole == 'hunter') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HunterDashboardScreen(userData: user)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                role: computedRole,
                user: user,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green[700],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk melanjutkan ♥',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: selectedRole,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedRole = newValue;
                              });
                            },
                            items: const <String>['Pembeli', 'Penitip', 'Kurir', 'Hunter']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: 'Email/Username',
                                prefixIcon:
                                    Icon(Icons.email, color: Colors.green),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.green),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                        )
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
