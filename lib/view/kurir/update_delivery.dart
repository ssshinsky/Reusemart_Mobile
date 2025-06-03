import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reusemart_mobile/services/api_client.dart';

class UpdateDeliveryStatusScreen extends StatefulWidget {
  const UpdateDeliveryStatusScreen({super.key});

  @override
  State<UpdateDeliveryStatusScreen> createState() =>
      UpdateDeliveryStatusScreenState();
}

class UpdateDeliveryStatusScreenState
    extends State<UpdateDeliveryStatusScreen> {
  final ApiClient _apiClient = ApiClient();
  final _deliveryIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _message;
  bool _isLoading = false;

  Future<void> _updateStatus() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _apiClient.updateDeliveryStatus(
        int.parse(_deliveryIdController.text.trim()),
        'Selesai',
      );
      setState(() {
        _message = 'Status updated successfully';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Delivery Status',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
        shadowColor: Colors.green.withAlpha(25),
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
              // Header Section
              Text(
                'Update Delivery',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mark a delivery as completed.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // Input Card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _deliveryIdController,
                      decoration: InputDecoration(
                        hintText: 'Enter Delivery ID',
                        prefixIcon: Icon(
                          Icons.local_shipping,
                          color: const Color(0xFF2E7D32),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Delivery ID cannot be empty';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                      ),
                    )
                  : GestureDetector(
                      onTap: _updateStatus,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.green.withAlpha((0.3 * 255).toInt()),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Mark as Selesai',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
              // Message Display
              if (_message != null) ...[
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: _message!.contains('success')
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _message!.contains('success')
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _deliveryIdController.dispose();
    super.dispose();
  }
}
