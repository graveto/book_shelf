import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ISBNScanner extends StatefulWidget {
  final Function(String) onISBNScanned;

  const ISBNScanner({required this.onISBNScanned});

  @override
  _ISBNScannerState createState() => _ISBNScannerState();
}

class _ISBNScannerState extends State<ISBNScanner> {
  bool _isScanning = false;
  MobileScannerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final Barcode? barcode = capture.barcodes.first;

    if (barcode!= null &&
        (barcode.format == BarcodeFormat.ean13 ||
            barcode.format == BarcodeFormat.ean8 ||
            barcode.format == BarcodeFormat.code128)) {
      final isbn = barcode.rawValue;
      if (isbn!= null) {
        _controller?.stop();
        setState(() {
          _isScanning = false;
        });
        widget.onISBNScanned(isbn); // Call the callback with the ISBN
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan ISBN'),
      ),
      body: Center(

        child: Container(
          width: 300, // Adjust the size as needed
          height: 300,
          child: MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
        ),
      ),
    );
  }
}