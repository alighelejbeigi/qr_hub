enum QRCodeAction {
  createQRCode(1, 'Create QR Code'),
  scanQRCode(2, 'Scan QR Code');

  // Properties for id and title
  final int id;
  final String title;

  // Constructor for assigning the id and title
  const QRCodeAction(this.id, this.title);

  // Factory method to create an instance from a string value
  factory QRCodeAction.fromValue(String value) {
    return QRCodeAction.values.firstWhere(
          (action) => action.name == value,
      orElse: () => throw ArgumentError('Invalid value for QRCodeAction: $value'),
    );
  }

  // Factory method to create an instance from an id
  factory QRCodeAction.fromId(int id) {
    return QRCodeAction.values.firstWhere(
          (action) => action.id == id,
      orElse: () => throw ArgumentError('Invalid id for QRCodeAction: $id'),
    );
  }
}
