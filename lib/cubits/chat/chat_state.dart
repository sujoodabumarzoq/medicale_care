part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<ChatModel> chats;

  const ChatsLoaded({required this.chats});

  @override
  List<Object> get props => [chats];
}

class ChatLoaded extends ChatState {
  final ChatModel chat;

  const ChatLoaded({required this.chat});

  @override
  List<Object> get props => [chat];
}

class ChatSendingMessage extends ChatState {
  final ChatModel chat;

  const ChatSendingMessage({required this.chat});

  @override
  List<Object> get props => [chat];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object> get props => [message];
}
