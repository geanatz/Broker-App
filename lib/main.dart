import 'package:flutter/material.dart';
import 'screens/auth/register.dart';
import 'screens/auth/login.dart';
import 'screens/auth/reset_password.dart';
import 'screens/auth/token.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Broker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        // mil sugu?
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF866C93),
          primary: const Color(0xFF77677E),
          secondary: const Color(0xFF866C93),
          background: const Color(0xFFF2F2F2),
        ),
        fontFamily: 'Outfit',
      ),
      initialRoute: '/register',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/token': (context) => const TokenScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) => const Placeholder(),
      },
    );
  }
}
