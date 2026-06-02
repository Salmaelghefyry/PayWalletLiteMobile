// lib/app/localization/strings.dart
class S {
  final String locale;
  S(this.locale);

  bool get fr => locale == 'fr';

  // ── Auth ──
  String get signIn => fr ? 'Se connecter' : 'Sign In';
  String get signUp => fr ? 'Créer un compte' : 'Sign Up';
  String get phone => fr ? 'Téléphone' : 'Phone';
  String get password => fr ? 'Mot de passe' : 'Password';
  String get forgotPassword => fr ? 'Mot de passe oublié ?' : 'Forgot password?';
  String get biometricAuth => fr ? 'Empreinte digitale' : 'Biometric login';
  String get createAccount => fr ? 'Créer un compte' : 'Create Account';
  String get enterPin => fr ? 'Entrez votre code PIN' : 'Enter your PIN';
  String get demoPin => fr ? 'PIN démo : 123456' : 'Demo PIN: 123456';
  String get wrongPin => fr ? 'Code incorrect. Réessayez.' : 'Incorrect code. Try again.';
  String get useBiometric => fr ? 'Utiliser biométrie' : 'Use Biometric';

  // ── Onboarding / Register ──
  String get tagline => fr
      ? 'Paiements mobiles sécurisés & hors-ligne'
      : 'Secure mobile & offline payments';
  String get walletType => fr ? 'Type de portefeuille' : 'Wallet type';
  String get firstName => fr ? 'Prénom' : 'First name';
  String get lastName => fr ? 'Nom' : 'Last name';
  String get email => fr ? 'E-mail' : 'Email';
  String get kycNotice => fr
      ? 'Le KYC est requis pour les niveaux SILVER et GOLD.'
      : 'KYC is required for SILVER and GOLD tiers.';

  // ── Bottom Nav / Tabs ──
  String get home => fr ? 'Accueil' : 'Home';
  String get wallet => fr ? 'Portefeuille' : 'Wallet';
  String get scan => fr ? 'Scan' : 'Scan';
  String get more => fr ? 'Plus' : 'More';
  String get myWallet => fr ? 'Mon portefeuille' : 'My Wallet';
  String get manageTokens => fr ? 'Gérer les tokens' : 'Manage tokens';
  String get tokensSec => fr ? 'Tokens' : 'Tokens';
  String get security => fr ? 'Sécurité' : 'Security';

  // ── Home ──
  String get hello => fr ? 'Bonjour,' : 'Hello,';
  String get availBal => fr ? 'Solde disponible' : 'Available Balance';
  String get send => fr ? 'Envoyer' : 'Send';
  String get tokens => fr ? 'Tokens' : 'Tokens';
  String get sync => fr ? 'Sync' : 'Sync';
  String get pendingSync => fr ? 'sync en attente' : 'pending sync';
  String get recentTxns => fr ? 'Transactions récentes' : 'Recent transactions';
  String get viewAll => fr ? 'Voir tout' : 'View all';

  // ── Wallet / Balance ──
  String get balance => fr ? 'Solde' : 'Balance';
  String get limit => fr ? 'Limite' : 'Limit';
  String get maxTx => fr ? 'Max/Tx' : 'Max/Tx';
  String get daily => fr ? 'Jour' : 'Daily';
  String get monthly => fr ? 'Mois' : 'Monthly';
  String get exp => fr ? 'Exp' : 'Exp';

