import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/localization/strings.dart';
import '../../navigation/routes.dart';

class KycUploadPage extends StatefulWidget {
  final String locale;
  const KycUploadPage({super.key, required this.locale});

  @override
  State<KycUploadPage> createState() => _KycUploadPageState();
}

class _KycUploadPageState extends State<KycUploadPage>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  File? _cinRecto;
  File? _cinVerso;
  File? _selfie;

  final _cinNumberController = TextEditingController();
  DateTime? _expiryDate;

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
    _cinNumberController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool get _allUploaded =>
      _cinRecto != null &&
          _cinVerso != null &&
          _selfie != null &&
          _cinNumberController.text.isNotEmpty &&
          _expiryDate != null;

  Future<void> _pickImage(String type, ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          switch (type) {
            case 'recto':
              _cinRecto = File(picked.path);
              break;
            case 'verso':
              _cinVerso = File(picked.path);
              break;
            case 'selfie':
              _selfie = File(picked.path);
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur caméra: $e');
    }
  }

  void _showImageSource(String type) {
    final s = S(widget.locale);
    showModalBottomSheet(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: C.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                s.fr ? 'Choisir la source' : 'Choose source',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: C.ink,
                ),
              ),
              const SizedBox(height: 24),
              _sourceButton(
                icon: Icons.camera_alt_rounded,
                label: s.fr ? 'Caméra' : 'Camera',
                color: C.teal,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(type, ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _sourceButton(
                icon: Icons.photo_library_rounded,
                label: s.fr ? 'Galerie' : 'Gallery',
                color: C.navy,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(type, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year + 5, 12),
      firstDate: DateTime(now.year, now.month),
      lastDate: DateTime(now.year + 20, 12),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: C.teal,
              onPrimary: Colors.white,
              surface: C.surface,
              onSurface: C.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expiryDate = DateTime(picked.year, picked.month));
    }
  }

  Future<void> _submit() async {
    if (!_allUploaded) {
      HapticFeedback.heavyImpact();
      await _shakeController.forward(from: 0);
      _shakeController.reset();
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.go(R.servicePromo, extra: {'locale': widget.locale});
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.locale);
    final isFr = s.fr;

    return Scaffold(
      backgroundColor: C.surface,
      appBar: AppBar(
        backgroundColor: C.surface,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          isFr ? 'Vérification d\'identité' : 'Identity Verification',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFr ? 'Finalisez votre inscription' : 'Complete your registration',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: C.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFr
                          ? 'Ces informations sont requises pour la sécurité de votre compte.'
                          : 'This information is required for your account security.',
                      style: const TextStyle(fontSize: 14, color: C.ink3, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // CIN Number field
              _animatedSection(
                delay: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(isFr ? 'Numéro de CIN' : 'ID Card Number'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cinNumberController,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 12,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined, color: C.ink3),
                        hintText: isFr ? 'Ex: AB123456' : 'Ex: AB123456',
                        counterText: '',
                        filled: true,
                        fillColor: C.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: C.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: C.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: C.teal, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Expiry Date field
              _animatedSection(
                delay: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(isFr ? 'Date d\'expiration' : 'Expiry Date'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectExpiryDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: C.surface2,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _expiryDate != null ? C.teal : C.border,
                            width: _expiryDate != null ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: _expiryDate != null ? C.teal : C.ink3,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _expiryDate != null
                                    ? DateFormat('MM/yyyy').format(_expiryDate!)
                                    : (isFr ? 'Sélectionner une date' : 'Select a date'),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _expiryDate != null ? C.ink : C.ink3,
                                ),
                              ),
                            ),
                            if (_expiryDate != null)
                              const Icon(Icons.check_circle_rounded, color: C.green, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Divider(color: C.border, height: 1),

              const SizedBox(height: 32),

              // Documents section
              _animatedSection(
                delay: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFr ? 'Documents requis' : 'Required Documents',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: C.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFr
                          ? 'Prenez des photos claires et lisibles'
                          : 'Take clear and readable photos',
                      style: const TextStyle(fontSize: 13, color: C.ink3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Upload tiles with stagger
              _animatedSection(
                delay: 3,
                child: _uploadTile(
                  'recto',
                  Icons.credit_card,
                  isFr ? 'CIN Recto' : 'ID Card Front',
                  isFr ? 'Photo du recto' : 'Front side photo',
                  _cinRecto,
                ),
              ),
              const SizedBox(height: 12),
              _animatedSection(
                delay: 4,
                child: _uploadTile(
                  'verso',
                  Icons.credit_card_outlined,
                  isFr ? 'CIN Verso' : 'ID Card Back',
                  isFr ? 'Photo du verso' : 'Back side photo',
                  _cinVerso,
                ),
              ),
              const SizedBox(height: 12),
              _animatedSection(
                delay: 5,
                child: _uploadTile(
                  'selfie',
                  Icons.face,
                  isFr ? 'Selfie' : 'Selfie',
                  isFr ? 'Photo de votre visage' : 'Face photo',
                  _selfie,
                ),
              ),

              const SizedBox(height: 40),

              // Progress indicator
              _buildProgressIndicator(),

              const SizedBox(height: 20),

              // Submit button
              _animatedSection(
                delay: 6,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allUploaded ? C.teal : C.border,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: C.border,
                      disabledForegroundColor: C.ink4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _allUploaded ? 4 : 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _loading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Text(
                        _allUploaded
                            ? (isFr ? 'Continuer' : 'Continue')
                            : (isFr
                            ? 'Veuillez compléter tous les champs'
                            : 'Please complete all fields'),
                        key: ValueKey(_allUploaded),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  Widget _animatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (delay * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    final total = 5; // cinNumber, expiry, recto, verso, selfie
    int completed = 0;
    if (_cinNumberController.text.isNotEmpty) completed++;
    if (_expiryDate != null) completed++;
    if (_cinRecto != null) completed++;
    if (_cinVerso != null) completed++;
    if (_selfie != null) completed++;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.ink3),
            ),
            Text(
              '$completed/$total',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.teal),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: completed / total,
            backgroundColor: C.border,
            valueColor: const AlwaysStoppedAnimation(C.teal),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _uploadTile(String type, IconData icon, String title, String subtitle, File? image) {
    final hasImage = image != null;

    return GestureDetector(
      onTap: () => _showImageSource(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasImage ? C.green2 : C.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? C.green : C.border,
            width: hasImage ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: hasImage ? C.green.withOpacity(0.15) : C.tealLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: hasImage
                  ? const Icon(Icons.check_circle_rounded, color: C.green, size: 28)
                  : Icon(icon, color: C.teal, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: C.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage
                        ? (S(widget.locale).fr ? 'Document ajouté ✓' : 'Document added ✓')
                        : subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasImage ? C.green : C.ink3,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                hasImage ? Icons.check_circle_rounded : Icons.add_circle_outline,
                key: ValueKey(hasImage),
                color: hasImage ? C.green : C.teal,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}