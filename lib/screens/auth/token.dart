import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final _tokenController = TextEditingController();
  
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
            transform: GradientRotation(107.56 * 3.14159 / 180),
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
                      // Token Field
                      _buildTokenField(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Go back to login link
                InkWell(
                  onTap: () {
                    // Navigate to login screen
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text.rich(
                      TextSpan(
                        text: 'Nu ai token? Înapoi la ',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF866C93),
                        ),
                        children: [
                          TextSpan(
                            text: 'conectare',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
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
                    'Înainte, dovedește că ești tu!',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF77677E),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Caută-ți tokenul secret.',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF866C93),
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
            child: Text(
              'M',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF866C93),
              ),
            ),
          ),
        ],
      ),
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
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF866C93),
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
                child: TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    hintText: 'Introdu tokenul tău',
                    hintStyle: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF77677E),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF77677E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return InkWell(
      onTap: () {
        // Handle token verification
        _verifyToken();
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
          'Verifică token',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF77677E),
          ),
        ),
      ),
    );
  }

  void _verifyToken() {
    // Validate token
    if (_tokenController.text.isEmpty) {
      _showErrorDialog('Introduceți tokenul.');
      return;
    }

    // TODO: Implement token verification logic against stored token
    print('Verificare token: ${_tokenController.text}');
    
    // If token is verified, navigate to reset password
    if (_tokenController.text.length >= 6) {
      Navigator.pushReplacementNamed(context, '/reset_password');
    } else {
      _showErrorDialog('Token invalid.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eroare'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }
}
