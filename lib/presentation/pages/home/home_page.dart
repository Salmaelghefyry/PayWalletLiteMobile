import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../../data/mock_data.dart';
import '../../../domain/entities/entities.dart';
import '../../navigation/routes.dart';
import '../../widgets/common/widgets.dart';

class HomePage extends StatefulWidget {
  final String locale;
  final Map<String, dynamic> wallet;
  const HomePage({super.key, required this.locale, this.wallet = const {}});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(
      body: IndexedStack(index: _tab, children: [
        _HomeTab(locale: widget.locale, wallet: widget.wallet),
        _WalletTab(locale: widget.locale),
        _ScanTab(locale: widget.locale),
        _MoreTab(locale: widget.locale),
      ]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: C.surface, border: Border(top: BorderSide(color: C.border))),
        child: BottomNavigationBar(
          currentIndex: _tab, onTap: (i) => setState(() => _tab = i),
          backgroundColor: Colors.transparent, elevation: 0,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home_rounded), label: s.home),
            BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), activeIcon: const Icon(Icons.account_balance_wallet_rounded), label: s.wallet),
            BottomNavigationBarItem(icon: const Icon(Icons.qr_code_scanner_outlined), activeIcon: const Icon(Icons.qr_code_scanner_rounded), label: s.scan),
            BottomNavigationBarItem(icon: const Icon(Icons.more_horiz_outlined), activeIcon: const Icon(Icons.more_horiz_rounded), label: s.more),
          ])));
  }

}

// ── Home tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final String locale;
  final Map<String, dynamic> wallet;
  const _HomeTab({required this.locale, required this.wallet});
  @override State<_HomeTab> createState() => _HomeTabState();
}
class _HomeTabState extends State<_HomeTab> {
  bool _isOffline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) setState(() => _isOffline = result == ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) setState(() => _isOffline = result == ConnectivityResult.none);
  }

  @override
  Widget build(BuildContext context) {
    final s    = S(widget.locale);
    final user = Mock.user;
    final txns = Mock.transactions;

    return CustomScrollView(slivers: [
      SliverAppBar(
        automaticallyImplyLeading: false, floating: true, toolbarHeight: 62,
        title: Row(children: [
          Image.asset('assets/images/logo_white.png', width: 28, height: 28),
          const SizedBox(width: 8),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'Pay',    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.teal)),
            TextSpan(text: 'Wallet',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.navy)),
            TextSpan(text: 'Lite',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: C.ink3)),
          ])),
        ]),
        actions: [
          if (_isOffline)
            Container(margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: C.amber2, borderRadius: BorderRadius.circular(100)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.wifi_off_rounded, size: 12, color: C.amber),
                SizedBox(width: 4),
                Text('OFFLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.amber, letterSpacing: 0.5)),
              ])),
          IconButton(icon: const Icon(Icons.notifications_outlined, size: 20), onPressed: () {}),
          Padding(padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(onTap: () => context.push(R.settings, extra: {'locale': widget.locale}),
              child: Container(width: 32, height: 32, decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text(user.initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: C.teal)))))),
        ],
      ),
      SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 14), child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.hello, style: const TextStyle(fontSize: 14, color: C.ink3)),
            Row(children: [
              Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.navy)),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(100)),
                child: Text(widget.wallet['type'] as String? ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.teal))),
            ]),
          ]),
        ])),
        _SelectedWalletCard(wallet: widget.wallet, locale: widget.locale, isOffline: _isOffline),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: widget.wallet.isNotEmpty
                  ? () => context.push(R.walletDetail, extra: {'locale': widget.locale, 'wallet': widget.wallet})
                  : null,
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(s.fr ? 'Voir le détail du wallet' : 'View wallet detail'),
              style: OutlinedButton.styleFrom(
                foregroundColor: C.teal,
                side: const BorderSide(color: C.teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )),
        const SizedBox(height: 18),
        // Quick actions
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            QuickBtn(icon: Icons.north_rounded,  label: s.send,    bg: C.blue2,    fg: C.blue,  onTap: () => context.push(R.transfer, extra: {'locale': widget.locale})),
            QuickBtn(icon: Icons.south_rounded,  label: s.receive, bg: C.green2,   fg: C.green, onTap: () => _showReceiveSheet(context)),
            QuickBtn(icon: Icons.token_outlined, label: s.tokens,  bg: C.goldLight, fg: C.gold, onTap: () {}),
            QuickBtn(icon: Icons.sync_rounded,   label: s.sync,    bg: C.green2,   fg: C.green, onTap: () => context.push(R.syncPage, extra: {'locale': widget.locale})),
          ])),
        const SizedBox(height: 14),
        // Pending sync banner
        Container(margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: C.amber2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.amber.withOpacity(0.3))),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 16, color: C.amber),
            const SizedBox(width: 8),
            Text('⚠  1 ${s.pendingSync}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.amber)),
          ])),
        SecTitle(title: s.recentTxns, action: s.viewAll, onAction: () => context.push(R.history, extra: {'locale': widget.locale})),
        // Transactions
        ListView.separated(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: txns.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final tx = txns[i];
            final sc = _sc(tx.status, s);
            return TxRow(
              name: tx.isSent ? tx.toName : tx.fromName,
              time: '${tx.date.month}/${tx.date.day}/${tx.date.year}',
              method: tx.method.name.toUpperCase(),
              amount: tx.amount,
              isSent: tx.isSent,
              statusLabel: sc[0] as String,
              statusColor: sc[1] as Color,
              statusBg: sc[2] as Color,
              onTap: () => context.push(R.txDetail, extra: {'tx': tx, 'locale': widget.locale}));
          }),
        const SizedBox(height: 24),
      ])),
    ]);
  }

  List<dynamic> _sc(TxStatus s, S str) {
    switch (s) {
      case TxStatus.completed: return [str.statusCompleted, C.green,  C.green2];
      case TxStatus.synced:    return [str.statusSynced,    C.green,  C.green2];
      case TxStatus.pending:   return [str.statusPending,   C.amber,  C.amber2];
      case TxStatus.failed:    return [str.statusFailed,    C.red,    C.red2];
    }
  }

  void _showReceiveSheet(BuildContext context) {
    if (widget.wallet.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReceiveSheet(locale: widget.locale, wallet: widget.wallet),
    );
  }
}

