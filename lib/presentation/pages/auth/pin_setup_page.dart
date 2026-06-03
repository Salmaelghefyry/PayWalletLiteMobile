import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';

class PinSetupPage extends StatefulWidget {
  final String locale;
  const PinSetupPage({super.key, required this.locale});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _error = false;
  bool _loading = false;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _press(String k) {
    if (_loading) return;
    setState(() => _error = false);

    final current = _isConfirmStep ? _confirmPin : _pin;

    if (k == '⌫') {
      if (current.isNotEmpty) {
        setState(() {
          if (_isConfirmStep) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          else _pin = _pin.substring(0, _pin.length - 1);
        });
      }
      return;
    }

    if (current.length >= 6) return;
    HapticFeedback.lightImpact();

    setState(() {
      if (_isConfirmStep) _confirmPin += k;
      else _pin += k;
    });

    if ((!_isConfirmStep && _pin.length == 6) || (_isConfirmStep && _confirmPin.length == 6)) {
      _handleComplete();
    }
  }

  Future<void> _handleComplete() async {
    if (!_isConfirmStep) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _isConfirmStep = true);
      return;
    }

    if (_pin == _confirmPin) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', _pin);

      if (mounted) context.go(R.kycUpload, extra: {'locale': widget.locale});
    } else {
      HapticFeedback.heavyImpact();
      await _shake.forward(from: 0);
      setState(() {
        _error = true;
        _isConfirmStep = false;
        _pin = '';
        _confirmPin = '';
      });
      _shake.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final currentPin = _isConfirmStep ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: C.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/logo_white.png', width: 72, height: 72),
              const SizedBox(height: 18),
              Text(
                _isConfirmStep
                    ? (s.fr ? 'Confirmez votre PIN' : 'Confirm your PIN')
                    : (s.fr ? 'Créez votre code PIN' : 'Create your PIN code'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.navy),
              ),
              const SizedBox(height: 6),
              Text(
                _isConfirmStep
                    ? (s.fr ? 'Resaisissez votre code' : 'Re-enter your code')
                    : (s.fr ? 'Choisissez un code à 6 chiffres' : 'Choose a 6-digit code'),
                style: const TextStyle(fontSize: 13, color: C.ink3),
              ),
              const SizedBox(height: 36),
              AnimatedBuilder(
                animation: _shake,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_error ? (_shake.value % 0.1 < 0.05 ? 1 : -1) * 12 : 0, 0),
                  child: child,
                ),
                child: _PinDots(filled: currentPin.length, error: _error),
              ),
              if (_error) ...[
                const SizedBox(height: 14),
                Text(
                  s.fr ? 'Les codes ne correspondent pas' : 'PIN codes do not match',
                  style: const TextStyle(fontSize: 13, color: C.red, fontWeight: FontWeight.w500),
                ),
              ],
              const Spacer(),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
                children: ['1','2','3','4','5','6','7','8','9','','0','⌫'].map((k) =>
                k.isEmpty ? const SizedBox() : _Key(k, () => _press(k), _loading)).toList(),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int filled;
  final bool error;
  const _PinDots({required this.filled, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final isFilled = i < filled;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? (error ? C.red : C.teal) : C.border,
          ),
        );
      }),
    );
  }
}

class _Key extends StatefulWidget {
  final String l;
  final VoidCallback tap;
  final bool dim;
  const _Key(this.l, this.tap, this.dim);
  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _d = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _d = true),
    onTapUp: (_) { setState(() => _d = false); widget.tap(); },
    onTapCancel: () => setState(() => _d = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      decoration: BoxDecoration(
        color: _d ? C.tealLight : C.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _d ? C.teal : C.border),
      ),
      child: Center(
        child: widget.l == '⌫'
            ? const Icon(Icons.backspace_outlined, color: C.ink3, size: 20)
            : Text(widget.l, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: widget.dim ? C.ink3 : C.ink)),
      ),
    ),
  );
}