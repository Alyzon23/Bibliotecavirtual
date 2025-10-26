import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

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
  
  PlatformFile? _selectedFile;
  PlatformFile? _selectedCover;
  
  String _selectedFormat = 'pdf';
  bool _isLoading = false;

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
        'description': _descriptionController.text,
        'file_url': fileUrl,
        'cover_url': coverUrl,
        'format': _selectedFormat,
        'categories': ['General'],
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
      appBar: AppBar(
        title: const Text('Agregar Libro'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Autor *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fileUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL del archivo (PDF/EPUB) *',
                      border: OutlineInputBorder(),
                      hintText: 'https://ejemplo.com/libro.pdf',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Subir'),
                ),
              ],
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Archivo: ${_selectedFile!.name}', style: const TextStyle(color: Colors.green)),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coverUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de la portada',
                      border: OutlineInputBorder(),
                      hintText: 'https://ejemplo.com/portada.jpg',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pickCover,
                  child: const Text('Subir'),
                ),
              ],
            ),
            if (_selectedCover != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Portada: ${_selectedCover!.name}', style: const TextStyle(color: Colors.green)),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              decoration: const InputDecoration(
                labelText: 'Formato',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'epub', child: Text('EPUB')),
              ],
              onChanged: (value) => setState(() => _selectedFormat = value!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addBook,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Agregar Libro'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}