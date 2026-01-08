import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/glass_theme.dart';

class FuturisticButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const FuturisticButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  State<FuturisticButton> createState() => _FuturisticButtonState();
}

class _FuturisticButtonState extends State<FuturisticButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width ?? double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              _isHovered ? GlassTheme.neonCyan : GlassTheme.primaryColor,
              _isHovered ? GlassTheme.neonPurple : GlassTheme.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? GlassTheme.neonCyan.withOpacity(0.6) 
                  : GlassTheme.primaryColor.withOpacity(0.3),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: GoogleFonts.outfit(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class FuturisticInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;
  final int maxLines;
  final String? hintText;

  const FuturisticInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.onSubmitted,
    this.suffixIcon,
    this.maxLines = 1,
    this.hintText,
  });

  @override
  State<FuturisticInput> createState() => _FuturisticInputState();
}

class _FuturisticInputState extends State<FuturisticInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black.withOpacity(0.3),
          border: Border.all(
            color: _isFocused 
                ? GlassTheme.neonCyan.withOpacity(0.8) 
                : Colors.white.withOpacity(0.1),
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: _isFocused ? [
            BoxShadow(
              color: GlassTheme.neonCyan.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ) 
          ] : [],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onSubmitted: widget.onSubmitted,
          maxLines: widget.maxLines,
          style: GoogleFonts.outfit(color: Colors.white),
          cursorColor: GlassTheme.neonCyan,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: GoogleFonts.outfit(
              color: _isFocused ? GlassTheme.neonCyan : Colors.white70
            ),
            hintText: widget.hintText,
            hintStyle: GoogleFonts.outfit(color: Colors.white30),
            prefixIcon: Icon(
              widget.icon, 
              color: _isFocused ? GlassTheme.neonCyan : Colors.white70
            ),
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            alignLabelWithHint: widget.maxLines > 1,
          ),
        ),
      ),
    );
  }
}

class FuturisticDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const FuturisticDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: const Color(0xFF1E1E2E), // Dark background for dropdown
        iconEnabledColor: GlassTheme.neonCyan,
        style: GoogleFonts.outfit(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: Colors.white70),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
