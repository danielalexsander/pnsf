import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pnsf/theme/app_settings.dart';

// #docregion platform_imports
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class CifraPage extends StatefulWidget {
  final String idCifra;
  final String tituloCifra;
  final String base64Cifra;
  final String? linkCifra;
  final String? tom;

  const CifraPage({
    super.key,
    required this.idCifra,
    required this.tituloCifra,
    required this.base64Cifra,
    this.linkCifra,
    this.tom,
  });

  @override
  State<CifraPage> createState() => _CifraPageState();
}

class _CifraPageState extends State<CifraPage> {
  late final WebViewController _controller;
  int _semitoneOffset = 0;
  late double _fontScale = AppSettings.instance.fontScale;

  static const List<String> _sharps = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];
  static const List<String> _flats = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) => _applyDisplaySettings(),
      ),
    );

    var strCifra = utf8.decode(base64.decode(widget.base64Cifra));
    controller..loadHtmlString(strCifra);

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  String _transposeNote(String note, int semitones) {
    int idx = _sharps.indexOf(note);
    if (idx == -1) idx = _flats.indexOf(note);
    if (idx == -1) return note;
    final newIdx = ((idx + semitones) % 12 + 12) % 12;
    return semitones >= 0 ? _sharps[newIdx] : _flats[newIdx];
  }

  String _transposeChord(String chord, int semitones) {
    final match = RegExp(r'^([A-G][#b]?)(.*)$').firstMatch(chord);
    if (match == null) return chord;
    final root = match.group(1)!;
    final suffix = match.group(2)!;
    final slashIdx = suffix.lastIndexOf('/');
    if (slashIdx != -1) {
      final quality = suffix.substring(0, slashIdx);
      final bass = suffix.substring(slashIdx + 1);
      final bassMatch = RegExp(r'^([A-G][#b]?)(.*)$').firstMatch(bass);
      if (bassMatch != null) {
        return '${_transposeNote(root, semitones)}$quality/${_transposeNote(bassMatch.group(1)!, semitones)}${bassMatch.group(2)!}';
      }
    }
    return _transposeNote(root, semitones) + suffix;
  }

  String get _currentTom {
    if (widget.tom == null || widget.tom!.isEmpty) return '?';
    return _transposeChord(widget.tom!, _semitoneOffset);
  }

  Future<void> _transposeStep(int step) async {
    setState(() => _semitoneOffset += step);

    final js = '''
      (function() {
        var sharps = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
        var flats  = ['C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'];
        var steps = $step;

        function transposeNote(note, s) {
          var idx = sharps.indexOf(note);
          if (idx === -1) idx = flats.indexOf(note);
          if (idx === -1) return note;
          var newIdx = ((idx + s) % 12 + 12) % 12;
          return s > 0 ? sharps[newIdx] : flats[newIdx];
        }

        function transposeChord(token, s) {
          // Extract root note at start (e.g. "C", "C#", "Db")
          var rootMatch = token.match(/^[A-G][#b]?/);
          if (!rootMatch) return token;
          var root = rootMatch[0];
          var rest = token.slice(root.length);
          // Check for bass note at end (e.g. "/E" in "C/E")
          var bassMatch = rest.match(/\\/([A-G][#b]?)\$/);
          if (bassMatch) {
            var quality = rest.slice(0, rest.length - bassMatch[0].length);
            return transposeNote(root, s) + quality + '/' + transposeNote(bassMatch[1], s);
          }
          return transposeNote(root, s) + rest;
        }

        document.querySelectorAll('[id="cifra"]').forEach(function(el) {
          // Split preserving whitespace groups, transpose each non-whitespace token
          var parts = el.textContent.split(/(\\s+)/);
          el.textContent = parts.map(function(part) {
            return /^\\s*\$/.test(part) ? part : transposeChord(part, steps);
          }).join('');
        });
      })();
    ''';

    await _controller.runJavaScript(js);
  }

  Future<void> _applyDisplaySettings() async {
    await _applyFontScale(_fontScale);
    if (AppSettings.instance.darkMode) {
      await _applyDarkMode();
    }
  }

  Future<void> _applyFontScale(double scale) async {
    final js = '''
      (function() {
        var scale = $scale;
        document.querySelectorAll('[style]').forEach(function(el) {
          var currentPx = parseFloat(getComputedStyle(el).fontSize);
          if (!currentPx) return;
          if (!el.dataset.origFontSize) {
            el.dataset.origFontSize = currentPx;
          }
          var base = parseFloat(el.dataset.origFontSize);
          el.style.fontSize = (base * scale) + 'px';
        });
      })();
    ''';
    await _controller.runJavaScript(js);
  }

  Future<void> _applyDarkMode() async {
    const js = '''
      (function() {
        var bg = '#121212';
        var fg = '#e8e8e8';
        document.body.style.backgroundColor = bg;
        document.querySelectorAll('*').forEach(function(el) {
          var cs = getComputedStyle(el);
          if (cs.backgroundColor === 'rgb(255, 255, 255)') {
            el.style.backgroundColor = bg;
          }
          if (cs.color === 'rgb(0, 0, 0)') {
            el.style.color = fg;
          }
        });
      })();
    ''';
    await _controller.runJavaScript(js);
  }

  Future<void> _setFontScale(double scale, void Function(void Function()) setSheetState) async {
    final clamped = scale.clamp(AppSettings.minFontScale, AppSettings.maxFontScale);
    setState(() => _fontScale = clamped);
    setSheetState(() {});
    await AppSettings.instance.setFontScale(clamped);
    await _applyFontScale(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 56, 115),
        title: Text(
          widget.tituloCifra,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'link') {
                _abrirLink();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'link',
                child: Row(
                  children: [
                    Icon(Icons.link, size: 20, color: Color.fromARGB(255, 21, 56, 115)),
                    SizedBox(width: 8),
                    Text('Link'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 21, 56, 115),
        onPressed: _showDisplaySheet,
        child: const Icon(Icons.tune, color: Colors.white),
      ),
    );
  }

  bool get _hasTom => widget.tom != null && widget.tom!.isNotEmpty;

  void _showDisplaySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 21, 56, 115),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasTom) ...[
                      const Text(
                        'Transpor tom',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _sheetStepButton(
                            icon: Icons.remove,
                            onPressed: () {
                              _transposeStep(-1);
                              setSheetState(() {});
                            },
                          ),
                          Text(
                            _currentTom,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _sheetStepButton(
                            icon: Icons.add,
                            onPressed: () {
                              _transposeStep(1);
                              setSheetState(() {});
                            },
                          ),
                        ],
                      ),
                      if (_semitoneOffset != 0) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _transposeStep(-_semitoneOffset);
                            setSheetState(() {});
                          },
                          child: Text(
                            'Voltar ao tom original (${widget.tom})',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: Colors.white24, height: 1),
                      ),
                    ],
                    const Text(
                      'Tamanho da letra',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _sheetStepButton(
                          icon: Icons.remove,
                          onPressed: () => _setFontScale(
                            _fontScale - 0.1,
                            setSheetState,
                          ),
                        ),
                        Text(
                          '${(_fontScale * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _sheetStepButton(
                          icon: Icons.add,
                          onPressed: () => _setFontScale(
                            _fontScale + 0.1,
                            setSheetState,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetStepButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Future<void> _abrirLink() async {
    if (widget.linkCifra == null || widget.linkCifra!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link não disponível')),
        );
      }
      return;
    }

    final Uri url = Uri.parse(widget.linkCifra!);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir link: $e')),
        );
      }
    }
  }
}
