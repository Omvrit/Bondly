import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/connection_service.dart';
import '../models/user.dart';
import '../components/user_profile_header.dart';
import '../components/chat_list.dart';
import '../components/search_bar.dart';
import '../components/bottom_navigation.dart';
import '../components/make_connections_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<User> _connections = [];
  List<User> _filteredConnections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final authProvider = context.read<AuthProvider>();
    final connectionService = ConnectionService(
      baseUrl: 'http://192.168.200.102:5000', // Replace with your API URL
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
        return connection.username.toLowerCase().contains(query.toLowerCase()) ||
            connection.email.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onChatSelected(String userName,String userId) {
    Navigator.pushNamed(context, '/chat/$userId/$userName');
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    if (_currentIndex == 0) ...[
                      
                      ChatSearchBar(
                        controller: _searchController,
                        onSearch: _onSearch,
                      ),
                      Expanded(
                        child: ChatList(
                          chats: _filteredConnections.map((connection) {
                            return ChatItem(
                              id: connection.id,
                              name: connection.username,
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
      
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}