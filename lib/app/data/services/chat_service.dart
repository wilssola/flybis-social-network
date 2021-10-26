// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/chat_model.dart';
import 'package:flybis/app/data/models/document_model.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class ChatService {
  ChatService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Future<void> setStatus(FlybisChatStatus status) async => await _db.set(
        documentPath: DatabasePath.chat(status.chatId),
        data: status.toMap(),
      );

  Future<void> updateStatus(FlybisChatStatus flybisChatStatus) async {
    FlybisChatStatus? oldFlybisChatStatus = await _db.get(
      documentPath: DatabasePath.chat(flybisChatStatus.chatId),
      builder: (data, documentId) => FlybisChatStatus.fromMap(data, documentId),
    );

    if (oldFlybisChatStatus != null) {
      flybisChatStatus.chatKey = oldFlybisChatStatus.chatKey;
      flybisChatStatus.timestamp = _db.serverTimestamp();

      await _db.update(
        documentPath: DatabasePath.chat(flybisChatStatus.chatId),
        data: flybisChatStatus.toMap(),
      );
    } else {
      await setStatus(flybisChatStatus);
    }
  }

  Stream<FlybisChatStatus>? streamStatus(String chatId) => _db.streamDoc(
        documentPath: DatabasePath.chat(chatId),
        builder: (data, documentId) =>
            FlybisChatStatus.fromMap(data, documentId),
      );

  Future<void> resetStatusCount({
    required String chatId,
    required String? userId,
  }) async =>
      await _db.update(documentPath: DatabasePath.chat(chatId), data: {
        'messageCounts.$userId': 0,
      });

  Future<void> setMessage(FlybisChatMessage message) async {
    try {
      await _db.setTransaction(
        documentPath: DatabasePath.message(message.chatId, message.messageId),
        data: message.toMap(),
      );
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> deleteMessage(FlybisChatMessage message) async =>
      await _db.delete(
        documentPath: DatabasePath.message(message.chatId, message.messageId),
      );

  Stream<FlybisChatMessage>? streamMessage(String chatId, String messageId) =>
      _db.streamDoc(
        documentPath: DatabasePath.message(chatId, messageId),
        builder: (data, documentId) =>
            FlybisChatMessage.fromMap(data, documentId),
      );

  Stream<List<FlybisChatMessage>>? streamMessages(String chatId, int limit) =>
      _db.streamCollection(
        collectionPath: DatabasePath.messages(chatId),
        builder: (data, documentId) =>
            FlybisChatMessage.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(25 + limit),
      );

  Future<void> updateAllChatMessagesViewed(String chatId) async =>
      await _db.updateBatch(
        collectionPath: DatabasePath.messages(chatId),
        data: {
          'viewed': true,
        },
      );

  Future<void> deleteAllChatMessages(String chatId) async =>
      await _db.deleteBatch(
        collectionPath: DatabasePath.messages(chatId),
      );

  Stream<List<FlybisDocument>>? streamChats(String? userId, int limit) =>
      _db.streamCollection(
        collectionPath: DatabasePath.friends(userId),
        builder: (data, documentId) => FlybisDocument.fromMap(data, documentId),
        queryBuilder: (query) => query.limit(15 + limit),
      );

  Future<String> addCall(String chatId) async {
    String path = await (_db.add(
      collectionPath: DatabasePath.calls(chatId),
      data: {
        'timestamp': _db.serverTimestamp(),
      },
    ) as FutureOr<String>);

    List<String> split = path.split('/');

    String callId = split[split.length];

    logger.i('addCall: $callId');

    return callId;
  }
}
