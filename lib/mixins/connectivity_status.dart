import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Rastreia o status de conexão e expõe um indicador discreto para a AppBar,
/// substituindo os antigos SnackBars de "tem conexão" / "sem conexão".
mixin ConnectivityStatusState<T extends StatefulWidget> on State<T> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  bool get isOnline =>
      _connectionStatus.contains(ConnectivityResult.wifi) ||
      _connectionStatus.contains(ConnectivityResult.mobile);

  @protected
  void initConnectivityTracking() {
    _checkInitialConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @protected
  void disposeConnectivityTracking() {
    _connectivitySubscription.cancel();
  }

  Future<void> _checkInitialConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }
    if (!mounted) return;
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (!mounted) return;
    setState(() => _connectionStatus = result);
  }

  /// Ícone discreto para colocar em `AppBar.actions`, sem interromper o usuário.
  Widget buildConnectivityIndicator() {
    final online = isOnline;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Tooltip(
        message:
            online ? 'Conectado à internet' : 'Sem conexão · usando dados locais',
        child: Icon(
          online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          color: Colors.white.withOpacity(online ? 0.55 : 0.95),
          size: 20,
        ),
      ),
    );
  }
}
