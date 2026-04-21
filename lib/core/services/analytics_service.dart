import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// App analytics — UI should depend on this, not on [FirebaseAnalytics] directly.
///
/// Naming: event and parameter names use snake_case (GA4 / Firebase convention).
/// Avoid PII (email, full names, free-text answers), reserved prefixes (`firebase_`,
/// `google_`, `ga_`), and high-cardinality unique values as parameter *names*.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  /// Automatic screen tracking for named routes (supplement with [logManualScreenView]).
  NavigatorObserver get navigatorObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static String _truncate(String value, int max) {
    if (value.length <= max) return value;
    return value.substring(0, max);
  }

  Future<void> logManualScreenView({
    required String screenName,
    String? screenClass,
  }) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// User opened a category (play flow, edit list, or multi-select play).
  Future<void> logCategoryOpened({
    required String categoryId,
    required String categoryName,
    int? selectionCount,
  }) {
    final params = <String, Object>{
      'category_id': _truncate(categoryId, 100),
      'category_name': _truncate(categoryName, 100),
    };
    if (selectionCount != null) {
      params['selection_count'] = selectionCount;
    }
    return _analytics.logEvent(name: 'category_opened', parameters: params);
  }

  Future<void> logQuestionViewed({
    required int questionId,
    required String categoryId,
  }) {
    return _analytics.logEvent(
      name: 'question_viewed',
      parameters: {
        'question_id': questionId,
        'category_id': _truncate(categoryId, 100),
      },
    );
  }

  Future<void> logQuestionLiked({
    required int questionId,
    required String categoryId,
  }) {
    return _analytics.logEvent(
      name: 'question_liked',
      parameters: {
        'question_id': questionId,
        'category_id': _truncate(categoryId, 100),
      },
    );
  }

  Future<void> logQuestionSkipped({
    required int questionId,
    required String categoryId,
  }) {
    return _analytics.logEvent(
      name: 'question_skipped',
      parameters: {
        'question_id': questionId,
        'category_id': _truncate(categoryId, 100),
      },
    );
  }

  Future<void> logUploadQuestionsUsed({
    required String categoryId,
    required int importedCount,
  }) {
    return _analytics.logEvent(
      name: 'upload_questions_used',
      parameters: {
        'category_id': _truncate(categoryId, 100),
        'imported_count': importedCount,
      },
    );
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}

/// Screen names for [logManualScreenView] (short, stable, lowercase).
abstract final class AnalyticsScreens {
  static const home = 'home';
  static const category = 'category';
  static const categoryEdit = 'category_edit';
  static const question = 'question';
  static const uploadQuestions = 'upload_questions';
}

