import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connection_service.dart';
import '../../models/connection.dart';
import '../components/user_profile_header.dart';
import '../components/chat_list.dart';
import '../components/search_bar.dart';
import '../components/bottom_navigation.dart';
import '../components/connection_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Connection> _connections = [];
  List<Connection> _filteredConnections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final authProvider = context.read<AuthProvider>();
    final connectionService = ConnectionService(
      baseUrl: 'http://192.168.150.102:5000/api/auth', // Replace with your API URL
      authToken: authProvider.tokens!.accessToken,
    );

    try {
      final connections = await connectionService.getConnections();
      setState(() {
        _connections = connections;
        _filteredConnections = connections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredConnections = _connections.where((connection) {
        return connection.name.toLowerCase().contains(query.toLowerCase()) ||
            connection.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onChatSelected(String connectionId) {
    Navigator.pushNamed(context, '/chat/$connectionId');
  }

  void _showAddConnectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ConnectionModal(
        onConnectionAdded: (connection) {
          setState(() {
            _connections.add(connection);
            _filteredConnections.add(connection);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    if (_currentIndex == 0) ...[
                      const UserProfileHeader(),
                      ChatSearchBar(
                        controller: _searchController,
                        onSearch: _onSearch,
                      ),
                      Expanded(
                        child: ChatList(
                          chats: _filteredConnections.map((connection) {
                            return ChatItem(
                              id: connection.id,
                              name: connection.name,
                              avatar: connection.avatar,
                              lastMessage: connection.isOnline
                                  ? 'Online'
                                  : 'Last seen recently',
                              time: '',
                            );
                          }).toList(),
                          onChatSelected: _onChatSelected,
                        ),
                      ),
                    ] else if (_currentIndex == 1) ...[
                      const Expanded(
                        child: Center(
                          child: Text('Contacts Screen'),
                        ),
                      ),
                    ] else ...[
                      const Expanded(
                        child: Center(
                          child: Text('Settings Screen'),
                        ),
                      ),
                    ],
                  ],
                ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddConnectionModal,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: ChatBottomNavigation(
        currentIndex: _currentIndex,
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}