// ── Receive bottom sheet ──────────────────────────────────────────────────────
class _ReceiveSheet extends StatefulWidget {
  final String locale;
  final Map<String, dynamic> wallet;
  const _ReceiveSheet({required this.locale, required this.wallet});
  @override State<_ReceiveSheet> createState() => _ReceiveSheetState();
}
class _ReceiveSheetState extends State<_ReceiveSheet> {
  bool _copied = false;

  Future<void> _copyId(String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final w = widget.wallet;
    final walletId   = w['id']   as String? ?? '';
    final walletName = w['name'] as String? ?? '';
    final type       = w['type'] as String? ?? '';
    final qrData     = 'paywallet://send?to=$walletId&name=$walletName';

    return Container(
      decoration: const BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4, decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        // Header row
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.fr ? 'Recevoir un paiement' : 'Receive payment',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.navy)),
            if (walletName.isNotEmpty)
              Text(walletName, style: const TextStyle(fontSize: 13, color: C.ink3)),
          ])),
          if (type.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(100)),
              child: Text(type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.teal))),
        ]),
        const SizedBox(height: 24),
        // QR card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.border),
          ),
          child: Column(children: [
            QrImageView(data: qrData, version: QrVersions.auto, size: 220,
              backgroundColor: Colors.white, foregroundColor: C.ink),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(100)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.qr_code_scanner_rounded, color: C.teal, size: 14),
                const SizedBox(width: 6),
                Text(s.fr ? 'Scan pour envoyer' : 'Scan to send',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.teal)),
              ])),
          ])),
        const SizedBox(height: 16),
        // Wallet ID section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.fr ? 'ID du Wallet' : 'Wallet ID',
              style: const TextStyle(fontSize: 11, color: C.ink3, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text(walletId,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.ink, letterSpacing: 0.2))),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _copyId(walletId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _copied ? C.green2 : C.tealLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 14, color: _copied ? C.green : C.teal),
                    const SizedBox(width: 5),
                    Text(
                      _copied ? (s.fr ? 'Copié !' : 'Copied!') : (s.fr ? 'Copier' : 'Copy'),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: _copied ? C.green : C.teal)),
                  ]),
                ),
              ),
            ]),
          ])),
        const SizedBox(height: 12),
        Text(
          s.fr
            ? 'Si le payeur ne peut pas scanner, communiquez-lui l\'ID ci-dessus.'
            : 'If the sender cannot scan, share the Wallet ID above.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: C.ink3)),
      ]));
  }
}

