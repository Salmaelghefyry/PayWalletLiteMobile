import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';
import '../../widgets/common/widgets.dart';

// ── Step progress bar ─────────────────────────────────────────────────────────
class _StepBar extends StatelessWidget {
  final int step; // 1–4
  final bool fr;
  const _StepBar({required this.step, required this.fr});

  @override
  Widget build(BuildContext context) {
    final labels = fr
        ? ['Destinat.', 'Vérif.', 'Montant', 'Confirmer']
        : ['Recipient', 'Verify', 'Amount', 'Confirm'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: List.generate(7, (i) {
          if (i.isOdd) {
            return Expanded(child: Container(height: 2, color: i ~/ 2 < step - 1 ? C.teal : C.border));
          }
          final idx = i ~/ 2;
          final done   = idx + 1 < step;
          final active = idx + 1 == step;
          return Column(children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle, color: done || active ? C.teal : C.surface3),
              child: Center(child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text('${idx + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : C.ink3))),
            ),
            const SizedBox(height: 3),
            Text(labels[idx], style: TextStyle(fontSize: 9,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? C.teal : done ? C.teal : C.ink3)),
          ]);
        }),
      ),
    );
  }
}

// ── Step 1: Recipient ─────────────────────────────────────────────────────────
class RecipientPage extends StatefulWidget {
  final String locale;
  const RecipientPage({super.key, required this.locale});
  @override State<RecipientPage> createState() => _RecipientPageState();
}
class _RecipientPageState extends State<RecipientPage> {
  final _ctrl = TextEditingController();
  bool _scanning = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String get _id => _ctrl.text.trim();

  Future<void> _scanQr() async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    _ctrl.text = 'WLT-SILVER-7F3A2B9E';
    setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final fr = s.fr;
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(s.sendMoney)),
      body: Column(children: [
        _StepBar(step: 1, fr: fr),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fr ? 'Qui est le destinataire ?' : 'Who are you sending to?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.navy)),
            const SizedBox(height: 6),
            Text(
              fr ? 'Entrez l\'ID du wallet ou scannez le QR code du destinataire.'
                 : 'Enter the recipient\'s Wallet ID or scan their QR code.',
              style: const TextStyle(fontSize: 13, color: C.ink3, height: 1.5)),
            const SizedBox(height: 28),
            // Wallet ID field
            Text(fr ? 'ID du Wallet' : 'Wallet ID',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.ink3)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink, letterSpacing: 0.4),
              decoration: InputDecoration(
                hintText: 'WLT-SILVER-XXXXXXXX',
                hintStyle: const TextStyle(color: C.ink4, fontWeight: FontWeight.w400, letterSpacing: 0),
                filled: true, fillColor: C.surface2,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.teal, width: 1.5)),
                suffixIcon: _id.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18, color: C.ink3),
                      onPressed: () { _ctrl.clear(); setState(() {}); })
                  : null,
              ),
            ),
            const SizedBox(height: 20),
            // OR divider
            Row(children: [
              const Expanded(child: Divider()),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(fr ? 'OU' : 'OR',
                  style: const TextStyle(fontSize: 12, color: C.ink3, fontWeight: FontWeight.w600))),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 20),
            // QR scan button
            SizedBox(width: double.infinity, height: 56,
              child: OutlinedButton.icon(
                onPressed: _scanning ? null : _scanQr,
                icon: _scanning
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: C.teal))
                  : const Icon(Icons.qr_code_scanner_rounded, color: C.teal),
                label: Text(
                  _scanning
                    ? (fr ? 'Scan en cours…' : 'Scanning…')
                    : (fr ? 'Scanner le QR code' : 'Scan QR code'),
                  style: const TextStyle(color: C.teal, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: C.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              )),
            const SizedBox(height: 28),
            // Info hint
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: C.navyLight, borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: C.navy),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  fr ? 'Le destinataire peut vous communiquer son ID ou afficher son QR depuis son application.'
                     : 'The recipient can share their ID or show their QR code from their app.',
                  style: const TextStyle(fontSize: 12, color: C.navy, height: 1.5))),
              ]),
            ),
          ]),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Btn(
            label: fr ? 'Suivant →' : 'Next →',
            onPressed: _id.isNotEmpty
              ? () => context.push(R.transferVerify, extra: {'locale': widget.locale, 'recipientId': _id})
              : null)),
      ]),
    );
  }
}

