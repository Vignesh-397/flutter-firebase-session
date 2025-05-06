import 'dart:convert';

import 'package:app_1/model/recipe.dart';
import 'package:app_1/recipe_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_recipe_page.dart';

class HomePage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  void _logout() => FirebaseAuth.instance.signOut();

  @override
  Widget build(BuildContext context) {
    final recipeStream =
        FirebaseFirestore.instance
            .collection('recipes')
            .where('userId', isEqualTo: user!.uid)
            .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: _logout)],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: recipeStream,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final recipes =
              snapshot.data!.docs
                  .map(
                    (doc) => Recipe.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();
          return ListView.builder(
            padding: EdgeInsets.all(12.0),
            itemCount: recipes.length,
            itemBuilder: (ctx, i) {
              final recipe = recipes[i];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      base64Decode(recipe.imageBase64),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    recipe.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(recipe),
                        ),
                      ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddRecipePage()),
            ),
      ),
    );
  }
}
