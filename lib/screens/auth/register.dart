import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
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
            end: Alignment.bottomLeft,
            colors: [Color(0xFFA4B8C2), Color(0xFFC2A4A4)],
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x80F2F2F2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
                
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
                        title: 'Cum te numesti?',
                        hintText: 'Introdu numele tau',
                        controller: _nameController,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Password Field
                      _buildTextField(
                        title: 'Creaza parola',
                        hintText: 'Introdu parola',
                        controller: _passwordController,
                        isPassword: true,
                        showInfoButton: true,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Confirm Password Field
                      _buildTextField(
                        title: 'Repeta parola',
                        hintText: 'Introdu parola iar',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        showInfoButton: true,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text.rich(
                    TextSpan(
                      text: 'Ai deja un cont de consultant? ',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.25, // line-height: 20px / font-size: 16px = 1.25
                        color: const Color(0xFF866C93),
                      ),
                      children: [
                        TextSpan(
                          text: 'Conecteaza-te!',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600, // Changed to 600 to match Figma spec
                            height: 1.25,
                            color: const Color(0xFF77677E), // Darker color for emphasis
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title and Description
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    'Bun venit in echipa!',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.25, // line-height: 25px / font-size: 20px = 1.25
                      color: const Color(0xFF77677E),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Hai sa oficializam intrarea ta in sistem.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.25, // line-height: 20px / font-size: 16px = 1.25
                      color: const Color(0xFF866C93),
                    ),
                  ),
                ),
              ],
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
      ),
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
        // Field Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.28, // line-height: 23px / font-size: 18px = 1.28
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
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword ? true : false, // Always obscure password fields
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.28, // line-height: 23px / font-size: 18px = 1.28
                        color: const Color(0xFF77677E),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero, // Remove padding from TextField itself
                      isDense: true, // Makes the field more compact
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.28, // line-height: 23px / font-size: 18px = 1.28
                      color: const Color(0xFF77677E),
                    ),
                  ),
                ),
              ),
              if (showInfoButton)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/InfoButton.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF77677E),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      // Show password info dialog
                      _showInfoDialog(
                        title: 'Cerinte parola',
                        message: 'Parola trebuie sa contina minim 8 caractere, o litera mare, o litera mica si un numar.',
                      );
                    },
                    padding: EdgeInsets.zero, // Remove padding from IconButton
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24
                    ), // Set minimum size
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
              height: 1.28, // line-height: 23px / font-size: 18px = 1.28
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
                'Selecteaza echipa',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.28, // line-height: 23px / font-size: 18px = 1.28
                  color: const Color(0xFF77677E),
                ),
              ),
              value: _selectedTeam,
              icon: SvgPicture.asset(
                'assets/DropdownButton.svg',
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
                      height: 1.28, // line-height: 23px / font-size: 18px = 1.28
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
    return InkWell(
      onTap: () {
        // Handle registration
        _register();
      },
      child: Container(
        width: 384,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFC3B6C9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'Creaza cont',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.28, // line-height: 23px / font-size: 18px = 1.28
            color: const Color(0xFF77677E),
          ),
        ),
      ),
    );
  }

  void _register() {
    // Validate fields
    if (_nameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedTeam == null) {
      _showErrorDialog('Completati toate campurile.');
      return;
    }

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Parolele nu coincid.');
      return;
    }

    // TODO: Implement registration logic
    print('inregistrare: ${_nameController.text}, ${_selectedTeam}');
    
    // Generate a token for password reset
    final token = _generateToken();
    
    // TODO: Save token in a secure storage in a real app
    print('Token generat: $token');
    
    // Show token to user
    _showTokenDialog(token);
  }

  String _generateToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
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
              'Acest token este cheia de securitate a contului tau. Pastreaza-l intr-un loc sigur, vei avea nevoie de el pentru a-ti reseta parola in caz ca o uiti.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF866C93),
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Am inteles, continua',
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
              'Am inteles',
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