// ── Step 2: Verify Recipient ──────────────────────────────────────────────────
class RecipientVerifyPage extends StatefulWidget {
  final String locale, recipientId;
  const RecipientVerifyPage({super.key, required this.locale, required this.recipientId});
  @override State<RecipientVerifyPage> createState() => _RecipientVerifyPageState();
}
class _RecipientVerifyPageState extends State<RecipientVerifyPage> {
  bool _verifying = true;
  Map<String, String> _info = {};

  @override
  void initState() { super.initState(); _lookup(); }

  Future<void> _lookup() async {
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() { _verifying = false; _info = _resolve(widget.recipientId); });
  }

  Map<String, String> _resolve(String id) {
    if (id.contains('7F3A2B9E')) return {'name': 'Yassine Mansouri', 'type': 'SILVER', 'initials': 'YM'};
    if (id.contains('2A9F1C4D')) return {'name': 'Fatima Zahra',     'type': 'BASIC',  'initials': 'FZ'};
    return {'name': 'Wallet User', 'type': 'BASIC', 'initials': '?'};
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final fr = s.fr;
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(fr ? 'Vérification' : 'Verify Recipient')),
      body: Column(children: [
        _StepBar(step: 2, fr: fr),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fr ? 'Vérification du destinataire' : 'Recipient verification',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.navy)),
            const SizedBox(height: 6),
            Text(
              fr ? 'Confirmez ces informations avant de continuer.'
                 : 'Confirm the details below before continuing.',
              style: const TextStyle(fontSize: 13, color: C.ink3, height: 1.5)),
            const SizedBox(height: 24),
            // Wallet ID chip (read-only)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
              child: Row(children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 18, color: C.ink3),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.recipientId,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink, letterSpacing: 0.3))),
              ])),
            const SizedBox(height: 16),
            // Animated recipient card
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _verifying
                ? Container(
                    key: const ValueKey('loading'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
                    child: Column(children: [
                      const CircularProgressIndicator(color: C.teal, strokeWidth: 2.5),
                      const SizedBox(height: 16),
                      Text(fr ? 'Vérification en cours…' : 'Verifying wallet…',
                        style: const TextStyle(fontSize: 14, color: C.ink3)),
                    ]))
                : Container(
                    key: const ValueKey('verified'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.teal, width: 1.5)),
                    child: Column(children: [
                      Row(children: [
                        Container(width: 52, height: 52,
                          decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text(_info['initials'] ?? '?',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.teal)))),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_info['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.ink)),
                          const SizedBox(height: 2),
                          Text(widget.recipientId, style: const TextStyle(fontSize: 11, color: C.ink3)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(100)),
                          child: Text(_info['type'] ?? '',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.teal))),
                      ]),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: C.green2, borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.verified_rounded, size: 16, color: C.green),
                          const SizedBox(width: 8),
                          Text(fr ? 'Wallet vérifié · Certificat valide' : 'Wallet verified · Valid certificate',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.green)),
                        ])),
                    ])),
            ),
            if (!_verifying) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: C.amber2, borderRadius: BorderRadius.circular(12)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: C.amber),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    fr ? 'Vérifiez soigneusement le nom. Toute transaction est irréversible.'
                       : 'Verify the name carefully. All transactions are irreversible.',
                    style: const TextStyle(fontSize: 12, color: C.amber, height: 1.5))),
                ])),
            ],
          ]),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Btn(
            label: fr ? 'Confirmer le destinataire' : 'Confirm Recipient',
            onPressed: _verifying ? null : () => context.push(R.transferAmount, extra: {
              'locale': widget.locale,
              'recipientId': widget.recipientId,
              'recipientName': _info['name'] ?? '',
            }))),
      ]),
    );
  }
}

