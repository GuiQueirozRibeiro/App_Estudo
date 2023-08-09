import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';
import 'notification_page.dart';

class NavegationPage extends StatefulWidget {
  const NavegationPage({super.key});

  @override
  NavegationPageState createState() => NavegationPageState();
}

class NavegationPageState extends State<NavegationPage>
    with TickerProviderStateMixin {
  int currentPageIndex = 0;
  late PageController _pageViewController;
  late AnimationController _animationController;

  final List<Widget> _pages = const [
    ChatPage(),
    NotificationPage(),
  ];

  final List<Widget> _icons = const [
    Icon(Icons.chat, size: 30, color: Colors.white),
    Icon(Icons.notifications, size: 30, color: Colors.white),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pageViewController = PageController();
    _pageViewController.addListener(() {
      setState(() {
        currentPageIndex = _pageViewController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageViewController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (currentPageIndex != index) {
      _pageViewController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageViewController,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: currentPageIndex,
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.primary,
        height: 60,
        items: _icons,
        onTap: _onTap,
      ),
    );
  }
}
