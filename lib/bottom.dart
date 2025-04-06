import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  Future<void> _launchURL() async {
    const url =
        'https://files.bpcontent.cloud/2025/04/05/06/20250405061617-KN2MUCB7.html';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.insert_drive_file),
              onPressed: _launchURL, // Launch link
            ),
            GestureDetector(
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
                  image: const DecorationImage(
                    image: AssetImage('assets/profile.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