// ── Step 3: Enter Amount ──────────────────────────────────────────────────────
class AmountPage extends StatefulWidget {
  final String locale, recipientId, recipientName;
  const AmountPage({super.key, required this.locale, required this.recipientId, required this.recipientName});
  @override State<AmountPage> createState() => _AmountPageState();
}
class _AmountPageState extends State<AmountPage> {
  String _amount = '0', _method = 'NFC';
  final double _avail = 850;

  bool get _valid { final v = double.tryParse(_amount) ?? 0; return v > 0 && v <= _avail; }

  void _key(String k) {
    HapticFeedback.lightImpact();
    setState(() {
      if (k == '⌫') { _amount = _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0'; return; }
      if (k == '.' && _amount.contains('.')) return;
      if (_amount == '0' && k != '.') { _amount = k; return; }
      if (_amount.contains('.') && _amount.split('.')[1].length >= 2) return;
      _amount += k;
    });
  }

  Map<String, dynamic> get _args => {
    'amount': double.parse(_amount),
    'method': _method,
    'locale': widget.locale,
    'recipientId': widget.recipientId,
    'recipientName': widget.recipientName,
  };

  String get _initials {
    final parts = widget.recipientName.trim().split(' ');
    return parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final fr = s.fr;
    final v = double.tryParse(_amount) ?? 0;
    final over = v > _avail;

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(fr ? 'Montant' : 'Amount')),
      body: Column(children: [
        _StepBar(step: 3, fr: fr),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            const SizedBox(height: 12),
            // Compact recipient header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(_initials,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.teal)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.recipientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink)),
                  Text(widget.recipientId, style: const TextStyle(fontSize: 11, color: C.ink3)),
                ])),
                Badge.verified(),
              ])),
            const SizedBox(height: 24),
            // Amount display
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('MAD ', style: TextStyle(fontSize: 20, color: C.ink3)),
              Text(_amount, style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800,
                letterSpacing: -1.5, color: over ? C.red : C.navy)),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(over ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                size: 14, color: over ? C.red : C.green),
              const SizedBox(width: 5),
              Text(over ? s.exceedsBalance : '${s.available}: ${_avail.toStringAsFixed(0)} MAD',
                style: TextStyle(fontSize: 12, color: over ? C.red : C.green)),
            ]),
            const SizedBox(height: 20),
            // Method pills
            Row(children: [
              for (final m in [('📱', 'NFC', 'NFC'), ('📶', 'BLE', 'BLE')])
                Expanded(child: Padding(
                  padding: EdgeInsets.only(right: m.$2 == 'NFC' ? 8 : 0),
                  child: _MethodPill(icon: m.$1, label: m.$3, sel: _method == m.$2,
                    onTap: () => setState(() => _method = m.$2)))),
            ]),
            const SizedBox(height: 16),
            // Numpad
            GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2,
              children: ['1','2','3','4','5','6','7','8','9','.','0','⌫']
                .map((k) => _NumKey(k, () => _key(k))).toList()),
          ]),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Btn(label: s.proceed, onPressed: _valid ? () {
            if (_method == 'BLE') context.push(R.bleWait, extra: _args);
            else                  context.push(R.nfcWait, extra: _args);
          } : null)),
      ]),
    );
  }
}

// ── Shared: method pill & numpad key ─────────────────────────────────────────
class _MethodPill extends StatelessWidget {
  final String icon, label;
  final bool sel;
  final VoidCallback onTap;
  const _MethodPill({required this.icon, required this.label, required this.sel, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: sel ? C.tealLight : C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sel ? C.teal : C.border, width: sel ? 1.5 : 1)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? C.teal : C.ink3)),
      ])));
}

