class QrGenerate {
  final String id;
  final String text;
  final DateTime date;
  final String userId;
  final String qrImageUrl;
  final String fileId;

  QrGenerate({
    required this.id,
    required this.text,
    required this.date,
    required this.userId,
    required this.qrImageUrl,
    required this.fileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
      'userId': userId,
      'qrImageUrl': qrImageUrl,
      'fileId': fileId,
    };
  }

  factory QrGenerate.fromJson(Map<String, dynamic> json) {
    return QrGenerate(
      id: json['\$id'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      userId: json['userId'],
      qrImageUrl: json['qrImageUrl'],
      fileId: json['fileId'],
    );
  }
}
