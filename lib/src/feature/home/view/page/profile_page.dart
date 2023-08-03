import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 25,
        itemBuilder: (ctx, i) => Column(
          children: [
            Image.asset('lib/assets/images/user.png'),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
