import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase.dart';

class Sender extends StatelessWidget {
  final String text;

  const Sender({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: const BoxConstraints(maxWidth: 220),
            decoration: BoxDecoration(
              color: Colors.orange.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(text),
          ),
          const SizedBox(width: 8),
          FutureBuilder<String?>(
            future: SupabaseService().getUserProfileImageUrl(),
            builder: (context, snapshot) {
              final imageUrl = snapshot.data;
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
        ],
      ),
    );
  }
}
