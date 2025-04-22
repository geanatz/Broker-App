import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart'; // Import AuthService

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final _tokenController = TextEditingController();
  final AuthService _authService = AuthService(); // Initialize AuthService
  bool _isLoading = false; // Add loading state
  
  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFA4B8C2), Color(0xFFC2A4A4)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x80F2F2F2), // 50% opacity
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 8),
                
                // Form
                Container(
                  width: 384,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCEC7D1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Token Field
                      _buildTokenField(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Go back to login link
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ți-a revenit memoria? ',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          color: const Color(0xFF866C93),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Future.delayed(Duration.zero, () {
                            Navigator.of(context).pushReplacementNamed('/login');
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Conectează-te!',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            color: const Color(0xFF77677E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Verify Token Button
                _buildVerifyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title and Description
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    'Înainte, dovedește că ești tu!',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: const Color(0xFF77677E),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Caută-ți tokenul secret.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: const Color(0xFF866C93),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Logo
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SvgPicture.asset(
            'assets/Logo.svg',
            width: 48,
            height: 48,
            colorFilter: const ColorFilter.mode(
              Color(0xFF866C93),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Token secret',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.28,
              color: const Color(0xFF866C93),
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Input Field
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFC3B6C9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  hintText: 'Introdu tokenul tău',
                  hintStyle: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.28,
                    color: const Color(0xFF77677E),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  isCollapsed: true,
                ),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.28,
                  color: const Color(0xFF77677E),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: 384,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _verifyTokenAndNavigate,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFFC3B6C9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF77677E)),
                  )
                : Text(
                    'Verifică token',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.28,
                      color: const Color(0xFF77677E),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _verifyTokenAndNavigate() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      _showErrorDialog('Introduceți tokenul.');
      return;
    }
    
    setState(() { _isLoading = true; });
    
    try {
      final result = await _authService.verifyToken(token);
      
      if (mounted) { // Check if widget is still mounted
        setState(() { _isLoading = false; });
        
        if (result['success']) {
          // Navigate to ResetPasswordScreen with token and consultantId
          Navigator.pushReplacementNamed(
            context,
            '/reset_password',
            arguments: {
              'token': token,
              'consultantId': result['consultantId'], // Pass consultantId
            },
          );
        } else {
          _showErrorDialog(result['message']);
        }
      }
    } catch (e) {
       print("Token Verification Error: $e");
        if (mounted) { // Check if widget is still mounted
          setState(() { _isLoading = false; });
          _showErrorDialog('Eroare la verificarea tokenului: $e');
        }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eroare',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF77677E)),
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF866C93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Ok',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF866C93)),
            ),
          ),
        ],
      ),
    );
  }
}
