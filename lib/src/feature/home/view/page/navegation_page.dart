import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'search_page.dart';
import 'profile_page.dart';

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
    HomePage(),
    SearchPage(),
    ProfilePage(),
  ];

  final List<Widget> _icons = const [
    Icon(Icons.home, size: 30),
    Icon(Icons.search, size: 30),
    Icon(Icons.person, size: 30),
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Estudo'),
      ),
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
