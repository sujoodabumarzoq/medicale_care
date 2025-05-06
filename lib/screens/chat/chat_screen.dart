import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/chat/chat_cubit.dart';
import 'package:medicale_care/models/chat_model.dart';

class ChatScreen extends StatelessWidget {
  final String patientId;
  final String doctorId;
  final String currentUserId;
  final String doctorName;

  ChatScreen({
    super.key,
    required this.patientId,
    required this.doctorId,
    required this.currentUserId,
    required this.doctorName,
  });

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final cubit = context.read<ChatCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text('Chat With Doctor $doctorName'),
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ChatError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is ChatLoaded || state is ChatSendingMessage) {
                      final chat = (state as dynamic).chat as ChatModel;
                      cubit.markAsRead(chat.id, currentUserId);

                      return ListView.builder(
                        itemCount: chat.messages.length,
                        itemBuilder: (context, index) {
                          final message = chat.messages[index];
                          final isMe = message.senderId == currentUserId;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF0266FF) : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(message.content, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.timestamp.toString().substring(11, 16),
                                    style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
              _buildMessageInput(context, cubit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                final state = cubit.state;
                if (state is ChatLoaded) {
                  cubit.sendMessage(
                    chatId: state.chat.id,
                    senderId: currentUserId,
                    receiverId: currentUserId == patientId ? doctorId : patientId,
                    content: _messageController.text,
                  );
                  _messageController.clear();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
