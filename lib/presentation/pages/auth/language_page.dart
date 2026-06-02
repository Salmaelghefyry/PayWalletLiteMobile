import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/routes.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});
  @override State<LanguagePage> createState() => _LanguagePageState();
}
class _LanguagePageState extends State<LanguagePage> {
  String _sel = 'en';

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0xFF0D1B2A), Color(0xFF1A3A5C), Color(0xFF1BA8C8)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: SafeArea(child: Padding(padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 24),
          Image.asset('assets/images/logo.png', width: 110, height: 110),
          const SizedBox(height: 20),
          const Text('PayWalletLite',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('SECURE MOBILE & OFFLINE PAYMENTS  |  BY PAYLOGIC',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.white54, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 48),
          Container(padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.15))),
            child: Column(children: [
              const Icon(Icons.language_rounded, color: Colors.white, size: 36),
              const SizedBox(height: 16),
              const Text('Choose your language\nChoisissez votre langue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, height: 1.5)),
              const SizedBox(height: 24),
              _tile('en', '🇬🇧', 'English',  'Continue in English'),
              const SizedBox(height: 12),
              _tile('fr', '🇫🇷', 'Français', 'Continuer en français'),
            ])),
          const Spacer(),
          SizedBox(width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: () => context.go(R.login, extra: {'locale': _sel}),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              child: Text(_sel == 'fr' ? 'Continuer →' : 'Continue →'))),
        ])))));

  Widget _tile(String loc, String flag, String name, String sub) {
    final sel = _sel == loc;
    return GestureDetector(onTap: () => setState(() => _sel = loc),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF1BA8C8) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? const Color(0xFF1BA8C8) : Colors.white.withOpacity(0.15), width: sel ? 2 : 1)),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(sub,  style: const TextStyle(fontSize: 12, color: Colors.white60)),
          ])),
          if (sel) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
        ])));
  }
}
