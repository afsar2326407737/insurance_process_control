import 'dart:convert';
import 'dart:developer';

import 'package:cbl/cbl.dart';
import 'package:flutter/services.dart';
import 'package:i_p_c/repository/couchbase_helper.dart';

import '../model/inspection_detailes_model.dart';
import '../model/page_inspection_model.dart';

class CouchbaseServices {
  // store the value in the database

  Future<void> storePaginatedJsonData() async {
    final db = CouchbaseHelper.db;
    // get the total pages from the json file
    final jsonInitialString = await rootBundle.loadString(
      'assets/data/page_1.json',
    );
    final jsonInitialData = json.decode(jsonInitialString);
    final int totalPages = jsonInitialData['total_pages'];

    for (int page = 1; page <= totalPages; page++) {
      //take the json data from the assets folder
      final jsonString = await rootBundle.loadString(
        'assets/data/page_$page.json',
      );
      final jsonData = json.decode(jsonString);

      // get the data
      final int currentPage = jsonData['page'];
      final int perPage = jsonData['per_page'];
      final int total = jsonData['total'];
      final int totalPages = jsonData['total_pages'];

      // Save page-level metadata as a separate document
      final pageMetaDoc = MutableDocument({
        'type': 'page_metadata',
        'page': currentPage,
        'per_page': perPage,
        'total': total,
        'total_pages': totalPages,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await db.saveDocument(pageMetaDoc);

      // Save inspection records individually, but link them to the page
      for (var item in jsonData['data']) {
        final doc = MutableDocument({
          ...Map<String, Object?>.from(item),
          'type': 'inspection',
          'page': currentPage,
        });

        await db.saveDocument(doc);
      }
    }
  }

  Future<List<Map<String, Object?>>> getAllInspections() async {
    final db = CouchbaseHelper.db;

    final query = const QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .where(
          Expression.property('type').equalTo(Expression.string('inspection')),
        );

    final resultSet = await query.execute();
    final result = await (await resultSet.allResults())
        .map((r) => r.toPlainMap())
        .toList();
    return result;
  }

  Future<List<Map<String, Object?>>> getInspectionsByPage(int page) async {
    final db = CouchbaseHelper.db;

    final query = const QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .where(
          Expression.property('type')
              .equalTo(Expression.string('inspection'))
              .and(Expression.property('page').equalTo(Expression.value(page))),
        );

    final resultSet = await query.execute();
    final result = (await resultSet.allResults())
        .map((r) => r.toPlainMap())
        .toList();
    return result;
  }

  // fetch the data using the pagination concepts
  Future<PaginatedInspections> fetchInspections({required int page}) async {
    final db = CouchbaseHelper.db;
    final query = await QueryBuilder()
        .select(SelectResult.expression(Meta.id), SelectResult.all())
        .from(DataSource.database(db))
        .where(
          Expression.property('type')
              .equalTo(Expression.string('inspection'))
              .and(
                Expression.property('page').equalTo(Expression.integer(page)),
              ),
        );

    final resultSet = await query.execute();
    //changer the query result as the inspection model.
    final inspections = <Inspection>[];
    final results = await resultSet.allResults();
    for (final result in results) {
      final map = result.toPlainMap();

      final data = map['inspections_db'];
      if (data is Map<String, Object?>) {
        inspections.add(Inspection.fromJson(data));
      } else {
        log(
          'Skipped: not a Map → ${result.length} | data: $data',
          name: 'Each Result',
        );
      }
    }

    final metaQuery = await QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .where(
          Expression.property('type')
              .equalTo(Expression.string('page_metadata'))
              .and(
                Expression.property('page').equalTo(Expression.integer(page)),
              ),
        );

    final metaResultSet = await metaQuery.execute();

    int totalPages = 1;
    final metaResults = await metaResultSet.allResults();
    for (final meta in metaResults) {
      final map = meta.toPlainMap();
      final metaData = map['inspections_db'];
      if (metaData is Map<String, Object?>) {
        totalPages = metaData['total_pages'] as int? ?? 1;
      }
    }

    return PaginatedInspections(
      inspections: inspections,
      page: page,
      totalPages: totalPages,
    );
  }

  Future<List<Map<String, Object?>>> queryInspections({
    String? query,
    String? status,
    String? priority,
    String? type,
  }) async {
    final db = CouchbaseHelper.db;

    final lowerQuery = query?.toLowerCase() ?? '';

    final buffer = StringBuffer('''
        SELECT *
        FROM _
        WHERE type = 'inspection'
  ''');

    if (query != null && query.isNotEmpty) {
      buffer.write('''
      AND (
        LOWER(inspection_id) LIKE '%$lowerQuery%'
        OR LOWER(property_name) LIKE '%$lowerQuery%'
        OR LOWER(address) LIKE '%$lowerQuery%'
      )
    ''');
    }

    if (status != null && status.isNotEmpty) {
      buffer.write(" AND status = '$status'");
    }

    if (priority != null && priority.isNotEmpty) {
      buffer.write(" AND priority = '$priority'");
    }

    if (type != null && type.isNotEmpty) {
      buffer.write(" AND inspection_type = '$type'");
    }

    final queryStr = buffer.toString();

    final queryObj = await db.createQuery(queryStr);
    final resultSet = await queryObj.execute();
    final results = await resultSet.allResults();
    return results.map((r) => r.toPlainMap()).toList();
  }

  // add new data
  Future<void> addInspectionToLastPage(
    Map<String, Object?> newInspection,
  ) async {
    final db = CouchbaseHelper.db;

    // Get last page metadata
    final metaQuery = await QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .where(
          Expression.property(
            'type',
          ).equalTo(Expression.string('page_metadata')),
        );
    final metaResults = await (await metaQuery.execute()).allResults();

    int lastPage = 1;
    int perPage = 5;

    if (metaResults.isNotEmpty) {

      final lastMeta =
          metaResults.last.toPlainMap()['inspections_db']
              as Map<String, Object?>?;
      if (lastMeta != null) {
        lastPage = lastMeta['page'] as int? ?? 1;
        perPage = lastMeta['per_page'] as int? ?? 5;
      }
    }

    // Count inspections in last page
    final countQuery = await QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.database(db))
        .where(
          Expression.property('type')
              .equalTo(Expression.string('inspection'))
              .and(
                Expression.property(
                  'page',
                ).equalTo(Expression.integer(lastPage)),
              ),
        );
    final count = (await (await countQuery.execute()).allResults()).length;

    int targetPage = lastPage;
    if (count >= perPage) {
      // Need new page
      targetPage = lastPage + 1;
      // Create new page metadata
      final newMetaDoc = MutableDocument({
        'type': 'page_metadata',
        'page': targetPage,
        'per_page': perPage,
        'total': 0,
        'total_pages': targetPage,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await db.saveDocument(newMetaDoc);
    }

    // Add inspection to target page
    final doc = MutableDocument({
      ...newInspection,
      'type': 'inspection',
      'page': targetPage,
    });
    await db.saveDocument(doc);
  }

  // test function
  Future<void> printMetaResult() async {
    final db = CouchbaseHelper.db;
    final countQuery = await QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.database(db))
        .where(
      Expression.property('type')
          .equalTo(Expression.string('inspection'))
          .and(Expression.property('page')
          .equalTo(Expression.integer(2))),
    );
    final count = (await (await countQuery.execute()).allResults()).length;
    // print what is the data present in the meta
    log(count.toString(), name: 'Meta Results');
  }
}
