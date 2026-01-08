import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_theme.dart';
import '../../widgets/futuristic_widgets.dart';

class AddVideoDialog extends StatefulWidget {
  const AddVideoDialog({super.key});

  @override
  State<AddVideoDialog> createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends State<AddVideoDialog> {
  String selectedCategory = 'Desarrollo de Software';
  String selectedSubcategory = 'Frontend';
  
  final categories = {
    'Desarrollo de Software': ['Frontend', 'Backend', 'Móvil', 'Base de Datos'],
    'Marketing': ['Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
    'Guía Nacional de Turismo': ['Costas', 'Sierra', 'Oriente', 'Galápagos'],
    'Arte Culinaria': ['Cocina Nacional', 'Cocina Internacional', 'Repostería', 'Bebidas'],
    'Idiomas': ['Inglés', 'Francés', 'Alemán', 'Italiano']
  };

  @override
  void initState() {
    super.initState();
    selectedSubcategory = categories[selectedCategory]!.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassmorphicContainer(
        width: 500,
        height: 650, // More height for spacing
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassTheme.neonBlue.withOpacity(0.5),
            GlassTheme.neonPurple.withOpacity(0.5),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agregar Video',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                FuturisticInput(
                  controller: TextEditingController(), // TODO: use real controllers if needed
                  label: 'Título del video *',
                  icon: Icons.movie_creation_outlined,
                ),
                const SizedBox(height: 20),
                
                FuturisticInput(
                  controller: TextEditingController(),
                  label: 'URL del video *',
                  icon: Icons.link,
                  hintText: 'https://youtube.com/...',
                ),
                const SizedBox(height: 20),
                
                FuturisticInput(
                  controller: TextEditingController(),
                  label: 'URL de miniatura',
                  icon: Icons.image_outlined,
                ),
                
                const SizedBox(height: 20),
                
                FuturisticDropdown<String>(
                  value: selectedCategory,
                  label: 'Categoría',
                  items: categories.keys.map((category) => 
                    DropdownMenuItem(value: category, child: Text(category, style: GoogleFonts.outfit(color: Colors.white)))
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      selectedSubcategory = categories[value]!.first;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                FuturisticDropdown<String>(
                  value: selectedSubcategory,
                  label: 'Subcategoría',
                  items: categories[selectedCategory]!.map((subcategory) => 
                    DropdownMenuItem(value: subcategory, child: Text(subcategory, style: GoogleFonts.outfit(color: Colors.white)))
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubcategory = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                FuturisticInput(
                  controller: TextEditingController(),
                  label: 'Descripción',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 32),
                
                FuturisticButton(
                  onPressed: () => Navigator.pop(context), // Mock action
                  text: 'GUARDAR VIDEO',
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}