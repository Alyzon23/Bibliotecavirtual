import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_theme.dart';

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
          const SnackBar(content: Text('Libro agregado exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Agregar Libro', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GlassTheme.glassDecoration.gradient,
          ),
        ),
      ),
      body: Container(
        decoration: GlassTheme.decorationBackground,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 900,
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
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalles del Libro', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 24),
                  _buildTextField(controller: _titleController, label: 'Título *', icon: Icons.title),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _authorController, label: 'Autor *', icon: Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _descriptionController, label: 'Descripción', icon: Icons.description, maxLines: 3),
                  const SizedBox(height: 16),
                  
                  // Archivo Picker
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _fileUrlController, 
                          label: 'URL del archivo (PDF/EPUB) *', 
                          icon: Icons.link,
                          hintText: 'https://ejemplo.com/libro.pdf'
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildUploadButton(onPressed: _pickFile, label: 'Subir'),
                    ],
                  ),
                  if (_selectedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Archivo: ${_selectedFile!.name}', style: GoogleFonts.outfit(color: Colors.green[700])),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Cover Picker
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _coverUrlController, 
                          label: 'URL de la portada', 
                          icon: Icons.image,
                          hintText: 'https://ejemplo.com/portada.jpg'
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildUploadButton(onPressed: _pickCover, label: 'Subir'),
                    ],
                  ),
                  if (_selectedCover != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Portada: ${_selectedCover!.name}', style: GoogleFonts.outfit(color: Colors.green[700])),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _isbnController, 
                          label: 'ISBN', 
                          icon: Icons.qr_code
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _yearController, 
                          label: 'Año de publicación', 
                          icon: Icons.calendar_today
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.outfit(color: Colors.grey[800]),
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: GlassTheme.primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    items: _categories.keys.map((category) => 
                      DropdownMenuItem(value: category, child: Text(category, style: GoogleFonts.outfit(color: Colors.grey[800])))
                    ).toList(),
                    onChanged: (value) => setState(() {
                      _selectedCategory = value!;
                      _selectedSubcategory = _categories[value]!.first;
                    }),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedSubcategory,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.outfit(color: Colors.grey[800]),
                    decoration: InputDecoration(
                      labelText: 'Subcategoría',
                      labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: GlassTheme.primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    items: _categories[_selectedCategory]!.map((subcategory) => 
                      DropdownMenuItem(value: subcategory, child: Text(subcategory, style: GoogleFonts.outfit(color: Colors.grey[800])))
                    ).toList(),
                    onChanged: (value) => setState(() => _selectedSubcategory = value!),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.outfit(color: Colors.grey[800]),
                    decoration: InputDecoration(
                      labelText: 'Formato',
                      labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: GlassTheme.primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    items: [
                      DropdownMenuItem(value: 'pdf', child: Text('PDF', style: GoogleFonts.outfit(color: Colors.grey[800]))),
                      DropdownMenuItem(value: 'epub', child: Text('EPUB', style: GoogleFonts.outfit(color: Colors.grey[800]))),
                    ],
                    onChanged: (value) => setState(() => _selectedFormat = value!),
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlassTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _addBook,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Agregar Libro', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.grey[600]),
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: GlassTheme.primaryColor),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildUploadButton({required VoidCallback onPressed, required String label}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: GoogleFonts.outfit()),
    );
  }
}