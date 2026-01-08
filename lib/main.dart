import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/reset_password_screen.dart';
import 'presentation/screens/admin/admin_dashboard.dart';
import 'presentation/screens/admin/librarian_dashboard.dart';
import 'presentation/screens/admin/teacher_dashboard.dart';
import 'presentation/screens/user/user_home.dart';
import 'data/services/database_seeder.dart';
import 'data/services/supabase_auth_service.dart';
import 'domain/dependency_injection.dart';

// Clase global para manejar el tema
class ThemeManager {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);
  
  static void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
  
  static bool get currentTheme => isDarkMode.value;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://yrakkfviiybzbwjqotgu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlyYWtrZnZpaXliemJ3anFvdGd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0NDA2MTQsImV4cCI6MjA3NzAxNjYxNH0.hxdFNt7XirJv1PetfL_Cq0rYWDCCJIO963egiiDN-fE',
  );
  
  // Inicializar DI
  DI.init();
  
  runApp(const BibliotecaDigitalApp());
  
  // Seed en background después de mostrar la app
  _seedDataInBackground();
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
          // Cargar UserHome inmediatamente, los datos del usuario se cargan después
          setState(() {
            _initialScreen = UserHome(authService: SupabaseAuthService());
            _isCheckingSession = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error checking session: $e');
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
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeManager.isDarkMode,
      builder: (context, darkMode, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          home: _isCheckingSession
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : _initialScreen,
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca Digital'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 80, color: Colors.indigo),
            SizedBox(height: 20),
            Text(
              'Bienvenido a tu Biblioteca Digital',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Accede a miles de libros en PDF y EPUB',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}