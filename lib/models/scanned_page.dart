/// One hour row read off a scanned production book page.
///
/// [stationId] is null when the written style could not be matched confidently - the supervisor
/// picks it during review. [rawStyle] keeps what was actually written so a wrong match is
/// visible, and [note] carries anything the reading flagged as worth checking.
class ScannedRow {
  final int hour;
  int? stationId;
  String? stationName;
  final String? rawStyle;
  final bool carriedForward;
  List<int> pieces;
  final String? note;

  ScannedRow({
    required this.hour,
    this.stationId,
    this.stationName,
    this.rawStyle,
    this.carriedForward = false,
    List<int>? pieces,
    this.note,
  }) : pieces = pieces ?? [];

  factory ScannedRow.fromJson(Map<String, dynamic> json) => ScannedRow(
        hour: json['hour'] as int,
        stationId: json['stationId'] as int?,
        stationName: json['stationName'] as String?,
        rawStyle: json['rawStyle'] as String?,
        carriedForward: json['carriedForward'] as bool? ?? false,
        pieces: (json['pieces'] as List?)?.map((e) => e as int).toList() ?? [],
        note: json['note'] as String?,
      );

  /// A row the supervisor must resolve before it can be saved.
  bool get needsAttention => stationId == null || note != null;

  /// A row with no station or no counts contributes nothing and is skipped on save.
  bool get isSaveable => stationId != null && pieces.isNotEmpty;

  int get totalPieces => pieces.fold(0, (sum, p) => sum + p);

  Map<String, dynamic> toConfirmJson() => {
        'hour': hour,
        'stationId': stationId,
        'pieces': pieces,
      };
}

/// The draft reading of a page, before anything is written to the production log.
class ScannedPage {
  final int employeeId;
  final String employeeName;
  String? shiftDate;
  final String? rawDate;
  final String? dateWarning;
  final List<ScannedRow> rows;

  ScannedPage({
    required this.employeeId,
    required this.employeeName,
    this.shiftDate,
    this.rawDate,
    this.dateWarning,
    required this.rows,
  });

  factory ScannedPage.fromJson(Map<String, dynamic> json) => ScannedPage(
        employeeId: json['employeeId'] as int,
        employeeName: json['employeeName'] as String,
        shiftDate: json['shiftDate'] as String?,
        rawDate: json['rawDate'] as String?,
        dateWarning: json['dateWarning'] as String?,
        rows: (json['rows'] as List? ?? [])
            .map((e) => ScannedRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  int get attentionCount => rows.where((r) => r.needsAttention).length;
  int get saveableCount => rows.where((r) => r.isSaveable).length;
  int get totalPieces => rows.where((r) => r.isSaveable).fold(0, (s, r) => s + r.totalPieces);

  /// Entries created on save - one per count, since an hour can hold several.
  int get entryCount =>
      rows.where((r) => r.isSaveable).fold(0, (sum, r) => sum + r.pieces.length);
}
