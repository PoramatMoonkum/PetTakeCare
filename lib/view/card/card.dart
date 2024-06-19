import 'package:flutter/material.dart';

class PetSitterCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final Function(bool)? onAcceptChanged;

  const PetSitterCard({
    required this.imageUrl,
    required this.name,
    required this.description,
    this.onAcceptChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(description),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (onAcceptChanged != null) {
                          onAcceptChanged!(false);
                        }
                      },
                      child: Text('ปฏิเสธ'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (onAcceptChanged != null) {
                          onAcceptChanged!(true);
                        }
                      },
                      child: Text('ตกลง'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