// ── Selected wallet balance card ─────────────────────────────────────────────
class _SelectedWalletCard extends StatefulWidget {
  final Map<String, dynamic> wallet;
  final String locale;
  final bool isOffline;
  const _SelectedWalletCard({required this.wallet, required this.locale, required this.isOffline});
  @override State<_SelectedWalletCard> createState() => _SelectedWalletCardState();
}
class _SelectedWalletCardState extends State<_SelectedWalletCard> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final w = widget.wallet;
    final balance        = (w['balance']        as num?)?.toDouble() ?? 0.0;
    final currency       = w['currency']        as String? ?? 'MAD';
    final dailyLimit     = (w['dailyLimit']     as num?)?.toDouble() ?? 0.0;
    final offlineReserve = (w['offlineReserve'] as num?)?.toDouble() ?? 0.0;
    final name           = w['name']            as String? ?? '';
    final type           = w['type']            as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A5C), Color(0xFF1BA8C8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: const Color(0xFF1BA8C8).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Stack(children: [
        Positioned(top: -24, right: -24, child: Container(width: 110, height: 110,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
        Positioned(bottom: -28, left: 20, child: Container(width: 80, height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top row: offline badge (conditional) + type badge
          Row(children: [
            if (widget.isOffline) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(100)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.wifi_off_rounded, size: 12, color: Colors.white70),
                  SizedBox(width: 4),
                  Text('OFFLINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                ])),
              const SizedBox(width: 8),
            ],
            const Spacer(),
            if (type.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(100)),
                child: Text(type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
          ]),
          if (name.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(name, style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 8),
          // Balance label + eye toggle
          Row(children: [
            Text(s.availBal, style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _balanceVisible = !_balanceVisible),
              child: Icon(
                _balanceVisible ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                color: Colors.white54,
                size: 18)),
          ]),
          const SizedBox(height: 4),
          // Balance amount
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _balanceVisible ? balance.toStringAsFixed(0) : '••••••',
                key: ValueKey(_balanceVisible),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5, height: 1)),
            ),
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 4),
              child: Text(currency, style: const TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.fr ? 'Offline réservé' : 'Offline reserve', style: const TextStyle(fontSize: 10, color: Colors.white54)),
              Text(
                _balanceVisible ? offlineReserve.toStringAsFixed(0) : '•••',
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.daily, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              Text(dailyLimit.toStringAsFixed(0), style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
            ])),
          ]),
        ])),
      ]));
  }
}

// ── Wallet tab ─────────────────────────────────────────────────────────────
class _WalletTab extends StatefulWidget {
  final String locale;
  const _WalletTab({required this.locale});
  @override State<_WalletTab> createState() => _WalletTabState();
}
class _WalletTabState extends State<_WalletTab> with SingleTickerProviderStateMixin {
  late TabController _tc;
  @override void initState() { super.initState(); _tc = TabController(length: 2, vsync: this); }
  @override void dispose() { _tc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s      = S(widget.locale);
    final wallet = Mock.wallet;
    final tokens = Mock.tokens;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.myWallet, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.navy)),
          Text(s.manageTokens, style: const TextStyle(fontSize: 11, color: C.ink3, fontWeight: FontWeight.w400)),
        ]),
        bottom: TabBar(controller: _tc,
          labelColor: C.teal, unselectedLabelColor: C.ink3,
          indicatorColor: C.teal, indicatorSize: TabBarIndicatorSize.label,
          tabs: [Tab(text: s.tokensSec), Tab(text: s.security)]),
      ),
      body: TabBarView(controller: _tc, children: [
        // Tokens tab
        ListView(padding: const EdgeInsets.all(16), children: [
          _WalletSummary(wallet: wallet, s: s),
          const SizedBox(height: 14),
          ...tokens.map((t) => _TokenCard(token: t, s: s)),
        ]),
        // Security tab
        ListView(padding: const EdgeInsets.all(16), children: [
          _SecRow(icon: Icons.key_rounded,           label: s.keyMgmt,   value: 'ECDSA + AES-256',            bg: C.tealLight, fg: C.teal),
          _SecRow(icon: Icons.verified_user_outlined, label: s.fr ? 'Certificat' : 'Certificate',  value: s.fr ? 'Valide' : 'Valid',   bg: C.green2,   fg: C.green),
          _SecRow(icon: Icons.shield_outlined,        label: s.fr ? 'Niveau KYC' : 'KYC Level',    value: s.fr ? 'Vérifié' : 'Verified', bg: C.navyLight, fg: C.navy),
          _SecRow(icon: Icons.fingerprint_rounded,    label: s.biometric, value: s.fr ? 'Activé' : 'Enabled',  bg: C.green2,   fg: C.green),
          _SecRow(icon: Icons.nfc_rounded,            label: 'NFC',       value: s.fr ? 'Disponible' : 'Available', bg: C.tealLight, fg: C.teal),
        ]),
      ]));
  }
}

