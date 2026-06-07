import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';

class WalletsListPage extends StatefulWidget {
  final String locale;
  const WalletsListPage({super.key, required this.locale});

  @override
  State<WalletsListPage> createState() => _WalletsListPageState();
}

class _WalletsListPageState extends State<WalletsListPage> {
  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 'WLT-SILVER-7F3A2B9E',
      'name': 'Mon Wallet Principal',
      'type': 'SILVER',
      'balance': 8500.0,
      'offlineReserve': 1700.0,
      'dailyLimit': 500.0,
      'status': 'active',
      'currency': 'MAD',
    },
    {
      'id': 'WLT-BASIC-2A9F1C4D',
      'name': 'Wallet Dépenses',
      'type': 'BASIC',
      'balance': 1200.0,
      'offlineReserve': 0.0,
      'dailyLimit': 200.0,
      'status': 'active',
      'currency': 'MAD',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    return Scaffold(
      backgroundColor: C.surface2,
      appBar: AppBar(
        title: Text(s.fr ? 'Mes Wallets' : 'My Wallets'),
        backgroundColor: C.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: C.red),
            onPressed: () => context.go(R.login, extra: {'locale': widget.locale}),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: C.teal),
            onPressed: () => context.push(R.createWallet, extra: {'locale': widget.locale}),
          ),
        ],
      ),
      body: _wallets.isEmpty ? _emptyState(s) : _walletList(s),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(R.createWallet, extra: {'locale': widget.locale}),
        backgroundColor: C.teal,
        icon: const Icon(Icons.add),
        label: Text(s.fr ? 'Créer un wallet' : 'Create wallet'),
      ),
    );
  }

  Widget _emptyState(S s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: C.ink4),
          const SizedBox(height: 16),
          Text(
            s.fr ? 'Aucun wallet' : 'No wallet yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.ink3),
          ),
          const SizedBox(height: 8),
          Text(
            s.fr ? 'Créez votre premier wallet' : 'Create your first wallet',
            style: TextStyle(fontSize: 14, color: C.ink4),
          ),
        ],
      ),
    );
  }

  Widget _walletList(S s) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _wallets.length,
      itemBuilder: (context, index) {
        final w = _wallets[index];
        return _walletCard(w, s);
      },
    );
  }

  Widget _walletCard(Map<String, dynamic> w, S s) {
    final typeColors = {
      'BASIC': [C.navy, C.navyLight],
      'SILVER': [C.teal, C.tealLight],
      'GOLD': [C.gold, C.goldLight],
    };
    final colors = typeColors[w['type']] ?? [C.ink, C.surface3];

    return GestureDetector(
      onTap: () => context.go(R.home, extra: {
        'locale': widget.locale,
        'wallet': w,
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors[0], colors[0].withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    w['type'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _statusBadge(w['status']),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              w['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              w['id'],
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.fr ? 'Solde' : 'Balance',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${w['balance'].toStringAsFixed(0)} ${w['currency']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      s.fr ? 'Réservé offline' : 'Offline reserve',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${w['offlineReserve'].toStringAsFixed(0)} ${w['currency']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final statusConfig = {
      'active': [C.green, '● Active'],
      'pending': [C.orange, '● En cours'],
      'rejected': [C.red, '● Refusé'],
    };
    final config = statusConfig[status] ?? [C.ink4, '● Inconnu'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config[1] as String,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config[0] as Color,
        ),
      ),
    );
  }
}