class _NumKey extends StatefulWidget {
  final String l; final VoidCallback onTap;
  const _NumKey(this.l, this.onTap);
  @override State<_NumKey> createState() => _NumKeyState();
}
class _NumKeyState extends State<_NumKey> {
  bool _d = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _d = true),
    onTapUp: (_) { setState(() => _d = false); widget.onTap(); },
    onTapCancel: () => setState(() => _d = false),
    child: AnimatedContainer(duration: const Duration(milliseconds: 70),
      decoration: BoxDecoration(color: _d ? C.tealLight : C.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: _d ? C.teal : C.border)),
      child: Center(child: widget.l == '⌫'
        ? const Icon(Icons.backspace_outlined, color: C.ink3, size: 20)
        : Text(widget.l, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: C.ink)))));
}

// ── NFC Wait ─────────────────────────────────────────────────────────────────
class NfcWaitPage extends StatefulWidget {
  final double amount;
  final String locale, recipientId, recipientName;
  const NfcWaitPage({super.key, required this.amount, required this.locale,
    required this.recipientId, required this.recipientName});
  @override State<NfcWaitPage> createState() => _NfcWaitPageState();
}
class _NfcWaitPageState extends State<NfcWaitPage> {
  bool _det = false;

  Map<String, dynamic> get _next => {
    'amount': widget.amount, 'method': 'NFC', 'locale': widget.locale,
    'recipientId': widget.recipientId, 'recipientName': widget.recipientName,
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _det = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) context.pushReplacement(R.confirm, extra: _next);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('NFC Transfer')),
      body: Column(children: [
        Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            NfcPulse(color: _det ? C.green : C.teal,
              child: Icon(Icons.nfc_rounded, size: 52, color: _det ? C.green : C.teal)),
            const SizedBox(height: 28),
            Text(_det ? s.deviceDetected : s.holdPhones,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _det ? C.green : C.navy)),
            const SizedBox(height: 8),
            Text(_det
              ? (s.fr ? 'Établissement du canal ECDH…' : 'Establishing ECDH channel…')
              : (s.fr ? 'Gardez les appareils proches' : 'Keep devices close until done'),
              style: const TextStyle(fontSize: 14, color: C.ink3, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A3A5C), Color(0xFF1BA8C8)]),
                borderRadius: BorderRadius.circular(100)),
              child: Text('${widget.amount.toStringAsFixed(0)} MAD',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))),
          ])))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: Column(children: [
          Btn(label: s.switchBt, outline: true,
            onPressed: () => context.pushReplacement(R.bleWait, extra: {
              'amount': widget.amount, 'locale': widget.locale,
              'recipientId': widget.recipientId, 'recipientName': widget.recipientName,
            })),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.pop(),
            child: Text(s.cancel, style: const TextStyle(color: C.red, fontWeight: FontWeight.w600))),
        ])),
      ]));
  }
}

// ── BLE Wait ──────────────────────────────────────────────────────────────────
class BleWaitPage extends StatelessWidget {
  final double amount;
  final String locale, recipientId, recipientName;
  const BleWaitPage({super.key, required this.amount, required this.locale,
    required this.recipientId, required this.recipientName});

  Map<String, dynamic> get _next => {
    'amount': amount, 'method': 'BLE', 'locale': locale,
    'recipientId': recipientId, 'recipientName': recipientName,
  };

