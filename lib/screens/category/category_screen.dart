import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: Category.getAll(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return const Center(
            child: Text('No categories found'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to category details
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (category.imageUrl != null)
                      Image.network(
                        category.imageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 