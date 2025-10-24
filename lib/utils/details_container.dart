import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/bloc/inspection_bloc/inspection_bloc.dart';
import 'package:i_p_c/utils/scaffold_message_notifier.dart';
import '../model/inspection_detailes_model.dart';

class DetailsContainer extends StatefulWidget {
  final Inspection inspection;
  final bool isManager;
  const DetailsContainer(this.inspection, this.isManager, {super.key});

  @override
  State<DetailsContainer> createState() => _DetailsContainerState();
}

class _DetailsContainerState extends State<DetailsContainer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Media> get _media => widget.inspection.media;
  String get _heroTag => 'inspection-${widget.inspection.inspectionId}';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context) {
    final title = widget.inspection.propertyName.isEmpty
        ? 'Property'
        : widget.inspection.propertyName;
    final subtitle = widget.inspection.address.isEmpty
        ? 'Address unavailable'
        : widget.inspection.address;
    final initials = title.trim().isEmpty
        ? 'P'
        : title
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              initials,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (widget.isManager)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              elevation: 4,
              onSelected: (value) {
                if (value == 'delete') {
                  context.read<InspectionBloc>().add(
                    DeleteInspectionEvent(widget.inspection.inspectionId),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    final hasMedia = _media.isNotEmpty && _media.first.url.isNotEmpty;

    Widget imageAt(int index) {
      final mediaItem = _media[index];
      final url = mediaItem.url;

      return Banner(
        location: BannerLocation.topStart,
        message: widget.inspection.status,
        color: widget.inspection.status.toLowerCase() == 'completed'
            ? Colors.green
            : widget.inspection.status.toLowerCase() == 'in progress'
            ? Colors.orange
            : Colors.red,
        textStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        shadow: BoxShadow(
          color: Colors.black,
          offset: Offset(2, 2),
          blurRadius: 4,
        ),
        child: Hero(
          tag: _heroTag,
          child: Stack(
            children: [
              Positioned.fill(
                child: url.startsWith('http') || url.startsWith('https')
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Image.file(
                        File(url),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 120,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final placeholder = Hero(
      tag: _heroTag,
      child: Container(
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const Icon(Icons.photo_outlined, size: 64, color: Colors.grey),
      ),
    );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasMedia
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: _media.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => imageAt(i),
                  )
                : placeholder,
          ),
        ),
        if (hasMedia && _media.length > 1)
          Positioned(
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(
                  _media.length,
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentPage ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCaption(BuildContext context) {
    final type = widget.inspection.inspectionType;
    final status = widget.inspection.status;
    final priority = widget.inspection.priority;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: widget.inspection.propertyName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  text: widget.inspection.address,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (type.isNotEmpty)
                Chip(
                  label: Text(type),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              if (priority.isNotEmpty)
                Chip(
                  backgroundColor: priority.toLowerCase() == 'high'
                      ? Colors.red.shade100
                      : priority.toLowerCase() == 'medium'
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  label: Text('Priority: $priority'),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final ts = widget.inspection.lastUpdated.isEmpty
        ? 'Recently updated'
        : widget.inspection.lastUpdated;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Text(
        ts,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
    );
  }

  void _openDetails() {
    context.push(
      '/details',
      extra: {'inspection': widget.inspection, 'heroTag': _heroTag},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 20,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (widget.inspection.status.toLowerCase() != "completed" ||
              widget.isManager == true) {
            _openDetails();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'This inspection is completed and cannot be edited.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              _buildImageCarousel(context),
              const SizedBox(height: 6),
              // _buildActions(),
              _buildCaption(context),
              _buildTimestamp(context),
            ],
          ),
        ),
      ),
    );
  }
}