  @override
  Widget build(BuildContext context) {
    final s = S(locale);
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Bluetooth Transfer')),
      body: Column(children: [
        Expanded(child: Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 100, height: 100,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: C.green2),
              child: const Icon(Icons.bluetooth_rounded, size: 48, color: C.green)),
            const SizedBox(height: 24),
            Text(s.scanDevices, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.navy)),
            const SizedBox(height: 24),
            Container(width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: C.border)),
              child: Column(children: [
                const Text('NEARBY DEVICES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.ink3, letterSpacing: 0.8)),
                const SizedBox(height: 10),
                ...[('Yassine M.', 'PWL-7F3A2B9E', '-72 dBm', true), ('Unknown', 'PWL-2A9F1C', '-89 dBm', false)]
                  .map((d) => GestureDetector(
                    onTap: d.$4 ? () => context.pushReplacement(R.confirm, extra: _next) : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: d.$4 ? C.tealLight : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Container(width: 36, height: 36,
                          decoration: BoxDecoration(color: d.$4 ? C.teal : C.surface3, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.smartphone_rounded, size: 18, color: Colors.white)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: d.$4 ? C.teal : C.ink)),
                          Text(d.$2, style: const TextStyle(fontSize: 10, color: C.ink3)),
                        ])),
                        Text(d.$3, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: d.$4 ? C.green : C.ink3)),
                      ])))),
              ])),
          ]))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Btn(label: 'Connect to Yassine M.',
            onPressed: () => context.pushReplacement(R.confirm, extra: _next))),
      ]));
  }
}

// ── Step 4: Confirm Transfer ──────────────────────────────────────────────────
class ConfirmTransferPage extends StatefulWidget {
  final double amount;
  final String method, locale, recipientId, recipientName;
  const ConfirmTransferPage({super.key, required this.amount, required this.method,
    required this.locale, required this.recipientId, required this.recipientName});
  @override State<ConfirmTransferPage> createState() => _ConfirmTransferPageState();
}
class _ConfirmTransferPageState extends State<ConfirmTransferPage> {
  bool _loading = false;

  String get _initials {
    final parts = widget.recipientName.trim().split(' ');
    return parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final fr = s.fr;
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(s.confirm)),
      body: Column(children: [
        _StepBar(step: 4, fr: fr),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
          const SizedBox(height: 8),
          Text(s.youAreSending, style: const TextStyle(fontSize: 14, color: C.ink3)),
          const SizedBox(height: 8),
          Text(widget.amount.toStringAsFixed(0),
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: C.navy, letterSpacing: -2)),
          const Text('MAD', style: TextStyle(fontSize: 18, color: C.ink3)),
          const SizedBox(height: 28),
          Container(width: double.infinity, padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
            child: Column(children: [
              // Recipient row
              Row(children: [
                Container(width: 46, height: 46,
                  decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(_initials,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.teal)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.recipientName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink)),
                  Text(widget.recipientId,
                    style: const TextStyle(fontSize: 11, color: C.ink3)),
                ])),
                Badge.verified(),
              ]),
              const SizedBox(height: 14),
              // Technical details
              ...[
                [fr ? 'Méthode' : 'Method', '${widget.method} (${widget.method == 'NFC' ? 'primary' : 'fallback'})'],
                ['Token', '1 × ${widget.amount.toInt()} MAD'],
                ['Nonce', '3F8A…2C1D'],
                [fr ? 'Clé session' : 'Session key', 'ECDH P-256'],
                [fr ? 'Signature' : 'Signature',     '✓ Ready'],
                [fr ? 'Double-dépense' : 'Double-spend', '✓ Clean'],
              ].map((r) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.border))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(r[0], style: const TextStyle(fontSize: 12, color: C.ink3)),
                  Text(r[1], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: r[1].startsWith('✓') ? C.green : C.ink)),
                ]))),
            ])),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: C.amber2, borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.warning_amber_rounded, color: C.amber, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(s.offlineWarning,
                style: const TextStyle(fontSize: 12, color: C.amber, height: 1.5))),
            ])),
        ]))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: Column(children: [
          Btn(label: s.confirmTransfer, loading: _loading, onPressed: () async {
            setState(() => _loading = true);
            await Future.delayed(const Duration(milliseconds: 1400));
            if (mounted) context.pushReplacement(R.success, extra: {
              'amount': widget.amount, 'method': widget.method, 'locale': widget.locale,
              'recipientName': widget.recipientName,
            });
          }),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go(R.walletsList, extra: {'locale': widget.locale}),
            child: Text(s.cancel, style: const TextStyle(color: C.red, fontWeight: FontWeight.w600))),
        ])),
      ]));
  }
}

