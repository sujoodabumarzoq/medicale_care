import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/models/chat_model.dart';
import 'package:medicale_care/models/message_model.dart';
import 'package:medicale_care/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  ChatCubit(this._chatRepository) : super(ChatInitial());

  void loadChats(String doctorId) async {
    try {
      emit(ChatLoading());
      final chats = await _chatRepository.getDoctorChats(doctorId);
      emit(ChatsLoaded(chats: chats));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void loadChat(String patientId, String doctorId) async {
    try {
      emit(ChatLoading());
      final chat = await _chatRepository.createOrGetChat(patientId, doctorId);
      final messages = await _chatRepository.getMessages(chat.id);
      emit(ChatLoaded(chat: chat.copyWith(messages: messages)));

      // Subscribe to real-time updates
      _chatRepository.subscribeToMessages(chat.id).listen((message) {
        final currentState = state;
        if (currentState is ChatLoaded) {
          final updatedMessages = List<MessageModel>.from(currentState.chat.messages);
          emit(ChatLoaded(chat: currentState.chat.copyWith(messages: updatedMessages)));
        }
      });
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? attachment,
    String? attachmentType,
  }) async {
    try {
      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(ChatSendingMessage(chat: currentState.chat));
        final message = await _chatRepository.sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
          attachment: attachment,
          attachmentType: attachmentType,
        );

        final updatedMessages = List<MessageModel>.from(currentState.chat.messages)..add(message);
        final updatedChat = currentState.chat.copyWith(
          messages: updatedMessages,
          lastMessageTime: DateTime.now(),
        );
        emit(ChatLoaded(chat: updatedChat));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void markAsRead(String chatId, String userId) async {
    try {
      final currentState = state;
      if (currentState is ChatLoaded) {
        await _chatRepository.markMessagesAsRead(chatId, userId);
        final updatedChat = currentState.chat.copyWith(
          unreadByPatient: userId == currentState.chat.patientId ? false : currentState.chat.unreadByPatient,
          unreadByDoctor: userId == currentState.chat.doctorId ? false : currentState.chat.unreadByDoctor,
        );
        emit(ChatLoaded(chat: updatedChat));
      }
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }
}
