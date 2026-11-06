import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// What reading a QR code with the camera gave.
sealed class QrScanResult {
  const QrScanResult();
}

/// A code was read; its text may be anything.
class QrScanned extends QrScanResult {
  const QrScanned(this.text);
  final String text;
}

/// The player closed the camera.
class QrScanCancelled extends QrScanResult {
  const QrScanCancelled();
}

/// The camera permission was refused.
class QrCameraDenied extends QrScanResult {
  const QrCameraDenied();
}

/// Reads one QR code; behind an interface so tests need no camera.
abstract interface class QrScanner {
  Future<QrScanResult> scan(BuildContext context);
}

/// The phone camera (package mobile_scanner). Android asks for the camera
/// permission only when this opens.
class CameraQrScanner implements QrScanner {
  const CameraQrScanner();

  @override
  Future<QrScanResult> scan(BuildContext context) async {
    final result = await Navigator.of(context)
        .push<QrScanResult>(MaterialPageRoute(builder: (_) => const QrScanScreen()));
    return result ?? const QrScanCancelled();
  }
}

/// Full-screen camera view; closes with the first QR code it reads.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  var _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish(QrScanResult result) {
    if (_done) return;
    _done = true;
    Navigator.of(context).pop(result);
  }

  void _onDetect(BarcodeCapture capture) {
    final text = capture.barcodes.map((b) => b.rawValue).nonNulls.firstOrNull;
    if (text != null) _finish(QrScanned(text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _finish(const QrCameraDenied());
                });
              }
              return const ColoredBox(color: Colors.black);
            },
          ),
          // Where to point the camera.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    tooltip: l10n.back,
                    sound: UiSound.back,
                    onPressed: () => _finish(const QrScanCancelled()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(l10n.qrScanTitle, style: AppTypography.h2(color: AppColors.paper)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
