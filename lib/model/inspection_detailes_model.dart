import 'dart:convert';

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
          ? List<Media>.from(
          json['media'].map((item) => Media.fromJson(item)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'media': media.map((e) => e.toJson()).toList(),
    };
  }

  static List<Inspection> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List;
    return data.map((e) => Inspection.fromJson(e)).toList();
  }

  static String toJsonList(List<Inspection> inspections) {
    final data = inspections.map((e) => e.toJson()).toList();
    return json.encode(data);
  }
}

class Media {
  final String type;
  final String url;

  Media({
    required this.type,
    required this.url,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }
}
