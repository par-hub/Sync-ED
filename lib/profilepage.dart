import 'package:flutter/material.dart';
import 'package:flutter_application_1/bottom.dart';
import 'package:flutter_application_1/dialog.dart';
import 'package:flutter_application_1/supabase.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  

  static const Color brown = Color(0xFF6D3B1F);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      bottomNavigationBar: const CustomBottomBar(),
      backgroundColor: const Color(0xFFF5E2CE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(height: 10, color: ProfilePage.brown),

              // Logout & Settings Row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => LogoutDialogScreen(supabase: supabase,),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4B860),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      child: const Text("Logout"),
                    ),
                    const Icon(Icons.settings, size: 24),
                  ],
                ),
              ),

              // Profile Card with Avatar
              Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: FutureBuilder<String?>(
                        future: supabase.getUserProfileImageUrl(),
                        builder: (context, snapshot) {
                          final imageUrl = snapshot.data ?? '';
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 40)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<Map<String, dynamic>?>(
                                future: supabase.getCurrentUser(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    );
                                  }
                                  
                                  final displayName = snapshot.data?['display_name'] ?? 'Guest';
                                  return Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // My Posts Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'My Posts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Serif',
                      color: ProfilePage.brown,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: supabase.getUserPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final posts = snapshot.data ?? [];
                    
                    if (posts.isEmpty) {
                      return const Center(
                        child: Text(
                          'No posts yet',
                          style: TextStyle(
                            color: ProfilePage.brown,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return InkWell(
                          onTap: () {
                            // Open PDF or show details
                            if (post['note'] != null) {
                              launchUrl(Uri.parse(post['note']));
                            }
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: ProfilePage.brown,
                                  child: const Center(
                                    child: Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ProfilePage.brown,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (post['data'] != null)
                                      Text(
                                        post['data'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
