// dart
import 'package:flutter/material.dart';
import 'package:i_p_c/utils/button_fun.dart';
import '../model/inspection_detailes_model.dart';
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
    final headerUrl = media.isNotEmpty ? media.first.url : '';

    // to set the image with the animation
    Widget headerImage() {
      final image = headerUrl.isNotEmpty
          ? Image.network(
              headerUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            )
          : Container(
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: const Icon(
                Icons.photo_outlined,
                size: 64,
                color: Colors.grey,
              ),
            );

      return Stack(
        fit: StackFit.expand,
        children: [
          Hero(tag: heroTag, child: image),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0, .6),
                    end: Alignment(0, 1.0),
                    colors: [Colors.transparent, Colors.black26],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 16,
                end: 16,
              ),
              title: Text(
                inspection.propertyName.isEmpty
                    ? 'Inspection'
                    : inspection.propertyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium!.copyWith(color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  headerImage(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80, // Adjust for shadow height
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

          // Property + address
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

          // Key info rows
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

          // Media grid (SliverGrid)
          if (media.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final m = media[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: m.url.isNotEmpty
                        ? Image.network(
                            m.url,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                              ),
                            ),
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
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: ButtonsFun((){
                  print('Take Button Was Handled');
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
