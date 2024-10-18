import 'package:flutter/material.dart';
import 'package:galaxy_mini/screens/setting_screens/ble_controller.dart';
import 'package:get/get.dart';

class Bledevice extends StatefulWidget {
  const Bledevice({super.key});

  @override
  State<Bledevice> createState() => _BledeviceState();
}

class _BledeviceState extends State<Bledevice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE SCANNER")),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (BleController controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Obx(() {
                    final devices = controller.discoveredDevices;

                    if (devices.isNotEmpty) {
                      return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(device.name.isNotEmpty
                                  ? device.name
                                  : 'Unknown Device'),
                              subtitle: Text(device.id),
                              trailing: Text('RSSI: ${device.rssi}'),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text("No devices found"));
                    }
                  }),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  child: const Text("SCAN"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
