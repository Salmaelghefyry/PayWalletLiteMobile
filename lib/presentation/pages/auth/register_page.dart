import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';
import '../../widgets/common/widgets.dart';

class RegisterPage extends StatefulWidget {
  final String locale;
  const RegisterPage({super.key, required this.locale});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _first = TextEditingController(text: 'Amara');
  final _last  = TextEditingController(text: 'Diallo');
  final _phone = TextEditingController(text: '+221 77 123 4567');
  final _email = TextEditingController(text: 'amara@example.com');
  final _pass  = TextEditingController(text: 'Demo1234!');
  bool _obscure = true, _loading = false;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.go(R.login, extra: {'locale': widget.locale})),
            title: Text(s.createAccount)),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Center(child: Column(children: [
            Image.asset('assets/images/logo_white.png', width: 70, height: 70),
            const SizedBox(height: 10),
            Text(s.fr ? 'Rejoignez PayWalletLite' : 'Join PayWalletLite',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: C.navy)),
            Text(s.tagline, style: const TextStyle(fontSize: 13, color: C.ink3)),
          ])),
          const SizedBox(height: 28),
          ...[
            [s.firstName,  _first, Icons.person_outline_rounded, TextInputType.name],
            [s.lastName,   _last,  Icons.person_outline_rounded, TextInputType.name],
            [s.phone,      _phone, Icons.phone_outlined,         TextInputType.phone],
            [s.email,      _email, Icons.email_outlined,         TextInputType.emailAddress],
          ].map((f) => Padding(padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f[0] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink2)),
                const SizedBox(height: 6),
                TextField(controller: f[1] as TextEditingController, keyboardType: f[3] as TextInputType,
                    decoration: InputDecoration(prefixIcon: Icon(f[2] as IconData, color: C.ink3, size: 20))),
              ]))),
          Text(s.password, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink2)),
          const SizedBox(height: 6),
          TextField(controller: _pass, obscureText: _obscure,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: C.ink3, size: 20),
                  suffixIcon: GestureDetector(onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: C.ink3)))),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: C.teal, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(
                    s.fr ? 'Vous devrez créer un code PIN et vérifier votre identité ensuite.' : 'You will create a PIN and verify your identity next.',
                    style: const TextStyle(fontSize: 12, color: C.tealDark, fontWeight: FontWeight.w500))),
              ])),
          const SizedBox(height: 22),
          Btn(label: s.createAccount, loading: _loading, onPressed: () async {
            setState(() => _loading = true);
            await Future.delayed(const Duration(milliseconds: 1100));
            if (mounted) context.go(R.pinSetup, extra: {'locale': widget.locale});
          }),
          const SizedBox(height: 14),
          Center(child: GestureDetector(
              onTap: () => context.go(R.login, extra: {'locale': widget.locale}),
              child: Text.rich(TextSpan(children: [
                TextSpan(text: s.fr ? 'Déjà inscrit ? ' : 'Already registered? ', style: const TextStyle(fontSize: 13, color: C.ink3)),
                TextSpan(text: s.signIn, style: const TextStyle(fontSize: 13, color: C.teal, fontWeight: FontWeight.w700)),
              ])))),
          const SizedBox(height: 28),
        ]));
  }
}