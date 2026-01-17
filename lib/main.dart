import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/optimized_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/reset_password_screen.dart';
import 'presentation/screens/user/user_home.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'data/services/database_seeder.dart';
import 'data/services/supabase_auth_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Inicializar Supabase con manejo de errores
    await Supabase.initialize(
      url: 'https://yrakkfviiybzbwjqotgu.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlyYWtrZnZpaXliemJ3anFvdGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0NDA2MTQsImV4cCI6MjA3NzAxNjYxNH0.hxdFNt7XirJv1PetfL_Cq0rYWDCCJIO963egiiDN-fE',
    );
    
    runApp(const BibliotecaDigitalApp());
    
    // Seed en background después de mostrar la app
    _seedDataInBackground();
  } catch (e) {
    print('Error initializing app: $e');
    // Ejecutar app sin Supabase si hay error
    runApp(const BibliotecaDigitalApp());
  }
}

void _seedDataInBackground() {
  // Ejecutar en background para no bloquear la UI
  Future.delayed(const Duration(seconds: 5), () async {
    try {
      await DatabaseSeeder.seedBooks();
      await DatabaseSeeder.seedVideos();
    } catch (e) {
      print('Error seeding data: $e');
    }
  });
}

class BibliotecaDigitalApp extends StatefulWidget {
  const BibliotecaDigitalApp({super.key});

  @override
  State<BibliotecaDigitalApp> createState() => _BibliotecaDigitalAppState();
}

class _BibliotecaDigitalAppState extends State<BibliotecaDigitalApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _isCheckingSession = true;
  bool _showSplash = !kIsWeb; // Solo mostrar splash en móvil
  Widget _initialScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _checkSession();
    _setupAuthListener();
  }

  Future<void> _checkSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          setState(() {
            _initialScreen = UserHome(authService: SupabaseAuthService());
            _isCheckingSession = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error checking session: $e');
      // Continuar con login screen si hay error
    }
    
    setState(() {
      _isCheckingSession = false;
    });
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      if (event == AuthChangeEvent.passwordRecovery && session != null) {
        _navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: OptimizedTheme.theme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: _showSplash
          ? SplashScreen(
              onComplete: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : _isCheckingSession
              ? const Scaffold(
                  backgroundColor: Color(0xFF0F172A),
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : _initialScreen,
    );
  }
}