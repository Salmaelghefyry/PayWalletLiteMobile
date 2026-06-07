import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';
import '../../widgets/common/widgets.dart';

class PinPage extends StatefulWidget {
  final String locale;
  const PinPage({super.key, required this.locale});
  @override State<PinPage> createState() => _PinPageState();
}
class _PinPageState extends State<PinPage> with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _loading = false, _error = false;
  late final AnimationController _shake;

  @override
  void initState() { super.initState(); _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 450)); }
  @override void dispose() { _shake.dispose(); super.dispose(); }

  void _press(String k) {
    if (_loading) return;
    setState(() => _error = false);
    if (k == '⌫') { if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1)); return; }
    if (_pin.length >= 6) return;
    HapticFeedback.lightImpact();
    setState(() => _pin += k);
    if (_pin.length == 6) _verify();
  }

  Future<void> _verify() async {
    setState(() =>
    _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (_pin == '123456') {
      context.go(R.walletsList, extra: {'locale': widget.locale});
    } else {
      HapticFeedback.heavyImpact();
      await _shake.forward(from: 0);
      setState(() { _loading = false; _error = true; _pin = ''; });
      _shake.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(backgroundColor: C.surface,
      body: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(children: [
          const SizedBox(height: 40),
          Image.asset('assets/images/logo_white.png', width: 72, height: 72),
          const SizedBox(height: 18),
          Text(s.enterPin, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.navy)),

          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: _shake,
            builder: (_, child) => Transform.translate(
              offset: Offset(_error ? (_shake.value % 0.1 < 0.05 ? 1 : -1) * 12 : 0, 0),
              child: child),
            child: PinDots(filled: _pin.length, error: _error)),
          if (_error) ...[
            const SizedBox(height: 14),
            Text(s.wrongPin, style: const TextStyle(fontSize: 13, color: C.red, fontWeight: FontWeight.w500)),
          ],
          const Spacer(),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.7,
            children: ['1','2','3','4','5','6','7','8','9','','0','⌫'].map((k) =>
              k.isEmpty ? const SizedBox() : _Key(k, () => _press(k), _loading)).toList()),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.go(R.walletsList, extra: {'locale': widget.locale}),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.fingerprint_rounded, size: 28, color: C.teal),
                const SizedBox(width: 10),
                Text(s.useBiometric, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.teal)),
              ]))),
          const SizedBox(height: 28),
        ]))));
  }
}

class _Key extends StatefulWidget {
  final String l; final VoidCallback tap; final bool dim;
  const _Key(this.l, this.tap, this.dim);
  @override State<_Key> createState() => _KeyState();
}
class _KeyState extends State<_Key> {
  bool _d = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _d = true),
    onTapUp: (_) { setState(() => _d = false); widget.tap(); },
    onTapCancel: () => setState(() => _d = false),
    child: AnimatedContainer(duration: const Duration(milliseconds: 70),
      decoration: BoxDecoration(
        color: _d ? C.tealLight : C.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _d ? C.teal : C.border)),
      child: Center(child: widget.l == '⌫'
        ? const Icon(Icons.backspace_outlined, color: C.ink3, size: 20)
        : Text(widget.l, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: widget.dim ? C.ink3 : C.ink)))));
}
