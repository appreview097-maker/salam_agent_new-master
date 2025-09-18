import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:salam_agent/routes/routes.dart';

class QRViewScreen extends StatefulWidget {
  const QRViewScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // keep two separate nodes
  final FocusNode _rawKeyboardNode = FocusNode();   // for RawKeyboardListener
  final FocusNode _hiddenTextNode = FocusNode();    // for TextField


  // HID scanner buffer
  final TextEditingController _hiddenController = TextEditingController();
  String _scanBuffer = '';
  Timer? _bufferResetTimer;
  Duration _interCharTimeout = const Duration(milliseconds: 120); // adjust if needed

  int type = Get.arguments['type'];

  @override
  void initState() {
    super.initState();
    // ensure focus grabs keyboard input after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestKeyboardFocus();
    });
  }

  void _requestKeyboardFocus() {
    if (mounted) {
      FocusScope.of(context).requestFocus(_hiddenTextNode);
    }
  }

  // call this when you want to process a scanned value
  void _processScannedValue(String scanned) {
    scanned = scanned.trim();
    if (scanned.isEmpty) return;

    // same behavior you had for camera scan:
    if (type == 0) {
      Get.offNamed(AppRoutes.payment, arguments: {'qrdata': scanned});
    } else {
      Get.offNamed(AppRoutes.verification, arguments: {'qrdata': scanned});
    }
  }

  void _handleCharacter(String? char) {
    if (char == null || char.isEmpty) return;

    // Some scanners send the entire string at once, some send char-by-char
    // The Enter key often comes as '\n' or as a logical Enter key event.
    if (char == '\n' || char == '\r') {
      // Got terminator
      _bufferResetTimer?.cancel();
      final full = _scanBuffer;
      _scanBuffer = '';
      _hiddenController.clear();
      _processScannedValue(full);
      // re-focus for next scan
      _requestKeyboardFocus();
      return;
    }

    // Otherwise append char and restart timer
    _scanBuffer += char;
    _hiddenController.text = _scanBuffer;

    _bufferResetTimer?.cancel();
    _bufferResetTimer = Timer(_interCharTimeout, () {
      // If no more characters for timeout, treat current buffer as complete
      final full = _scanBuffer;
      _scanBuffer = '';
      _hiddenController.clear();
      if (full.isNotEmpty) _processScannedValue(full);
      _requestKeyboardFocus();
    });
  }

  // For RawKeyboard events (some platforms deliver keys here)
  void _onRawKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Prefer character if available
      final String? ch = event.character;
      if (ch != null && ch.isNotEmpty) {
        _handleCharacter(ch);
        return;
      }

      // Fallback: detect Enter key
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        _handleCharacter('\n');
        return;
      }

      // Some scanners send digits as separate key codes without event.character; we can map them:
      final keyLabel = event.logicalKey.keyLabel;
      if (keyLabel.isNotEmpty) {
        _handleCharacter(keyLabel);
      }
    }
  }

  // camera QR code created
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          controller.pauseCamera();
          final qrdata = result!.code;
          if (type == 0) {
            Get.offNamed(AppRoutes.payment, arguments: {'qrdata': qrdata});
          } else {
            Get.offNamed(AppRoutes.verification, arguments: {'qrdata': qrdata});
          }
        }
      });
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.resumeCamera();
    _requestKeyboardFocus();
  }

  @override
  void dispose() {
    _bufferResetTimer?.cancel();
    controller?.dispose();
    _hiddenController.dispose();
    _rawKeyboardNode.dispose();
    _hiddenTextNode.dispose();
    super.dispose();
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width) - 50;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with RawKeyboardListener to capture keyboard events (HID scanners)
    return RawKeyboardListener(
      focusNode: _rawKeyboardNode,
      autofocus: true,
      onKey: _onRawKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Scanner le numero du destinataire',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(flex: 4, child: _buildQrView(context)),
                Container(
                  color: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon:
                        const Icon(Icons.flash_on, color: Colors.white, size: 30),
                        onPressed: () async {
                          await controller?.toggleFlash();
                        },
                      ),
                      IconButton(
                        icon:
                        const Icon(Icons.cancel, color: Colors.white, size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip_camera_android,
                            color: Colors.white, size: 30),
                        onPressed: () async {
                          await controller?.flipCamera();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Hidden TextField — keeps focus and provides fallback for some scanners
            // Use Offstage so it doesn't affect layout
            Offstage(
              offstage: true,
              child: TextField(
                controller: _hiddenController,
                focusNode: _hiddenTextNode,
                autofocus: true,
                enableSuggestions: false,
                autocorrect: false,
                readOnly: true,       // ✅ stops keyboard
                showCursor: false,    // ✅ hides cursor
                keyboardType: TextInputType.none, // extra safety
                onChanged: (value) {
                  // In case the scanner inserts the whole value at once into the TextField,
                  // we can detect Enter via onSubmitted or watch value + timeout.
                  // We'll simply mirror into buffer: if it ends with newline we process.
                  if (value.endsWith('\n') || value.endsWith('\r')) {
                    final scanned = value.replaceAll(RegExp(r'[\r\n]$'), '');
                    _hiddenController.clear();
                    _scanBuffer = '';
                    _processScannedValue(scanned);
                    _requestKeyboardFocus();
                  } else {
                    // If scanner sends whole string without newline, this will catch it via timer
                    _scanBuffer = value;
                    _bufferResetTimer?.cancel();
                    _bufferResetTimer = Timer(_interCharTimeout, () {
                      final full = _scanBuffer;
                      _scanBuffer = '';
                      _hiddenController.clear();
                      if (full.isNotEmpty) _processScannedValue(full);
                      _requestKeyboardFocus();
                    });
                  }
                },
                onSubmitted: (value) {
                  final scanned = value.trim();
                  _hiddenController.clear();
                  _scanBuffer = '';
                  if (scanned.isNotEmpty) _processScannedValue(scanned);
                  _requestKeyboardFocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
