import 'package:flutter/material.dart' hide Badge;
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/localization/strings.dart';
import '../../data/mock_data.dart';
import '../../domain/entities/entities.dart';
import '../navigation/routes.dart';
import '../widgets/common/widgets.dart';

// ── Transaction History ───────────────────────────────────────────────────────
class HistoryPage extends StatefulWidget {
  final String locale;
  const HistoryPage({super.key, required this.locale});
  @override State<HistoryPage> createState() => _HistoryPageState();
}
class _HistoryPageState extends State<HistoryPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final filters = [s.all, s.sent, s.received, s.pendingStr, s.completed];
    final txns = Mock.transactions.where((t) {
      if (_filter == s.sent) return t.isSent;
      if (_filter == s.received) return !t.isSent;
      if (_filter == s.pendingStr) return t.status == TxStatus.pending;
      if (_filter == s.completed) return t.status == TxStatus.completed || t.status == TxStatus.synced;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(s.history),
        actions: [IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {})]),
      body: Column(children: [
        SizedBox(height: 52, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: filters.map((f) => GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _filter == f ? C.teal : C.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _filter == f ? C.teal : C.border)),
              child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _filter == f ? Colors.white : C.ink3))))).toList())),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: txns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final tx = txns[i];
            final sc = _sc(tx.status, S(widget.locale));
            return GestureDetector(
              onTap: () => context.push(R.txDetail, extra: {'tx': tx, 'locale': widget.locale}),
              child: Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
                child: Column(children: [
                  Row(children: [
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: tx.isSent ? C.red2 : C.green2, borderRadius: BorderRadius.circular(12)),
                      child: Icon(tx.isSent ? Icons.north_rounded : Icons.south_rounded, color: tx.isSent ? C.red : C.green, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tx.isSent ? tx.toName : tx.fromName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink)),
                      Text('${tx.date.day}/${tx.date.month}/${tx.date.year}', style: const TextStyle(fontSize: 11, color: C.ink3)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${tx.isSent ? '-' : '+'}${tx.amount.toStringAsFixed(0)} XOF',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: tx.isSent ? C.red : C.green3)),
                      const SizedBox(height: 3),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: sc[0], borderRadius: BorderRadius.circular(100)),
                        child: Text(sc[1] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc[2] as Color))),
                    ]),
                  ]),
                  const SizedBox(height: 8), const Divider(height: 1), const SizedBox(height: 8),
                  Row(children: [
                    MethodBadge(method: tx.method.name.toUpperCase()),
                    const SizedBox(width: 6),
                    Text(tx.shortId, style: const TextStyle(fontFamily: 'Courier', fontSize: 10, color: C.ink3)),
                  ]),
                ])));
          })),
      ]));
  }

  List<dynamic> _sc(TxStatus s, S str) {
    switch (s) {
      case TxStatus.completed: return [C.green2, str.statusCompleted, C.green];
      case TxStatus.synced:    return [C.green2, str.statusSynced,    C.green];
      case TxStatus.pending:   return [C.amber2, str.statusPending,   C.amber];
      case TxStatus.failed:    return [C.red2,   str.statusFailed,    C.red];
    }
  }
}

// ── Transaction Detail ────────────────────────────────────────────────────────
class TxDetailPage extends StatelessWidget {
  final TxEntity tx;
  final String locale;
  const TxDetailPage({super.key, required this.tx, required this.locale});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton(), title: const Text('Transaction detail')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Center(child: Column(children: [
        Container(width: 72, height: 72, decoration: BoxDecoration(
          shape: BoxShape.circle, color: tx.isSent ? C.red2 : C.green2),
          child: Icon(tx.isSent ? Icons.north_rounded : Icons.south_rounded, color: tx.isSent ? C.red : C.green, size: 36)),
        const SizedBox(height: 12),
        Text('${tx.isSent ? '-' : '+'}${tx.amount.toStringAsFixed(0)} ${tx.currency}',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: tx.isSent ? C.red : C.green, letterSpacing: -1)),
        const SizedBox(height: 6),
        Badge(label: tx.status.name.toUpperCase(),
          bg: tx.status == TxStatus.pending ? C.amber2 : C.green2,
          fg: tx.status == TxStatus.pending ? C.amber : C.green),
      ])),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
        child: Column(children: [
          ...[
            ['Transaction ID', tx.shortId],
            ['From', tx.fromName],
            ['To', tx.toName],
            ['Amount', '${tx.amount.toStringAsFixed(0)} ${tx.currency}'],
            ['Method', tx.method.name.toUpperCase()],
            ['Date', '${tx.date.day}/${tx.date.month}/${tx.date.year}'],
            ['Status', tx.status.name],
          ].map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(r[0], style: const TextStyle(fontSize: 13, color: C.ink3)),
              Text(r[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink)),
            ]))),
        ])),
    ]));
}

