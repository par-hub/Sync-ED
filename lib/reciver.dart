import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase.dart';

class Receiver extends StatelessWidget {
  final String text;
  final String? userId;

  const Receiver({
    super.key, 
    required this.text,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: userId != null 
                ? SupabaseService().getUserById(userId!)
                : null,
            builder: (context, snapshot) {
              final imageUrl = snapshot.data?['pfp'];
              return CircleAvatar(
                radius: 14,
                backgroundColor: Colors.brown[200],
                backgroundImage: imageUrl != null 
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? const Icon(Icons.person, size: 16, color: Colors.white)
                    : null,
              );
            },
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: const BoxConstraints(maxWidth: 220),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
