import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OffScanApp());
}

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

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.all],
    returnImage: true, 
  );
  
  bool _isScanning = true;
  String _scanResult = "";
  Uint8List? _frozenImage;
  
  // Pinch-to-Zoom Control
  double _baseZoomScale = 0.0;
  double _currentZoomScale = 0.0;
  
  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      if (barcodes.first.rawValue != null) {
        setState(() {
          _isScanning = false;
          _scanResult = barcodes.first.rawValue!;
          _frozenImage = capture.image; 
        });
        
        HapticFeedback.vibrate();
        
        _showLensStyleBottomSheet();
      }
    }
  }

  Future<void> _scanFromGallery() async {
    HapticFeedback.vibrate();
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final Uint8List imgBytes = await image.readAsBytes();
        final BarcodeCapture? capture = await _controller.analyzeImage(image.path);
        
        if (capture != null && capture.barcodes.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _isScanning = false;
            _scanResult = capture.barcodes.first.rawValue ?? "";
            _frozenImage = imgBytes; 
          });
          
          HapticFeedback.vibrate();
          _showLensStyleBottomSheet();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              content: const Text(
                'No recognizable barcode or QR code found in this image. Please try a different one.', 
                style: TextStyle(color: Colors.black)
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
        }
      }
    } catch (e) {
      debugPrint("Gallery Scan Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: const Text('Failed to load image from gallery.', style: TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
    }
  }

  void _showHelpBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.help_outline, color: Colors.white54, size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  "OffScan Instructions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Welcome to OffScan.\n\n"
                  "• Point your camera at any 1D/2D barcode or QR code.\n"
                  "• Pinch the screen to digitally zoom in on rigid labels.\n"
                  "• Use the Gallery Icon (Left) to pick an existing image.\n"
                  "• Tap the Camera Icon (Center) to trigger manual focus and feedback.\n"
                  "• Use the Flip icon at the top to change cameras.\n\n"
                  "Note: Data resolves securely and fully offline.\n"
                  "Need Support? Contact: cfungame@gmail.com",
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Got it"),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _showLensStyleBottomSheet() {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4), 
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      elevation: 0,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
            ]
          ),
          child: SafeArea(
            bottom: true,
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
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
                              )
                            );
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.copy, size: 20),
                        label: const Text("Copy"),
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
                            await Share.share(_scanResult, subject: 'OffScan Result');
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text("Share"),
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
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Rescan"),
                  ),
                )
              ],
            ),
          ),
        );
      }
    ).whenComplete(() {
      setState(() {
        _isScanning = true;
        _scanResult = "";
        _frozenImage = null; 
      });
      _controller.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Camera Feed wrapped in silent GestureDetector for pinch zoom
          GestureDetector(
            onScaleStart: (details) {
              _baseZoomScale = _currentZoomScale;
            },
            onScaleUpdate: (details) {
              if (_frozenImage != null) return;
              double newZoom = (_baseZoomScale + (details.scale - 1.0) * 0.3).clamp(0.0, 1.0);
              if (newZoom != _currentZoomScale) {
                setState(() => _currentZoomScale = newZoom);
                _controller.setZoomScale(newZoom);
              }
            },
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleBarcode,
              tapToFocus: true, // Native autofocus delegation
            ),
          ),
          
          if (_frozenImage != null)
            Positioned.fill(
              child: Image.memory(
                _frozenImage!,
                fit: BoxFit.cover,
              ),
            ),
            
          if (_frozenImage != null)
            Positioned.fill(
               child: Container(color: Colors.black.withOpacity(0.2)),
            ),

          if (_frozenImage == null)
            Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: CornerPainter(),
                ),
              ),
            ),

          // Top Header (Perfectly aligned with explicit heights)
          Positioned(
            top: 70, // Margin matching the gaps between buttons
            left: 32, // Narrowed edge gap to match inner gaps
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Left: Flip Camera (uses simple sync circle)
                Container(
                  width: 55, 
                  height: 55,
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.vibrate();
                      _controller.switchCamera();
                    },
                    icon: const Icon(Icons.sync, color: Colors.white, size: 30),
                  ),
                ),
                
                // Top Center: OffScan Logo Text
                Expanded(
                  child: Center(
                    child: Text(
                      "OffScan",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28, 
                        fontWeight: FontWeight.w300, // Very thin, minimalist weight
                        letterSpacing: 1.0,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 8)
                        ]
                      ),
                    ),
                  ),
                ),

                // Top Right: Instructions / Info
                Container(
                  width: 55,
                  height: 55,
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.vibrate();
                      _showHelpBottomSheet();
                    },
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 30),
                  ),
                )
              ],
            ),
          ),

          // Bottom Action Buttons 
          if (_frozenImage == null)
            Positioned(
              bottom: 70, // Margin matching the gaps between buttons
              left: 32, // Narrowed edge gap to match inner gaps
              right: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Gallery Button
                  GestureDetector(
                    onTap: _scanFromGallery,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        color: Colors.black12,
                      ),
                      child: const Icon(Icons.photo_library, color: Colors.white, size: 24),
                    ),
                  ),
                  
                  // Middle: Camera / Shutter Button
                  GestureDetector(
                    onTap: () {
                       // Trigger haptics only, sound relies on success
                       HapticFeedback.vibrate();
                       
                       // Show a helpful popup indicating that it's actively seeking
                       if (_scanResult.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             backgroundColor: Colors.white,
                             content: const Text(
                               'Searching... hold steady over a QR or Barcode.', 
                               style: TextStyle(color: Colors.black)
                             ),
                             behavior: SnackBarBehavior.floating,
                             duration: const Duration(seconds: 2),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                           )
                         );
                       }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2), 
                      ),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black87, size: 30),
                        ),
                      ),
                    ),
                  ),
                  
                  // Far Right: Flashlight Button
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _controller,
                    builder: (context, state, child) {
                      final isOn = state.torchState == TorchState.on;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.vibrate();
                          _controller.toggleTorch();
                        },
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOn ? Colors.white : Colors.black12,
                          ),
                          child: Icon(
                            isOn ? Icons.flash_on : Icons.flash_off, 
                            color: isOn ? Colors.black87 : Colors.white, 
                            size: 24
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

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4) 
      ..strokeWidth = 1.5 
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double length = size.width * 0.10; 
    final double radius = 32.0; 
    
    // Top Left
    var path = Path()
      ..moveTo(0, length)
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..lineTo(length, 0);
    canvas.drawPath(path, paint);

    // Top Right
    path = Path()
      ..moveTo(size.width - length, 0)
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
      ..lineTo(size.width, length);
    canvas.drawPath(path, paint);

    // Bottom Right
    path = Path()
      ..moveTo(size.width, size.height - length)
      ..arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius))
      ..lineTo(size.width - length, size.height);
    canvas.drawPath(path, paint);

    // Bottom Left
    path = Path()
      ..moveTo(length, size.height)
      ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius))
      ..lineTo(0, size.height - length);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
