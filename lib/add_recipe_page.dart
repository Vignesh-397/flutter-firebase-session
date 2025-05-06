import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        picked.path,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedBytes != null) {
        setState(() => _imageBytes = Uint8List.fromList(compressedBytes));
      } else {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    }
  }

  Future<void> _saveRecipe() async {
    if (_imageBytes == null || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter title and select an image')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final encodedImage = base64Encode(_imageBytes!);

    await FirebaseFirestore.instance.collection('recipes').add({
      'title': _titleController.text.trim(),
      'ingredients': _ingredientsController.text.trim(),
      'steps': _stepsController.text.trim(),
      'imageBase64': encodedImage,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Recipe')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter recipe title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Ingredients',
                hintText: 'List ingredients separated by commas',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _stepsController,
              decoration: InputDecoration(
                labelText: 'Steps',
                hintText: 'Describe the cooking steps',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 24),
            _imageBytes != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.memory(
                      _imageBytes!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No image selected',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('Pick Image'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveRecipe,
              icon: Icon(Icons.save),
              label: Text('Save Recipe'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
