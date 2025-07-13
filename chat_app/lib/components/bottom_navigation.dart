import 'package:flutter/material.dart';

class ChatBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const ChatBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChange,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat), label: 'Chats'),
        BottomNavigationBarItem(
          icon: Icon(Icons.people), label: 'Contacts'),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Profile'),
        
        
      ],
    );
  }
}