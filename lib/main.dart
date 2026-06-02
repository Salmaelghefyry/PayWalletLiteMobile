import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const PayWalletLiteApp());
}

class PayWalletLiteApp extends StatelessWidget {
  const PayWalletLiteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'PayWalletLite',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    routerConfig: appRouter,
  );
}
