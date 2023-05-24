class Messages {
  final int id;
  final int conversationId;
  final String senderId;
  final String content;
  final DateTime sentTime;

  Messages({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'sentTime': sentTime.toIso8601String(),
    };
  }
}
