import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/env.dart';
import '../di/di.dart';

final analyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

class AnalyticsUtils {
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging analytics event', e, stack);
    }
  }

  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging screen view', e, stack);
    }
  }

  static Future<void> logLogin({
    required String method,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logLogin(loginMethod: method);
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging login', e, stack);
    }
  }

  static Future<void> logSignUp({
    required String method,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logSignUp(signUpMethod: method);
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging sign up', e, stack);
    }
  }

  static Future<void> logSearch({
    required String searchTerm,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logSearch(searchTerm: searchTerm);
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging search', e, stack);
    }
  }

  static Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logSelectContent(
        contentType: contentType,
        itemId: itemId,
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging select content', e, stack);
    }
  }

  static Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method,
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging share', e, stack);
    }
  }

  static Future<void> logTutorialBegin() async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logTutorialBegin();
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging tutorial begin', e, stack);
    }
  }

  static Future<void> logTutorialComplete() async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logTutorialComplete();
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging tutorial complete', e, stack);
    }
  }

  static Future<void> logPurchase({
    required String currency,
    required double value,
    required String itemId,
    required String itemName,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logPurchase(
        currency: currency,
        value: value,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
          ),
        ],
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging purchase', e, stack);
    }
  }

  static Future<void> logRefund({
    required String currency,
    required double value,
    required String itemId,
    required String itemName,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logRefund(
        currency: currency,
        value: value,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
          ),
        ],
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging refund', e, stack);
    }
  }

  static Future<void> logAddToCart({
    required String currency,
    required double value,
    required String itemId,
    required String itemName,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logAddToCart(
        currency: currency,
        value: value,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
          ),
        ],
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging add to cart', e, stack);
    }
  }

  static Future<void> logRemoveFromCart({
    required String currency,
    required double value,
    required String itemId,
    required String itemName,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logRemoveFromCart(
        currency: currency,
        value: value,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
          ),
        ],
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging remove from cart', e, stack);
    }
  }

  static Future<void> logBeginCheckout({
    required String currency,
    required double value,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logBeginCheckout(
        currency: currency,
        value: value,
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging begin checkout', e, stack);
    }
  }

  static Future<void> logAddShippingInfo({
    required String currency,
    required double value,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logAddShippingInfo(
        currency: currency,
        value: value,
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging add shipping info', e, stack);
    }
  }

  static Future<void> logAddPaymentInfo({
    required String currency,
    required double value,
  }) async {
    if (!Env.enableAnalytics) return;

    try {
      final analytics = ProviderContainer().read(analyticsProvider);
      await analytics.logAddPaymentInfo(
        currency: currency,
        value: value,
      );
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error logging add payment info', e, stack);
    }
  }
} 