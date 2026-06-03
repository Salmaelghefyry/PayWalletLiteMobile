import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';

class CreateWalletPage extends StatefulWidget {
  final String locale;
  const CreateWalletPage({super.key, required this.locale});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage>
    with SingleTickerProviderStateMixin {
  String _selectedType = 'SILVER';
  String _walletName = '';
  String _reserveMode = 'percentage';
  double _reserveValue = 20;
  double _dailyLimit = 500;
  bool _loading = false;
  int _currentStepIndex = 0;

  final List<Map<String, dynamic>> _plans = [
    {
      'type': 'BASIC',
      'title': 'Basic',
      'subtitle': 'Gestion manuelle',
      'desc': 'Vous réservez manuellement le montant offline',
      'color': C.navy,
      'bgColor': C.navyLight,
      'icon': Icons.account_balance_wallet_outlined,
      'features': [
        'Allocation manuelle offline',
        'Aucun automatisme',
        'Parfait pour débuter',
      ],
    },
    {
      'type': 'SILVER',
      'title': 'Silver',
      'subtitle': 'Automatisation intelligente',
      'desc': 'Réservation automatique du solde offline',
      'color': C.teal,
      'bgColor': C.tealLight,
      'icon': Icons.auto_mode_rounded,
      'features': [
        'Réservation auto configurable',
        'Pourcentage ou montant fixe',
        'Idéal pour usage régulier',
      ],
    },
    {
      'type': 'GOLD',
      'title': 'Gold',
      'subtitle': 'Premium & crédit',
      'desc': 'Tout le Silver + crédit de dépannage',
      'color': C.gold,
      'bgColor': C.goldLight,
      'icon': Icons.diamond_outlined,
      'features': [
        'Toutes les fonctionnalités Silver',
        'Crédit de dépannage offline',
        'Service premium dédié',
      ],
    },
  ];

  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_currentStepIndex) {
      case 0:
        return _walletName.isNotEmpty && _selectedType.isNotEmpty;
      case 1:
        return true; // Configuration a toujours une valeur par défaut
      case 2:
        return _dailyLimit > 0;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canContinue) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0).then((_) => _shakeController.reset());
      return;
    }

    HapticFeedback.lightImpact();

    if (_currentStepIndex < 2) {
      setState(() => _currentStepIndex++);
    } else {
      _createWallet();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
    }
  }

  Future<void> _createWallet() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _loading = false);
    if (mounted) {
      context.go(R.walletsList, extra: {'locale': widget.locale});
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final isFr = s.fr;

    return Scaffold(
      backgroundColor: C.surface,
      appBar: AppBar(
        title: Text(isFr ? 'Créer un wallet' : 'Create wallet'),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shake = _shakeController.value;
          return Transform.translate(
            offset: Offset(
              shake > 0 ? (shake % 0.1 < 0.05 ? 1 : -1) * 8 : 0,
              0,
            ),
            child: child,
          );
        },
        child: Stepper(
          currentStep: _currentStepIndex,
          onStepContinue: _nextStep,
          onStepCancel: _previousStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _AnimatedButton(
                      label: _currentStepIndex == 2
                          ? (isFr ? 'Créer le wallet' : 'Create wallet')
                          : (isFr ? 'Continuer' : 'Continue'),
                      onPressed: details.onStepContinue!,
                      isPrimary: true,
                    ),
                  ),
                  if (_currentStepIndex > 0) ...[
                    const SizedBox(width: 12),
                    _AnimatedButton(
                      label: isFr ? 'Retour' : 'Back',
                      onPressed: details.onStepCancel!,
                      isPrimary: false,
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // ÉTAPE 1 : Nom + Type
            Step(
              title: Text(
                isFr ? 'Nom & Type' : 'Name & Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _currentStepIndex >= 0 ? C.teal : C.ink3,
                ),
              ),
              subtitle: Text(
                isFr ? 'Identifiez votre wallet' : 'Identify your wallet',
                style: const TextStyle(fontSize: 12, color: C.ink3),
              ),
              content: _stepNameAndType(s),
              isActive: _currentStepIndex >= 0,
              state: _currentStepIndex > 0
                  ? StepState.complete
                  : StepState.indexed,
            ),

            // ÉTAPE 2 : Configuration offline
            Step(
              title: Text(
                isFr ? 'Configuration' : 'Configuration',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _currentStepIndex >= 1 ? C.teal : C.ink3,
                ),
              ),
              subtitle: Text(
                isFr ? 'Réserve offline' : 'Offline reserve',
                style: const TextStyle(fontSize: 12, color: C.ink3),
              ),
              content: _stepConfiguration(s),
              isActive: _currentStepIndex >= 1,
              state: _currentStepIndex > 1
                  ? StepState.complete
                  : _currentStepIndex == 1
                  ? StepState.editing
                  : StepState.indexed,
            ),

            // ÉTAPE 3 : Limite journalière
            Step(
              title: Text(
                isFr ? 'Limite journalière' : 'Daily limit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _currentStepIndex >= 2 ? C.teal : C.ink3,
                ),
              ),
              subtitle: Text(
                isFr ? 'Sécurisez vos dépenses' : 'Secure your spending',
                style: const TextStyle(fontSize: 12, color: C.ink3),
              ),
              content: _stepDailyLimit(s),
              isActive: _currentStepIndex >= 2,
              state: _currentStepIndex == 2 ? StepState.editing : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ÉTAPE 1 : NOM + TYPE ====================

  Widget _stepNameAndType(S s) {
    final isFr = s.fr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nom du wallet
        _fieldLabel(isFr ? 'Nom du wallet' : 'Wallet name'),
        const SizedBox(height: 8),
        TextField(
          onChanged: (v) => setState(() => _walletName = v),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: isFr ? 'Ex: Mon wallet principal' : 'Ex: My main wallet',
            prefixIcon: const Icon(Icons.edit_outlined, color: C.ink3),
            filled: true,
            fillColor: C.surface2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _walletName.isNotEmpty ? C.teal : C.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: C.teal, width: 2),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Type de wallet
        _fieldLabel(isFr ? 'Type de wallet' : 'Wallet type'),
        const SizedBox(height: 12),

        ..._plans.map((plan) {
          final sel = _selectedType == plan['type'];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedType = plan['type']);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sel ? plan['bgColor'] : C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? plan['color'] : C.border,
                    width: sel ? 2.5 : 1,
                  ),
                  boxShadow: sel
                      ? [
                    BoxShadow(
                      color: plan['color'].withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                plan['color'],
                                plan['color'].withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(plan['icon'], color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet ${plan['title']}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: sel ? plan['color'] : C.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan['subtitle'],
                                style: const TextStyle(fontSize: 12, color: C.ink3),
                              ),
                            ],
                          ),
                        ),
                        AnimatedScale(
                          scale: sel ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: plan['color'],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      plan['desc'],
                      style: TextStyle(
                        fontSize: 13,
                        color: C.ink3,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List<String>.from(plan['features']).map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check_rounded, size: 14, color: plan['color']),
                          const SizedBox(width: 8),
                          Text(
                            f,
                            style: const TextStyle(fontSize: 12, color: C.ink2),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==================== ÉTAPE 2 : CONFIGURATION ====================

  Widget _stepConfiguration(S s) {
    final isFr = s.fr;
    final isBasic = _selectedType == 'BASIC';
    final plan = _plans.firstWhere((p) => p['type'] == _selectedType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Récap du type choisi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: plan['bgColor'],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: plan['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(plan['icon'], color: plan['color']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet ${plan['title']}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: plan['color'],
                      ),
                    ),
                    Text(
                      plan['subtitle'],
                      style: const TextStyle(fontSize: 12, color: C.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        if (!isBasic) ...[
          _fieldLabel(isFr ? 'Mode de réserve offline' : 'Offline reserve mode'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _modeChip(
                  isFr ? 'Pourcentage' : 'Percentage',
                  'percentage',
                  Icons.percent_rounded,
                  plan['color'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _modeChip(
                  isFr ? 'Montant fixe' : 'Fixed amount',
                  'fixed',
                  Icons.attach_money_rounded,
                  plan['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Valeur animée
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _reserveValue),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Center(
                child: Text(
                  _reserveMode == 'percentage'
                      ? '${value.toInt()}%'
                      : '${value.toInt()} MAD',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: plan['color'],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          Slider(
            value: _reserveValue,
            min: _reserveMode == 'percentage' ? 5 : 100,
            max: _reserveMode == 'percentage' ? 50 : 5000,
            divisions: _reserveMode == 'percentage' ? 9 : 49,
            activeColor: plan['color'],
            inactiveColor: plan['color'].withOpacity(0.2),
            onChanged: (v) => setState(() => _reserveValue = v),
          ),
          const SizedBox(height: 8),
          Text(
            _reserveMode == 'percentage'
                ? (isFr
                ? 'du solde total sera automatiquement réservé pour les paiements offline'
                : 'of total balance will be automatically reserved for offline payments')
                : (isFr
                ? 'seront automatiquement réservés pour les paiements offline'
                : 'will be automatically reserved for offline payments'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: C.ink3, height: 1.5),
          ),
        ],

        if (isBasic)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: C.navyLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.navy.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: C.navy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: C.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFr ? 'Mode manuel' : 'Manual mode',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: C.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFr
                            ? 'En mode BASIC, vous gérez manuellement votre réserve offline depuis les paramètres du wallet. Aucune automatisation n\'est appliquée.'
                            : 'In BASIC mode, you manually manage your offline reserve from wallet settings. No automation is applied.',
                        style: TextStyle(
                          fontSize: 13,
                          color: C.navy.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==================== ÉTAPE 3 : LIMITE JOURNALIÈRE ====================

  Widget _stepDailyLimit(S s) {
    final isFr = s.fr;
    final presets = [200.0, 500.0, 1000.0, 2000.0, 5000.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFr ? 'Limite journalière offline' : 'Daily offline limit',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.ink),
        ),
        const SizedBox(height: 8),
        Text(
          isFr
              ? 'Les transactions offline ne pourront pas dépasser ce montant par jour. Cette limite protège vos fonds en cas de perte ou de vol.'
              : 'Offline transactions cannot exceed this amount per day. This limit protects your funds in case of loss or theft.',
          style: const TextStyle(fontSize: 13, color: C.ink3, height: 1.5),
        ),

        const SizedBox(height: 32),

        // Montant animé
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _dailyLimit),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Center(
              child: Text(
                '${value.toInt()} MAD',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: C.teal,
                  letterSpacing: -1,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Slider
        Slider(
          value: _dailyLimit,
          min: 100,
          max: 5000,
          divisions: 49,
          activeColor: C.teal,
          inactiveColor: C.teal.withOpacity(0.2),
          thumbColor: C.teal,
          onChanged: (v) => setState(() => _dailyLimit = v),
        ),

        // Min/Max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100 MAD', style: TextStyle(fontSize: 11, color: C.ink4)),
              Text('5000 MAD', style: TextStyle(fontSize: 11, color: C.ink4)),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Presets
        _fieldLabel(isFr ? 'Suggestions rapides' : 'Quick presets'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presets.map((p) {
            final sel = (_dailyLimit - p).abs() < 50;
            return GestureDetector(
              onTap: () => setState(() => _dailyLimit = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: sel
                      ? const LinearGradient(
                    colors: [C.teal, C.tealDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: sel ? null : C.surface2,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: sel ? C.teal : C.border,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Text(
                  '${p.toInt()} MAD',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : C.ink,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.tealLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: C.teal, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFr
                      ? 'Cette limite peut être modifiée à tout moment dans les paramètres de votre wallet.'
                      : 'This limit can be changed at any time in your wallet settings.',
                  style: const TextStyle(fontSize: 12, color: C.tealDark, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== WIDGETS UTILITAIRES ====================

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: C.ink2,
      ),
    );
  }

  Widget _modeChip(String label, String mode, IconData icon, Color color) {
    final sel = _reserveMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _reserveMode = mode;
          _reserveValue = mode == 'percentage' ? 20 : 500;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: sel
              ? LinearGradient(
            colors: [color, color.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: sel ? null : C.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel ? color : C.border,
            width: sel ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: sel ? Colors.white : C.ink3,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : C.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== BOUTON ANIMÉ ====================

class _AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _AnimatedButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        _pressController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
        _pressController.reverse();
      },
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_pressController.value * 0.05),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? const LinearGradient(
              colors: [C.teal, C.tealDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : null,
            color: widget.isPrimary ? null : C.surface2,
            borderRadius: BorderRadius.circular(16),
            border: widget.isPrimary
                ? null
                : Border.all(color: C.border),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: widget.isPrimary ? Colors.white : C.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}