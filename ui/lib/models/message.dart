class Message {
  final String id;
  final String medicationId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.medicationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor to create a Message object from the JSON map received from the API.
  factory Message.fromJson(Map<String, dynamic> json) {
    // We use null-safe access (json['key'] as String?) and provide sensible default values 
    // using ?? 'default' to prevent 'Null is not a subtype of String' errors during parsing.
    return Message(
      // The API should provide an ID, but we handle the case where it might be missing.
      id: json['id'] as String? ?? 'missing-id', 
      
      // These are required fields from the server but are defensively handled here.
      medicationId: json['medicationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? 'No content',
      
      // Parse ISO 8601 string into a DateTime object.
      // If the timestamp is null or invalid, we default to the current time.
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : DateTime.now(), 
    );
  }

  // Helper method for optimistic updates (if needed)
  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'senderId': senderId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
}