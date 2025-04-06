import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom.dart';
import 'package:flutter_application_1/studyplanner_popup.dart';
import 'supabase.dart';

class StudyPlannerPage extends StatefulWidget {
  const StudyPlannerPage({super.key});

  @override
  State<StudyPlannerPage> createState() => _StudyPlannerPageState();
}

class _StudyPlannerPageState extends State<StudyPlannerPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.getStudyPlannerNotes();
      setState(() {
        cards = data.map((note) => {
          "id": note['id'],
          "color": note['index'] % 2 == 0 
              ? Colors.orange.shade200 
              : Colors.orange.shade300,
          "controller": TextEditingController(text: note['title']),
          "notes": note['notes'],
          "date": note['date'] != null ? DateTime.parse(note['date']) : null,
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notes: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCard() async {
    try {
      final response = await _supabaseService.addToStudyPlanner(
        title: '',
        notes: '',
        id: cards.length,
      );
      
      setState(() {
        cards.add({
          "id": response['id'],
          "color": cards.length % 2 == 0
              ? Colors.orange.shade200
              : Colors.orange.shade300,
          "controller": TextEditingController(),
          "notes": '',
          "date": null,
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding note: $e')),
      );
    }
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
      bottomNavigationBar: const CustomBottomBar(),
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
