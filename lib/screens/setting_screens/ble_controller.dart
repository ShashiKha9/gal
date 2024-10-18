import 'dart:async';
import 'dart:developer';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleController extends GetxController {
  final FlutterReactiveBle _ble =
      FlutterReactiveBle(); // Initialize FlutterReactiveBle instance
  late StreamSubscription<DiscoveredDevice>
      _scanSubscription; // To hold the subscription for the scanning

  final RxList<DiscoveredDevice> discoveredDevices =
      <DiscoveredDevice>[].obs; // Observable list for scan results
  String P58D_CHARACTERISTIC_UUID =
      "bef8d6c9-9c21-4c9e-b632-bd58c1009f9f"; // Adjust if needed
  int MAX_RETRIES = 3;

  Future<void> scanDevices() async {
    // Request necessary permissions
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      discoveredDevices.clear(); // Clear previous results before a new scan

      // Start scanning for devices
      _scanSubscription = _ble.scanForDevices(
          withServices: [], scanMode: ScanMode.balanced).listen((device) {
        if (!discoveredDevices.any((d) => d.id == device.id)) {
          discoveredDevices
              .add(device); // Add new device if not already in the list
        }
      }, onError: (error) {
        // Handle scan errors
        log("Scan error: $error");
      });

      // Automatically stop scanning after 10 seconds
      await Future.delayed(const Duration(seconds: 10));
      _scanSubscription
          .cancel(); // Stop scanning by cancelling the subscription
    }
  }

  Future<void> connectToDevice(DiscoveredDevice device) async {
    // print(device);

    // Connect to the device and listen to the connection state
    _ble.connectToDevice(id: device.id).listen((connectionState) {
      switch (connectionState.connectionState) {
        case DeviceConnectionState.connecting:
          log("Connecting...");
          break;
        case DeviceConnectionState.connected:
          log("Device connected: $device");

          // Check if the connected device is a printer (adjust the condition as necessary)

          if (device.name.contains("CN811-UB") ||
              device.name.contains("P58D")) {
            log("Successfully connected to a printer!");

            // Discover services and characteristics
            _discoverServicesAndLogCharacteristics(device);
          }

          break;
        case DeviceConnectionState.disconnected:
          log("Disconnected");
          break;
        default:
          break;
      }
    }, onError: (error) {
      // Handle connection errors
      log("Connection error: $error");
    });
  }

  Future<void> _discoverServicesAndLogCharacteristics(
      DiscoveredDevice device) async {
    try {
      // Discover services on the connected device
      final services = await _ble.discoverServices(device.id);

      // Iterate through the discovered services and characteristics
      for (var service in services) {
        log("Service UUID: ${service.serviceId}");
        for (var characteristic in service.characteristics) {
          log("Characteristic UUID: ${characteristic.characteristicId}");

          // Directly call print function with the discovered serviceId and characteristicId
          // _printSampleText(
          //     device, service.serviceId, characteristic.characteristicId);
        }
      }
    } catch (e) {
      log("Error discovering services or characteristics: $e");
    }
  }

  // void _printSampleText(
  //     DiscoveredDevice device, Uuid serviceId, Uuid characteristicId) async {
  //   // Construct the sample text data to print (once)
  //   String sampleText = "Hello, this is a sample print text!";

  //   // ESC/POS command to print text
  //   List<int> printCommand = <int>[
  //     0x1B, 0x40, // Initialize printer
  //     0x1B, 0x21, 0x00, // Select print mode: normal text
  //   ];

  //   // Convert the sample text to bytes and add a new line
  //   List<int> textBytes =
  //       sampleText.codeUnits + [0x0A]; // 0x0A is the newline command

  //   // ESC/POS command to feed paper and cut (optional, depends on printer capabilities)
  //   List<int> endCommand = <int>[
  //     0x1D, 0x56, 0x41, 0x10, // Cut paper (optional)
  //   ];

  //   // Combine commands and text to form the full print command
  //   List<int> fullCommand = printCommand + textBytes + endCommand;

  //   // Send the data to the printer using the discovered serviceId and characteristicId
  //   await _ble.writeCharacteristicWithResponse(
  //     QualifiedCharacteristic(
  //       serviceId: serviceId, // Use the dynamically discovered service UUID
  //       characteristicId:
  //           characteristicId, // Use the dynamically discovered characteristic UUID
  //       deviceId: device.id,
  //     ),
  //     value: fullCommand,
  //   );

  //   log("Print command sent to the printer.");
  // }

  Future<void> printData(String data) async {
    List<int> printCommand = <int>[0x1B, 0x40]; // Simplified initialization
    List<int> textBytes =
        data.codeUnits + [0x0A]; // Convert data to bytes with newline
    List<int> endCommand = <int>[0x1D, 0x56, 0x41, 0x10]; // Cut command
    List<int> fullCommand = printCommand + textBytes + endCommand;

    final prefs = await SharedPreferences.getInstance();
    String? printerId = prefs.getString('selectedPrinterId');
    String? printerName = prefs.getString('selectedPrinterName');

    if (printerId == null || printerName == null) {
      log("No printer selected. Please select a printer first.");
      return;
    }

    try {
      // Find the printer device by its ID
      final device = discoveredDevices.firstWhere(
        (device) => device.id == printerId,
        orElse: () =>
            throw Exception("Printer not found in discovered devices"),
      );

      final services = await _ble.discoverServices(device.id);
      bool commandSent =
          false; // Flag to check if command was sent successfully

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          log("Characteristic UUID: ${characteristic.characteristicId}");

          // Check if the characteristic UUID matches the specified UUID
          if (characteristic.characteristicId.toString() ==
              "bef8d6c9-9c21-4c9e-b632-bd58c1009f9f") {
            // Attempt to write to the characteristic directlyx
            try {
              // Retry mechanism for writing data
              for (int attempt = 0; attempt < 3; attempt++) {
                try {
                  await _ble.writeCharacteristicWithResponse(
                    QualifiedCharacteristic(
                      serviceId: service.serviceId,
                      characteristicId: characteristic.characteristicId,
                      deviceId: device.id,
                    ),
                    value: fullCommand,
                  );
                  log("Print command sent to the printer: $printerName");
                  commandSent = true; // Mark command as sent
                  break; // Break the retry loop on success
                } catch (e) {
                  log("Attempt ${attempt + 1} failed: $e");
                  if (attempt == 2) {
                    throw Exception("Failed after 3 attempts: $e");
                  }
                }
              }
            } catch (e) {
              log("Error while writing data: $e");
            }

            // Break if the command was sent successfully
            if (commandSent) {
              break; // Exit the characteristic loop
            }
          }
        }
        if (commandSent) {
          break; // Exit the service loop if command has been sent
        }
      }

      if (!commandSent) {
        log("Failed to send the print command to the printer: $printerName. Printing is allowed only for the specified UUID.");
      }
    } catch (e) {
      log("Error while printing: $e");
    }
  }

  Future<void> writePdata(String data) async {
    List<int> printCommand = <int>[
      0x1B,
      0x40
    ]; // Simplified initialization for P58D
    List<int> textBytes =
        data.codeUnits + [0x0A]; // Convert data to bytes with newline
    List<int> endCommand = <int>[
      0x1D,
      0x56,
      0x41,
      0x10
    ]; // Cut command for P58D
    List<int> fullCommand = printCommand + textBytes + endCommand;

    final prefs = await SharedPreferences.getInstance();
    String? printerId = prefs.getString('selectedPrinterId');
    String? printerName = prefs.getString('selectedPrinterName');

    if (printerId == null || printerName == null) {
      log("No printer selected. Please select a printer first.");
      return;
    }

    try {
      // Find the printer device by its ID
      final device = discoveredDevices.firstWhere(
        (device) => device.id == printerId,
        orElse: () =>
            throw Exception("Printer not found in discovered devices"),
      );

      final services = await _ble.discoverServices(device.id);
      bool commandSent =
          false; // Flag to check if command was sent successfully

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          log("Characteristic UUID: ${characteristic.characteristicId}");

          // Check if the characteristic UUID matches the specified UUID
          if (characteristic.characteristicId.toString() ==
              P58D_CHARACTERISTIC_UUID) {
            // Attempt to write to the characteristic
            try {
              // Retry mechanism for writing data
              for (int attempt = 0; attempt < MAX_RETRIES; attempt++) {
                try {
                  await _ble.writeCharacteristicWithResponse(
                    QualifiedCharacteristic(
                      serviceId: service.serviceId,
                      characteristicId: characteristic.characteristicId,
                      deviceId: device.id,
                    ),
                    value: fullCommand,
                  );
                  log("Print command sent to the printer: $printerName");
                  commandSent = true; // Mark command as sent
                  break; // Break the retry loop on success
                } catch (e) {
                  log("Attempt ${attempt + 1} failed: $e");
                  if (attempt == MAX_RETRIES - 1) {
                    throw Exception("Failed after ${MAX_RETRIES} attempts: $e");
                  }
                }
              }
            } catch (e) {
              log("Error while writing data: $e");
            }

            // Break if the command was sent successfully
            if (commandSent) {
              break; // Exit the characteristic loop
            }
          }
        }
        if (commandSent) {
          break; // Exit the service loop if command has been sent
        }
      }

      if (!commandSent) {
        log("Failed to send the print command to the printer: $printerName. Printing is allowed only for the specified UUID.");
      }
    } catch (e) {
      log("Error while printing: $e");
    }
  }

  // Expose the list of discovered devices
  List<DiscoveredDevice> get scanResults => discoveredDevices.toList();
}
