import 'package:flutter/material.dart';
import '../models/token_model.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';
import 'notification_provider.dart';

class TokenProvider extends ChangeNotifier {
  List<TokenTicket> _tokens = [];
  bool _isLoading = false;

  List<TokenTicket> get tokens => _tokens;
  bool get isLoading => _isLoading;

  final SupabaseService _service = SupabaseService();

  Future<void> fetchTokens() async {
    _isLoading = true;
    notifyListeners();
    _tokens = await _service.getTokens();
    _isLoading = false;
    notifyListeners();
  }

  List<TokenTicket> getQueueTokens(String queueType) {
    final queue = _tokens.where((t) => t.queueType == queueType).toList();
    // Strict FIFO order based on appliedAt timestamp
    queue.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
    return queue;
  }

  TokenTicket? getCurrentServing(String queueType) {
    final queue = getQueueTokens(queueType);
    try {
      return queue.firstWhere((t) => t.status == 'Serving');
    } catch (_) {
      return null;
    }
  }

  List<TokenTicket> getWaitingTokens(String queueType) {
    final queue = getQueueTokens(queueType);
    return queue.where((t) => t.status == 'Waiting').toList();
  }

  TokenTicket? getMyActiveToken(String queueType, String studentRegNo) {
    final queue = getQueueTokens(queueType);
    try {
      return queue.firstWhere((t) => t.registerNumber == studentRegNo && (t.status == 'Waiting' || t.status == 'Serving'));
    } catch (_) {
      return null;
    }
  }

  int getTokensAheadCount(String queueType, String studentRegNo) {
    final waiting = getWaitingTokens(queueType);
    final myIndex = waiting.indexWhere((t) => t.registerNumber == studentRegNo);
    return myIndex >= 0 ? myIndex : 0;
  }

  Future<bool> applyToken({
    required String queueType,
    required String studentName,
    required String registerNumber,
    required NotificationProvider notificationProvider,
  }) async {
    // Check if student already has active ticket in this queue
    if (getMyActiveToken(queueType, registerNumber) != null) {
      return false;
    }

    final queue = getQueueTokens(queueType);
    int nextNumber = 101;
    if (queue.isNotEmpty) {
      final maxNum = queue.map((t) => t.tokenNumber).reduce((a, b) => a > b ? a : b);
      nextNumber = maxNum + 1;
    }

    final ticket = TokenTicket(
      id: 'token_${DateTime.now().millisecondsSinceEpoch}',
      queueType: queueType,
      tokenNumber: nextNumber,
      studentName: studentName,
      registerNumber: registerNumber,
      status: 'Waiting',
      appliedAt: DateTime.now(),
    );

    _tokens.add(ticket);
    await _service.saveTokens(_tokens);

    // Initial notification to applicant
    final aheadCount = getTokensAheadCount(queueType, registerNumber);
    await notificationProvider.addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Token Booked: $queueType-$nextNumber',
      message: aheadCount > 0 
          ? 'Token $queueType-$nextNumber confirmed. $aheadCount tokens ahead of you.' 
          : 'Token $queueType-$nextNumber confirmed. You are next in line!',
      recipientType: 'student',
      recipientId: registerNumber,
      createdAt: DateTime.now(),
    ));

    notifyListeners();
    return true;
  }

  Future<void> callNextToken({
    required String queueType,
    required NotificationProvider notificationProvider,
  }) async {
    final queue = getQueueTokens(queueType);
    
    // Complete current serving token if any
    final servingIndex = _tokens.indexWhere((t) => t.queueType == queueType && t.status == 'Serving');
    if (servingIndex >= 0) {
      _tokens[servingIndex] = _tokens[servingIndex].copyWith(status: 'Completed');
    }

    // Pick first Waiting token in strict FIFO order
    final waitingQueue = queue.where((t) => t.status == 'Waiting').toList();
    if (waitingQueue.isNotEmpty) {
      final nextTicket = waitingQueue.first;
      final targetIndex = _tokens.indexWhere((t) => t.id == nextTicket.id);
      if (targetIndex >= 0) {
        _tokens[targetIndex] = _tokens[targetIndex].copyWith(
          status: 'Serving',
          calledAt: DateTime.now(),
        );

        // Rule: Called notification
        await notificationProvider.addNotification(AppNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Token Called: ${queueType}-${nextTicket.tokenNumber}',
          message: 'Your token is called. Please proceed immediately to the counter.',
          recipientType: 'student',
          recipientId: nextTicket.registerNumber,
          createdAt: DateTime.now(),
        ));
      }

      // Rule: Notify subsequent tokens (1 ahead & 2 ahead)
      final remainingWaiting = _tokens.where((t) => t.queueType == queueType && t.status == 'Waiting').toList();
      remainingWaiting.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));

      if (remainingWaiting.isNotEmpty) {
        // 1 student ahead -> "Next is your token."
        final firstAhead = remainingWaiting[0];
        await notificationProvider.addNotification(AppNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Queue Update: Token ${queueType}-${firstAhead.tokenNumber}',
          message: 'Next is your token. Please prepare to move to counter.',
          recipientType: 'student',
          recipientId: firstAhead.registerNumber,
          createdAt: DateTime.now(),
        ));
      }

      if (remainingWaiting.length >= 2) {
        // 2 students ahead -> "2 tokens ahead of you."
        final secondAhead = remainingWaiting[1];
        await notificationProvider.addNotification(AppNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Queue Update: Token ${queueType}-${secondAhead.tokenNumber}',
          message: '2 tokens ahead of you in line.',
          recipientType: 'student',
          recipientId: secondAhead.registerNumber,
          createdAt: DateTime.now(),
        ));
      }
    }

    await _service.saveTokens(_tokens);
    notifyListeners();
  }

  Future<void> updateTokenStatus(String tokenId, String newStatus) async {
    final index = _tokens.indexWhere((t) => t.id == tokenId);
    if (index >= 0) {
      _tokens[index] = _tokens[index].copyWith(status: newStatus);
      await _service.saveTokens(_tokens);
      notifyListeners();
    }
  }
}
