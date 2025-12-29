// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'camera_screen.dart'; // Import the camera screen

/// The main form where the user initiates the camera and sees the result.
class MonitorReportForm extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MonitorReportForm({super.key, required this.cameras});

  @override
  State<MonitorReportForm> createState() => _MonitorReportFormState();
}

class _MonitorReportFormState extends State<MonitorReportForm> {
  final _formKey = GlobalKey<FormState>();

  // Form State
  String _reportType = 'Confirmation';
  String _procurementRef = '';
  String _details = '';
  String _severity = 'Low';
  String _deliveryStatus = 'Delivered';

  String?
  _capturedImagePath; // State to hold the path of the last captured image

  // Options
  final List<String> typeOptions = ['Confirmation', 'Discrepancy'];
  final List<String> severityOptions = ['Low', 'Medium', 'High'];
  final List<String> deliveryOptions = [
    'Delivered',
    'Partial Delivery',
    'Pending',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the captured image path state
    _loadHardcodedImagePath();
  }

  // Load the hardcoded image path (2026.png) for display if it exists
  Future<void> _loadHardcodedImagePath() async {
    // Note: The original logic used getExternalStorageDirectory()
    // which requires special permissions. Use getApplicationDocumentsDirectory()
    // for private persistent storage if external is not strictly needed.
    // Sticking to original for context, but external storage permissions are required.
    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final filePath = join(directory.path, '2026.png');
    _capturedImagePath = filePath;
  }

  // Utility function to show the captured image in a dialog
  Future<void> _showCapturedImageDialog(BuildContext context) async {
    final file = File(_capturedImagePath!);

    if (!await file.exists()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please capture a photo')));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Captured Image'),
          content: Image.file(
            File(_capturedImagePath!),
            fit: BoxFit.contain,
            // Use a container for constrained size within the dialog
            height: MediaQuery.of(context).size.height * 0.5,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Submission placeholder
  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final file = File(_capturedImagePath!);

      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please capture a photo before submitting.'),
          ),
        );
        return;
      }

      debugPrint('Report Type: $_reportType');
      debugPrint('Procurement Ref: $_procurementRef');
      debugPrint('Details: $_details');
      debugPrint('Photo Path: $_capturedImagePath');
      // Add logic to upload data/image here
      deleteFile(filePath: _capturedImagePath!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report Submitted! (Simulated)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor Report Form'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Report Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 30),

              // Report Type Toggle
              _buildDropdownField(
                'Report Type',
                _reportType,
                typeOptions,
                (val) => setState(() => _reportType = val!),
              ),
              const SizedBox(height: 20),

              // Procurement Reference
              _buildTextFormField(
                'Procurement/Project Reference ID',
                (val) => val!.isEmpty ? 'Enter a reference ID' : null,
                (val) => _procurementRef = val!,
              ),
              const SizedBox(height: 20),

              // Conditional Fields
              if (_reportType == 'Discrepancy')
                _buildDropdownField(
                  'Severity Level',
                  _severity,
                  severityOptions,
                  (val) => setState(() => _severity = val!),
                ),
              if (_reportType == 'Confirmation')
                _buildDropdownField(
                  'Delivery Status',
                  _deliveryStatus,
                  deliveryOptions,
                  (val) => setState(() => _deliveryStatus = val!),
                ),
              const SizedBox(height: 20),

              // Details Field
              _buildTextFormField(
                'Detailed Observation/Description',
                (val) => val!.length < 10
                    ? 'Description must be at least 10 characters'
                    : null,
                (val) => _details = val!,
                maxLines: 4,
              ),
              const SizedBox(height: 30),

              // Container(
              //   height: 100,
              //   decoration: BoxDecoration(
              //     color: Colors.grey[100],
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(color: Colors.grey.shade400),
              //   ),
              //   child: Center(
              //     child: _capturedImagePath != null
              //         ? GestureDetector(
              //             onTap: () => _showCapturedImageDialog(context),
              //             child: ClipRRect(
              //               borderRadius: BorderRadius.circular(8),
              //               child: Image.file(
              //                 File(_capturedImagePath!),
              //                 fit: BoxFit.cover,
              //                 width: 90,
              //                 height: 90,
              //               ),
              //             ),
              //           )
              //         : const Text(
              //             'No photo captured',
              //             style: TextStyle(color: Colors.grey),
              //           ),
              //   ),
              // ),
              const SizedBox(height: 10),

              // Open Camera Button
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push<String?>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CameraScreen(camera: widget.cameras.first),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Capture Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCapturedImageDialog(context);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitReport,
                  icon: const Icon(Icons.send),
                  label: Text('Submit $_reportType Report'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for TextFormFields
  Widget _buildTextFormField(
    String label,
    FormFieldValidator<String> validator,
    FormFieldSetter<String> onSaved, {
    int maxLines = 1,
  }) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  // Helper widget for DropdownFormFields
  Widget _buildDropdownField(
    String label,
    String initialValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: initialValue,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
