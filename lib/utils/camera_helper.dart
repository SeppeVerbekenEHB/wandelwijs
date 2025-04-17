import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Helper class to manage camera functionality
class CameraHelper {
  /// Check if the app is running on an emulator
  static bool get isEmulator {
    // This is a simple check that detects most emulators
    // More sophisticated checks can be added if needed
    return defaultTargetPlatform == TargetPlatform.android && 
           !kIsWeb &&
           (const bool.fromEnvironment('dart.vm.product') == false);
  }

  /// Gets the best camera for current device
  static Future<CameraDescription?> getBestCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return null;

    // On emulator, we want the first camera which is typically the webcam
    if (isEmulator) return cameras.first;

    // On a real device, we prefer the back camera
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        return camera;
      }
    }

    // Fall back to the first camera
    return cameras.first;
  }
}
