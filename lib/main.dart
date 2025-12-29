// import 'dart:io';
// import 'package:camera_app/home.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;

// // Global variable to store the list of available cameras
// late List<CameraDescription> _cameras;

// // Main function to initialize cameras and run the app
// Future<void> main() async {
//   // Ensure that plugin services are initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   try {
//     // Obtain a list of the available cameras on the device.
//     _cameras = await availableCameras();
//   } on CameraException catch (e) {
//     print('Error: $e.code\nError Message: $e.description');
//     // Handle the case where no cameras are available gracefully
//     _cameras = [];
//   }

//   runApp(const CameraApp());
// }

// class CameraApp extends StatelessWidget {
//   const CameraApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Camera Capture',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         // Use a dark theme for the full-screen camera experience
//         brightness: Brightness.dark,
//         useMaterial3: true,
//       ),
//       home: const MonitorReportForm(),
//     );
//   }
// }

// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   String? _imagePath;
//   bool _isCameraInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     // Check if cameras are available before initializing
//     if (_cameras.isNotEmpty) {
//       _initializeCamera(_cameras.first);
//     }
//   }

//   // Initializes the camera controller with the given camera description
//   void _initializeCamera(CameraDescription cameraDescription) async {
//     // Create a CameraController.
//     _controller = CameraController(
//       cameraDescription,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );

//     // Initialize the controller and store the Future for later use.
//     _initializeControllerFuture = _controller
//         .initialize()
//         .then((_) {
//           if (!mounted) return;
//           setState(() {
//             _isCameraInitialized = true;
//           });
//         })
//         .catchError((error) {
//           if (error is CameraException) {
//             // Handle specific camera exceptions (e.g., permissions)
//             _showErrorDialog(
//               'Camera Initialization Error',
//               error.description ?? 'Unknown error.',
//             );
//           } else {
//             _showErrorDialog('Error', 'Could not initialize camera.');
//           }
//           setState(() {
//             _isCameraInitialized = false;
//           });
//         });
//   }

//   // Function to take a picture and save it locally
//   Future<void> _takePicture() async {
//     try {
//       // Ensure the controller is initialized.
//       await _initializeControllerFuture;

//       // Show a loading indicator while capturing
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Capturing photo...'),
//           duration: Duration(milliseconds: 500),
//         ),
//       );

//       // Attempt to take a picture and get the file.
//       final XFile image = await _controller.takePicture();

//       // Get the directory where we can save the file.
//       // We use getTemporaryDirectory for a simple local storage solution.
//       final directory = await getTemporaryDirectory();

//       // Create a unique file path.
//       // final filePath = join(
//       //   directory.path,
//       //   '${DateTime.now().toIso8601String()}.png',
//       // );
//       final filePath = join(directory.path, '2026.png');

//       try {
//         // 1. Get the File object
//         // final file = await _localFile(filename);
//         final file = File(filePath);

//         // 2. Check if the file exists
//         if (await file.exists()) {
//           // 3. Delete the file
//           await file.delete();
//           print('deleted successfully.');
//         } else {
//           print('does not exist.');
//         }
//       } catch (e) {
//         // Handle errors (e.g., permission denied, file being used)
//         print('Error deleting file: $e');
//       }
//       // Save the captured image to the determined path.
//       await image.saveTo(filePath);

//       // Update the state to display the captured image thumbnail
//       setState(() {
//         _imagePath = filePath;
//       });

//       // Show a success message
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       // Optional: uncomment below to show a persistent message of where it was saved
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(content: Text('Photo saved locally to: $filePath')),
//       // );
//       Navigator.pop(context);
//     } catch (e) {
//       _showErrorDialog('Capture Error', e.toString());
//       print(e); // Log error to console
//     }
//   }

//   // Utility function to show an error dialog
//   void _showErrorDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Utility function to show the captured image in a dialog
//   void _showCapturedImageDialog(BuildContext context) {
//     if (_imagePath != null) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Last Captured Image'),
//             content: Image.file(
//               File(_imagePath!),
//               fit: BoxFit.contain,
//               // Use a container for constrained size within the dialog
//               height: MediaQuery.of(context).size.height * 0.5,
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('Close'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Scaffold without an AppBar for a true full-screen camera UI
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(),
//       body: Stack(
//         children: <Widget>[
//           // 1. Full-Screen Camera Preview
//           if (_isCameraInitialized)
//             // Use FittedBox with BoxFit.cover to ensure the camera feed fills the screen
//             // and handles the aspect ratio correctly (by clipping excess).
//             SizedBox.expand(
//               child: FittedBox(
//                 fit: BoxFit.cover,
//                 // The size of the CameraPreview needs to be set based on the controller's
//                 // aspect ratio to work correctly inside FittedBox.
//                 child: SizedBox(
//                   width: _controller.value.previewSize!.height,
//                   height: _controller.value.previewSize!.width,
//                   child: CameraPreview(_controller),
//                 ),
//               ),
//             )
//           else if (_cameras.isEmpty)
//             const Center(
//               child: Text(
//                 'No cameras found on this device.',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             )
//           else
//             const Center(child: CircularProgressIndicator(color: Colors.white)),

//           // 2. Capture Button (Overlayed at the bottom center)
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 40.0),
//               child: FloatingActionButton(
//                 onPressed: _isCameraInitialized ? _takePicture : null,
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.indigo,
//                 shape: const CircleBorder(),
//                 elevation: 4.0,
//                 heroTag: 'capture', // Added unique hero tag
//                 child: const Icon(Icons.camera_alt, size: 30),
//               ),
//             ),
//           ),

