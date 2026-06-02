import 'package:go_router/go_router.dart';
import '../pages/auth/splash_page.dart';
import '../pages/auth/language_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/pin_page.dart';
import '../pages/home/home_page.dart';
import '../pages/offline_payment/transfer_pages.dart';
import '../pages/other_pages.dart';
import 'routes.dart';
import '../../data/mock_data.dart';

String _locale(Object? extra) => (extra is Map ? extra['locale'] as String? : null) ?? 'en';
double _amount(Object? extra) => (extra is Map ? extra['amount'] as double? : null) ?? 0.0;
String _method(Object? extra) => (extra is Map ? extra['method'] as String? : null) ?? 'NFC';

final appRouter = GoRouter(
  initialLocation: R.splash,
  routes: [
    GoRoute(path: R.splash,   builder: (_, __) => const SplashPage()),
    GoRoute(path: R.language, builder: (_, __) => const LanguagePage()),
    GoRoute(path: R.login,    builder: (_, s)  => LoginPage(locale: _locale(s.extra))),
    GoRoute(path: R.register, builder: (_, s)  => RegisterPage(locale: _locale(s.extra))),
    GoRoute(path: R.pin,      builder: (_, s)  => PinPage(locale: _locale(s.extra))),
    GoRoute(path: R.home,     builder: (_, s)  => HomePage(locale: _locale(s.extra))),

    // Transfer flow
    GoRoute(path: R.transfer, builder: (_, s)  => TransferPage(locale: _locale(s.extra))),
    GoRoute(path: R.nfcWait,  builder: (_, s)  => NfcWaitPage(amount: _amount(s.extra), locale: _locale(s.extra))),
    GoRoute(path: R.bleWait,  builder: (_, s)  => BleWaitPage(amount: _amount(s.extra), locale: _locale(s.extra))),
    GoRoute(path: R.confirm,  builder: (_, s)  => ConfirmTransferPage(amount: _amount(s.extra), method: _method(s.extra), locale: _locale(s.extra))),
    GoRoute(path: R.success,  builder: (_, s)  => TransferSuccessPage(amount: _amount(s.extra), method: _method(s.extra), locale: _locale(s.extra))),
    GoRoute(path: R.scan,     builder: (_, s)  => ScanPage(locale: _locale(s.extra))),
    GoRoute(path: R.rxWait,   builder: (_, s)  => ReceiveWaitPage(locale: _locale(s.extra))),
    GoRoute(path: R.rxConfirm,builder: (_, s)  => ReceiveConfirmPage(
      amount: _amount(s.extra), from: (s.extra is Map ? (s.extra as Map)['from'] as String? : null) ?? 'Unknown',
      locale: _locale(s.extra))),

    // Other pages
    GoRoute(path: R.history,  builder: (_, s)  => HistoryPage(locale: _locale(s.extra))),
    GoRoute(path: R.txDetail, builder: (_, s)  => TxDetailPage(
      tx: (s.extra is Map ? (s.extra as Map)['tx'] : null) ?? Mock.transactions.first,
      locale: _locale(s.extra))),
    GoRoute(path: R.settings, builder: (_, s)  => SettingsPage(locale: _locale(s.extra))),
    GoRoute(path: R.syncPage, builder: (_, s)  => SyncPage(locale: _locale(s.extra))),
  ],
);
