import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/book_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/services/ai_search_service.dart';

class AiMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final List<BookModel>? books;
  final Map<String, dynamic>? filters;

  AiMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.books,
    this.filters,
  });
}

class AiChatViewModel extends ChangeNotifier {
  final _aiService = sl<AiSearchService>();
  final _bookRepo = sl<BookRepository>();

  List<AiMessage> messages = [];
  bool isProcessing = false;
  bool _isInitialized = false;

  void init(String userName) {
    if (_isInitialized) return;
    _isInitialized = true;
    messages.add(
      AiMessage(text: 'Hi, $userName!\n**How can I help you?**', isUser: false),
    );
    notifyListeners();
  }

  void addMessage(AiMessage msg) {
    messages.add(msg);
    notifyListeners();
  }

  void removeLastMessage() {
    if (messages.isNotEmpty) {
      messages.removeLast();
      notifyListeners();
    }
  }

  Future<void> submitQuery(String query) async {
    if (query.isEmpty) return;

    addMessage(AiMessage(text: query, isUser: true));
    addMessage(AiMessage(text: '', isUser: false, isLoading: true));

    isProcessing = true;
    notifyListeners();

    try {
      final aiResponse = await _aiService.handleQuery(query);

      List<BookModel> topBooks = [];

      if (aiResponse.type == 'book_search' && aiResponse.filters != null) {
        final filters = aiResponse.filters!;
        double? maxPrice;
        if (filters['max_price'] != null) {
          maxPrice = double.tryParse(filters['max_price'].toString());
        }

        final booksMap = await _bookRepo.getBooksPaginated(
          search: filters['search'],
          category: filters['category'],
          minPrice: null,
          maxPrice: maxPrice,
          sort: filters['sort'],
        );

        final List<BookModel> booksList = List<BookModel>.from(
          booksMap['books'] ?? [],
        );
        topBooks = booksList.take(5).toList();
      }

      removeLastMessage(); // Remove loading bubble

      if (aiResponse.type == 'book_search' && topBooks.isEmpty) {
        addMessage(
          AiMessage(
            text: aiResponse.message.isNotEmpty
                ? "${aiResponse.message}\n\n(However, I couldn't find any matching books in the store.)"
                : "Sorry, I couldn't find any books matching your request. Try adjusting your search!",
            isUser: false,
          ),
        );
      } else {
        addMessage(
          AiMessage(
            text: aiResponse.message,
            isUser: false,
            books: topBooks.isNotEmpty ? topBooks : null,
            filters: aiResponse.filters,
          ),
        );
      }
    } catch (e) {
      removeLastMessage(); // Remove loading bubble

      String errorMessage = "Sorry, I encountered an error: $e";
      if (e.toString().toLowerCase().contains('quota') ||
          e.toString().contains('429')) {
        String waitTime = "a moment";
        final match = RegExp(
          r'Please retry in ([0-9.]+)s',
        ).firstMatch(e.toString());
        if (match != null && match.groupCount >= 1) {
          final secondsStr = match.group(1);
          final seconds = double.tryParse(secondsStr ?? '');
          if (seconds != null) {
            waitTime = "${seconds.ceil()} seconds";
          }
        }
        errorMessage =
            "I'm experiencing high traffic right now and reached my rate limit. Please wait $waitTime and try again.";
      }

      addMessage(AiMessage(text: errorMessage, isUser: false));
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
