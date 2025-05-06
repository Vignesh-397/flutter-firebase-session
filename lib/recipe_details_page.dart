import 'dart:convert';
import 'dart:typed_data';

import 'package:app_1/model/recipe.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  RecipeDetailPage(this.recipe);

  Future<void> _deleteRecipe(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipe.id)
        .delete();
    Navigator.pop(context);
  }

  void _editRecipe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditRecipePage(recipe)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = base64Decode(recipe.imageBase64);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editRecipe(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteRecipe(context),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(imageBytes, height: 550, fit: BoxFit.cover),
          ),
          SizedBox(height: 16),
          Text(
            recipe.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Ingredients:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(recipe.ingredients),
          SizedBox(height: 12),
          Text(
            'Steps:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(recipe.steps),
        ],
      ),
    );
  }
}

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;

  EditRecipePage(this.recipe);

  @override
  _EditRecipePageState createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  late TextEditingController _titleController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _ingredientsController = TextEditingController(
      text: widget.recipe.ingredients,
    );
    _stepsController = TextEditingController(text: widget.recipe.steps);
    _imageBytes = base64Decode(widget.recipe.imageBase64);
  }

  Future<void> _saveChanges() async {
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipe.id)
        .update({
          'title': _titleController.text.trim(),
          'ingredients': _ingredientsController.text.trim(),
          'steps': _stepsController.text.trim(),
          // keep image same for now
        });

    Navigator.pop(context);
  }

  // optional: implement picking a new image (similar to AddRecipePage)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Recipe')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Ingredients',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _stepsController,
              decoration: InputDecoration(
                labelText: 'Steps',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(_imageBytes!, height: 200, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: Icon(Icons.save),
              label: Text('Save Changes'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
