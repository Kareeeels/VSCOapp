import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../app_config.dart';
import '../session.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  Uint8List? _imageBytes;
  final _picker = ImagePicker();
  String _selectedFilter = 'None';
  final TextEditingController _captionController = TextEditingController();

  final List<String> _filters = ['None', 'A6', 'M5', 'B1'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  ColorFilter _getFilter(String filter) {
    switch (filter) {
      case 'A6':
        return const ColorFilter.matrix([
          1, 0, 0, 0, 30,
          0, 1, 0, 0, 10,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'M5':
        return const ColorFilter.matrix([
          0.9, 0, 0, 0, 0,
          0, 0.9, 0, 0, 0,
          0, 0, 1.1, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'B1':
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      default:
        return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
    }
  }

  String _getFilterString(String filter) {
    switch (filter) {
      case 'A6': return 'sepia(0.3) contrast(1.1) brightness(1.1)';
      case 'M5': return 'hue-rotate(180deg) saturate(0.8) contrast(1.2)';
      case 'B1': return 'grayscale(1) contrast(1.2)';
      default: return 'none';
    }
  }

  Future<void> _publishPost() async {
    if (_imageBytes == null) return;

    final String base64Image = 'data:image/jpeg;base64,${base64Encode(_imageBytes!)}';
    
    final postData = {
      'username': Session.username,
      'imageUrl': base64Image,
      'caption': _captionController.text,
      'likes': 0,
      'filter': _getFilterString(_selectedFilter),
    };

    try {
      final response = await http.post(
        AppConfig.uri('/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post published!')),
          );
          setState(() {
            _imageBytes = null;
            _captionController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STUDIO', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w200)),
        backgroundColor: Colors.black,
        actions: [
          if (_imageBytes != null)
            TextButton(
              onPressed: _publishPost,
              child: const Text('POST', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF121212),
              child: _imageBytes == null
                  ? Center(
                      child: TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white54),
                        label: const Text('IMPORT A PHOTO', style: TextStyle(color: Colors.white54)),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ColorFiltered(
                              colorFilter: _getFilter(_selectedFilter),
                              child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              hintText: 'Add a caption...',
                              hintStyle: TextStyle(color: Colors.white24),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          height: 120,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => setState(() => _selectedFilter = _filters[index]),
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedFilter == _filters[index] ? Colors.white : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_filters[index], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      const Icon(Icons.style_outlined, size: 30, color: Colors.white24),
                                    ],
                                  ),
                                ),
                              );
                            },
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
