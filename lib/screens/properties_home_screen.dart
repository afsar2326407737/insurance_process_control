import 'dart:developer';

import 'package:cbl/cbl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/bloc/inspection_bloc/inspection_bloc.dart';
import 'package:i_p_c/model/user_model.dart';
import 'package:i_p_c/utils/details_container.dart';
import '../bloc/user_bloc/user_bloc.dart' show UserBloc;
import '../model/inspection_detailes_model.dart';
import '../repository/database_repo.dart';
import '../utils/count_display_cart.dart' show StatCard;
import '../utils/scaffold_message_notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionBloc>().add(InspectionInitialEvent());
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<InspectionBloc>().add(LoadMoreInspections());
    }
  }

  Future<void> _onRefresh() async {
    log('On Refresh Clicked', name: '_onRefresh');
    context.read<InspectionBloc>().add(InspectionInitialEvent());
    await context.read<InspectionBloc>().stream.firstWhere(
      (s) => s is InspectionLoaded || s is InspectionError,
    );
  }

  int _countNewPolicies(List<Inspection> list) {
    return list
        .where((i) => i.inspectionType.toLowerCase() == 'new policy')
        .length;
  }

  int _countHighPriority(List<Inspection> list) {
    return list.where((i) => i.priority.toLowerCase() == 'high').length;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildStatsRow({required int newPolicies, required int highPriority}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'New Policies',
              count: newPolicies,
              icon: Icons.assignment_turned_in_outlined,
              start: const Color(0xFF6DD5FA),
              end: const Color(0xFF2980B9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'High Priority',
              count: highPriority,
              icon: Icons.priority_high_rounded,
              start: const Color(0xFFFFA17F),
              end: const Color(0xFFFF7E5F),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            centerTitle: false,
            pinned: true,
            elevation: 0,
            expandedHeight: 140,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {

                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.push('/settings');
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  titlePadding: EdgeInsetsDirectional.only(
                    start: 16,
                    bottom: 12,
                    end: 16,
                  ),
                  title: Text(
                    'Home',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          CupertinoSliverRefreshControl(onRefresh: _onRefresh),
          BlocConsumer<InspectionBloc, InspectionState>(
            listener: (context, state) {
              if (state is InspectionError) {
                MyScaffoldMessenger.scaffoldSuccessMessage(
                  context,
                  'Something went wrong',
                  Colors.red,
                );
              }
            },
            builder: (context, state) {
              if (state is InspectionLoading || state is InspectionInitial) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is InspectionError) {
                return SliverFillRemaining(
                  child: Center(child: Text('No data Found ${state.message}')),
                );
              }
              if (state is InspectionLoaded) {
                final inspections = state.inspections;
                final newPolicies = _countNewPolicies(inspections);
                final highPriority = _countHighPriority(inspections);
                final showBottomLoader = state.isLoadingMore;

                if (inspections.isEmpty) {
                  return SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatsRow(
                          newPolicies: newPolicies,
                          highPriority: highPriority,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No data found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  );
                }

                const headerCount = 1;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return _buildStatsRow(
                          newPolicies: newPolicies,
                          highPriority: highPriority,
                        );
                      }

                      final listIndex = index - headerCount;
                      if (listIndex < inspections.length) {
                        return DetailsContainer(inspections[listIndex]);
                      }

                      if (showBottomLoader) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No more data',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                    },
                    childCount:
                        headerCount +
                        inspections.length +
                        (showBottomLoader ? 1 : 0),
                  ),
                );
              }
              return SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        DatabaseService().checkthecouchsetup();
      } , child:  Icon(Icons.person),),
    );
  }
}
