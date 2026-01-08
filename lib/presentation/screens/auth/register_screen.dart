import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../../theme/glass_theme.dart';
import '../../widgets/futuristic_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Las contraseñas no coinciden', style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await _authService.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registro exitoso', style: GoogleFonts.outfit()),
          backgroundColor: GlassTheme.successColor,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el registro', style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: GlassTheme.decorationBackground,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassmorphicContainer(
                  width: 450,
                  height: 700,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: GlassTheme.neonPurple.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: GlassTheme.neonPurple.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(Icons.person_add, size: 50, color: GlassTheme.neonPurple),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Crear Cuenta',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        FuturisticInput(
                          controller: _nameController,
                          label: 'Nombre completo',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        FuturisticInput(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        FuturisticInput(
                          controller: _passwordController,
                          label: 'Contraseña',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        FuturisticInput(
                          controller: _confirmPasswordController,
                          label: 'Confirmar contraseña',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        FuturisticButton(
                          onPressed: _isLoading ? null : _register,
                          text: 'REGISTRARSE',
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta? ',
                              style: GoogleFonts.outfit(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              ),
                              child: Text(
                                'Inicia sesión',
                                style: GoogleFonts.outfit(
                                  color: GlassTheme.neonCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}