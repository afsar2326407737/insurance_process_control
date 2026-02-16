import 'dart:convert';
import 'dart:developer';
import 'package:cbl/cbl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:i_p_c/repository/couchbase_helper.dart';
import '../model/bank_det_models.dart';
import '../model/inspection_detailes_model.dart';
import '../model/page_inspection_model.dart';
import '../model/support_request_model.dart';

class CouchbaseServices {
  /// store the value in the database
  Future<void> storePaginatedJsonData() async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;

    /// get the total pages from the json file
    final jsonInitialString = await rootBundle.loadString(
      'assets/data/page_1.json',
    );
    final jsonInitialData = json.decode(jsonInitialString);
    final int totalPages = jsonInitialData['total_pages'];

    for (int page = 1; page <= totalPages; page++) {
      ///take the json data from the assets folder
      final jsonString = await rootBundle.loadString(
        'assets/data/page_$page.json',
      );
      final jsonData = json.decode(jsonString);

      /// get the data
      final int currentPage = jsonData['page'];
      final int perPage = jsonData['per_page'];
      final int total = jsonData['total'];
      final int totalPages = jsonData['total_pages'];

      /// Save page-level metadata as a separate document
      final pageMetaDoc = MutableDocument({
        'type': 'page_metadata',
        'page': currentPage,
        'per_page': perPage,
        'total': total,
        'total_pages': totalPages,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await collection.saveDocument(pageMetaDoc);

      /// Save inspection records individually, but link them to the page
      for (var item in jsonData['data']) {
        final doc = MutableDocument({
          ...Map<String, Object?>.from(item),
          'type': 'inspection',
          'page': currentPage,
        });

        await collection.saveDocument(doc);
      }
    }
  }

  Future<void> storeBankDetails() async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;
    final jsonString = await rootBundle.loadString(
      'assets/bank_data/bank_details.json',
    );
    final jsonData = json.decode(jsonString);
    final bankDet = BankDet.fromJson(jsonData);
    for (var bank in bankDet.banks ?? []) {
      final doc = MutableDocument({
        'type': 'bank',
        'bank_id': bank.bankId,
        'bank_name': bank.bankName,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await collection.saveDocument(doc);
    }
    if (kDebugMode) {
      log(
        "Bank details stored successfully in Couchbase Lite",
        name: 'CouchbaseServices',
      );
    }
  }

  Future<BankDet> getBankDetails() async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;

    final query = QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.collection(collection))
        .where(Expression.property('type').equalTo(Expression.string('bank')));

    final result = await query.execute();
    final List<Banks> banks = [];

    await for (final row in result.asStream()) {
      final docData = row.dictionary(collection.name)?.toPlainMap();
      if (docData != null) {
        banks.add(
          Banks(
            bankId: docData['bank_id'] as String?,
            bankName: docData['bank_name'] as String?,
          ),
        );
      }
    }
    log(
      "Fetched ${banks.length} banks from Couchbase Lite",
      name: 'CouchbaseServices',
    );
    return BankDet(banks: banks);
  }

  Future<List<Map<String, Object?>>> getAllInspections() async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;

