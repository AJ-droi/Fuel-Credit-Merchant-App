import 'package:flutter/foundation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/repositories/support_repository.dart';
import '../../domain/models/support_models.dart';

class SupportController extends ChangeNotifier {
  SupportController(this._repository);

  final SupportRepository _repository;

  bool loading = false;
  bool submitting = false;
  String? error;

  List<SupportTopicModel> topics = [];
  SupportContactInfoModel? contactInfo;
  List<SupportTicketModel> tickets = [];
  SupportTicketModel? selectedTicket;

  Future<void> loadHelpCenter() async {
    loading = true;
    error = null;
    notifyListeners();

    final results = await Future.wait([
      _repository.fetchTopics(),
      _repository.fetchContactInfo(),
      _repository.fetchTickets(),
    ]);

    final topicsResult = results[0] as ApiResult<List<SupportTopicModel>>;
    final contactResult = results[1] as ApiResult<SupportContactInfoModel>;
    final ticketsResult = results[2] as ApiResult<SupportTicketListResult>;

    if (topicsResult case ApiSuccess(:final data)) {
      topics = data;
    }
    if (contactResult case ApiSuccess(:final data)) {
      contactInfo = data;
    }
    if (ticketsResult case ApiSuccess(:final data)) {
      tickets = data.tickets;
    }

    if (contactResult case ApiFailure(:final error)) {
      this.error = error.message;
    } else if (ticketsResult case ApiFailure(:final error)) {
      this.error = error.message;
    } else if (topicsResult case ApiFailure(:final error)) {
      this.error = error.message;
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loadTopics() async {
    final result = await _repository.fetchTopics();
    if (result case ApiSuccess(:final data)) {
      topics = data;
      error = null;
    } else if (result case ApiFailure(:final error)) {
      this.error = error.message;
    }
    notifyListeners();
  }

  Future<bool> createTicket({required String topic, required String message}) async {
    submitting = true;
    error = null;
    notifyListeners();

    final result = await _repository.createTicket(topic: topic, message: message);
    submitting = false;

    if (result case ApiSuccess(:final data)) {
      tickets = [data, ...tickets];
      selectedTicket = data;
      notifyListeners();
      return true;
    }

    if (result case ApiFailure(:final error)) {
      this.error = error.message;
    }
    notifyListeners();
    return false;
  }

  Future<bool> loadTicket(String ticketId) async {
    loading = true;
    error = null;
    notifyListeners();

    final result = await _repository.fetchTicket(ticketId);
    loading = false;

    if (result case ApiSuccess(:final data)) {
      selectedTicket = data;
      notifyListeners();
      return true;
    }

    if (result case ApiFailure(:final error)) {
      this.error = error.message;
    }
    notifyListeners();
    return false;
  }

  Future<bool> sendFollowUp({required String ticketId, required String message}) async {
    submitting = true;
    error = null;
    notifyListeners();

    final result = await _repository.sendMessage(ticketId: ticketId, message: message);
    submitting = false;

    if (result case ApiSuccess(:final data)) {
      selectedTicket = data;
      tickets = tickets.map((t) => t.id == data.id ? data : t).toList();
      notifyListeners();
      return true;
    }

    if (result case ApiFailure(:final error)) {
      this.error = error.message;
    }
    notifyListeners();
    return false;
  }
}
