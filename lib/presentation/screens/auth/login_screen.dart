import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../../../data/services/test_users_service.dart';
import '../../theme/glass_theme.dart';
import '../../widgets/futuristic_widgets.dart';
import '../user/user_home.dart';
import '../admin/admin_dashboard.dart';
import '../admin/librarian_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    await _saveCredentials();
    
    final success = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final userRole = _authService.currentUser?.role.toString().split('.').last ?? 'lector';
      print('🔍 Debug - Rol encontrado: $userRole');
      
      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserHome(authService: _authService),
          ),
        );
      } else if (userRole == 'bibliotecario') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LibrarianDashboard(authService: _authService),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserHome(authService: _authService),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Credenciales incorrectas', style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/vision.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0F0C29).withOpacity(0.8),
                const Color(0xFF302B63).withOpacity(0.6),
                const Color(0xFF24243e).withOpacity(0.8),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildWebLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        // Left Side - Logo and Mission/Vision
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: GlassTheme.neonCyan.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: GlassTheme.neonCyan.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/yavirac.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 70, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Mission and Vision
                  GlassmorphicContainer(
                    width: 600,
                    height: 350,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        GlassTheme.neonCyan.withOpacity(0.5),
                        GlassTheme.neonPurple.withOpacity(0.5),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NUESTRA MISIÓN',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: GlassTheme.neonCyan,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Formar profesionales de excelencia enfocados en Ciencia, Tecnología y Sociedad.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'NUESTRA VISIÓN',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: GlassTheme.neonPurple,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Al 2027 el Instituto Superior Tecnológico de Turismo y Patrimonio Yavirac será una institución de vanguardia en la formación tecnológica y conservación del patrimonio.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right Side - Login Form
        Expanded(
          flex: 2,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(40),
                margin: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bienvenido',
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accede a tu biblioteca digital',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildLoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassmorphicContainer(
              width: double.infinity,
              height: 600,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GlassTheme.neonCyan.withOpacity(0.5),
                  GlassTheme.neonPurple.withOpacity(0.5),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GlassTheme.neonCyan.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: GlassTheme.neonCyan.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(Icons.auto_stories, size: 50, color: GlassTheme.neonCyan),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Biblioteca Digital',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        FuturisticInput(
          controller: _emailController,
          label: 'Email',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        FuturisticInput(
          controller: _passwordController,
          label: 'Contraseña',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          onSubmitted: (_) => _login(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white54),
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: GlassTheme.neonCyan,
                      checkColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Recordar',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Olvidé contraseña',
                style: GoogleFonts.outfit(color: GlassTheme.neonCyan, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        FuturisticButton(
          onPressed: _isLoading ? null : _login,
          text: 'INICIAR SESIÓN',
          isLoading: _isLoading,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes cuenta? ',
              style: GoogleFonts.outfit(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              ),
              child: Text(
                'Regístrate',
                style: GoogleFonts.outfit(
                  color: GlassTheme.neonPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}