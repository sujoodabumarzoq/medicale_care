import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicale_care/cubits/chat/chat_cubit.dart';
import 'package:medicale_care/repositories/chat_repository.dart';
import 'package:medicale_care/screens/chat/doctor_chats_details.dart';

class DoctorChatsScreen extends StatelessWidget {
  final String doctorId;

  const DoctorChatsScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(ChatRepository())..loadChats(doctorId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Chats'),
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatError) {
              return Center(child: Text(state.message));
            }
            if (state is ChatsLoaded) {
              final chats = state.chats;
              if (chats.isEmpty) {
                return const Center(child: Text('No chats yet'));
              }
              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final lastMessage = chat.messages.isNotEmpty ? chat.messages.last.content : 'No messages yet';
                  return ListTile(
                    title: Text('Patient ${chat.patientName}'),
                    subtitle: Text(lastMessage),
                    trailing: chat.unreadByDoctor ? const Icon(Icons.circle, color: Colors.blue, size: 10) : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => ChatCubit(ChatRepository())..loadChat(chat.patientId, doctorId),
                            child: DoctorChatsDetails(
                              patientName: chat.patientName ?? '',
                              chatId: chat.id,
                              patientId: chat.patientId,
                              doctorId: doctorId,
                              currentUserId: doctorId,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
