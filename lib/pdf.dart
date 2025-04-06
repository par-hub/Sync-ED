import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application_1/supabase.dart';

class UploadPDFPage extends StatefulWidget {
  const UploadPDFPage({super.key});

  @override
  State<UploadPDFPage> createState() => _UploadPDFPageState();
}

class _UploadPDFPageState extends State<UploadPDFPage> {
  final SupabaseService _supabaseService = SupabaseService();
  String? fileName;
  Uint8List? fileBytes;
  final TextEditingController _docNameController = TextEditingController();
  final TextEditingController _docDescriptionController = TextEditingController();

  bool _isLoading = false;

  void _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // Important: This ensures we get the file bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            fileName = file.name;
            fileBytes = file.bytes;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not read the PDF file')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF: $e')),
        );
      }
    }
  }

  Future<void> _uploadPDF() async {
    if (fileBytes == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabaseService.uploadNote(
        title: _docNameController.text,
        path: path,
        fileBytes: fileBytes!,
        data: _docDescriptionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
        Navigator.pop(context); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        title: const Text("Upload PDF"),
        backgroundColor: Colors.brown,
        elevation: 4,
      ),
      // Wrap the body with GestureDetector to handle taps
      body: GestureDetector(
        onTap: () {
          // Hide keyboard when tapping outside of text fields
          FocusScope.of(context).unfocus();
        },
        // Make sure the gesture detector doesn't interfere with scrolling
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _docNameController,
                      decoration: InputDecoration(
                        labelText: 'Document Name',
                        labelStyle: TextStyle(color: Colors.brown[700]),
                        filled: true,
                        fillColor: Colors.brown[50],
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown.shade300, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _docDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Document Description',
                        labelStyle: TextStyle(color: Colors.brown[700]),
                        filled: true,
                        fillColor: Colors.brown[50],
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown.shade300, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      fileName != null
                          ? "Selected: $fileName"
                          : "No PDF selected",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _pickPDF,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Pick a PDF"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _uploadPDF,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Upload PDF"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
