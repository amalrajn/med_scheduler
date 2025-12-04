import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/api_service.dart';
import '../models/message.dart'; // Correctly using the Message model

class ChatPage extends StatefulWidget {
  final String userId; // The ID of the current user (patient or caregiver)
  final Medication medication;
  final bool isCaregiver; // New: Flag to determine message layout

  const ChatPage({
    super.key,
    required this.userId,
    required this.medication,
    this.isCaregiver = false, // Set this correctly when navigating from caregiver dashboard
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = []; // Correctly typed list
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      // Fetch messages using the medication ID. The API service returns List<Message>.
      final fetchedMessages = await _apiService.fetchChatHistory(widget.medication.id);
      
      setState(() => _messages = fetchedMessages);
      _scrollToBottom();

      if (_messages.isNotEmpty) {
        debugPrint('--- Chat Alignment Debug ---');
        debugPrint('Current widget.userId: ${widget.userId}');
        debugPrint('First message senderId: ${_messages.first.senderId}');
        debugPrint('Are they the same? ${_messages.first.senderId == widget.userId}');
        debugPrint('----------------------------');
      }
    } catch (e) {
      debugPrint('Error loading chat: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    // Use the Message class for the optimistic update
    final optimisticMessage = Message(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}', 
      medicationId: widget.medication.id,
      senderId: widget.userId,
      content: content,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(optimisticMessage);
    });
    _scrollToBottom();

    try {
      await _apiService.sendMessage(
        widget.medication.id,
        widget.userId, // The current user ID is the sender ID
        content,
      );
      // Optional: Reload messages to replace the optimistic message with the confirmed one
      // await _loadMessages();
    } catch (e) {
      debugPrint('Error sending message: $e');
      // If failed, remove the optimistic message and show error
      setState(() {
        _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: ${widget.medication.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // 1. Determine if the message belongs to the current user (you)
                      final isMe = message.senderId == widget.userId;

                      return Align(
                        // 2. Align the entire bubble based on ownership: Right for 'me', Left for 'them'
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            // 3. Set color based on ownership
                            color: isMe ? Colors.blue.shade100 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12).copyWith(
                              // 4. Adjust border radius for a chat bubble look
                              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                            ),
                          ),
                          child: Column(
                            // FIX: Align content inside the bubble (text/timestamp) based on who sent it
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              // For right-aligned messages, consider wrapping text in Flexible and using TextAlign.right
                              Text(
                                message.content, 
                                style: const TextStyle(fontSize: 16),
                                textAlign: isMe ? TextAlign.right : TextAlign.left,
                              ),
                              const SizedBox(height: 4),
                              // Display formatted timestamp
                              Text(
                                _formatTime(message.timestamp), 
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Message Input Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
                    : FloatingActionButton.small(
                        onPressed: _sendMessage,
                        child: const Icon(Icons.send),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Parameter type is correctly DateTime
  String _formatTime(DateTime timestamp) {
    try {
      final timeOfDay = TimeOfDay.fromDateTime(timestamp);
      return timeOfDay.format(context); // Format: 8:30 PM
    } catch (e) {
      return 'Error time';
    }
  }
}