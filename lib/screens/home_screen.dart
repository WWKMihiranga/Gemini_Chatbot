import 'package:flutter/material.dart';
import 'package:gemini_chatbot/constant/theme_provider.dart';
import 'package:gemini_chatbot/widgets/message_widget.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  bool _loading = false;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  int _loadedMessageCount = 10;

  String _selectedTheme = "Default"; // Tracks the selected theme

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyALij-T8oOm8qgsOG2gCADlHg3H6MJQT24',
    );
    _chatSession = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.getTheme(_selectedTheme);

    return Theme(
      data: themeProvider, // Apply selected theme
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Build with Gemini"),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _selectedTheme = value;
                });
              },
              itemBuilder: (context) {
                return ThemeProvider.availableThemes
                    .map((theme) => PopupMenuItem(
                          value: theme,
                          child: Text(theme),
                        ))
                    .toList();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _loadedMessageCount + 1,
                  itemBuilder: (context, index) {
                    if (index == _loadedMessageCount) {
                      return _buildLoadMoreButton();
                    }

                    // Safeguard against out-of-bounds access
                    if (index >= _messages.length) {
                      return const SizedBox(); // Return an empty widget if the index is invalid
                    }

                    final message = _messages[index];
                    return MessageWidget(
                      text: message['text'],
                      isFormUser: message['role'] == 'user',
                      status: message['status'] ?? '',
                      timestamp:
                          message['role'] == 'ai' ? message['timestamp'] : null,
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        controller: _textEditingController,
                        decoration: _textFieldDecoration(),
                        onSubmitted: _sendChatMessage,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_textEditingController.text.isNotEmpty) {
                          _sendChatMessage(_textEditingController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: TextButton(
        onPressed: _loadMoreMessages,
        child: const Text('Load More'),
      ),
    );
  }

  InputDecoration _textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Type a message...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
      _messages.insert(0, {
        'text': message,
        'role': 'user',
        'status': 'Sent',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    _textEditingController.clear();
    _scrollDown();

    try {
      final response = await _chatSession.sendMessage(
        Content.text(message),
      );
      final text = response.text;
      if (text != null) {
        setState(() {
          _messages.insert(0, {
            'text': text,
            'role': 'ai',
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      } else {
        _showError('No response from API');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
      _scrollDown();
    }
  }

  void _loadMoreMessages() {
    setState(() {
      _loadedMessageCount =
          (_loadedMessageCount + 10).clamp(0, _messages.length);
    });
  }

  void _showError(String message) {
    print(message);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }
}