class _WalletSummary extends StatelessWidget {
  final WalletEntity wallet;
  final S s;
  const _WalletSummary({required this.wallet, required this.s});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: C.border)),
    child: Column(children: [
      Row(children: [
        Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: C.teal)),
        const SizedBox(width: 8),
        Text('${wallet.tierName} Wallet', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.navy)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: C.tealLight, borderRadius: BorderRadius.circular(100)),
          child: Text('${Mock.tokens.where((t) => t.isActive).length} tokens',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.teal))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${s.balance}: ${wallet.balance.toStringAsFixed(0)} MAD', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink)),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: wallet.balance / wallet.monthlyLimit, minHeight: 5, backgroundColor: C.surface3, color: C.teal)),
          const SizedBox(height: 4),
          Text('${s.limit}: ${wallet.monthlyLimit.toStringAsFixed(0)} MAD', style: const TextStyle(fontSize: 11, color: C.ink3)),
        ])),
        const SizedBox(width: 16),
        ...[s.maxTx, s.daily, s.monthly].asMap().entries.map((e) {
          final vals = [wallet.maxTx, wallet.dailyLimit, wallet.monthlyLimit];
          return Padding(padding: const EdgeInsets.only(right: 12),
            child: Column(children: [
              Text(e.value, style: const TextStyle(fontSize: 10, color: C.ink3)),
              Text(vals[e.key].toStringAsFixed(0), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.navy)),
            ]));
        }),
      ]),
    ]));
}

class _TokenCard extends StatelessWidget {
  final TokenEntity token;
  final S s;
  const _TokenCard({required this.token, required this.s});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.border)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(token.shortId, style: const TextStyle(fontSize: 11, color: C.ink3, fontFamily: 'Courier')),
        Text('${token.value.toStringAsFixed(0)} ${token.currency}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.navy)),
        const SizedBox(height: 4),
        const Text('ECDSA512...truncated...', style: TextStyle(fontSize: 11, color: C.ink3)),
        Row(children: [const Icon(Icons.sync_rounded, size: 12, color: C.green), const SizedBox(width: 4), const Text('Synced', style: TextStyle(fontSize: 11, color: C.green))]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: token.isActive ? C.green2 : C.surface3, borderRadius: BorderRadius.circular(100)),
          child: Text(token.isActive ? (s.fr ? 'Actif' : 'Active') : (s.fr ? 'Dépensé' : 'Spent'),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: token.isActive ? C.green : C.ink3))),
        const SizedBox(height: 8),
        Text('${s.exp}: ${token.expiresAt.day}/${token.expiresAt.month}/${token.expiresAt.year}',
          style: const TextStyle(fontSize: 10, color: C.ink3)),
      ]),
    ]));
}

class _SecRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color bg, fg;
  const _SecRow({required this.icon, required this.label, required this.value, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: fg, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: C.ink))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
        child: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg))),
    ]));
}

// ── Scan tab ────────────────────────────────────────────────────────────────
class _ScanTab extends StatelessWidget {
  final String locale;
  const _ScanTab({required this.locale});
  @override
  Widget build(BuildContext context) {
    final s = S(locale);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(s.qrScanner),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(20),
          child: Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Text(s.receiveViaQr, style: const TextStyle(fontSize: 12, color: C.ink3))))),
      body: Column(children: [
        Expanded(child: Container(margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.border, width: 2)),
          child: Stack(children: [
            const Center(child: Icon(Icons.camera_alt_outlined, size: 64, color: C.ink4)),
            ...[Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight].map((a) =>
              Align(alignment: a, child: Container(width: 36, height: 36, margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border(
                  top: BorderSide(color: C.teal, width: 3, style: [Alignment.topLeft, Alignment.topRight].contains(a) ? BorderStyle.solid : BorderStyle.none),
                  bottom: BorderSide(color: C.teal, width: 3, style: [Alignment.bottomLeft, Alignment.bottomRight].contains(a) ? BorderStyle.solid : BorderStyle.none),
                  left: BorderSide(color: C.teal, width: 3, style: [Alignment.topLeft, Alignment.bottomLeft].contains(a) ? BorderStyle.solid : BorderStyle.none),
                  right: BorderSide(color: C.teal, width: 3, style: [Alignment.topRight, Alignment.bottomRight].contains(a) ? BorderStyle.solid : BorderStyle.none),
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

// ── More tab ─────────────────────────────────────────────────────────────────
class _MoreTab extends StatelessWidget {
  final String locale;
  const _MoreTab({required this.locale});
  @override
  Widget build(BuildContext context) {
    final s = S(locale);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(s.more)),
      body: ListView(children: [
        _tile(context, Icons.swap_horiz_rounded,    s.transfer,  () => context.push(R.transfer, extra: {'locale': locale})),
        _tile(context, Icons.history_rounded,        s.history,   () => context.push(R.history,  extra: {'locale': locale})),
        _tile(context, Icons.sync_rounded,           s.syncStatus,() => context.push(R.syncPage, extra: {'locale': locale})),
        _tile(context, Icons.settings_outlined,      s.settings,  () => context.push(R.settings, extra: {'locale': locale})),
        _tile(context, Icons.help_outline_rounded,   s.helpFaq,   () {}),
      ]));
  }
  Widget _tile(BuildContext ctx, IconData icon, String label, VoidCallback tap) =>
    ListTile(leading: Icon(icon, color: C.teal), title: Text(label), trailing: const Icon(Icons.chevron_right_rounded, color: C.ink3), onTap: tap);
}