  // ── Transfer ──
  String get transfer      => fr ? 'Transférer' : 'Transfer';   // ← ADD if missing
  String get sendMoney => fr ? 'Envoyer de l\'argent' : 'Send Money';
  String get proceed => fr ? 'Continuer' : 'Proceed';
  String get available => fr ? 'Disponible' : 'Available';
  String get exceedsBalance => fr ? 'Montant trop élevé' : 'Exceeds balance';
  String get deviceDetected => fr ? 'Appareil détecté' : 'Device detected';
  String get holdPhones => fr ? 'Rapprochez les téléphones' : 'Hold phones together';
  String get switchBt => fr ? 'Passer en Bluetooth' : 'Switch to Bluetooth';
  String get cancel => fr ? 'Annuler' : 'Cancel';
  String get confirm => fr ? 'Confirmer' : 'Confirm';
  String get youAreSending => fr ? 'Vous envoyez' : 'You are sending';
  String get offlineWarning => fr
      ? 'Cette transaction sera synchronisée lors de la prochaine connexion.'
      : 'This transaction will sync on next connection.';
  String get confirmTransfer => fr ? 'Confirmer le transfert' : 'Confirm transfer';
  String get transferOk => fr ? 'Transfert réussi !' : 'Transfer successful!';
  String get sentVia => fr ? 'Envoyé via' : 'Sent via';
  String get pendingSyncBadge => fr ? 'SYNC EN ATTENTE' : 'PENDING SYNC';
  String get backHome => fr ? 'Retour à l\'accueil' : 'Back to Home';

  // ── Scan / Receive ──
  String get scanDevices => fr ? 'Recherche d\'appareils…' : 'Scanning for devices…';
  String get qrScanner => fr ? 'Scanner QR' : 'QR Scanner';
  String get receiveViaQr => fr ? 'Recevoir via QR' : 'Receive via QR';
  String get pointCamera => fr ? 'Pointez la caméra vers le QR code' : 'Point camera at QR code';
  String get startScan => fr ? 'Démarrer le scan' : 'Start scan';
  String get readyReceive => fr ? 'Prêt à recevoir' : 'Ready to receive';
  String get incomingTx => fr ? 'Transaction entrante' : 'Incoming transaction';
  String get acceptTransfer => fr ? 'Accepter le transfert' : 'Accept transfer';
  String get declineTransfer => fr ? 'Refuser' : 'Decline';

  // ── History ──
  String get all => fr ? 'Tout' : 'All';
  String get sent => fr ? 'Envoyé' : 'Sent';
  String get received => fr ? 'Reçu' : 'Received';
  String get pendingStr => fr ? 'En attente' : 'Pending';
  String get completed => fr ? 'Terminé' : 'Completed';
  String get history => fr ? 'Historique' : 'History';
  String get statusCompleted => fr ? 'TERMINÉ' : 'COMPLETED';
  String get statusSynced => fr ? 'SYNC' : 'SYNCED';
  String get statusPending => fr ? 'EN ATTENTE' : 'PENDING';
  String get statusFailed => fr ? 'ÉCHEC' : 'FAILED';

  // ── Settings ──
  String get settings => fr ? 'Paramètres' : 'Settings';
  String get account => fr ? 'COMPTE' : 'ACCOUNT';
  String get profile => fr ? 'Profil' : 'Profile';
  String get walletTier => fr ? 'Niveau' : 'Tier';
  String get keyMgmt => fr ? 'Clés cryptographiques' : 'Key management';
  String get preferences => fr ? 'PRÉFÉRENCES' : 'PREFERENCES';
  String get notifications => fr ? 'Notifications' : 'Notifications';
  String get biometric => fr ? 'Biométrie' : 'Biometric';
  String get darkMode => fr ? 'Mode sombre' : 'Dark mode';
  String get language => fr ? 'Langue' : 'Language';
  String get helpFaq => fr ? 'Aide & FAQ' : 'Help & FAQ';
  String get signOut => fr ? 'Déconnexion' : 'Sign out';
  String get signOutConfirm => fr
      ? 'Êtes-vous sûr de vouloir vous déconnecter ?'
      : 'Are you sure you want to sign out?';
  String get yes => fr ? 'Oui' : 'Yes';
  String get no => fr ? 'Non' : 'No';
  String get syncStatus => fr ? 'État de sync' : 'Sync status';
}