//           // 3. Captured Image Thumbnail (Overlayed at the bottom right)
//           if (_imagePath != null)
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 48.0, right: 20),
//                 child: GestureDetector(
//                   onTap: () => _showCapturedImageDialog(context),
//                   child: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.white, width: 2),
//                       image: DecorationImage(
//                         image: FileImage(File(_imagePath!)),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously

import 'package:camera_app/home.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Global variable to store the list of available cameras
late List<CameraDescription> _cameras;

// Main function to initialize cameras and run the app
Future<void> main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error: $e.code\nError Message: $e.description');
    _cameras = [];
  }

  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Capture',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      // Start the app on the main form that triggers the camera
      home: MonitorReportForm(cameras: _cameras),
    );
  }
}

// /// The main form where the user initiates the camera and sees the result.
// class MonitorReportForm extends StatefulWidget {
//   const MonitorReportForm({super.key});

//   @override
//   State<MonitorReportForm> createState() => _MonitorReportFormState();
// }

// class _MonitorReportFormState extends State<MonitorReportForm> {
//   final _formKey = GlobalKey<FormState>();

//   // Form State
//   String _reportType = 'Confirmation';
//   String _procurementRef = '';
//   String _details = '';
//   String _severity = 'Low';
//   String _deliveryStatus = 'Delivered';

//   // Note: Geolocation and Photo fields removed as per user request.

//   // Options
//   final List<String> typeOptions = ['Confirmation', 'Discrepancy'];
//   final List<String> severityOptions = ['Low', 'Medium', 'High'];
//   final List<String> deliveryOptions = [
//     'Delivered',
//     'Partial Delivery',
//     'Pending',
//   ];

//   // Utility function to show the captured image in a dialog
//   Future<void> _showCapturedImageDialog(BuildContext context) async {
//     final directory = await getExternalStorageDirectory();
//     final filePath = join(directory!.path, '2026.png');
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Last Captured Image'),
//           content: Image.file(
//             File(filePath),
//             fit: BoxFit.contain,
//             // Use a container for constrained size within the dialog
//             height: MediaQuery.of(context).size.height * 0.5,
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Monitor Report Form'),
//         backgroundColor: Colors.indigo,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Report Details',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal,
//                   ),
//                 ),
//                 const Divider(height: 30),

//                 // --- CORE REPORT FIELDS ---

//                 // Report Type Toggle
//                 const Text(
//                   'Report Type',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 DropdownButtonFormField<String>(
//                   initialValue: _reportType,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                   ),
//                   items: typeOptions
//                       .map(
//                         (type) =>
//                             DropdownMenuItem(value: type, child: Text(type)),
//                       )
//                       .toList(),
//                   onChanged: (val) {
//                     setState(() {
//                       _reportType = val!;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 20),

//                 // Procurement Reference
//                 TextFormField(
//                   decoration: const InputDecoration(
//                     labelText: 'Procurement/Project Reference ID',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (val) =>
//                       val!.isEmpty ? 'Enter a reference ID' : null,
//                   onSaved: (val) => _procurementRef = val!,
//                 ),
//                 const SizedBox(height: 20),

//                 // Conditional Fields
//                 if (_reportType == 'Discrepancy') ...[
//                   const Text(
//                     'Severity Level',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   DropdownButtonFormField<String>(
//                     initialValue: _severity,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                     ),
//                     items: severityOptions
//                         .map(
//                           (sev) =>
//                               DropdownMenuItem(value: sev, child: Text(sev)),
//                         )
//                         .toList(),
//                     onChanged: (val) => setState(() => _severity = val!),
//                   ),
//                   const SizedBox(height: 20),
//                 ] else if (_reportType == 'Confirmation') ...[
//                   const Text(
//                     'Delivery Status',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   DropdownButtonFormField<String>(
//                     initialValue: _deliveryStatus,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                     ),
//                     items: deliveryOptions
//                         .map(
//                           (stat) =>
//                               DropdownMenuItem(value: stat, child: Text(stat)),
//                         )
//                         .toList(),
//                     onChanged: (val) => setState(() => _deliveryStatus = val!),
//                   ),
//                   const SizedBox(height: 20),
//                 ],

