import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class YouTubeVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> video;

  const YouTubeVideoPlayer({super.key, required this.video});

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late String viewId;
  bool _hasError = false;
  String? _originalUrl;

  @override
  void initState() {
    super.initState();
    viewId = 'video-${widget.video['id']}';
    _registerVideoPlayer();
  }

  void _registerVideoPlayer() {
    final videoIdField = widget.video['video_id'] ?? '';
    
    if (videoIdField.isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    
    String? embedUrl;
    
    // Detectar si es URL de YouTube
    if (videoIdField.contains('youtube.com/watch?v=')) {
      final videoId = videoIdField.split('v=')[1].split('&')[0];
      embedUrl = 'https://www.youtube.com/embed/$videoId?enablejsapi=1';
      _originalUrl = videoIdField; // Guardar URL original para fallback
    } 
    // Detectar si es archivo MP4 de Supabase
    else if (videoIdField.contains('.mp4')) {
      embedUrl = videoIdField;
    }
    // Asumir que es solo el ID de YouTube
    else {
      embedUrl = 'https://www.youtube.com/embed/$videoIdField?enablejsapi=1';
      _originalUrl = 'https://www.youtube.com/watch?v=$videoIdField';
    }
    
    // Crear elemento apropiado
    html.Element element;
    
    if (videoIdField.contains('.mp4')) {
      // Para archivos MP4, usar video element
      element = html.VideoElement()
        ..src = embedUrl!
        ..controls = true
        ..autoplay = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none';
    } else {
      // Para YouTube, usar iframe con manejo de errores
      element = html.IFrameElement()
        ..src = embedUrl!
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      
      // Detectar errores de carga
      element.onError.listen((event) {
        setState(() => _hasError = true);
      });
    }

    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => element,
    );
  }

  Future<void> _openInYouTube() async {
    if (_originalUrl != null) {
      final uri = Uri.parse(_originalUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.video['title'] ?? 'Video',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // YouTube Player o mensaje de error
            Expanded(
              child: _hasError 
                  ? Container(
                      color: Colors.grey.shade900,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white54, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              'Video no disponible',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Este video tiene restricciones de reproducción',
                              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      child: HtmlElementView(viewType: viewId),
                    ),
            ),
            // Video Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.video['description'] != null) ...[
                    Text(
                      'Descripción',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video['description'],
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  if (widget.video['category'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Categoría: ${widget.video['category']}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}