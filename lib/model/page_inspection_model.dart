import 'inspection_detailes_model.dart';

class PaginatedInspections {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<Inspection> inspections;

  PaginatedInspections({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.inspections,
  });

  factory PaginatedInspections.fromJson(Map<String, dynamic> json) {
    return PaginatedInspections(
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      inspections: (json['data'] as List<dynamic>)
          .map((e) => Inspection.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
      'data': inspections.map((e) => e.toJson()).toList(),
    };
  }
}
