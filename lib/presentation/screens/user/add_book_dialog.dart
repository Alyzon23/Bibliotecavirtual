import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
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
    return AlertDialog(
      title: const Text('Agregar Libro'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Título *'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Autor *'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categories.keys.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    selectedSubcategory = categories[value]!.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey(selectedCategory),
                value: selectedSubcategory,
                decoration: const InputDecoration(labelText: 'Subcategoría'),
                items: categories[selectedCategory]!.map((subcategory) {
                  return DropdownMenuItem(value: subcategory, child: Text(subcategory));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubcategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'URL de portada'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'URL del archivo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('O'),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'epub'],
                        );
                        
                        if (result != null && result.files.single.bytes != null) {
                          final file = result.files.first;
                          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
                          
                          await Supabase.instance.client.storage
                              .from('books')
                              .uploadBinary(fileName, file.bytes!);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Archivo subido: ${file.name}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Subir archivo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: 'PDF',
                decoration: const InputDecoration(labelText: 'Formato'),
                items: const [
                  DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                  DropdownMenuItem(value: 'EPUB', child: Text('EPUB')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'ISBN'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Año de publicación'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}