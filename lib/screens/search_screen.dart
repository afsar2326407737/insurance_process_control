import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/utils/search_utils.dart';
import '../bloc/search/search_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> results = [];



  @override
  void initState() {
    super.initState();
    // Focus the text field automatically when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    log('Searching for: $value', name: 'Search');
    context.read<SearchBloc>().add(SearchQueryChanged(value));
  }

  //open the details screen
  void _openDetails(BuildContext context, dynamic inspection, String heroTag ) {
    context.push(
      '/details',
      extra: {'inspection': inspection, 'heroTag': heroTag},
    );
  }

// Dart
  Widget _buildFilterChips({
    required String label,
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(isSelected ? null : option),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  // filter apply screen
  void _showFilterSheet(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();
    final state = searchBloc.state;

    // Initialize selected values from current SearchLoaded state if available
    String? selectedStatus;
    String? selectedPriority;
    String? selectedType;

    if (state is SearchLoaded) {
      selectedStatus = state.status;
      selectedPriority = state.priority;
      selectedType = state.inspectionType;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (buildContext) {
        // local variables captured by StatefulBuilder
        String? localStatus = selectedStatus;
        String? localPriority = selectedPriority;
        String? localType = selectedType;

        return Padding(
          // ensure sheet moves above the keyboard when it appears
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(buildContext).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    'Filter Inspections',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(
                    label: 'Status',
                    options: ['Completed', 'In Progress', 'Pending'],
                    selected: localStatus,
                    onSelected: (v) => setState(() => localStatus = v),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(
                    label: 'Priority',
                    options: ['High', 'Medium', 'Low'],
                    selected: localPriority,
                    onSelected: (v) => setState(() => localPriority = v),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterChips(
                    label: 'Inspection Type',
                    options: ['New Policy', 'Renewal', 'Damage Claim'],
                    selected: localType,
                    onSelected: (v) => setState(() => localType = v),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              searchBloc.add(SearchFilterApplied(
                                status: localStatus,
                                priority: localPriority,
                                inspectionType: localType,
                              ));
                              Navigator.pop(context);
                            },
                            child:  Text(
                              'Apply',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              searchBloc.add(SearchFilterCleared());
                              Navigator.pop(context);
                            },
                            child:  Text(
                              'Clear',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            stretch: false,
            expandedHeight: 140,
            collapsedHeight: 140,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            actions: [
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  log('Filter Clicked', name: 'Button Check');
                  _showFilterSheet(context);
                },
              ),
            ],
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row with back and optional icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search bar itself
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12),
                        child: Material(
                          elevation: 6,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(30),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: _onSearchChanged,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search properties, address , IDs...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                              ),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.deepPurple),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search results section
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is SearchLoaded) {
                  if (state.results.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text('No results found')),
                    );
                  }
                  return SliverList.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final data = state.results[index];
                      final color = SearchUtils.statusColor(data.status);
                      final priorityColor = SearchUtils.priorityColor(data.priority);
                      return GestureDetector(
                        onTap: (){
                          final heroTag = 'search-${data.inspectionId}';
                          _openDetails(context, data, heroTag);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: data.media.isNotEmpty
                                      ? Image.network(
                                    data.media.first.url,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.file(
                                        File(data.media.first.toString()),
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.broken_image, color: Colors.redAccent, size: 36),
                                          );
                                        },
                                      );
                                    },
                                  )
                                      : Container(
                                    height: 80,
                                    width: 80,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.home, color: Colors.white70, size: 36),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Details section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.propertyName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data.address,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          SearchUtils.infoChip(data.inspectionType, Icons.assignment, Colors.blue.shade600),
                                          const SizedBox(width: 6),
                                          SearchUtils.infoChip(data.priority, Icons.flag, priorityColor),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Status: ${data.status}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: color,
                                            ),
                                          ),
                                          Text(
                                            data.syncStatus,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: data.syncStatus == 'Synced'
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Due: ${data.dueDate} • Updated: ${data.lastUpdated}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is SearchError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${state.message}')),
                  );
                }
                // Initial state
                return SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Icon(Icons.search_rounded,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Start typing to search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
