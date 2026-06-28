class ChatMessageModel {
  final String id;
  final String threadId;
  final String role; // user | assistant
  final String content;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.threadId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isUser      => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory ChatMessageModel.fromJson(Map<String, dynamic> j) => ChatMessageModel(
        id:        j['_id'] as String? ?? '',
        threadId:  j['thread_id'] as String? ?? '',
        role:      j['role'] as String? ?? 'user',
        content:   j['content'] as String? ?? '',
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class ChatThreadModel {
  final String id;
  final String parentId;
  final String? childId;
  final String? title;
  final bool isActive;
  final DateTime createdAt;

  const ChatThreadModel({
    required this.id,
    required this.parentId,
    this.childId,
    this.title,
    required this.isActive,
    required this.createdAt,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> j) => ChatThreadModel(
        id:        j['_id'] as String? ?? '',
        parentId:  j['parent_id'] as String? ?? '',
        childId:   j['child_id'] as String?,
        title:     j['title'] as String?,
        isActive:  j['is_active'] as bool? ?? true,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
