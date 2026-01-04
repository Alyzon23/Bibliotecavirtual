import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../auth/login_screen.dart';
import '../user/user_home.dart';

class TeacherDashboard extends StatefulWidget {
  final SupabaseAuthService authService;
  
  const TeacherDashboard({super.key, required this.authService});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  void _logout() {
    widget.authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Row(
                children: [
                  const Icon(Icons.school, size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  Text(
                    'Panel Profesor',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: UserHome(authService: widget.authService),
            ),
          ],
        ),
      ),
    );
  }
}