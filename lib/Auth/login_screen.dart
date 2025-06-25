import 'package:flutter/material.dart';
import 'package:reusemart_mobile/services/api_client.dart'; // Sesuaikan path jika berbeda
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Diperlukan untuk jsonEncode

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiClient _apiClient = ApiClient(); // Inisialisasi ApiClient
  bool _isLoading = false;
  String _errorMessage = '';

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous errors
    });

    try {
      // Panggil metode login dari ApiClient
      final response = await _apiClient.login(
        _emailController.text,
        _passwordController.text,
      );

      // Handle respons dari backend
      if (response['success']) {
        // Login berhasil
        final String token = response['token'];
        final String userType = response['user_type']; // Misalnya: 'owner', 'pembeli', 'penitip', 'kurir', dll.
        final Map<String, dynamic> userData = response['user']; // Data user yang login

        // Simpan token dan data user menggunakan shared_preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userType', userType);
        await prefs.setString('userData', jsonEncode(userData)); // Simpan userData sebagai JSON string

        // Navigasi ke tampilan yang sesuai berdasarkan userType
        // Menggunakan pushReplacementNamed agar user tidak bisa kembali ke halaman login dengan tombol back
        // Data user dilewatkan sebagai 'arguments'
        if (userType == 'owner' || userType == 'admin') {
          Navigator.of(context).pushReplacementNamed('/admin_dashboard', arguments: userData);
        } else if (userType == 'pembeli') {
          Navigator.of(context).pushReplacementNamed('/home_pembeli', arguments: userData);
        } else if (userType == 'penitip') {
          Navigator.of(context).pushReplacementNamed('/home_penitip', arguments: userData);
        } else if (userType == 'kurir') {
          Navigator.of(context).pushReplacementNamed('/home_kurir', arguments: userData);
        } else if (userType == 'organisasi') {
          Navigator.of(context).pushReplacementNamed('/home_organisasi', arguments: userData);
        } else if (userType == 'customer service') { 
          Navigator.of(context).pushReplacementNamed('/home_cs', arguments: userData);
        } else if (userType == 'gudang') { 
          Navigator.of(context).pushReplacementNamed('/home_gudang', arguments: userData);
        } else if (userType == 'hunter') { 
          Navigator.of(context).pushReplacementNamed('/home_hunter', arguments: userData);
        }
        else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Text("Tampilan default untuk $userType")));
        }

      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
      print('Login error: $e'); 
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: Text('Login ReuseMart'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email), // Contoh ikon
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock), // Contoh ikon
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            _isLoading 
                ? CircularProgressIndicator(color: Color(0xFF2E7D32))
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Sudut membulat
                      ),
                    ),
                  ),
            if (_errorMessage.isNotEmpty) // Menampilkan pesan error jika ada
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}