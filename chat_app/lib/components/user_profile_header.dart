import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Column(
      children: [
        if (authProvider.user?.avatar != null)
          CircleAvatar(
            backgroundImage: NetworkImage(authProvider.user!.avatar),
            radius: 50,
          ),
        const SizedBox(height: 20),
        Text(
          'Welcome, ${authProvider.user?.username ?? 'User'}!',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 10),
        Text(
          authProvider.user?.email ?? '',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}