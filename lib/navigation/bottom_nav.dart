import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/settings/global_settings_controller.dart';

import '../features/home/home_screen.dart';
import '../features/library/library_screen.dart';
import '../features/tv/screens/tv_screen.dart';
import '../features/community/screens/community_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  /// Home tab is the middle
  int currentIndex = 2;

  // Global Keys to maintain separate navigator states for each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _pages = const [
    LibraryScreen(),   // 0
    TvScreen(),        // 1
    HomeScreen(),      // 2
    CommunityScreen(), // 3 Community
    ProfileScreen(),   // 4 Profile
  ];

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => _pages[index],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<GlobalSettingsController>(context).isArabicOnlyMode;

    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[currentIndex].currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (currentIndex != 2) {
            setState(() {
              currentIndex = 2;
            });
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        extendBody: true, // Let the body content scroll BEHIND the glass navbar
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
            _buildOffstageNavigator(4),
          ],
        ),

        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04), // Barely-there white tint
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.0)), // Specular edge highlight
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent, // Ensures it inherits glass background
                currentIndex: currentIndex,
                type: BottomNavigationBarType.fixed,
      
                onTap: (index) {
                  if (index == currentIndex) {
                    // Pop to first route if tapping the active tab again
                    _navigatorKeys[index]
                        .currentState!
                        .popUntil((route) => route.isFirst);
                  } else {
                    setState(() {
                      currentIndex = index;
                    });
                  }
                },
      
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.menu_book),
                    label: isArabic ? 'المكتبة' : 'Library',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.tv),
                    label: isArabic ? 'البث' : 'TV',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: isArabic ? 'الرئيسية' : 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.groups),
                    label: isArabic ? 'أمتي' : 'Ummah',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person),
                    label: isArabic ? 'الحساب' : 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}