// ── Transfer Success ──────────────────────────────────────────────────────────
class TransferSuccessPage extends StatefulWidget {
  final double amount;
  final String method, locale, recipientName;
  const TransferSuccessPage({super.key, required this.amount, required this.method,
    required this.locale, required this.recipientName});
  @override State<TransferSuccessPage> createState() => _TransferSuccessPageState();
}
class _TransferSuccessPageState extends State<TransferSuccessPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.3, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _c.forward();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final txId = 'TXN-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 8).toUpperCase()}';
    return Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 36),
      AnimatedBuilder(animation: _c,
        builder: (_, ch) => Transform.scale(scale: _scale.value, child: ch),
        child: Container(width: 88, height: 88,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: C.green2),
          child: const Icon(Icons.check_rounded, color: C.green, size: 50))),
      const SizedBox(height: 24),
      Text(s.transferOk, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.navy)),
      const SizedBox(height: 4),
      Text('${s.sentVia} ${widget.method}', style: const TextStyle(fontSize: 14, color: C.ink3)),
      const SizedBox(height: 14),
      Text('${widget.amount.toStringAsFixed(0)} MAD',
        style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: C.green, letterSpacing: -1)),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(color: C.amber2, borderRadius: BorderRadius.circular(100)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.sync_rounded, color: C.amber, size: 16), const SizedBox(width: 6),
          Text(s.pendingSyncBadge, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.amber)),
        ])),
      const SizedBox(height: 24),
      Container(width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
        child: Column(children: [
          ...[
            [s.fr ? 'À' : 'To', widget.recipientName.isNotEmpty ? widget.recipientName : '—'],
            [s.fr ? 'Méthode' : 'Method', widget.method],
            [s.fr ? 'Heure' : 'Time', s.fr ? 'À l\'instant' : 'Just now'],
            ['Txn ID', txId],
          ].map((r) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: r[0] == 'Txn ID' ? null : const Border(bottom: BorderSide(color: C.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r[0], style: const TextStyle(fontSize: 12, color: C.ink3)),
              Text(r[1], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: r[0] == 'Txn ID' ? C.teal : C.ink)),
            ]))),
        ])),
      const Spacer(),
      Btn(label: s.backHome,
        onPressed: () => context.go(R.walletsList, extra: {'locale': widget.locale})),
    ]))));
  }
}

// ── Scan Page ─────────────────────────────────────────────────────────────────
class ScanPage extends StatelessWidget {
  final String locale;
  const ScanPage({super.key, required this.locale});
  @override
  Widget build(BuildContext context) {
    final s = S(locale);
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(s.qrScanner)),
      body: Column(children: [
        Expanded(child: Container(margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.border, width: 2)),
          child: Stack(children: [
            const Center(child: Icon(Icons.camera_alt_outlined, size: 64, color: C.ink4)),
            ...[Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight].map((a) =>
              Align(alignment: a, child: Container(width: 36, height: 36, margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border(
                  top:    BorderSide(color: C.teal, width: 3, style: [Alignment.topLeft,    Alignment.topRight].contains(a)    ? BorderStyle.solid : BorderStyle.none),
                  bottom: BorderSide(color: C.teal, width: 3, style: [Alignment.bottomLeft, Alignment.bottomRight].contains(a) ? BorderStyle.solid : BorderStyle.none),
                  left:   BorderSide(color: C.teal, width: 3, style: [Alignment.topLeft,    Alignment.bottomLeft].contains(a)  ? BorderStyle.solid : BorderStyle.none),
                  right:  BorderSide(color: C.teal, width: 3, style: [Alignment.topRight,   Alignment.bottomRight].contains(a) ? BorderStyle.solid : BorderStyle.none),
                ))))),
            Center(child: Padding(padding: const EdgeInsets.only(top: 90),
              child: Text(s.pointCamera, style: const TextStyle(fontSize: 14, color: C.ink3)))),
          ]))),
        Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Btn(icon: Icons.qr_code_scanner_rounded, label: s.startScan,
            onPressed: () => context.push(R.rxWait, extra: {'locale': locale}))),
      ]));
  }
}