    final query = const QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.collection(collection))
        .where(
          Expression.property('type').equalTo(Expression.string('inspection')),
        );

    final resultSet = await query.execute();
    final result =
        (await resultSet.allResults()).map((r) => r.toPlainMap()).toList();
    return result;
  }

  Future<List<Map<String, Object?>>> getInspectionsByPage(int page) async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;

    final query = const QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.collection(collection))
        .where(
          Expression.property('type')
              .equalTo(Expression.string('inspection'))
              .and(Expression.property('page').equalTo(Expression.value(page))),
        );

    final resultSet = await query.execute();
    final result =
        (await resultSet.allResults()).map((r) => r.toPlainMap()).toList();
    return result;
  }

  /// fetch the data using the pagination concepts
  Future<PaginatedInspections> fetchInspections({required int page}) async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;
    final query = QueryBuilder()
        .select(SelectResult.expression(Meta.id), SelectResult.all())
        .from(DataSource.collection(collection))
        .where(
          Expression.property('type')
              .equalTo(Expression.string('inspection'))
              .and(
                Expression.property('page').equalTo(Expression.integer(page)),
              ),
        );

    final resultSet = await query.execute();

    ///changer the query result as the inspection model.
    final inspections = <Inspection>[];
    final results = await resultSet.allResults();
    for (final result in results) {
      final map = result.toPlainMap();

      final data = map[collection.name];
      if (data is Map<String, Object?>) {
        inspections.add(Inspection.fromJson(data));
      } else {
        log(
          'Skipped: not a Map → ${result.length} | data: $data',
          name: 'Each Result',
        );
      }
    }

    final metaQuery = QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.collection(collection))
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
      final metaData = map[collection.name];
      if (metaData is Map<String, Object?>) {
        totalPages = metaData['total_pages'] as int? ?? 1;
      }
    }

    log('Total Pages $totalPages', name: 'CouchbaseServices');
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
    final db_collection = await db.defaultCollection;

    final List<ExpressionInterface> conditions = [];

    conditions.add(
      Expression.property('type').equalTo(Expression.string('inspection')),
    );

    //for Search query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      final pattern = '%$lowerQuery%';

      final inspectionIdExp = Function_.lower(
        Expression.property('inspection_id'),
      ).like(Expression.string(pattern));

      final propertyNameExp = Function_.lower(
        Expression.property('property_name'),
      ).like(Expression.string(pattern));

      final addressExp = Function_.lower(
        Expression.property('address'),
      ).like(Expression.string(pattern));

      conditions.add(inspectionIdExp.or(propertyNameExp).or(addressExp));
    }

    //status filter
    if (status != null && status.isNotEmpty) {
      conditions.add(
        Expression.property(
          'status',
        ).equalTo(Expression.string(status.toLowerCase())),
      );
    }

    //priority filter
    if (priority != null && priority.isNotEmpty) {
      conditions.add(
        Expression.property('priority').equalTo(Expression.string(priority)),
      );
    }

    //Type filter
    if (type != null && type.isNotEmpty) {
      conditions.add(
        Expression.property('inspection_type').equalTo(Expression.string(type)),
      );
    }

    //combain all conditions with AND
    ExpressionInterface whereClause = conditions.first;
    for (int i = 1; i < conditions.length; i++) {
      whereClause = whereClause.and(conditions[i]);
    }

    final queryBuilder = QueryBuilder()
        .select(SelectResult.all())
        .from(DataSource.collection(db_collection))
        .where(whereClause);

    final resultSet = await queryBuilder.execute();
    final result = await resultSet.allResults();

    return result.map((r) => r.toPlainMap()).toList();
  }

  /// add new inspection data
  Future<void> addInspectionToLastPage(
    Map<String, Object?> newInspection,
  ) async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;

    final metaQueryWithId = QueryBuilder()
        .select(SelectResult.expression(Meta.id), SelectResult.all())
        .from(DataSource.collection(collection))
        .where(
          Expression.property(
            'type',
          ).equalTo(Expression.string('page_metadata')),
        );

    final metaResults = await (await metaQueryWithId.execute()).allResults();

    int lastPage = 1;
    int perPage = 5;

    ///to get the last page and per page from the last meta data
    if (metaResults.isNotEmpty) {
      final lastMetaMap =
          metaResults.last.toPlainMap()[collection.name]
              as Map<String, Object?>?;
      if (lastMetaMap != null) {
        lastPage = lastMetaMap['page'] as int? ?? 1;
        perPage = lastMetaMap['per_page'] as int? ?? 5;
      }
    }

    /// count no of inspections in the last page
    final countQuery = QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.collection(collection))
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

    /// create new page if last page is full
    if (count >= perPage) {
      targetPage = lastPage + 1;
      final newMetaDoc = MutableDocument({
        'type': 'page_metadata',
        'page': targetPage,
        'per_page': perPage,
        'total': 0,
        'total_pages': targetPage,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await collection.saveDocument(newMetaDoc);
    }

    /// Update total_pages in all existing page_metadata documents
    for (final meta in metaResults) {
      final map = meta.toPlainMap();
      final docId = map['id'];
      if (docId is String) {
        final existingDoc = await collection.document(docId);
        if (existingDoc != null) {
          final mutable = existingDoc.toMutable();
          mutable.setInteger(key: 'total_pages', targetPage);
          mutable.setString(key: 'timestamp', DateTime.now().toIso8601String());
          await collection.saveDocument(mutable);
        } else {
          log(
            'Could not find document with ID: $docId',
            name: 'CouchbaseServices',
          );
        }
      }
    }

    /// Save the new inspection document
    final newInspectionDoc = MutableDocument({
      ...newInspection,
      'type': 'inspection',
      'page': targetPage,
    });

    await collection.saveDocument(newInspectionDoc);
    log('New inspection Added to page $targetPage', name: 'CouchbaseServices');
  }

  /// test function to print the meta result
  Future<void> printMetaResult() async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;
    final countQuery = QueryBuilder()
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.collection(collection))
        .where(
          Expression.property('type')
              .equalTo(Expression.string('inspection'))
              .and(Expression.property('page').equalTo(Expression.integer(2))),
        );
    final count = (await (await countQuery.execute()).allResults()).length;
    // print what is the data present in the meta
    log(count.toString(), name: 'Meta Results');
  }

  /// upload report data Take option
  Future<bool> uploadReportData(
    Map<String, Object?> reportData,
    String inspectionId,
  ) async {
    final db = CouchbaseHelper.db;
    final collection = await db.defaultCollection;
    try {
      final query = const QueryBuilder()
          .select(SelectResult.expression(Meta.id), SelectResult.all())
          .from(DataSource.collection(collection))
          .where(
            Expression.property('type')
                .equalTo(Expression.string('inspection'))
                .and(
                  Expression.property(
                    'inspection_id',
                  ).equalTo(Expression.string(inspectionId)),
                ),
          );
      final resultSet = await query.execute();
      final results = await resultSet.allResults();

      if (results.isEmpty) {
        log(
          'No inspection found with ID: $inspectionId',
          name: 'Couchbase Services',
        );
        return false;
      }

      final result = results.first;
      final docId = result.toPlainMap()['id'];
      final inspectionData =
          result.toPlainMap()[collection.name] as Map<String, Object?>?;

      ///debugging print
      log('Found document id: $docId', name: 'Couchbase Services');
      log(
        'Existing inspection data: $inspectionData',
        name: 'Couchbase Services',
      );

      /// new completion status
      final Map<String, Object?> completionEntry = {
        'employee_id': reportData['employee_id'],
        'proof_media': reportData['proof_media'],
        'signature': reportData['signature'],
        'created_at': reportData['created_at'],
      };
      inspectionData!['completion_status'] = completionEntry;
      inspectionData['status'] = reportData['status'] ?? 'Completed';
      inspectionData['last_updated'] = DateTime.now().toIso8601String();

      final mutableDoc = MutableDocument.withId(
        docId.toString(),
        inspectionData,
      );
      await collection.saveDocument(mutableDoc);

      final updated = await collection.document(docId.toString());
      log(
        'Updated inspection data: ${updated?.toPlainMap()}',
        name: 'Couchbase Services',
      );
      return true;
    } catch (e, st) {
      log('Error updating inspection: $e', name: 'Couchbase Services');
      log(st.toString(), name: 'StackTrace');
      return false;
    }
  }

  ///to check the inspection id exist or not
  Future<bool> doesInspectionIdExist(String inspectionId) async {
    try {
      final db = CouchbaseHelper.db;
      final collection = await db.defaultCollection;

      final query = const QueryBuilder()
          .select(SelectResult.expression(Meta.id))
          .from(DataSource.collection(collection))
          .where(
            Expression.property('type')
                .equalTo(Expression.string('inspection'))
                .and(
                  Expression.property(
                    'inspection_id',
                  ).equalTo(Expression.string(inspectionId)),
                ),
          );

      final resultSet = await query.execute();
      final results = await resultSet.allResults();
      log(
        'Inspection ID $inspectionId exists: ${results.isNotEmpty}',
        name: 'CouchbaseServices',
      );
      return results.isNotEmpty;
    } catch (e) {
      log(
        'Error checking inspection ID existence: $e',
        name: 'CouchbaseServices',
      );
      return false;
    }
  }

  /// delete the inspections
  Future<String?> deleteInspectionById(String inspectionId) async {
    try {
      final db = CouchbaseHelper.db;
      final collection = await db.defaultCollection;
      final query = const QueryBuilder()
          .select(SelectResult.expression(Meta.id))
          .from(DataSource.collection(collection))
          .where(
            Expression.property('type')
                .equalTo(Expression.string('inspection'))
                .and(
                  Expression.property(
                    'inspection_id',
                  ).equalTo(Expression.string(inspectionId)),
                ),
          );

      final resultSet = await query.execute();
      final results = await resultSet.allResults();

      if (results.isEmpty) {
        log(
          'No inspection found with ID: $inspectionId',
          name: 'CouchbaseServices',
        );
        return null;
      }

      final docId = results.first.toPlainMap()['id'] as String;

      final doc = await collection.document(docId);

      if (doc != null) {
        await collection.deleteDocument(doc);
        log(
          'Inspection with ID $inspectionId deleted successfully.',
          name: 'CouchbaseServices',
        );
        return inspectionId;
      } else {
        log(
          'Document not found in DB for ID: $inspectionId',
          name: 'CouchbaseServices',
        );
        return null;
      }
    } catch (e) {
      log('Error deleting inspection: $e', name: 'CouchbaseServices');
      return null;
    }
  }

  Future<int> countNewPolicyInspections() async {
    try {
      final db = CouchbaseHelper.db;
      final collections = await db.defaultCollection;

      final query = QueryBuilder()
          .select(
            SelectResult.expression(
              Function_.count(Expression.string('*')),
            ).as('totalCount'),
          )
          .from(DataSource.collection(collections))
          .where(
            Expression.property('type')
                .equalTo(Expression.string('inspection'))
                .and(
                  Expression.property(
                    'inspection_type',
                  ).equalTo(Expression.string('New Policy')),
                ),
          );
      final resultSet = await query.execute();
      final results = await resultSet.allResults();

      if (results.isNotEmpty) {
        final count = results.first.toPlainMap()['totalCount'] as int? ?? 0;
        log('Total New Policy inspections: $count', name: 'CouchbaseServices');
        return count;
      }
    } catch (e, st) {
      log('Error counting inspections: $e', name: 'CouchbaseServices');
      log(st.toString(), name: 'StackTrace');
    }

    return 0;
  }

  Future<int> countHighPriorityInspections() async {
    try {
      final db = CouchbaseHelper.db;
      final collections = await db.defaultCollection;

      final whereClass = Expression.property('type')
          .equalTo(Expression.string('inspection'))
          .and(
            Expression.property('priority').equalTo(Expression.string('High')),
          );

      final query = QueryBuilder()
          .select(
            SelectResult.expression(
              Function_.count(Expression.string('*')),
            ).as('totalCount'),
          )
          .from(DataSource.collection(collections))
          .where(whereClass);

      final resultSet = await query.execute();
      final results = await resultSet.allResults();

      if (results.isNotEmpty) {
        final count = results.first.toPlainMap()['totalCount'] as int? ?? 0;

        return count;
      }
    } catch (e, st) {
      log('Error counting inspections: $e', name: 'CouchbaseServices');
      log(st.toString(), name: 'StackTrace');
    }
    return 0;
  }

  /// store the inspection support request
  Future<bool> storeSupportReport(String employeeId, String message) async {
    try {
      final db = CouchbaseHelper.db;
      final collection = await db.defaultCollection;
      final doc = MutableDocument({
        'type': 'support_request',
        'employee_id': employeeId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await collection.saveDocument(doc);
      log('Message stored successfully for employee: $employeeId');
      return true;
    } catch (e) {
      log('Error storing message: $e');
      return false;
    }
  }

  /// get all the support requests
  Future<List<SupportRequest>> getAllSupportRequests() async {
    try {
      final db = CouchbaseHelper.db;
      final collections = await db.defaultCollection;

      final whereClass = Expression.property(
        'type',
      ).equalTo(Expression.string('support_request'));

      final query = QueryBuilder()
          .select(
            SelectResult.expression(Expression.property('employee_id')),
            SelectResult.expression(Expression.property('message')),
            SelectResult.expression(Expression.property('timestamp')),
          )
          .from(DataSource.collection(collections))
          .where(whereClass)
          .orderBy(Ordering.property('timestamp').descending());

      final resultSet = await query.execute();
      final results = await resultSet.allResults();

      final requests =
          results.map((result) {
            final map = result.toPlainMap();
            return SupportRequest.fromMap(map);
          }).toList();

      log(
        '✅ Retrieved ${requests.length} support requests',
        name: 'SupportRepository',
      );
      return requests;
    } catch (e) {
      log('❌ Error fetching support requests: $e', name: 'SupportRepository');
      return [];
    }
  }
}
