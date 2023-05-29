class Conversation {
  int? id; // Make the id field nullable

  final String name;
  final String userId;
  final String otherUserId;
  final String lastMessage;
  final DateTime lastMessageTime;

  Conversation({
    this.id,
    required this.userId,
    required this.name,
    required this.otherUserId,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'otherUserId': otherUserId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
    };
  }
}