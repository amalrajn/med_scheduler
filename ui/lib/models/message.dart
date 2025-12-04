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
    
    // Helper to safely extract string data, returning null if missing or if the value is 'null' string
    String? _extractString(String key) {
      final value = json[key] as String?;
      return (value != null && value.isNotEmpty && value != 'null') ? value.trim() : null;
    }

    // --- Sender ID Extraction (Prioritize Flask Model Keys) ---
    // The Flask model uses 'sender_id'. We prioritize this snake_case key.
    String extractedSenderId = _extractString('sender_id') ?? 
                               _extractString('senderId') ?? 
                               'missing-id'; // Use a final fallback
    // -------------------------------------------------------------
    
    // --- Medication ID Extraction (Prioritize Flask Model Keys) ---
    // The Flask model uses 'medication_id'.
    String extractedMedicationId = _extractString('medication_id') ?? 
                                   _extractString('medicationId') ?? 
                                   'unknown-med';

    return Message(
      // The Flask model uses 'id'
      id: _extractString('id') ?? 'unknown-id',
      
      medicationId: extractedMedicationId,
      
      // Use the deterministically extracted sender ID
      senderId: extractedSenderId, 
      
      // The Flask model uses 'content'
      content: _extractString('content') ?? _extractString('text') ?? 'No Content',
      
      // The Flask model uses 'timestamp'
      // Parse ISO 8601 string into a DateTime object.
      // We expect the 'Z' (Zulu time) suffix from the Flask model's isoformat() + 'Z'
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