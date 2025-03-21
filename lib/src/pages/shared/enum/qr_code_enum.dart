enum QRCodeAction {
  createQRCode(1, 'Create QR Code'),
  scanQRCode(2, 'Scan QR Code');

  final int id;
  final String title;

  const QRCodeAction(this.id, this.title);

  factory QRCodeAction.fromValue(String value) {
    return QRCodeAction.values.firstWhere(
      (action) => action.name == value,
      orElse: () =>
          throw ArgumentError('Invalid value for QRCodeAction: $value'),
    );
  }

  factory QRCodeAction.fromId(int id) {
    return QRCodeAction.values.firstWhere(
      (action) => action.id == id,
      orElse: () => throw ArgumentError('Invalid id for QRCodeAction: $id'),
    );
  }
}
