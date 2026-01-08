import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class SimpleVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> video;

  const SimpleVideoPlayer({super.key, required this.video});

  @override
  State<SimpleVideoPlayer> createState() => _SimpleVideoPlayerState();
}

class _SimpleVideoPlayerState extends State<SimpleVideoPlayer> {
  late String viewId;

  @override
  void initState() {
    super.initState();
    viewId = 'video-${widget.video['id']}';
    _registerVideoElement();
  }

  void _registerVideoElement() {
    final videoUrl = widget.video['video_id'] ?? '';
    
    // Crear elemento de video HTML
    final videoElement = html.VideoElement()
      ..src = videoUrl
      ..controls = true
      ..autoplay = false
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none';

    // Registrar el elemento
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) => videoElement,
    );
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Video Player
            Expanded(
              child: Container(
                width: double.infinity,
                child: HtmlElementView(viewType: viewId),
              ),
            ),
            // Info
            if (widget.video['description'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Text(
                  widget.video['description'],
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}