import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';
import '../../widgets/common/widgets.dart';
class LoginPage extends StatefulWidget {
  final String locale;
  const LoginPage({super.key, required this.locale});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController(text: '+221 77 123 4567');
  final _pass  = TextEditingController(text: 'Demo1234!');
  bool _obscure = true, _loading = false;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(backgroundColor: C.surface,
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        // Header row
        Row(children: [
          GestureDetector(onTap: () => context.go(R.language),
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
              child: const Icon(Icons.arrow_back_rounded, size: 18, color: C.ink2))),
          const SizedBox(width: 12),
          Image.asset('assets/images/logo_white.png', width: 32, height: 32),
          const SizedBox(width: 8),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'Pay',    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.teal)),
            TextSpan(text: 'Wallet',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.navy)),
            TextSpan(text: 'Lite',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: C.ink3)),
          ])),
        ]),
        const SizedBox(height: 36),
        Text(s.signIn, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: C.navy)),
        const SizedBox(height: 6),
        Text(s.fr ? 'Bienvenue ! Veuillez vous connecter.' : 'Welcome back! Please sign in.',
          style: const TextStyle(fontSize: 14, color: C.ink3)),
        const SizedBox(height: 32),
        _lbl(s.phone),
        const SizedBox(height: 6),
        TextField(controller: _phone, keyboardType: TextInputType.phone,
          decoration: InputDecoration(prefixIcon: const Icon(Icons.phone_outlined, color: C.ink3), hintText: '+221 77 XXX XXXX')),
        const SizedBox(height: 18),
        _lbl(s.password),
        const SizedBox(height: 6),
        TextField(controller: _pass, obscureText: _obscure,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: C.ink3),
            suffixIcon: GestureDetector(onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: C.ink3)),
            hintText: '••••••••')),
        Align(alignment: Alignment.centerRight,
          child: TextButton(onPressed: () {},
            child: Text(s.forgotPassword, style: const TextStyle(fontSize: 13, color: C.teal)))),
        const SizedBox(height: 8),
        Btn(label: s.signIn, loading: _loading, onPressed: () async {
          setState(() => _loading = true);
          await Future.delayed(const Duration(milliseconds: 900));
          if (mounted) context.go(R.pin, extra: {'locale': widget.locale});
        }),
        const SizedBox(height: 20),
        Row(children: [
          const Expanded(child: Divider()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(s.fr ? 'ou continuer avec' : 'or continue with', style: const TextStyle(fontSize: 12, color: C.ink3))),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.fingerprint_rounded, size: 22, color: C.teal),
            label: Text(s.biometricAuth, style: const TextStyle(fontSize: 14, color: C.teal, fontWeight: FontWeight.w600)),
            onPressed: () => context.go(R.home, extra: {'locale': widget.locale}),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: C.teal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        const SizedBox(height: 28),
        Center(child: GestureDetector(
          onTap: () => context.go(R.register, extra: {'locale': widget.locale}),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: s.fr ? 'Pas de compte ? ' : 'No account? ', style: const TextStyle(fontSize: 14, color: C.ink3)),
            TextSpan(text: s.signUp, style: const TextStyle(fontSize: 14, color: C.teal, fontWeight: FontWeight.w700)),
          ])))),
        const SizedBox(height: 24),
      ]))));
  }
  Widget _lbl(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink2));
}
