import 'dart:ui';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'search_page.dart';
import 'profile_page.dart';

class NavegationPage extends StatefulWidget {
  const NavegationPage({Key? key}) : super(key: key);

  @override
  NavegationPageState createState() => NavegationPageState();
}

class NavegationPageState extends State<NavegationPage> {
  late PageController pageViewController;
  int currentPageIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    ProfilePage(),
  ];

  final List<Widget> _icons = const [
    Icon(Icons.home),
    Icon(Icons.search),
    Icon(Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    pageViewController = PageController();
    pageViewController.addListener(() {
      setState(() {
        currentPageIndex = pageViewController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  Widget _buildBottomNavigation(Size size) {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
          ),
          child: SizedBox(
            height: size.height * 0.075,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _icons
                  .asMap()
                  .entries
                  .map(
                      (entry) => _buildIconButton(entry.key, entry.value, size))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(int index, Widget icon, Size size) {
    final isActive = currentPageIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isActive ? colorScheme.secondary : colorScheme.tertiary;

    return Expanded(
      child: IconButton(
        icon: icon,
        iconSize: size.height * 0.035,
        onPressed: () => pageViewController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        ),
        color: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),
          PageView(
            controller: pageViewController,
            children: _pages,
          ),
          _buildBottomNavigation(size)
        ],
      ),
    );
  }
}
