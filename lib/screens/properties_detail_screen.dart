import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/utils/button_fun.dart';
import 'package:i_p_c/utils/image_dialog.dart';
import 'package:i_p_c/utils/report_dialogbox.dart';
import '../model/inspection_detailes_model.dart';
import '../utils/image_showing_utils.dart';
import '../utils/info_row.dart';

class InspectionDetailsScreen extends StatelessWidget {
  final Inspection inspection;
  final String heroTag;

  const InspectionDetailsScreen({
    super.key,
    required this.inspection,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final media = inspection.media;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: BackButton(
                color: Colors.black,
              ),
            ),
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                inspection.propertyName.isEmpty
                    ? 'Inspection'
                    : inspection.propertyName,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium!.copyWith(color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ImageShowingUtils().buildMediaPreview(
                    inspection.media.first.url,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black26,
                            Colors.black38,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inspection.propertyName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          inspection.address,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (inspection.inspectionType.isNotEmpty)
                        Chip(label: Text(inspection.inspectionType)),
                      if (inspection.status.isNotEmpty)
                        Chip(label: Text(inspection.status)),
                      if (inspection.priority.isNotEmpty)
                        Chip(label: Text('Priority: ${inspection.priority}')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Key info rows
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.today_outlined,
                    title: 'Assigned',
                    value: inspection.assignedDate,
                  ),
                  InfoRow(
                    icon: Icons.event_outlined,
                    title: 'Due',
                    value: inspection.dueDate,
                  ),
                  InfoRow(
                    icon: Icons.sync_outlined,
                    title: 'Sync Status',
                    value: inspection.syncStatus,
                  ),
                  InfoRow(
                    icon: Icons.update,
                    title: 'Last Updated',
                    value: inspection.lastUpdated.isEmpty
                        ? 'Recently updated'
                        : inspection.lastUpdated,
                  ),
                ],
              ),
            ),
          ),

          /// Media grid (SliverGrid)
          if (media.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final m = media[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: m.url.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => ImageDialog(imageUrl: m.url),
                              );
                            },
                            child: ImageShowingUtils().buildMediaPreview(m.url),
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.photo_outlined,
                              color: Colors.grey,
                            ),
                          ),
                  );
                }, childCount: media.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0 , left: 16.0 , right: 16.0),
              child: inspection.completionStatus != null
                  ? ButtonsFun(() {
                showDialog(
                  context: context,
                  builder: (context) => ReportDialog(
                    employeeId: inspection.completionStatus?.employeeId ?? '',
                    createdAt: inspection.completionStatus?.createdAt ?? '',
                    mediaPaths:
                    inspection.completionStatus?.proofMedia ?? const [],
                    signature:
                    inspection.completionStatus?.signature ?? Uint8List(0),
                  ),
                );
              }, 'View Report')
                  : ButtonsFun(() {
                context.push('/uploadreport', extra: inspection.inspectionId);
              }, 'Take'),
            ),
          )
        ],
      ),
    );
  }
}
