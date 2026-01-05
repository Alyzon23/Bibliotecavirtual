import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: const Text('Agregar Video'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Título del video *'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'URL del video *'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'URL de miniatura'),
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