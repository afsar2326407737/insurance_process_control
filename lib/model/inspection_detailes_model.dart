import 'dart:convert';
import 'dart:typed_data';

class Inspection {
  final String inspectionId;
  final String propertyName;
  final String address;
  final String inspectionType;
  final String status;
  final String assignedDate;
  final String dueDate;
  final String priority;
  final String lastUpdated;
  final String syncStatus;
  final List<Media> media;
  final CompletionStatus? completionStatus;

  Inspection({
    required this.inspectionId,
    required this.propertyName,
    required this.address,
    required this.inspectionType,
    required this.status,
    required this.assignedDate,
    required this.dueDate,
    required this.priority,
    required this.lastUpdated,
    required this.syncStatus,
    required this.media,
    this.completionStatus,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      inspectionId: json['inspection_id'] ?? '',
      propertyName: json['property_name'] ?? '',
      address: json['address'] ?? '',
      inspectionType: json['inspection_type'] ?? '',
      status: json['status'] ?? '',
      assignedDate: json['assigned_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      priority: json['priority'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      syncStatus: json['sync_status'] ?? '',
      media: json['media'] != null
          ? List<Media>.from(json['media'].map((item) => Media.fromJson(item)))
          : [],
      completionStatus: json['completion_status'] != null
          ? CompletionStatus.fromJson(json['completion_status'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'inspection_id': inspectionId,
    'property_name': propertyName,
    'address': address,
    'inspection_type': inspectionType,
    'status': status,
    'assigned_date': assignedDate,
    'due_date': dueDate,
    'priority': priority,
    'last_updated': lastUpdated,
    'sync_status': syncStatus,
    'media': media.map((m) => m.toMap()).toList(),
  };

  static List<Inspection> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List;
    return data.map((e) => Inspection.fromJson(e)).toList();
  }

  static String toJsonList(List<Inspection> inspections) {
    final data = inspections.map((e) => e.toMap()).toList();
    return json.encode(data);
  }
}

class Media {
  final String type;
  final String url;

  Media({required this.type, required this.url});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(type: json['type'] ?? '', url: json['url'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'type': type, 'url': url};
  }
}

class CompletionStatus {
  final String? employeeId;
  final Uint8List? signature;
  final String? createdAt;
  final List<String>? proofMedia;

  CompletionStatus({
    this.employeeId,
    this.signature,
    this.createdAt,
    this.proofMedia,
  });

  factory CompletionStatus.fromJson(Map<String, dynamic> json) {
    return CompletionStatus(
      employeeId: json['employee_id'],
      signature: json['signature'] != null
          ? Uint8List.fromList(List<int>.from(json['signature']))
          : null,
      createdAt: json['created_at'],
      proofMedia: json['proof_media'] != null
          ? List<String>.from(json['proof_media'].map((e) => e.toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    if (employeeId != null) 'employee_id': employeeId,
    if (proofMedia != null) 'proof_media': proofMedia,
    if (signature != null) 'signature': signature!.toList(),
    if (createdAt != null) 'created_at': createdAt,
  };
}
