import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override State<SplashPage> createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logo, _text;
  late final Animation<double> _scale, _fade, _textFade, _textY;

  @override
  void initState() {
    super.initState();
    _logo = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _text = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale   = Tween<double>(begin: 0.3, end: 1).animate(CurvedAnimation(parent: _logo, curve: Curves.easeOutBack));
    _fade    = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logo, curve: const Interval(0, 0.5)));
    _textFade= Tween<double>(begin: 0, end: 1).animate(_text);
    _textY   = Tween<double>(begin: 20, end: 0).animate(CurvedAnimation(parent: _text, curve: Curves.easeOut));

    _logo.forward().then((_) => _text.forward()).then((_) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) context.go(R.language);
      });
    });
  }
  @override void dispose() { _logo.dispose(); _text.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0xFF0D1B2A), Color(0xFF1A3A5C), Color(0xFF1BA8C8)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Stack(children: [
        Positioned(top: -80, right: -80, child: _circle(220, 0.06)),
        Positioned(bottom: -100, left: -60, child: _circle(300, 0.04)),
        SafeArea(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedBuilder(animation: _logo, builder: (_, __) => Transform.scale(
            scale: _scale.value, child: Opacity(opacity: _fade.value,
              child: Image.asset('assets/images/logo.png', width: 160, height: 160)))),
          const SizedBox(height: 32),
          AnimatedBuilder(animation: _text, builder: (_, __) => Transform.translate(
            offset: Offset(0, _textY.value),
            child: Opacity(opacity: _textFade.value, child: Column(children: [
              RichText(text: const TextSpan(children: [
                TextSpan(text: 'Pay',    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xFF1BA8C8))),
                TextSpan(text: 'Wallet',style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
                TextSpan(text: 'Lite',  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w300, color: Colors.white60)),
              ])),
              const SizedBox(height: 8),
              const Text('SECURE MOBILE & OFFLINE PAYMENTS',
                style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 1.8, fontWeight: FontWeight.w600)),
              const Text('BY PAYLOGIC',
                style: TextStyle(fontSize: 10, color: Color(0xFFF5A623), letterSpacing: 2.5, fontWeight: FontWeight.w700)),
            ])))),
        ]))),
      ])));

  Widget _circle(double s, double o) => Container(width: s, height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(o)));
}
