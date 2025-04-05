import 'package:flutter/material.dart';

class Receiver extends StatelessWidget {
  final String text; // 1️⃣ Declare the text variable

  const Receiver(
      {super.key, required this.text}); // 2️⃣ Accept it in constructor

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage("https://via.placeholder.com/150"),
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
            child: Text(text), // 3️⃣ Use it here
          ),
        ],
      ),
    );
  }
}