//                 // Details Field
//                 TextFormField(
//                   maxLines: 4,
//                   decoration: const InputDecoration(
//                     labelText: 'Detailed Observation/Description',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (val) => val!.length < 10
//                       ? 'Description must be at least 10 characters'
//                       : null,
//                   onSaved: (val) => _details = val!,
//                 ),
//                 const SizedBox(height: 30),

//                 // Submit Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => CameraScreen()),
//                       );
//                     },
//                     icon: const Icon(Icons.send),
//                     label: Text('Submit $_reportType'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       backgroundColor: Colors.teal,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Submit Button
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       _showCapturedImageDialog(context);
//                     },
//                     icon: const Icon(Icons.send),
//                     label: Text('Show'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       backgroundColor: Colors.teal,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// The full-screen camera view, optimized to return the captured file path.
// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});

//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _isCameraInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     if (_cameras.isNotEmpty) {
//       _initializeCamera(_cameras.first);
//     }
//   }

//   // Initializes the camera controller
//   void _initializeCamera(CameraDescription cameraDescription) async {
//     _controller = CameraController(
//       cameraDescription,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );

//     _initializeControllerFuture = _controller
//         .initialize()
//         .then((_) {
//           if (!mounted) return;
//           setState(() {
//             _isCameraInitialized = true;
//           });
//         })
//         .catchError((error) {
//           if (error is CameraException) {
//             _showErrorDialog(
//               'Camera Error',
//               error.description ?? 'Unknown error.',
//             );
//           } else {
//             _showErrorDialog('Error', 'Could not initialize camera.');
//           }
//           setState(() {
//             _isCameraInitialized = false;
//           });
//         });
//   }

//   // Function to take a picture and save it locally, then return the path
//   Future<void> _takePicture() async {
//     try {
//       await _initializeControllerFuture;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Capturing photo...'),
//           duration: Duration(milliseconds: 500),
//         ),
//       );

//       final XFile image = await _controller.takePicture();

//       // Get the temp directory and create a unique file path.
//       final directory = await getExternalStorageDirectory();
//       // final filePath = join(
//       //   directory.path,
//       //   '${DateTime.now().microsecondsSinceEpoch}.png', // Unique name
//       // );

//       final filePath = join(directory!.path, '2026.png');

//       try {
//         // 1. Get the File object
//         // final file = await _localFile(filename);
//         final file = File(filePath);

//         // 2. Check if the file exists
//         if (await file.exists()) {
//           // 3. Delete the file
//           await file.delete();
//           debugPrint('deleted successfully.');
//         } else {
//           debugPrint('does not exist.');
//         }
//       } catch (e) {
//         // Handle errors (e.g., permission denied, file being used)
//         debugPrint('Error deleting file: $e');
//       }

//       // Save the captured image to the determined path.
//       await image.saveTo(filePath);

//       ScaffoldMessenger.of(context).hideCurrentSnackBar();

//       // Navigate back and pass the file path back to MonitorReportForm
//       Navigator.pop(context, filePath);
//     } catch (e) {
//       _showErrorDialog('Capture Error', e.toString());
//       debugPrint('Capture Error: $e'); // Log error to console
//     }
//   }

//   // Utility function to show an error dialog
//   void _showErrorDialog(String title, String message) {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title, style: const TextStyle(color: Colors.red)),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // If it's a fatal error, pop the camera screen too
//                 if (title.contains('Error')) {
//                   Navigator.of(context).pop(null);
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use AnnotatedRegion and SystemChrome to achieve a truly full-screen look
//     // without the status bar, if desired (though Scaffold handles it well enough).
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: <Widget>[
//           // 1. Full-Screen Camera Preview
//           if (_isCameraInitialized)
//             SizedBox.expand(
//               child: FittedBox(
//                 fit: BoxFit.cover,
//                 // Ensure the camera view uses the correct aspect ratio dimensions
//                 child: SizedBox(
//                   width: _controller.value.previewSize!.height,
//                   height: _controller.value.previewSize!.width,
//                   child: CameraPreview(_controller),
//                 ),
//               ),
//             )
//           else if (_cameras.isEmpty)
//             const Center(
//               child: Text(
//                 'No cameras found on this device.',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             )
//           else
//             const Center(child: CircularProgressIndicator(color: Colors.white)),

//           // 2. Overlay for controls and back button
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Close/Back Button (Top Left)
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.black45,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                         onPressed: () =>
//                             Navigator.pop(context), // Go back without result
//                       ),
//                     ),
//                   ),

//                   // Capture Button (Bottom Center)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 24.0),
//                     child: FloatingActionButton(
//                       onPressed: _isCameraInitialized ? _takePicture : null,
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.indigo,
//                       shape: const CircleBorder(),
//                       elevation: 8.0,
//                       heroTag: 'capture',
//                       // Custom circle button style
//                       child: Container(
//                         width: 70,
//                         height: 70,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.indigo, width: 3),
//                           color: Colors.white,
//                         ),
//                         child: const Icon(Icons.camera_alt, size: 35),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
