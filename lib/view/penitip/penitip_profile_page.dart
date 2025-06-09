import 'package:flutter/material.dart';
import 'package:reusemart_mobile/models/penitip.dart';
import 'package:reusemart_mobile/services/api_client.dart';

class PenitipProfilePage extends StatefulWidget {
  final ApiClient apiClient;

  const PenitipProfilePage({super.key, required this.apiClient});

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
      final profile = await widget.apiClient.getPenitipProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Penitip')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_profile!.profilPict != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_profile!.profilPict!),
                        ),
                      const SizedBox(height: 16),
                      Text('Nama: ${_profile!.nama}', style: const TextStyle(fontSize: 20)),
                      Text('Email: ${_profile!.email}', style: const TextStyle(fontSize: 16)),
                      Text('Saldo: Rp ${_profile!.saldo.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      Text('Poin: ${_profile!.poin}', style: const TextStyle(fontSize: 16)),
                      Text('Rating: ${_profile!.rataRating} (dari ${_profile!.banyakRating} ulasan)', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
    );
  }
}