import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController controller = MobileScannerController();
  final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
  List<String> scannedUUIDs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Codes')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              key: qrKey,
              controller: controller,
              onDetect: (barcodeData) {
                if (barcodeData.barcodes.isEmpty) {showSnackbar("Unsuccessful scan.");return;}
                setState(() {
                  for (Barcode barcode in barcodeData.barcodes) {
                    String? uuid = barcode.rawValue;
                    if (uuid == null) {
                      debugPrint("Found empty QR code.");
                      continue;
                    }
                    if (!uuidRegex.hasMatch(uuid)) {
                      debugPrint("QR code is not a valid V4 UUID.");
                      continue;
                    }
                    if (!scannedUUIDs.contains(uuid)) {
                     scannedUUIDs.add(uuid);
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Added UUID $uuid"),
                        ));
                      debugPrint("Added UUID $uuid");
                    }
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Scanned UUIDs: ${scannedUUIDs.length}'),
                ElevatedButton(
                  onPressed: () {
                    exportQRCodesToCSV(scannedUUIDs);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("CSV saved."),
                    ));
                  },
                  child: Text('Export to CSV'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(
            child: Text(
      text,
      textAlign: TextAlign.center,
    ))));
  }
}

Future<String> initConfig() async {

  if (Platform.isAndroid) {
    final directoryInstance = await getExternalStorageDirectory();
    if (directoryInstance == null) {
      return "";
    }
    return directoryInstance.path;
  } else if (Platform.isIOS) {
    final directoryInstance = await getApplicationDocumentsDirectory();
    return directoryInstance.path;
  } else {
    throw UnimplementedError(
        "You're trying to run this app on something other than iOS/Android. why?");
  }
}

Future<void> exportQRCodesToCSV(List<String> scannedUUIDs) async {
  String configFolder = await initConfig();
  List<List<String>> rows = [
    ["UUID"], // Header row
    ...scannedUUIDs.map((uuid) => [uuid]), // Each UUID in a new row
  ];

  String csvData = const ListToCsvConverter().convert(rows);
  final uuidPath = Directory("$configFolder/scanned_uuids");
  if (!(await uuidPath.exists())) {
    await uuidPath.create();
  }

  final path = "${uuidPath.path}/scan_${DateTime.now().millisecondsSinceEpoch.toString()}.csv";
  final file = File(path);
  await file.writeAsString(csvData);
}

