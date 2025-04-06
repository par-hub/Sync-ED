import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom.dart';
import 'package:flutter_application_1/pdf.dart';
import 'package:flutter_application_1/supabase.dart';
import 'package:url_launcher/url_launcher.dart';

class Academic extends StatefulWidget {
  const Academic({super.key});

  @override
  State<Academic> createState() => _AcademicState();
}

class _AcademicState extends State<Academic> {
  final _supabaseService = SupabaseService();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPosts = [];
  List<Map<String, dynamic>> _filteredPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() => _isLoading = true);
      final posts = await _supabaseService.getAllPosts();
      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading posts: $e')),
        );
      }
    }
  }

  void _filterPosts(String query) {
    setState(() {
      _filteredPosts = _allPosts.where((post) {
        final title = post['title']?.toString().toLowerCase() ?? '';
        return title.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomBar(),
      backgroundColor: Colors.brown[800],
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text(
          "Academic Notes",
          style: TextStyle(fontFamily: 'Serif', color: Colors.white),
        ),
        actions: const [
          Icon(Icons.settings),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: Colors.orange.shade400,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu, color: Colors.white),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 160,
                              height: 35,
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  hintText: "Search...",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.orange.shade300,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: _filterPosts,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadPDFPage(title: "Upload PDF"),
                              ),
                            );
                          },
                          child: const Icon(Icons.add_circle_outline, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 👇 Repeat document blocks to test scroll
                  for (var post in _filteredPosts) ...[
                    GestureDetector(
                      onTap: (){
                              if (post['note'] != null) {
                              launchUrl(Uri.parse(post['note']));
                            }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          height: 240,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text(post['title'] ?? 'Document Preview')),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.favorite_border, color: Colors.brown),
                          Icon(Icons.share, color: Colors.brown),
                          Icon(Icons.download, color: Colors.brown),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter document name...',
                              hintStyle: TextStyle(color: Colors.orange),
                              border: InputBorder.none,
                            ),
                            controller: TextEditingController(text: post['title']),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Enter document description...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            controller: TextEditingController(text: post['description']),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
      ),
    );
  }
}
