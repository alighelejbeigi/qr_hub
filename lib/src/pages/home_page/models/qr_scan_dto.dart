class QrScan {
  final String id;
  final String text;
  final DateTime date;
  final String userId;
  final String? photoUrl;
  final String? fileId;

  QrScan({
    required this.id,
    required this.text,
    required this.date,
    required this.userId,
    this.photoUrl,
    this.fileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
      'userId': userId,
      'photoUrl': photoUrl,
      'fileId': fileId,
    };
  }

  factory QrScan.fromJson(Map<String, dynamic> json) {
    return QrScan(
      id: json['\$id'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      userId: json['userId'],
      photoUrl: json['photoUrl'],
      fileId: json['fileId'],
    );
  }
}
