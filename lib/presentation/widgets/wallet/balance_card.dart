import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../../../app/localization/strings.dart';

class BalanceCard extends StatelessWidget {
  final WalletEntity wallet;
  final S s;
  const BalanceCard({super.key, required this.wallet, required this.s});

  @override
  Widget build(BuildContext context) => Container(
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
        Row(children: [
          _offlinePill(),
          const Spacer(),
          const Icon(Icons.remove_red_eye_outlined, color: Colors.white54, size: 18),
        ]),
        const SizedBox(height: 14),
        Text(s.availBal, style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(wallet.balance.toStringAsFixed(0),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.5, height: 1)),
          const SizedBox(width: 6),
          const Padding(padding: EdgeInsets.only(bottom: 4),
            child: Text('MAD', style: TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 2),
        Text('${wallet.tokenCount} tokens • Max ${wallet.maxTx.toStringAsFixed(0)} MAD',
          style: const TextStyle(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 16),
        Row(children: [
          _stat(s.maxTx,   wallet.maxTx.toStringAsFixed(0)),
          _stat(s.daily,   wallet.dailyLimit.toStringAsFixed(0)),
          _stat(s.monthly, wallet.monthlyLimit.toStringAsFixed(0)),
        ]),
      ])),
    ]));

  Widget _offlinePill() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(100)),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.wifi_off_rounded, size: 12, color: Colors.white70),
      SizedBox(width: 4),
      Text('OFFLINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
    ]));

  Widget _stat(String label, String value) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w500)),
    Text(value,  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
  ]));
}
