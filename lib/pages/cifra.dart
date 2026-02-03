import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class CifraPage extends StatefulWidget {
  final String idCifra;
  final String tituloCifra;
  final String base64Cifra;
  final String? linkCifra;
  const CifraPage({
    super.key,
    required this.idCifra,
    required this.tituloCifra,
    required this.base64Cifra,
    this.linkCifra,
  });

  @override
  State<CifraPage> createState() => _CifraPageState();
}

class _CifraPageState extends State<CifraPage> {
  late final WebViewController _controller;

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
                    Icon(Icons.link, size: 20,),
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

enum MenuOptions {
  loadHtmlString,
}

class SampleMenu extends StatelessWidget {
  SampleMenu({
    super.key,
    required this.webViewController,
  });

  final WebViewController webViewController;
  late final WebViewCookieManager cookieManager = WebViewCookieManager();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuOptions>(
      key: const ValueKey<String>('ShowPopupMenu'),
      onSelected: (MenuOptions value) {
        switch (value) {
          case MenuOptions.loadHtmlString:
            _onLoadHtmlStringExample();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
        const PopupMenuItem<MenuOptions>(
          value: MenuOptions.loadHtmlString,
          child: Text('Load HTML string'),
        ),
      ],
    );
  }

  Future<void> _onLoadHtmlStringExample() {
    var strCifra = utf8.decode(base64.decode('widget.base64Cifra'));

    return webViewController.loadHtmlString(strCifra);
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }
}
