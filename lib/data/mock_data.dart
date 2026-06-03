import '../domain/entities/entities.dart';

class Mock {
  Mock._();

  static const user = UserEntity(
    id: 'usr-001', firstName: 'Amara', lastName: 'Diallo',
    phone: '+221 77 123 4567', email: 'amara@example.com',
  );

  static const wallet = WalletEntity(
    id: 'wlt-001', currency: 'MAD', tier: WalletTier.silver,
    balance: 850, dailyLimit: 2000, monthlyLimit: 10000, maxTx: 500,
    tokenCount: 3, isSynced: false,
  );

  static final tokens = [
    TokenEntity(id: 'a1b2c3d4e5f6g7h8', currency: 'MAD', value: 100, status: TokenStatus.active,  expiresAt: DateTime(2026, 8, 20)),
    TokenEntity(id: 'e5f6g7h8i9j0k1l2', currency: 'MAD', value: 250, status: TokenStatus.active,  expiresAt: DateTime(2026, 8, 20)),
    TokenEntity(id: 'i9j0k1l2m3n4o5p6', currency: 'MAD', value: 500, status: TokenStatus.active,  expiresAt: DateTime(2026, 8, 20)),
    TokenEntity(id: 'm3n4o5p6q7r8s9t0', currency: 'MAD', value: 50,  status: TokenStatus.spent,   expiresAt: DateTime(2026, 6, 25)),
    TokenEntity(id: 'q7r8s9t0u1v2w3x4', currency: 'MAD', value: 200, status: TokenStatus.active,  expiresAt: DateTime(2026, 8, 30)),
  ];

  static final transactions = [
    TxEntity(id: 'tx001aabbccdd', fromName: 'Amara Diallo',  toName: 'Kwame Asante',  currency: 'MAD', amount: 250, method: TxMethod.qr,  status: TxStatus.completed, date: DateTime(2026, 3, 31), isSent: true),
    TxEntity(id: 'tx002eeffgghh', fromName: 'Fatima Ndiaye', toName: 'Amara Diallo',  currency: 'MAD', amount: 500, method: TxMethod.ble, status: TxStatus.synced,    date: DateTime(2026, 3, 30), isSent: false),
    TxEntity(id: 'tx003iijjkkll', fromName: 'Amara Diallo',  toName: 'Oumar Bah',     currency: 'MAD', amount: 100, method: TxMethod.qr,  status: TxStatus.pending,   date: DateTime(2026, 4, 1),  isSent: true),
    TxEntity(id: 'tx004mmnnoopp', fromName: 'Amara Diallo',  toName: 'Aya Traoré',    currency: 'MAD', amount: 200, method: TxMethod.qr,  status: TxStatus.completed, date: DateTime(2026, 3, 30), isSent: true),
    TxEntity(id: 'tx005qqrrsstt', fromName: 'Moussa Koné',   toName: 'Amara Diallo',  currency: 'MAD', amount: 750, method: TxMethod.nfc, status: TxStatus.synced,    date: DateTime(2026, 3, 28), isSent: false),
  ];
}
