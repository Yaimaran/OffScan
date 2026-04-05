import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OffScanApp());
}

/// Main application entry point.
class OffScanApp extends StatelessWidget {
  const OffScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OffScan',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const ScannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Main scanner screen.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  /// Controller for local ML Kit processing.
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.all],
    returnImage: true,
  );

  bool _isScanning = true;
  String _scanResult = '';
  Uint8List? _frozenImage;

  // --- Barcode Detection ---
  /// Processes camera feed and triggers sheet on detection.
  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() {
        _isScanning = false;
        _scanResult = barcodes.first.rawValue!;
        _frozenImage = capture.image;
      });
      HapticFeedback.vibrate();
      _showResultSheet();
    }
  }

  // --- Gallery Scan ---
  /// Scans barcodes from saved photos.
  Future<void> _scanFromGallery() async {
    HapticFeedback.vibrate();
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imgBytes = await image.readAsBytes();
      final capture = await _controller.analyzeImage(image.path);
      if (!mounted) return;

      if (capture != null && capture.barcodes.isNotEmpty) {
        setState(() {
          _isScanning = false;
          _scanResult = capture.barcodes.first.rawValue ?? '';
          _frozenImage = imgBytes;
        });
        HapticFeedback.vibrate();
        _showResultSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white,
            content: const Text(
              'No barcode or QR code found in this image.',
              style: TextStyle(color: Colors.black),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gallery scan error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: const Text('Failed to process gallery image.', style: TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // --- Reset state cleanly ---
  void _resetScanner() {
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _scanResult = '';
      _frozenImage = null;
    });
    _controller.start();
  }

  // --- Help / Instructions ---
  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Icon(Icons.help_outline, color: Colors.white54, size: 40)),
              const SizedBox(height: 16),
              const Text(
                'OffScan Instructions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome to OffScan.\n\n'
                '• Point your camera at any barcode or QR code.\n'
                '• Gallery icon (left) scans an existing image.\n'
                '• Camera icon (center) triggers focus feedback.\n'
                '• Flip icon (top-left) switches front/rear camera.\n\n'
                'All data is processed fully offline.\n'
                'Support: cfungame@gmail.com',
                style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Scan Result Sheet ---
  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      elevation: 0,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
        ),
        child: SafeArea(
          bottom: true,
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(
                  _scanResult,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        HapticFeedback.vibrate();
                        try {
                          await Clipboard.setData(ClipboardData(text: _scanResult));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.white,
                              content: const Text('Copied to clipboard', style: TextStyle(color: Colors.black)),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.copy, size: 20),
                      label: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3C3C3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        HapticFeedback.vibrate();
                        try {
                          await SharePlus.instance.share(ShareParams(text: _scanResult, subject: 'OffScan Result'));
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.share, size: 20),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    Navigator.pop(ctx);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Rescan'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(_resetScanner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed 
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // Frozen image overlay
          if (_frozenImage != null) ...[
            Positioned.fill(child: Image.memory(_frozenImage!, fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black26)),
          ],

          // Scan target corners
          if (_frozenImage == null)
            const Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(painter: CornerPainter()),
              ),
            ),

          // Top header
          Positioned(
            top: 70,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 55, height: 55,
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.vibrate();
                      _controller.switchCamera();
                    },
                    icon: const Icon(Icons.sync, color: Colors.white, size: 30),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'OffScan',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.0,
                        shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 55, height: 55,
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.vibrate();
                      _showHelpSheet();
                    },
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),

          // Bottom action buttons
          if (_frozenImage == null)
            Positioned(
              bottom: 70,
              left: 32,
              right: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        color: Colors.black12,
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _scanFromGallery,
                        child: const SizedBox(
                          width: 55, height: 55,
                          child: Icon(Icons.photo_library, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                  // Shutter
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          HapticFeedback.vibrate();
                          if (_scanResult.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.white,
                                content: const Text(
                                  'Searching... hold steady over a QR or barcode.',
                                  style: TextStyle(color: Colors.black),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Container(
                            width: 60, height: 60,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(Icons.camera_alt, color: Colors.black87, size: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Flashlight
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _controller,
                    builder: (context, state, _) {
                      final isOn = state.torchState == TorchState.on;
                      return Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOn ? Colors.white : Colors.black12,
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              HapticFeedback.vibrate();
                              _controller.toggleTorch();
                            },
                            child: SizedBox(
                              width: 55, height: 55,
                              child: Icon(
                                isOn ? Icons.flash_on : Icons.flash_off,
                                color: isOn ? Colors.black87 : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Renders the target brackets in the center of the camera.
class CornerPainter extends CustomPainter {
  const CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double len = size.width * 0.10;
    const double r = 32.0;

    // Top Left
    canvas.drawPath(
      Path()..moveTo(0, len)..arcToPoint(Offset(r, 0), radius: const Radius.circular(r))..lineTo(len, 0),
      paint,
    );
    // Top Right
    canvas.drawPath(
      Path()..moveTo(size.width - len, 0)..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))..lineTo(size.width, len),
      paint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()..moveTo(size.width, size.height - len)..arcToPoint(Offset(size.width - r, size.height), radius: const Radius.circular(r))..lineTo(size.width - len, size.height),
      paint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()..moveTo(len, size.height)..arcToPoint(Offset(0, size.height - r), radius: const Radius.circular(r))..lineTo(0, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
