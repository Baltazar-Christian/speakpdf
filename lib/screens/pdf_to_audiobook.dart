import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

class PDFToAudiobook extends StatefulWidget {
  @override
  _PDFToAudiobookState createState() => _PDFToAudiobookState();
}

class _PDFToAudiobookState extends State<PDFToAudiobook> {
  FlutterTts flutterTts = FlutterTts();
  double _speechRate = 0.5;
  String _status = 'Ready';

  Future<void> readPdfAloud(String filePath) async {
    setState(() {
      _status = 'Reading...';
    });
    // Load the PDF document
    PdfDocument document =
        PdfDocument(inputBytes: File(filePath).readAsBytesSync());

    // Initialize the text extractor
    PdfTextExtractor extractor = PdfTextExtractor(document);

    // Extract text from all pages
    String text = '';
    for (int i = 1; i <= document.pages.count; i++) {
      text += extractor.extractText(startPageIndex: i, endPageIndex: i) + "\n";
    }

    // Close the document
    document.dispose();

    // Speak the text
    await flutterTts.setSpeechRate(_speechRate);
    await flutterTts.speak(text);
    setState(() {
      _status = 'Finished';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SpeakPDF'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_status,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            SizedBox(height: 20),
            Slider(
              value: _speechRate,
              onChanged: (newRate) {
                setState(() {
                  _speechRate = newRate;
                });
              },
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: "Speech Rate: ${(_speechRate * 10).toStringAsFixed(1)}",
              activeColor: Colors.red,
              inactiveColor: Colors.red[100],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );

                if (result != null) {
                  String? filePath = result.files.single.path;
                  if (filePath != null) {
                    readPdfAloud(filePath);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text('Open PDF', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
