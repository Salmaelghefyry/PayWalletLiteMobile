import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';


class WalletDetailPage extends StatefulWidget {
  final String locale;
  final Map<String, dynamic> wallet;
  const WalletDetailPage({super.key, required this.locale, required this.wallet});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  bool _showQr = false;
  late double _offlineReserve;
  bool _saveSuccess = false;

  @override
  void initState() {
    super.initState();
    _offlineReserve = (widget.wallet['offlineReserve'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final w = widget.wallet;

    return Scaffold(
      backgroundColor: C.surface2,
      appBar: AppBar(
        title: Text(w['name']),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: Icon(_showQr ? Icons.close : Icons.qr_code_rounded, color: C.teal),
            onPressed: () => setState(() => _showQr = !_showQr),
          ),
        ],
      ),
      body: _showQr ? _qrView(w, s) : _detailView(w, s),
    );
  }

  Widget _detailView(Map<String, dynamic> w, S s) {
    final isBasic = w['type'] == 'BASIC';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _balanceCard(w),
          const SizedBox(height: 20),
          if (isBasic) ...[
            _offlineAllocationSection(w, s),
            const SizedBox(height: 20),
          ],
          _infoCard(w, s),
          const SizedBox(height: 20),
          _actionButtons(s),
        ],
      ),
    );
  }

  Widget _balanceCard(Map<String, dynamic> w) {
    final typeColors = {
      'BASIC': C.navy,
      'SILVER': C.teal,
      'GOLD': C.gold,
    };
    final color = typeColors[w['type']] ?? C.ink;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  ),
                ),
              ),
              _statusBadge(w['status']),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            '${w['balance'].toStringAsFixed(0)} ${w['currency']}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Solde disponible',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réservé offline',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_offlineReserve.toStringAsFixed(0)} ${w['currency']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Limite/jour',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${w['dailyLimit'].toStringAsFixed(0)} ${w['currency']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(Map<String, dynamic> w, S s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          _infoRow('Wallet ID', w['id']),
          _infoRow('Type', w['type']),
          _infoRow('Devise', w['currency']),
          _infoRow('Statut', w['status']),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: C.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: C.ink3)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink),
          ),
        ],
      ),
    );
  }

  Widget _offlineAllocationSection(Map<String, dynamic> w, S s) {
    final balance = (w['balance'] as num?)?.toDouble() ?? 0.0;
    final currency = w['currency'] as String? ?? 'MAD';
    final isFr = s.fr;
    final maxReserve = (balance * 0.9).clamp(0.0, 5000.0);
    final availableOnline = balance - _offlineReserve;
    final pct = balance > 0 ? (_offlineReserve / balance).clamp(0.0, 1.0) : 0.0;
    final presets = [0.0, 100.0, 200.0, 500.0].where((p) => p <= maxReserve).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: C.navy.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: C.navyLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.wifi_off_rounded, color: C.navy, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFr ? 'Réserve Hors-ligne' : 'Offline Cash Reserve',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.navy),
                    ),
                    Text(
                      isFr ? 'Fonds utilisables sans connexion' : 'Usable without internet connection',
                      style: const TextStyle(fontSize: 11, color: C.ink3),
                    ),
                  ],
                ),
              ),
              if (_saveSuccess)
                AnimatedOpacity(
                  opacity: _saveSuccess ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: C.green2, borderRadius: BorderRadius.circular(100)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: C.green),
                      SizedBox(width: 4),
                      Text('OK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.green)),
                    ]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          // Balance breakdown bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: (((1 - pct) * 1000).round()).clamp(1, 1000),
                    child: Container(color: C.teal),
                  ),
                  if (_offlineReserve > 0)
                    Flexible(
                      flex: ((pct * 1000).round()).clamp(1, 1000),
                      child: Container(color: C.navy),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: C.teal, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 5),
                Text(
                  '${availableOnline.toStringAsFixed(0)} $currency ${isFr ? "en ligne" : "online"}',
                  style: const TextStyle(fontSize: 11, color: C.ink2, fontWeight: FontWeight.w500),
                ),
              ]),
              const Spacer(),
              Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 5),
                Text(
                  '${_offlineReserve.toStringAsFixed(0)} $currency ${isFr ? "offline" : "offline"}',
                  style: const TextStyle(fontSize: 11, color: C.ink2, fontWeight: FontWeight.w500),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          // Amount display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: C.navyLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Text(
                  _offlineReserve.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: C.navy),
                ),
                const SizedBox(width: 6),
                Text(currency, style: const TextStyle(fontSize: 13, color: C.ink3, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: C.navy.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.navy),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: C.navy,
              inactiveTrackColor: C.navyLight,
              thumbColor: C.navy,
              overlayColor: C.navy.withOpacity(0.1),
              valueIndicatorColor: C.navy,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            child: Slider(
              value: _offlineReserve.clamp(0.0, maxReserve),
              min: 0,
              max: maxReserve > 0 ? maxReserve : 1,
              divisions: maxReserve > 0 ? (maxReserve / 50).round().clamp(1, 100) : 1,
              label: '${_offlineReserve.toStringAsFixed(0)} $currency',
              onChanged: (val) => setState(() {
                _offlineReserve = ((val / 50).round() * 50.0).clamp(0.0, maxReserve);
                _saveSuccess = false;
              }),
            ),
          ),
          // Preset chips
          Wrap(
            spacing: 8,
            children: presets.map((p) {
              final isSelected = _offlineReserve == p;
              return GestureDetector(
                onTap: () => setState(() {
                  _offlineReserve = p;
                  _saveSuccess = false;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? C.navy : C.navyLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    p == 0 ? (isFr ? 'Aucune' : 'None') : p.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : C.navy,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _saveSuccess = true);
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) setState(() => _saveSuccess = false);
                });
              },
              icon: Icon(_saveSuccess ? Icons.check_rounded : Icons.save_rounded, size: 18),
              label: Text(
                _saveSuccess
                  ? (isFr ? 'Réserve enregistrée !' : 'Reserve saved!')
                  : (isFr
                    ? 'Enregistrer : ${_offlineReserve.toStringAsFixed(0)} $currency'
                    : 'Save: ${_offlineReserve.toStringAsFixed(0)} $currency'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _saveSuccess ? C.green : C.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(S s) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _showQr = true),
            icon: const Icon(Icons.qr_code_rounded),
            label: Text(s.fr ? 'Afficher mon QR' : 'Show my QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: C.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: C.teal),
            label: Text(
              s.fr ? 'Partager le wallet ID' : 'Share wallet ID',
              style: const TextStyle(color: C.teal),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: C.teal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _qrView(Map<String, dynamic> w, S s) {
    final isFr = s.fr;
    final qrData = 'paywallet://send?to=${w['id']}&name=${w['name']}&type=${w['type']}';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: C.border),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 280,
                    backgroundColor: Colors.white,
                    foregroundColor: C.ink,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    w['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    w['id'],
                    style: const TextStyle(fontSize: 12, color: C.ink3),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: C.tealLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: C.teal, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isFr ? 'Scan pour payer' : 'Scan to pay',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: C.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFr
                  ? 'Scannez ce QR code pour m\'envoyer de l\'argent'
                  : 'Scan this QR code to send me money',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: C.ink3),
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