import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/glass_theme.dart';

class SimpleBookReader extends StatefulWidget {
  final Map<String, dynamic> book;

  const SimpleBookReader({super.key, required this.book});

  @override
  State<SimpleBookReader> createState() => _SimpleBookReaderState();
}

class _SimpleBookReaderState extends State<SimpleBookReader> {
  final PdfViewerController _pdfController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.brown.shade300, width: 3),
                    ),
                    child: SfPdfViewer.network(
                      widget.book['file_url'],
                      controller: _pdfController,
                      pageLayoutMode: PdfPageLayoutMode.single,
                      scrollDirection: PdfScrollDirection.horizontal,
                      pageSpacing: 0,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        setState(() {
                          _totalPages = details.document.pages.count;
                        });
                      },
                      onPageChanged: (PdfPageChangedDetails details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.brown.shade800,
            Colors.brown.shade600,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book['title'] ?? 'Libro',
                  style: GoogleFonts.crimsonText(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.book['author'] ?? 'Autor desconocido',
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.brown.shade800,
            Colors.brown.shade600,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Página anterior
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: _currentPage > 1
                  ? () => _pdfController.previousPage()
                  : null,
              icon: Icon(
                Icons.chevron_left,
                color: _currentPage > 1 ? Colors.white : Colors.white30,
                size: 32,
              ),
            ),
          ),
          
          // Indicador de página con estilo de libro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.brown.shade400, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Página $_currentPage de $_totalPages',
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
          ),
          
          // Página siguiente
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: _currentPage < _totalPages
                  ? () => _pdfController.nextPage()
                  : null,
              icon: Icon(
                Icons.chevron_right,
                color: _currentPage < _totalPages ? Colors.white : Colors.white30,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}