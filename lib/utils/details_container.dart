import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/inspection_detailes_model.dart';
import '../screens/properties_detail_screen.dart';

class DetailsContainer extends StatefulWidget {
  final Inspection inspection;
  const DetailsContainer(this.inspection, {super.key});

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
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    final hasMedia = _media.isNotEmpty && _media.first.url.isNotEmpty;

    Widget imageAt(int index) {
      final url = _media[index].url;
      return Hero(
        tag: _heroTag,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (c, w, p) => p == null
                    ? w
                    : const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                //image error handling
                errorBuilder: (c, e, s) => Container(
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

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.mode_comment_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.send_outlined), onPressed: () {}),
          const Spacer(),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
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
              if (status.isNotEmpty)
                Chip(
                  backgroundColor: status.toLowerCase() == 'completed'
                      ? Colors.green.shade100
                      : status.toLowerCase() == 'in progress'
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                  label: Text(status),
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
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _openDetails,
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
