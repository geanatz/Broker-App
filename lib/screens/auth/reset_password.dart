import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart'; // Import AuthService

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService(); // Initialize AuthService
  bool _isLoading = false; // Add loading state
  
  String? _token;
  String? _consultantId; // Renamed
  
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve token and consultantId from route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _token = args['token'];
      _consultantId = args['consultantId']; // Renamed key expected from arguments
      // Log the received values for debugging
      print("Received token: $_token, consultantId: $_consultantId");
    }
  }
  
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                      // New Password Field
                      _buildPasswordField(
                        title: 'Parola nouă',
                        hintText: 'Introdu parola',
                        controller: _newPasswordController,
                        showInfoButton: true,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Confirm Password Field
                      _buildPasswordField(
                        title: 'Repetă parola',
                        hintText: 'Introdu parola iar',
                        controller: _confirmPasswordController,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Login Link
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
                
                // Reset Button
                _buildResetButton(),
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
                    'Parola nouă (test de memorie)',
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
                    'Ceva sigur, nu ziua ta de naștere...',
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

  Widget _buildPasswordField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    bool showInfoButton = false,
  }) {
    bool isNewPassword = controller == _newPasswordController;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.28,
                  color: const Color(0xFF866C93),
                ),
              ),
              if (showInfoButton) 
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/InfoIcon.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF77677E),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      // Show password requirements
                      _showInfoDialog(
                        title: 'Cerințe parolă',
                        message: 'Parola trebuie să conțină minim 8 caractere, o literă mare, o literă mică și un număr.',
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16
                    ),
                  ),
                ),
            ],
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
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
                    obscureText: isNewPassword ? _obscureNewPassword : _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.28,
                        color: const Color(0xFF77677E),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
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
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Icon(
                    // Change icon based on password visibility (Corrected logic)
                    (isNewPassword ? _obscureNewPassword : _obscureConfirmPassword)
                        ? Icons.visibility // Show visibility icon when obscured
                        : Icons.visibility_off, // Show visibility_off icon when visible
                    color: const Color(0xFF77677E), // Use the same color as Figma design
                    size: 24, // Match the size from Figma
                  ),
                  onPressed: () {
                    setState(() {
                      if (isNewPassword) {
                        _obscureNewPassword = !_obscureNewPassword;
                      } else {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return Container(
      width: 384,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _resetPassword,
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
                    'Resetează parola',
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

  void _resetPassword() async {
    if (_token == null || _consultantId == null) { // Check if token or consultantId is null
      _showErrorDialog('Token invalid sau lipsă sau ID consultant lipsă. Încearcă din nou procesul de resetare.');
      return;
    }
    
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Te rog completează ambele câmpuri pentru parolă.');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Parolele nu se potrivesc.');
      return;
    }
    
    // Password validation (optional but recommended)
    // final password = _newPasswordController.text;
    // if (password.length < 8 || ... ) { ... }
    
    setState(() { _isLoading = true; });
    
    try {
      final result = await _authService.resetPasswordWithToken(
        consultantId: _consultantId!,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      
      if(mounted) {
        setState(() { _isLoading = false; });

        if (result['success']) {
          // Show success message and navigate to login
          _showSuccessDialog(result['message']); 
        } else {
          _showErrorDialog(result['message']);
        }
      }
    } catch (e) {
      print("Reset Password Error: $e");
      if(mounted) {
        setState(() { _isLoading = false; });
        _showErrorDialog('Eroare la resetarea parolei: $e');
      }
    }
  }

  void _showInfoDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF77677E),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF866C93),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Am înțeles',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF866C93),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eroare',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF77677E),
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF866C93),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Ok',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF866C93),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must acknowledge
      builder: (context) => AlertDialog(
        title: Text(
          'Succes', // Generic title, message comes from service
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xFF77677E)),
        ),
        content: Text(
          message, // Display the message from the service
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF866C93)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.of(context).pushReplacementNamed('/login'); // Go to login
            },
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
