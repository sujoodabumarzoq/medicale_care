import 'package:medicale_care/models/chat_model.dart';
import 'package:medicale_care/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    try {
      final response = await _supabase.from('chats').select('*, messages(*)').eq('id', chatId).single();

      return ChatModel.fromJson(response);
      return null;
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  // Get chat by patient and doctor IDs
  Future<ChatModel?> getChatByParticipants(String patientId, String doctorId) async {
    try {
      final response = await _supabase.from('chats').select('*, messages(*)').eq('patient_id', patientId).eq('doctor_id', doctorId).single();

      return ChatModel.fromJson(response);
      return null;
    } catch (e) {
      // If no chat exists, return null rather than throwing an error
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null;
      }
      throw Exception('Failed to get chat by participants: $e');
    }
  }

  // Create or get chat
  Future<ChatModel> createOrGetChat(String patientId, String doctorId) async {
    try {
      // Try to get existing chat
      final existingChat = await getChatByParticipants(patientId, doctorId);
      if (existingChat != null) {
        return existingChat;
      }

      // Create new chat
      final response = await _supabase
          .from('chats')
          .insert({
            'patient_id': patientId,
            'doctor_id': doctorId,
            'last_message_time': DateTime.now().toIso8601String(),
          })
          .select('*, messages(*)')
          .single();

      return ChatModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create or get chat: $e');
    }
  }

  // Get patient's chats
  Future<List<ChatModel>> getPatientChats(String patientId) async {
    try {
      final response =
          await _supabase.from('chats').select('*, messages(*))').eq('patient_id', patientId).order('last_message_time', ascending: false);

      return (response as List).map((chat) => ChatModel.fromJson(chat)).toList();
    } catch (e) {
      throw Exception('Failed to get patient chats: $e');
    }
  }

  // Get doctor's chats
  Future<List<ChatModel>> getDoctorChats(String doctorId) async {
    try {
      final response = await _supabase.from('chats').select('''
      *,
      messages(*),
      patient_profile:patient_profiles(*, user:users(full_name))
    ''').eq('doctor_id', doctorId).order('last_message_time', ascending: false);
      return (response as List).map((chat) => ChatModel.fromJson(chat as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get doctor chats: $e');
    }
  }

  // Send message
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? attachment,
    String? attachmentType,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'chat_id': chatId,
            'sender_id': senderId,
            'receiver_id': receiverId,
            'content': content,
            'timestamp': DateTime.now().toIso8601String(),
            'attachment': attachment,
            'attachment_type': attachmentType,
          })
          .select()
          .single();

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages for a chat
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final response = await _supabase.from('messages').select().eq('chat_id', chatId).order('timestamp', ascending: true);

      return (response as List).map((msg) => MessageModel.fromJson(msg)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      await _supabase.rpc('mark_messages_as_read', params: {
        'p_chat_id': chatId,
        'p_user_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Subscribe to new messages in a chat
  Stream<List<MessageModel>> subscribeToMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .map((event) => event.map((e) => MessageModel.fromJson(e)).toList());
  }

  // Subscribe to chat updates
  Stream<ChatModel> subscribeToChat(String chatId) {
    return _supabase.from('chats').stream(primaryKey: ['id']).eq('id', chatId).map((event) => ChatModel.fromJson(event as Map<String, dynamic>));
  }
}
