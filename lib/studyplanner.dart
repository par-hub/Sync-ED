import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom.dart';
import 'package:flutter_application_1/studyplanner2.dart';

class StudyPlannerPage extends StatefulWidget {
  const StudyPlannerPage({super.key});

  @override
  State<StudyPlannerPage> createState() => _StudyPlannerPageState();
}

class _StudyPlannerPageState extends State<StudyPlannerPage> {
  List<Map<String, dynamic>> cards = [
    {
      "color": Colors.orange.shade200,
      "controller": TextEditingController(),
    },
    {
      "color": Colors.orange.shade300,
      "controller": TextEditingController(),
    },
  ];

  void _addCard() {
    setState(() {
      cards.add({
        "color": cards.length % 2 == 0
            ? Colors.orange.shade200
            : Colors.orange.shade300,
        "controller": TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    for (var card in cards) {
      card['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomBar(),
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: const Text("Study Planner"),
        backgroundColor: Colors.brown,
        actions: [IconButton(onPressed: _addCard, icon: const Icon(Icons.add))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // dismiss keyboard
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Studyplanner2(controller: card['controller']),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: card["color"],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IgnorePointer(
                  ignoring: true,
                  child: TextField(
                    controller: card["controller"],
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "Write something...",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
