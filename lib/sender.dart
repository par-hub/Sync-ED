import 'package:flutter/material.dart';

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
          const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage("https://via.placeholder.com/150"),
          ),
        ],
      ),
    );
  }
}
