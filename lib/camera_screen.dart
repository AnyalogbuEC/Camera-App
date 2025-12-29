// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

Future<void> deleteFile({required String filePath}) async {
  try {
    final file = File(filePath);

    // Delete existing file before saving the new one (as per your original intent)
    if (await file.exists()) {
      await file.delete();
      debugPrint('Deleted old file successfully.');
    }
  } catch (e) {
    debugPrint('Error handling file: $e');
  }
}

/// The full-screen camera view, optimized to return the captured file path.
class CameraScreen extends StatefulWidget {
  final CameraDescription? camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(widget.camera!);
  }

  // Initializes the camera controller
  void _initializeCamera(CameraDescription cameraDescription) async {
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _isCameraInitialized = true;
          });
        })
        .catchError((error) {
          if (error is CameraException) {
            _showErrorDialog(
              'Camera Error',
              error.description ?? 'Unknown error.',
            );
          } else {
            _showErrorDialog('Error', 'Could not initialize camera.');
          }
          setState(() {
            _isCameraInitialized = false;
          });
        });
  }

  // Function to take a picture, save it to the hardcoded path, and return the path
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capturing photo...'),
          duration: Duration(milliseconds: 500),
        ),
      );

      final XFile image = await _controller.takePicture();

      // IMPORTANT: Using getExternalStorageDirectory() and hardcoded path '2026.png'
      // as per your original code. This will overwrite the previous photo.
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        _showErrorDialog('Storage Error', 'External storage not available.');
        return;
      }
      final filePath = join(directory.path, '2026.png');

      deleteFile(filePath: filePath);

      // Save the captured image to the determined path.
      await image.saveTo(filePath);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Navigate back and pass the hardcoded file path back to MonitorReportForm
      Navigator.pop(context, filePath);
    } catch (e) {
      _showErrorDialog('Capture Error', e.toString());
      debugPrint('Capture Error: $e'); // Log error to console
    }
  }

  // Utility function to show an error dialog
  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.red)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // If it's a fatal error, pop the camera screen too
                if (title.contains('Error')) {
                  Navigator.of(context).pop(null);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          // 1. Full-Screen Camera Preview
          if (_isCameraInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                // Ensure the camera view uses the correct aspect ratio dimensions
                child: SizedBox(
                  width: _controller.value.previewSize!.height,
                  height: _controller.value.previewSize!.width,
                  child: CameraPreview(_controller),
                ),
              ),
            )
          else if (widget.camera ==
              null) // Check if camera list was empty from main
            const Center(
              child: Text(
                'No camera device found.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 2. Overlay for controls and back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close/Back Button (Top Left)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () =>
                            Navigator.pop(context), // Go back without result
                      ),
                    ),
                  ),

                  // Capture Button (Bottom Center)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: FloatingActionButton(
                      onPressed: _isCameraInitialized ? _takePicture : null,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      shape: const CircleBorder(),
                      elevation: 8.0,
                      heroTag: 'capture',
                      // Custom circle button style
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.indigo, width: 3),
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.camera_alt, size: 35),
                      ),
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
