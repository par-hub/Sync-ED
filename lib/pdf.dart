import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadPDFPage extends StatefulWidget {
  const UploadPDFPage({super.key});

  @override
  State<UploadPDFPage> createState() => _UploadPDFPageState();
}

class _UploadPDFPageState extends State<UploadPDFPage> {
  String? fileName;

  void _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });
    }
  }

  void _uploadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload button clicked (no backend yet)')),
    );
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 60),
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
    );
  }
}
