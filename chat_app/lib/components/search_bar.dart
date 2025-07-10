import 'package:flutter/material.dart';

class ChatSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final TextEditingController controller;

  const ChatSearchBar({
    super.key,
    required this.onSearch,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search chats...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: onSearch,
      ),
    );
  }
}