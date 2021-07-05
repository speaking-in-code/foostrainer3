import 'package:rate_my_app/rate_my_app.dart';
import 'package:in_app_review/in_app_review.dart';

class AppRater {
  // Same on Android and iOS
  static const _appId = 'net.speakingincode.foostrainer';

  static Future<AppRater> create() async {
    final rater = RateMyApp(
      minDays: 7,
      minLaunches: 10,
      remindDays: 7,
      remindLaunches: 10,
    );
    final InAppReview inAppReview = InAppReview.instance;
    Future<bool> available = inAppReview.isAvailable();
    await rater.init();
    return AppRater._create(rater, inAppReview, await available);
  }

  final RateMyApp _rateMyApp;
  final InAppReview _inAppReview;
  final bool _available;

  AppRater._create(this._rateMyApp, this._inAppReview, this._available);

  bool get shouldRequestReview => _available && _rateMyApp.shouldOpenDialog;

  bool get available => _available;

  void requestReview() {
    _inAppReview.requestReview();
  }

  void openStoreListing() {
    _inAppReview.openStoreListing(appStoreId: _appId);
  }
}
