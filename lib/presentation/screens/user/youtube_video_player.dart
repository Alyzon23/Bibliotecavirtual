import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/optimized_theme.dart';

// Solo importar en web
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';

class YouTubeVideoPlayer extends StatefulWidget {
  final Map<String, dynamic> video;

  const YouTubeVideoPlayer({super.key, required this.video});

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  bool _hasError = false;
  String? _originalUrl;
  YoutubePlayerController? _mobileController;
  static final Set<String> _registeredViews = {};

  @override
  void initState() {
    super.initState();
    
    if (!kIsWeb) {
      _initMobilePlayer();
    }
  }

  void _initMobilePlayer() {
    try {
      final videoIdField = widget.video['video_id'] ?? '';
      
      if (videoIdField.isEmpty) {
        setState(() => _hasError = true);
        return;
      }
      
      String? videoId;
      
      // Extraer ID de YouTube
      if (videoIdField.contains('youtube.com/watch?v=')) {
        videoId = videoIdField.split('v=')[1].split('&')[0];
        _originalUrl = videoIdField;
      } else if (videoIdField.contains('youtu.be/')) {
        videoId = videoIdField.split('youtu.be/')[1].split('?')[0];
        _originalUrl = 'https://www.youtube.com/watch?v=$videoId';
      } else if (!videoIdField.contains('.mp4')) {
        videoId = videoIdField;
        _originalUrl = 'https://www.youtube.com/watch?v=$videoId';
      }
      
      if (videoId != null && videoId.isNotEmpty) {
        _mobileController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } else {
        setState(() => _hasError = true);
      }
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _openInYouTube() async {
    if (_originalUrl != null) {
      final uri = Uri.parse(_originalUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildWebPlayer() {
    try {
      final videoIdField = widget.video['video_id'] ?? '';
      
      if (videoIdField.isEmpty) {
        return _buildErrorWidget();
      }
      
      String? videoId;
      
      // Extraer ID de YouTube
      if (videoIdField.contains('youtube.com/watch?v=')) {
        videoId = videoIdField.split('v=')[1].split('&')[0];
        _originalUrl = videoIdField;
      } else if (videoIdField.contains('youtu.be/')) {
        videoId = videoIdField.split('youtu.be/')[1].split('?')[0];
        _originalUrl = 'https://www.youtube.com/watch?v=$videoId';
      } else if (!videoIdField.contains('.mp4')) {
        videoId = videoIdField;
        _originalUrl = 'https://www.youtube.com/watch?v=$videoId';
      }
      
      if (videoId != null && videoId.isNotEmpty) {
        final viewType = 'youtube-iframe-$videoId';
        
        // Registrar el iframe solo una vez
        if (kIsWeb && !_registeredViews.contains(viewType)) {
          _registeredViews.add(viewType);
          ui_web.platformViewRegistry.registerViewFactory(
            viewType,
            (int viewId) {
              final iframe = html.IFrameElement()
                ..src = 'https://www.youtube.com/embed/$videoId?autoplay=0&controls=1'
                ..allowFullscreen = true;
              iframe.style.border = 'none';
              iframe.style.width = '100%';
              iframe.style.height = '100%';
              return iframe;
            },
          );
        }
        
        return Container(
          width: double.infinity,
          height: kIsWeb ? 400 : 250,
          child: HtmlElementView(viewType: viewType),
        );
      } else {
        return _buildErrorWidget();
      }
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'Video no disponible',
              style: OptimizedTheme.bodyText.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (_originalUrl != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openInYouTube,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Ver en YouTube'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () {
          // Recuperar el foco cuando se toca la pantalla
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Header con botón de escape visible
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
                          style: OptimizedTheme.heading3.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_originalUrl != null)
                        IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.white),
                          onPressed: _openInYouTube,
                        ),
                    ],
                  ),
                ),
                // Player
                Flexible(
                  flex: kIsWeb ? 2 : 1,
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
                                  style: OptimizedTheme.bodyText.copyWith(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Este video tiene restricciones de reproducción',
                                  style: OptimizedTheme.bodyTextSmall.copyWith(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                if (_originalUrl != null) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _openInYouTube,
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Ver en YouTube'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : kIsWeb
                          ? _buildWebPlayer()
                          : _mobileController != null
                              ? YoutubePlayer(
                                  controller: _mobileController!,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: Colors.red,
                                  progressColors: const ProgressBarColors(
                                    playedColor: Colors.red,
                                    handleColor: Colors.redAccent,
                                  ),
                                )
                              : Container(
                                  color: Colors.grey.shade900,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
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
                          style: OptimizedTheme.bodyText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.video['description'],
                          style: OptimizedTheme.bodyTextSmall.copyWith(fontSize: 14),
                        ),
                      ],
                      if (widget.video['category'] != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Categoría: ${widget.video['category']}',
                          style: OptimizedTheme.bodyTextSmall.copyWith(
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
        ),
      ),
    );
  }
}