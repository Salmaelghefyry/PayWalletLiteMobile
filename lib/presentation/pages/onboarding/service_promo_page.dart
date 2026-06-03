import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';

class ServicePromoPage extends StatefulWidget {
  final String locale;
  const ServicePromoPage({super.key, required this.locale});

  @override
  State<ServicePromoPage> createState() => _ServicePromoPageState();
}

class _ServicePromoPageState extends State<ServicePromoPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _logoPulse;
  late final AnimationController _cardFloat;
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _logoPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _cardFloat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoPulse.dispose();
    _cardFloat.dispose();
    _shine.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go(R.createWallet, extra: {'locale': widget.locale});
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final isFr = s.fr;

    return Scaffold(
      backgroundColor: C.surface,
      body: Stack(
        children: [
          // Background animated gradient
          AnimatedBuilder(
            animation: _shine,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      C.surface,
                      C.surface2,
                      C.tealLight.withOpacity(0.1 + (_shine.value * 0.1)),
                      C.surface,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                    begin: Alignment(-1 + (_shine.value * 2), -1),
                    end: Alignment(1 - (_shine.value * 2), 1),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button with fade
                AnimatedOpacity(
                  opacity: _currentPage < 3 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: () => context.go(
                          R.createWallet,
                          extra: {'locale': widget.locale},
                        ),
                        child: Text(
                          isFr ? 'Passer →' : 'Skip →',
                          style: const TextStyle(
                            color: C.ink3,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _IntroPage(
                        locale: widget.locale,
                        logoPulse: _logoPulse,
                        onNext: _nextPage,
                      ),
                      _PlanPage(
                        plan: _Plan.basic,
                        floatAnim: _cardFloat,
                        onNext: _nextPage,
                      ),
                      _PlanPage(
                        plan: _Plan.silver,
                        floatAnim: _cardFloat,
                        onNext: _nextPage,
                      ),
                      _PlanPage(
                        plan: _Plan.gold,
                        floatAnim: _cardFloat,
                        onNext: _nextPage,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                // Dots with animation
                _AnimatedDots(currentPage: _currentPage, total: 4),

                const SizedBox(height: 12),

                // Bottom button with scale animation
                _AnimatedButton(
                  label: _currentPage < 3
                      ? (isFr ? 'Découvrir' : 'Discover')
                      : (isFr ? 'Créer mon wallet' : 'Create my wallet'),
                  onPressed: _nextPage,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== INTRO PAGE ====================

class _IntroPage extends StatelessWidget {
  final String locale;
  final AnimationController logoPulse;
  final VoidCallback onNext;

  const _IntroPage({
    required this.locale,
    required this.logoPulse,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final s = S(locale);
    final isFr = s.fr;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo with pulse
            AnimatedBuilder(
              animation: logoPulse,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (logoPulse.value * 0.08),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [C.teal, C.navy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: C.teal.withOpacity(0.3 + (logoPulse.value * 0.2)),
                          blurRadius: 30 + (logoPulse.value * 20),
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Title with stagger
            _StaggeredText(
              text: isFr ? 'Pas de réseau ?\nPas de problème !' : 'No signal?\nNo problem!',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: C.navy,
                height: 1.2,
              ),
              delay: const Duration(milliseconds: 200),
            ),

            const SizedBox(height: 20),

            // Subtitle
            _StaggeredText(
              text: isFr
                  ? 'PayWalletLite transforme votre téléphone en wallet. Achetez, payez, transférez — même sans internet.'
                  : 'PayWalletLite turns your phone into a wallet. Buy, pay, transfer — even without internet.',
              style: const TextStyle(
                fontSize: 15,
                color: C.ink3,
                height: 1.7,
              ),
              delay: const Duration(milliseconds: 400),
              align: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Badge with bounce
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [C.orange, C.orangeDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: C.orange.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_android_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isFr ? 'Votre téléphone = Votre wallet' : 'Your phone = Your wallet',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PLAN PAGE ====================

class _Plan {
  final String title;
  final String subtitle;
  final String price;
  final List<String> features;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? badge;

  const _Plan({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.features,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.badge,
  });

  static _Plan get basic => const _Plan(
    title: 'Basic',
    subtitle: 'Gestion manuelle',
    price: 'Gratuit',
    features: [
      'Allocation manuelle offline',
      'Contrôle total de vos fonds',
      'Parfait pour débuter',
      'Aucun automatisme',
    ],
    description: 'Vous décidez quand et combien réserver pour le mode offline. Idéal pour les petits budgets.',
    icon: Icons.account_balance_wallet_outlined,
    color: C.navy,
    bgColor: C.navyLight,
  );

  static _Plan get silver => const _Plan(
    title: 'Silver',
    subtitle: 'Automatisation intelligente',
    price: 'Standard',
    features: [
      'Réservation auto configurable',
      'Pourcentage ou montant fixe',
      'Limite journalière personnalisée',
      'Idéal pour usage régulier',
    ],
    description: 'Le système réserve automatiquement votre solde offline. Vous choisissez le mode : pourcentage ou montant fixe.',
    icon: Icons.auto_mode_rounded,
    color: C.teal,
    bgColor: C.tealLight,
    badge: 'POPULAIRE',
  );

  static _Plan get gold => const _Plan(
    title: 'Gold',
    subtitle: 'Premium & crédit',
    price: 'Premium',
    features: [
      'Toutes les fonctionnalités Silver',
      'Crédit de dépannage offline',
      'Service premium dédié',
      'Support prioritaire',
    ],
    description: 'Le nec plus ultra. Même à court de solde offline, notre crédit de dépannage vous permet de continuer.',
    icon: Icons.diamond_outlined,
    color: C.gold,
    bgColor: C.goldLight,
    badge: 'PREMIUM',
  );
}

class _PlanPage extends StatelessWidget {
  final _Plan plan;
  final AnimationController floatAnim;
  final VoidCallback onNext;
  final bool isLast;

  const _PlanPage({
    required this.plan,
    required this.floatAnim,
    required this.onNext,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(100 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Floating card
              AnimatedBuilder(
                animation: floatAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -5 + (floatAnim.value * 10)),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        plan.color,
                        plan.color.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: plan.color.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Hero(
                            tag: 'icon_${plan.title}',
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(plan.icon, color: Colors.white, size: 32),
                            ),
                          ),
                          if (plan.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                plan.badge!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Wallet ${plan.title}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          plan.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Features with stagger
              ...plan.features.asMap().entries.map((entry) {
                final index = entry.key;
                final feature = entry.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(-30 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 500 + (index * 100)),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: plan.bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_rounded, color: plan.color, size: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 14,
                              color: C.ink2,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Description card
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.95 + (value * 0.05),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: plan.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: plan.color.withOpacity(0.1)),
                  ),
                  child: Text(
                    plan.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: plan.color.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ANIMATED DOTS ====================

class _AnimatedDots extends StatelessWidget {
  final int currentPage;
  final int total;

  const _AnimatedDots({required this.currentPage, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? C.teal : C.border,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

// ==================== ANIMATED BUTTON ====================

class _AnimatedButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _AnimatedButton({required this.label, required this.onPressed});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _pressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressAnim.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressAnim.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressAnim.reverse();
      },
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_pressAnim.value * 0.05),
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [C.teal, C.tealDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: C.teal.withOpacity(_isPressed ? 0.2 : 0.4),
                blurRadius: _isPressed ? 10 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.label,
                key: ValueKey(widget.label),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== STAGGERED TEXT ====================

class _StaggeredText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  final TextAlign? align;

  const _StaggeredText({
    required this.text,
    required this.style,
    required this.delay,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );
  }
}