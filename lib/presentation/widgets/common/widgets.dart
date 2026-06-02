import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

// ── Btn ─────────────────────────────────────────────────────────────────────
class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading, outline, danger;
  final IconData? icon;
  final Color? color;
  const Btn({super.key, required this.label, this.onPressed, this.loading = false, this.outline = false, this.danger = false, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? (danger ? C.red : C.teal);
    if (outline) return SizedBox(width: double.infinity, height: 54,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(foregroundColor: bg, side: BorderSide(color: bg, width: 1.5)),
        child: _child(bg)));
    return SizedBox(width: double.infinity, height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: Colors.white),
        child: _child(Colors.white)));
  }

  Widget _child(Color fg) => loading
    ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
        Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
      ]);
}

// ── PwCard ───────────────────────────────────────────────────────────────────
class PwCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;
  const PwCard({super.key, required this.child, this.padding, this.color, this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: color ?? C.surface, borderRadius: BorderRadius.circular(18),
    child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap,
      child: Container(padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: C.border)),
        child: child)));
}

// ── SecTitle ────────────────────────────────────────────────────────────────
class SecTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SecTitle({super.key, required this.title, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.ink)),
      if (action != null) GestureDetector(onTap: onAction,
        child: Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.teal))),
    ]));
}

// ── Badge ────────────────────────────────────────────────────────────────────
class Badge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const Badge({super.key, required this.label, required this.bg, required this.fg});
  factory Badge.active()    => const Badge(label: 'Active',    bg: Color(0xFFDDF4EC), fg: Color(0xFF0A8754));
  factory Badge.synced()    => const Badge(label: 'Synced',    bg: Color(0xFFDDF4EC), fg: Color(0xFF0A8754));
  factory Badge.pending()   => const Badge(label: 'Pending',   bg: Color(0xFFFEF3DC), fg: Color(0xFFE67E22));
  factory Badge.completed() => const Badge(label: 'Completed', bg: Color(0xFFDDF4EC), fg: Color(0xFF0A8754));
  factory Badge.failed()    => const Badge(label: 'Failed',    bg: Color(0xFFFEECEC), fg: Color(0xFFD63031));
  factory Badge.offline()   => const Badge(label: 'OFFLINE',   bg: Color(0xFFFEF3DC), fg: Color(0xFFE67E22));
  factory Badge.verified()  => const Badge(label: '✓ Verified',bg: Color(0xFFDDF4EC), fg: Color(0xFF0A8754));
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)));
}

// ── MethodBadge ──────────────────────────────────────────────────────────────
class MethodBadge extends StatelessWidget {
  final String method;
  const MethodBadge({super.key, required this.method});
  @override
  Widget build(BuildContext context) {
    final m = method.toUpperCase();
    Color bg, fg;
    if (m == 'NFC')      { bg = C.tealLight; fg = C.teal; }
    else if (m == 'BLE') { bg = C.green2;    fg = C.green; }
    else                 { bg = C.navyLight; fg = C.navy; }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(m, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)));
  }
}

// ── NfcPulse ─────────────────────────────────────────────────────────────────
class NfcPulse extends StatefulWidget {
  final Color color;
  final Widget child;
  const NfcPulse({super.key, required this.color, required this.child});
  @override State<NfcPulse> createState() => _NfcPulseState();
}
class _NfcPulseState extends State<NfcPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale, _opacity;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _scale   = Tween<double>(begin: 1, end: 1.7).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.7, end: 0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(width: 120, height: 120,
    child: Stack(alignment: Alignment.center, children: [
      AnimatedBuilder(animation: _c, builder: (_, __) => Transform.scale(scale: _scale.value,
        child: Opacity(opacity: _opacity.value,
          child: Container(width: 120, height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.color.withOpacity(0.5), width: 2)))))),
      Container(width: 88, height: 88,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withOpacity(0.13)),
        child: Center(child: widget.child)),
    ]));
}

// ── PinDots ──────────────────────────────────────────────────────────────────
class PinDots extends StatelessWidget {
  final int filled;
  final bool error;
  const PinDots({super.key, required this.filled, this.error = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(6, (i) => AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 15, height: 15,
      decoration: BoxDecoration(shape: BoxShape.circle,
        color: i < filled ? (error ? C.red : C.teal) : Colors.transparent,
        border: Border.all(width: 2, color: i < filled ? (error ? C.red : C.teal) : C.ink3)))));
}

// ── QuickBtn ─────────────────────────────────────────────────────────────────
class QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, fg;
  final VoidCallback? onTap;
  const QuickBtn({super.key, required this.icon, required this.label, required this.bg, required this.fg, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Column(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: fg, size: 24)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: C.ink2)),
    ]));
}

// ── TxRow ─────────────────────────────────────────────────────────────────────
class TxRow extends StatelessWidget {
  final String name, time, method;
  final double amount;
  final bool isSent;
  final Color statusColor, statusBg;
  final String statusLabel;
  final VoidCallback? onTap;
  const TxRow({super.key, required this.name, required this.time, required this.method, required this.amount, required this.isSent, required this.statusColor, required this.statusBg, required this.statusLabel, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(
          color: isSent ? C.red2 : C.green2, borderRadius: BorderRadius.circular(12)),
          child: Icon(isSent ? Icons.north_rounded : Icons.south_rounded, color: isSent ? C.red : C.green, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink)),
          const SizedBox(height: 2),
          Row(children: [
            Text(time, style: const TextStyle(fontSize: 11, color: C.ink3)),
            const SizedBox(width: 6),
            MethodBadge(method: method),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${isSent ? '-' : '+'}${amount.toStringAsFixed(0)} XOF',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isSent ? C.red : C.green3)),
          const SizedBox(height: 3),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100)),
            child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor))),
        ]),
      ])));
}

// ── SettingsRow ───────────────────────────────────────────────────────────────
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  const SettingsRow({super.key, required this.icon, required this.label, this.value, this.trailing, this.onTap, this.danger = false});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: danger ? C.red : C.ink3),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: danger ? C.red : C.ink))),
        if (value != null) Text(value!, style: const TextStyle(fontSize: 13, color: C.ink3)),
        if (trailing != null) trailing!,
        if (value == null && trailing == null && !danger) const Icon(Icons.chevron_right_rounded, color: C.ink3, size: 18),
      ])));
}
