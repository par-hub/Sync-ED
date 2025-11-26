import 'package:flutter/material.dart';
import 'package:flutter_application_1/supabase.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService();

    return BottomAppBar(
      color: Colors.orange[300],
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.pushNamed(context, '/studyplanner');
              },
            ),
            IconButton(
              icon: const Icon(Icons.smart_toy), // <-- Changed icon
              onPressed: () {
                Navigator.pushNamed(context, '/ai'); // <-- Navigate to in-app AI chat
              },
              tooltip: 'AI Chat',
            ),
            FutureBuilder<Map<String, dynamic>?>(
              future: supabase.getCurrentUser(),
              builder: (context, snapshot) {
                String? pfpUrl;
                if (snapshot.hasData && snapshot.data != null) {
                  pfpUrl = snapshot.data!['pfp'];
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.brown, width: 2),
                      image: pfpUrl != null
                          ? DecorationImage(
                              image: NetworkImage(pfpUrl),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/default_avatar.png'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                Navigator.pushNamed(context, '/academic');
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
          ],
        ),
      ),
    );
  }
}
