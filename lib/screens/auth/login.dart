import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordController = TextEditingController();
  
  String? _selectedAgent;
  final List<String> _agents = ['Agent 1', 'Agent 2', 'Agent 3'];
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
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
                      // Agent Selection
                      _buildAgentDropdown(),
                      
                      const SizedBox(height: 8),
                      
                      // Password Field
                      _buildPasswordField(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Register Link
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'Nu ai un cont de consultant? ',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.25, // line-height: 20px / font-size: 16px = 1.25
                        color: const Color(0xFF866C93),
                      ),
                      children: [
                        TextSpan(
                          text: 'Creaza unul!',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600, // Changed to 600 for emphasis
                            height: 1.25,
                            color: const Color(0xFF77677E), // Darker color for emphasis
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, '/register');
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Login Button
                _buildLoginButton(),
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
                    'E timpul sa facem cifre!',
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
                    'Sper ca ai dormit bine, clientii asteapta!',
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

  Widget _buildAgentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Agent',
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
                'Selecteaza agent',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.28, // line-height: 23px / font-size: 18px = 1.28
                  color: const Color(0xFF77677E),
                ),
              ),
              value: _selectedAgent,
              icon: SvgPicture.asset(
                'assets/DropdownButton.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF695C70),
                  BlendMode.srcIn,
                ),
              ),
              items: _agents.map((String agent) {
                return DropdownMenuItem<String>(
                  value: agent,
                  child: Text(
                    agent,
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
                  _selectedAgent = newValue;
                });
              },
              dropdownColor: const Color(0xFFC3B6C9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Parola',
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
                  padding: const EdgeInsets.only(left: 16),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true, // Always obscure password
                    decoration: InputDecoration(
                      hintText: 'Introdu parola',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.28, // line-height: 23px / font-size: 18px = 1.28
                        color: const Color(0xFF77677E),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero, // Remove padding from TextField
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
              // Reset Password Button
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/HelpButton.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF77677E),
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    // Navigate to token screen for password reset
                    Navigator.pushNamed(context, '/token');
                  },
                  tooltip: 'Am uitat parola',
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

  Widget _buildLoginButton() {
    return InkWell(
      onTap: () {
        // Handle login
        _login();
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
          'Conectare',
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

  void _login() {
    // Validate fields
    if (_selectedAgent == null || _passwordController.text.isEmpty) {
      _showErrorDialog('Completați toate câmpurile.');
      return;
    }

    // TODO: Implement login logic
    print('Login: $_selectedAgent');
    
    // Navigate to dashboard
    Navigator.pushReplacementNamed(context, '/dashboard');
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
