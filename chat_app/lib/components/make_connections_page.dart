import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connection_service.dart';
import '../../services/user_service.dart';
import '../models/user.dart';
import '../../services/friend_request.dart';

class ConnectionModal extends StatefulWidget {
  final Function(User) onConnectionAdded;

  const ConnectionModal({super.key, required this.onConnectionAdded});

  @override
  State<ConnectionModal> createState() => _ConnectionModalState();
}

class _ConnectionModalState extends State<ConnectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _suggestedConnections = [];
  bool _isLoading = false;
  String? _error;
  bool _requestSent = false;

  Future<void> _searchUsers(String username) async {
    if (username.isEmpty) {
      setState(() {
        _suggestedConnections = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userService = UserService(
        baseUrl: 'http://192.168.200.102:5000',
        authToken: authProvider.tokens!.accessToken,
      );

      final users = await userService.searchUsersByUsername(username);
      
      setState(() {
        _suggestedConnections = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search users';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFriendRequest(User user) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = context.read<AuthProvider>();
      final friendRequestService = FriendRequest(
        baseUrl: 'http://192.168.200.102:5000',
        authToken: authProvider.tokens!.accessToken,
      );
      
      final message = await friendRequestService.sendRequest(user.username);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      setState(() {
        _requestSent = true;
      });

      // Close the modal after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Connection',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by username',
                  hintText: 'Enter username to search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                ),
                onChanged: _searchUsers,
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              )
            else if (_suggestedConnections.isEmpty && _searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No users found for "${_searchController.text}"',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else if (_suggestedConnections.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search for users to connect with',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _suggestedConnections.length,
                  itemBuilder: (context, index) {
                    final connection = _suggestedConnections[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(connection.avatar),
                            radius: 24,
                          ),
                          title: Text(
                            connection.username,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            connection.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: _requestSent
                              ? const Icon(Icons.check, color: Colors.green)
                              : FilledButton.tonal(
                                  onPressed: () => _sendFriendRequest(connection),
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all(
                                      const Size(40, 36)),
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(horizontal: 12)),
                                  ),
                                  child: const Text('Add'),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}