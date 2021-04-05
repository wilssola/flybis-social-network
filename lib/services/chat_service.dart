// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/models/chat_model.dart';
import 'package:flybis/models/document_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class ChatService {
  ChatService();

  final DatabaseService _db = DatabaseService.instance;

  Future<void> setStatus(FlybisChatStatus status) async => await _db.set(
        documentPath: PathService.chat(status.chatId),
        data: status.toMap(),
      );

  Future<void> updateStatus(FlybisChatStatus flybisChatStatus) async {
    FlybisChatStatus oldFlybisChatStatus = await _db.get(
      documentPath: PathService.chat(flybisChatStatus.chatId),
      builder: (data, documentId) => FlybisChatStatus.fromMap(data, documentId),
    );

    if (oldFlybisChatStatus != null) {
      flybisChatStatus.chatKey = oldFlybisChatStatus.chatKey;
      flybisChatStatus.timestamp = _db.serverTimestamp();

      await _db.update(
        documentPath: PathService.chat(flybisChatStatus.chatId),
        data: flybisChatStatus.toMap(),
      );
    } else {
      await setStatus(flybisChatStatus);
    }
  }

  Stream<FlybisChatStatus> streamStatus(String chatId) => _db.streamDoc(
        documentPath: PathService.chat(chatId),
        builder: (data, documentId) =>
            FlybisChatStatus.fromMap(data, documentId),
      );

  Future<void> resetStatusCount({
    @required String chatId,
    @required String userId,
  }) async =>
      await _db.update(documentPath: PathService.chat(chatId), data: {
        'messageCounts.$userId': 0,
      });

  Future<void> setMessage(FlybisChatMessage message) async {
    try {
      await _db.setTransaction(
        documentPath: PathService.message(message.chatId, message.messageId),
        data: message.toMap(),
      );
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> deleteMessage(FlybisChatMessage message) async =>
      await _db.delete(
        documentPath: PathService.message(message.chatId, message.messageId),
      );

  Stream<FlybisChatMessage> streamMessage(String chatId, String messageId) =>
      _db.streamDoc(
        documentPath: PathService.message(chatId, messageId),
        builder: (data, documentId) =>
            FlybisChatMessage.fromMap(data, documentId),
      );

  Stream<List<FlybisChatMessage>> streamMessages(String chatId, int limit) =>
      _db.streamCollection(
        collectionPath: PathService.messages(chatId),
        builder: (data, documentId) =>
            FlybisChatMessage.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(25 + limit),
      );

  Future<void> updateAllChatMessagesViewed(String chatId) async =>
      await _db.updateBatch(
        collectionPath: PathService.messages(chatId),
        data: {
          'viewed': true,
        },
      );

  Future<void> deleteAllChatMessages(String chatId) async =>
      await _db.deleteBatch(
        collectionPath: PathService.messages(chatId),
      );

  Stream<List<FlybisDocument>> streamChats(String userId, int limit) =>
      _db.streamCollection(
        collectionPath: PathService.friends(userId),
        builder: (data, documentId) => FlybisDocument.fromMap(data, documentId),
        queryBuilder: (query) => query.limit(15 + limit),
      );

  Future<String> addCall(String chatId) async {
    String path = await _db.add(
      collectionPath: PathService.calls(chatId),
      data: {
        'timestamp': _db.serverTimestamp(),
      },
    );

    List<String> split = path.split('/');

    String callId = split[split.length];

    logger.i('addCall: $callId');

    return callId;
  }
}
