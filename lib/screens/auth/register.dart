import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../services/auth_service.dart'; // Import AuthService
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService(); // Initialize AuthService
  bool _isLoading = false; // Add loading state
  
  String? _selectedTeam;
  final List<String> _teams = ['Echipa Andreea', 'Echipa Cristina', 'Echipa Scarlat'];
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
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
                      // Name Field
                      _buildTextField(
                        title: 'Cum te numești?',
                        hintText: 'Introdu numele tău',
                        controller: _nameController,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Password Field
                      _buildTextField(
                        title: 'Creează parolă',
                        hintText: 'Introdu parola',
                        controller: _passwordController,
                        isPassword: true,
                        showInfoButton: true,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Confirm Password Field
                      _buildTextField(
                        title: 'Repetă parola',
                        hintText: 'Introdu parola iar',
                        controller: _confirmPasswordController,
                        isPassword: true,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Team Selection Field
                      _buildDropdownField(),
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
                        'Ai deja un cont de consultant? ',
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
                
                // Register Button
                _buildRegisterButton(),
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
                    'Bun venit în echipă!',
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
                    'Hai să oficializăm intrarea ta în sistem.',
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

  Widget _buildTextField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    bool showInfoButton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Title with Info Button (if needed)
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
                      // Show password info dialog
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
                    obscureText: isPassword ? (controller == _passwordController ? _obscurePassword : _obscureConfirmPassword) : false,
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
              if (isPassword)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: Icon(
                      // Change icon based on password visibility (Corrected logic)
                      (controller == _passwordController ? _obscurePassword : _obscureConfirmPassword)
                          ? Icons.visibility // Show visibility icon when obscured
                          : Icons.visibility_off, // Show visibility_off icon when visible
                      color: const Color(0xFF77677E), // Use the same color as Figma design
                      size: 24, // Match the size from Figma
                    ),
                    onPressed: () {
                      setState(() {
                        if (controller == _passwordController) {
                          _obscurePassword = !_obscurePassword;
                        } else if (controller == _confirmPasswordController) {
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

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Alege echipa',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.28,
              color: const Color(0xFF866C93),
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Dropdown Field
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFC3B6C9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                'Selectează echipa',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.28,
                  color: const Color(0xFF77677E),
                ),
              ),
              value: _selectedTeam,
              icon: SvgPicture.asset(
                'assets/DropdownIcon.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF695C70),
                  BlendMode.srcIn,
                ),
              ),
              items: _teams.map((String team) {
                return DropdownMenuItem<String>(
                  value: team,
                  child: Text(
                    team,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.28,
                      color: const Color(0xFF77677E),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTeam = newValue;
                });
              },
              dropdownColor: const Color(0xFFC3B6C9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: 384,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _register,
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
                    'Creează cont',
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

  void _register() async {
    // Validate fields
    if (_nameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedTeam == null) {
      _showErrorDialog('Completați toate câmpurile.');
      return;
    }

    // Password validation (minimum 8 characters, at least one uppercase, one lowercase, one number)
    final password = _passwordController.text;
    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[0-9]'))) {
      _showErrorDialog(
          'Parola trebuie să conțină minim 8 caractere, o literă mare, o literă mică și un număr.');
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Register agent with Firebase Authentication
      final result = await _authService.registerAgent(
        agentName: _nameController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        team: _selectedTeam!,
      );

      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Show token to user
        _showTokenDialog(result['token']);
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      // Hide loading indicator
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Eroare la înregistrare: $e');
    }
  }

  void _showTokenDialog(String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Token de securitate',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF77677E),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Acest token este cheia de securitate a contului tău. Păstrează-l într-un loc sigur, vei avea nevoie de el pentru a-ți reseta parola în caz că o uiți.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF866C93),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCEC7D1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      token,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF77677E),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    color: Color(0xFF77677E),
                  ),
                  onPressed: () {
                    // Copy token to clipboard
                    Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Token copiat în clipboard!',
                          style: GoogleFonts.outfit(),
                        ),
                        backgroundColor: const Color(0xFF77677E),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Am înțeles, continuă',
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
}
