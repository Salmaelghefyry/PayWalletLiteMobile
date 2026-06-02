enum WalletTier    { basic, silver, gold }
enum TokenStatus   { active, spent, expired, revoked }
enum TxStatus      { pending, completed, synced, failed }
enum TxMethod      { nfc, ble, qr }

class UserEntity {
  final String id, firstName, lastName, phone, email;
  const UserEntity({required this.id, required this.firstName, required this.lastName, required this.phone, required this.email});
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
}

class WalletEntity {
  final String id, currency;
  final WalletTier tier;
  final double balance, dailyLimit, monthlyLimit, maxTx;
  final int tokenCount;
  final bool isSynced;
  const WalletEntity({required this.id, required this.currency, required this.tier, required this.balance, required this.dailyLimit, required this.monthlyLimit, required this.maxTx, required this.tokenCount, this.isSynced = false});
  String get tierName => tier.name.toUpperCase();
}

class TokenEntity {
  final String id, currency;
  final double value;
  final TokenStatus status;
  final DateTime expiresAt;
  const TokenEntity({required this.id, required this.currency, required this.value, required this.status, required this.expiresAt});
  String get shortId => 'PW-2026-${id.substring(0, 8).toUpperCase()}';
  bool get isActive  => status == TokenStatus.active && expiresAt.isAfter(DateTime.now());
}

class TxEntity {
  final String id, fromName, toName, currency;
  final double amount;
  final TxMethod method;
  final TxStatus status;
  final DateTime date;
  final bool isSent;
  const TxEntity({required this.id, required this.fromName, required this.toName, required this.currency, required this.amount, required this.method, required this.status, required this.date, required this.isSent});
  String get shortId => id.substring(0, 8).toUpperCase();
}