// ── Receive Wait ──────────────────────────────────────────────────────────────
class ReceiveWaitPage extends StatefulWidget {
  final String locale;
  const ReceiveWaitPage({super.key, required this.locale});
  @override State<ReceiveWaitPage> createState() => _ReceiveWaitPageState();
}
class _ReceiveWaitPageState extends State<ReceiveWaitPage> {
  bool _incoming = false;
  @override void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _incoming = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) context.pushReplacement(R.rxConfirm,
          extra: {'amount': 500.0, 'from': 'Moussa Koné', 'locale': widget.locale});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(s.readyReceive)),
      body: Center(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          NfcPulse(color: _incoming ? C.green : C.teal,
            child: Icon(Icons.south_rounded, size: 44, color: _incoming ? C.green : C.teal)),
          const SizedBox(height: 28),
          Text(_incoming ? s.incomingTx : s.readyReceive,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _incoming ? C.green : C.navy)),
          const SizedBox(height: 8),
          Text(_incoming
            ? (s.fr ? 'Vérification signature ECDSA…' : 'Verifying ECDSA signature…')
            : (s.fr ? 'NFC actif · BLE scanning · QR prêt' : 'NFC active · BLE scanning · QR ready'),
            style: const TextStyle(fontSize: 14, color: C.ink3, height: 1.6), textAlign: TextAlign.center),
        ]))));
  }
}

// ── Receive Confirm ───────────────────────────────────────────────────────────
class ReceiveConfirmPage extends StatefulWidget {
  final double amount; final String from, locale;
  const ReceiveConfirmPage({super.key, required this.amount, required this.from, required this.locale});
  @override State<ReceiveConfirmPage> createState() => _ReceiveConfirmPageState();
}
class _ReceiveConfirmPageState extends State<ReceiveConfirmPage> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(s.incomingTx)),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 20),
          Container(width: 72, height: 72,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: C.tealLight),
            child: const Icon(Icons.south_rounded, size: 34, color: C.teal)),
          const SizedBox(height: 16),
          Text(s.incomingTx, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.navy)),
          Text('${s.fr ? 'De' : 'From'} ${widget.from} · QR', style: const TextStyle(fontSize: 13, color: C.ink3)),
          const SizedBox(height: 20),
          Text('${widget.amount.toStringAsFixed(0)} MAD',
            style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: C.navy, letterSpacing: -1.5)),
          const SizedBox(height: 24),
          Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
            child: Column(children: [
              ...[
                [s.fr ? 'De' : 'From', widget.from],
                ['Wallet', 'WLT-GOLD-F9A2B3'],
                [s.fr ? 'Signature' : 'Signature', '✓ ECDSA valid'],
                ['Token', '1 × ${widget.amount.toInt()} MAD'],
                ['Nonce', '✓ Not replayed'],
                [s.fr ? 'Certificat' : 'Certificate', '✓ Valid'],
              ].map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(r[0], style: const TextStyle(fontSize: 12, color: C.ink3)),
                  Text(r[1], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: r[1].startsWith('✓') ? C.green : C.ink)),
                ]))),
            ])),
        ]))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: Column(children: [
          Btn(label: s.acceptTransfer, loading: _loading, onPressed: () async {
            setState(() => _loading = true);
            await Future.delayed(const Duration(milliseconds: 1200));
            if (mounted) context.go(R.home, extra: {'locale': widget.locale});
          }),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.pop(),
            child: Text(s.declineTransfer, style: const TextStyle(color: C.red, fontWeight: FontWeight.w600))),
        ])),
      ]));
  }
}
