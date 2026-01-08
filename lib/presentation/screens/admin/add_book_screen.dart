import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_theme.dart';
import '../../widgets/futuristic_widgets.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _isbnController = TextEditingController();
  final _yearController = TextEditingController();
  
  PlatformFile? _selectedFile;
  PlatformFile? _selectedCover;
  
  String _selectedFormat = 'pdf';
  String _selectedCategory = 'Desarrollo de Software';
  String _selectedSubcategory = 'Frontend';
  bool _isLoading = false;

  final Map<String, List<String>> _categories = {
    'Desarrollo de Software': ['Frontend', 'Backend', 'Móvil', 'Base de Datos'],
    'Marketing': ['Digital', 'Tradicional', 'Redes Sociales', 'SEO'],
    'Guía Nacional de Turismo': ['Destinos', 'Hoteles', 'Restaurantes', 'Actividades'],
    'Arte Culinaria': ['Cocina Nacional', 'Cocina Internacional', 'Repostería', 'Bebidas'],
    'Idioma': ['Inglés', 'Francés', 'Alemán', 'Portugués'],
  };

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
        _fileUrlController.text = 'Archivo seleccionado: ${_selectedFile!.name}';
      });
    }
  }

  Future<void> _pickCover() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedCover = result.files.single;
        _coverUrlController.text = 'Imagen seleccionada: ${_selectedCover!.name}';
      });
    }
  }

  Future<void> _addBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa título y autor')),
      );
      return;
    }

    if (_fileUrlController.text.isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega URL o selecciona archivo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? fileUrl;
      String? coverUrl;

      // Subir archivo si es local
      if (_selectedFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_titleController.text.replaceAll(' ', '_')}.$_selectedFormat';
        
        if (_selectedFile!.bytes != null) {
          await Supabase.instance.client.storage
              .from('books')
              .uploadBinary(fileName, _selectedFile!.bytes!);
          
          fileUrl = Supabase.instance.client.storage
              .from('books')
              .getPublicUrl(fileName);
        }
      } else {
        fileUrl = _fileUrlController.text;
      }

      // Subir portada si es local
      if (_selectedCover != null) {
        final coverName = '${DateTime.now().millisecondsSinceEpoch}_cover_${_titleController.text.replaceAll(' ', '_')}.jpg';
        
        if (_selectedCover!.bytes != null) {
          await Supabase.instance.client.storage
              .from('covers')
              .uploadBinary(coverName, _selectedCover!.bytes!);
          
          coverUrl = Supabase.instance.client.storage
              .from('covers')
              .getPublicUrl(coverName);
        }
      } else if (_coverUrlController.text.isNotEmpty && !_coverUrlController.text.contains('seleccionada')) {
        coverUrl = _coverUrlController.text;
      }

      await Supabase.instance.client.from('books').insert({
        'title': _titleController.text,
        'author': _authorController.text,
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'file_url': fileUrl,
        'cover_url': coverUrl,
        'isbn': _isbnController.text.isEmpty ? null : _isbnController.text,
        'year': _yearController.text.isEmpty ? null : int.tryParse(_yearController.text),
        'format': _selectedFormat,
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'categories': [_selectedCategory],
        'published_date': DateTime.now().toIso8601String().split('T')[0],
        'created_by': Supabase.instance.client.auth.currentUser?.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Libro agregado exitosamente', style: GoogleFonts.outfit()),
            backgroundColor: GlassTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e', style: GoogleFonts.outfit()), backgroundColor: Colors.redAccent),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Agregar Libro', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                GlassTheme.neonPurple.withOpacity(0.3),
                GlassTheme.neonBlue.withOpacity(0.3),
              ],
            ),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
        ),
      ),
      body: Container(
        decoration: GlassTheme.decorationBackground,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
          child: Column(
            children: [
              GlassmorphicContainer(
                width: double.infinity,
                height: 950,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Libro', 
                        style: GoogleFonts.outfit(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: GlassTheme.neonCyan
                        )
                      ),
                      const SizedBox(height: 32),
                      
                      FuturisticInput(
                        controller: _titleController, 
                        label: 'Título', 
                        icon: Icons.title
                      ),
                      const SizedBox(height: 20),
                      
                      FuturisticInput(
                        controller: _authorController, 
                        label: 'Autor', 
                        icon: Icons.person_outline
                      ),
                      const SizedBox(height: 20),
                      
                      FuturisticInput(
                        controller: _descriptionController, 
                        label: 'Descripción', 
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      
                      // Archivo Picker
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: FuturisticInput(
                              controller: _fileUrlController, 
                              label: 'URL archivo (PDF/EPUB)', 
                              icon: Icons.link,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: FuturisticButton(
                              onPressed: _pickFile, 
                              text: 'SUBIR',
                              icon: Icons.upload_file,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            '✓ ${_selectedFile!.name}', 
                            style: GoogleFonts.outfit(color: GlassTheme.successColor, fontSize: 13),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Cover Picker
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: FuturisticInput(
                              controller: _coverUrlController, 
                              label: 'URL Portada', 
                              icon: Icons.image_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: FuturisticButton(
                              onPressed: _pickCover, 
                              text: 'SUBIR',
                              icon: Icons.image,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedCover != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            '✓ ${_selectedCover!.name}', 
                            style: GoogleFonts.outfit(color: GlassTheme.successColor, fontSize: 13),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: FuturisticInput(
                              controller: _isbnController, 
                              label: 'ISBN', 
                              icon: Icons.qr_code
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FuturisticInput(
                              controller: _yearController, 
                              label: 'Año', 
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      FuturisticDropdown<String>(
                        value: _selectedCategory,
                        label: 'Categoría',
                        items: _categories.keys.map((category) => 
                          DropdownMenuItem(value: category, child: Text(category, style: GoogleFonts.outfit(color: Colors.white)))
                        ).toList(),
                        onChanged: (value) => setState(() {
                          _selectedCategory = value!;
                          _selectedSubcategory = _categories[value]!.first;
                        }),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      FuturisticDropdown<String>(
                        value: _selectedSubcategory,
                        label: 'Subcategoría',
                        items: _categories[_selectedCategory]!.map((subcategory) => 
                          DropdownMenuItem(value: subcategory, child: Text(subcategory, style: GoogleFonts.outfit(color: Colors.white)))
                        ).toList(),
                        onChanged: (value) => setState(() => _selectedSubcategory = value!),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      FuturisticDropdown<String>(
                        value: _selectedFormat,
                        label: 'Formato',
                        items: [
                          DropdownMenuItem(value: 'pdf', child: Text('PDF', style: GoogleFonts.outfit(color: Colors.white))),
                          DropdownMenuItem(value: 'epub', child: Text('EPUB', style: GoogleFonts.outfit(color: Colors.white))),
                        ],
                        onChanged: (value) => setState(() => _selectedFormat = value!),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      FuturisticButton(
                        onPressed: _isLoading ? null : _addBook, 
                        text: 'AGREGAR LIBRO',
                        isLoading: _isLoading,
                        icon: Icons.add_circle_outline,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}