// ── Settings ──────────────────────────────────────────────────────────────────
class SettingsPage extends StatefulWidget {
  final String locale;
  const SettingsPage({super.key, required this.locale});
  @override State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  bool _notif = false, _bio = true, _dark = false;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final user = Mock.user;
    final wallet = Mock.wallet;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(s.settings)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Profile card
        Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
          child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(user.initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.teal)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: C.ink)),
              Text(user.phone, style: const TextStyle(fontSize: 12, color: C.ink3)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: C.green2, borderRadius: BorderRadius.circular(100)),
              child: const Text('active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.green))),
          ])),
        _sLabel(s.account),
        _group([
          SettingsRow(icon: Icons.person_outline_rounded, label: s.profile, value: user.email, onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SettingsRow(icon: Icons.account_balance_wallet_outlined, label: s.walletTier, value: wallet.tierName, onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SettingsRow(icon: Icons.key_rounded, label: s.keyMgmt, value: 'ECDSA + AES-256', onTap: () => _keySheet(context, s)),
        ]),
        const SizedBox(height: 16),
        _sLabel(s.preferences),
        _group([
          SettingsRow(icon: Icons.notifications_outlined, label: s.notifications,
            trailing: Switch(value: _notif, onChanged: (v) => setState(() => _notif = v), activeColor: C.teal)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SettingsRow(icon: Icons.fingerprint_rounded, label: s.biometric,
            trailing: Switch(value: _bio, onChanged: (v) => setState(() => _bio = v), activeColor: C.teal)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SettingsRow(icon: Icons.dark_mode_outlined, label: s.darkMode,
            trailing: Switch(value: _dark, onChanged: (v) => setState(() => _dark = v), activeColor: C.teal)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SettingsRow(icon: Icons.language_rounded, label: s.language,
            value: s.fr ? 'Français' : 'English', onTap: () => context.push(R.language)),
        ]),
        const SizedBox(height: 16),
        _sLabel('SUPPORT'),
        _group([
          SettingsRow(icon: Icons.help_outline_rounded, label: s.helpFaq, onTap: () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SettingsRow(icon: Icons.sync_outlined, label: s.syncStatus, onTap: () => context.push(R.syncPage, extra: {'locale': widget.locale})),
        ]),
        const SizedBox(height: 16),
        _group([
          SettingsRow(icon: Icons.logout_rounded, label: s.signOut, danger: true,
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
              backgroundColor: C.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(s.signOut),
              content: Text(s.signOutConfirm),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(s.no)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: C.red),
                  onPressed: () => context.go(R.login, extra: {'locale': widget.locale}),
                  child: Text(s.yes, style: const TextStyle(color: Colors.white))),
              ]))),
        ]),
        const SizedBox(height: 28),
      ]));
  }

  Widget _sLabel(String t) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.ink3, letterSpacing: 0.9)));

  Widget _group(List<Widget> rows) => Container(
    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
    child: Column(children: rows));

  void _keySheet(BuildContext ctx, S s) => showModalBottomSheet(context: ctx,
    backgroundColor: C.surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(s.keyMgmt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: C.navy)),
      const SizedBox(height: 20),
      ...[['Algorithm','ECDSA-P256'],['Storage','Android Keystore / iOS Secure Enclave'],['Last rotation','12 days ago'],['Next rotation','In 18 days'],['Status','ACTIVE ✓']].map((r) =>
        Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(r[0], style: const TextStyle(fontSize: 13, color: C.ink3)),
            Text(r[1], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: r[1].endsWith('✓') ? C.green : C.ink)),
          ]))),
      const SizedBox(height: 8),
      Btn(label: s.fr ? 'Faire une rotation' : 'Rotate keys', outline: true, icon: Icons.refresh_rounded, onPressed: () => Navigator.pop(ctx)),
      const SizedBox(height: 20),
    ])));
}

// ── Sync Page ─────────────────────────────────────────────────────────────────
class SyncPage extends StatefulWidget {
  final String locale;
  const SyncPage({super.key, required this.locale});
  @override State<SyncPage> createState() => _SyncPageState();
}
class _SyncPageState extends State<SyncPage> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(s.syncStatus)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
          child: Column(children: [
            Row(children: [
              Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, color: C.amber2),
                child: const Icon(Icons.sync_rounded, color: C.amber, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('1 ${s.pendingStr.toLowerCase()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.ink)),
                Text(s.fr ? 'Dernière sync : il y a 24 min' : 'Last sync: 24 minutes ago', style: const TextStyle(fontSize: 12, color: C.ink3)),
              ])),
              Badge.pending(),
            ]),
            const SizedBox(height: 16),
            Btn(label: _syncing ? (s.fr ? 'Synchronisation…' : 'Syncing…') : (s.fr ? 'Synchroniser' : 'Sync now'),
              loading: _syncing, icon: Icons.sync_rounded,
              onPressed: () async {
                setState(() => _syncing = true);
                await Future.delayed(const Duration(milliseconds: 2000));
                if (mounted) setState(() => _syncing = false);
              }),
          ])),
        const SizedBox(height: 20),
        Text(s.fr ? 'Éléments en attente' : 'Pending items', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.ink)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
          child: Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: C.amber2, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.north_rounded, color: C.amber, size: 18)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('To: Oumar Bah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink)),
              Text('100 XOF · QR · 4/1/2026', style: TextStyle(fontSize: 11, color: C.ink3)),
            ])),
            Badge.pending(),
          ])),
      ]));
  }
}
