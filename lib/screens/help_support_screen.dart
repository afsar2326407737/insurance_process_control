import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/bloc/support_req/support_req_bloc.dart';
import 'package:i_p_c/repository/couchbase_services.dart';
import 'package:i_p_c/utils/button_fun.dart';
import 'package:i_p_c/utils/scaffold_message_notifier.dart';
import '../model/support_request_model.dart';

class HelpSupportScreen extends StatefulWidget {
  final String employeeId;
  final bool isManager;
  const HelpSupportScreen({
    super.key,
    required this.employeeId,
    required this.isManager,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _issueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              title: Text(
                'Help and Support',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          if (widget.isManager)
            SliverToBoxAdapter(child: _buildListOfSupportRequests())
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildSupportForm(context),
            ),
        ],
      ),
    );
  }

  Widget _buildSupportForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ClipOval(
            child: Image.asset(
              'assets/report_issue.jpg',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'For assistance, please contact our support team:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 10,
            controller: _issueController,
            decoration: InputDecoration(
              hintText: 'Describe your issue here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          BlocConsumer<SupportReqBloc, SupportReqState>(
            listener: (context, state) {
              if (state is SupportReqSuccess) {
                MyScaffoldMessenger.scaffoldSuccessMessage(
                  context,
                  'Support request submitted successfully',
                  Colors.green,
                );
                _issueController.clear();
                context.pop();
              } else if (state is SupportReqFailure) {
                MyScaffoldMessenger.scaffoldSuccessMessage(
                  context,
                  'Failed to submit request: ${state.error}',
                  Colors.red,
                );
              }
            },
            builder: (context, state) {
              if (state is SupportReqLoading) {
                return const CircularProgressIndicator();
              }
              return ButtonsFun(() async {
                context.read<SupportReqBloc>().add(
                  SubmitSupportRequestEvent(
                    employeeId: widget.employeeId,
                    message: _issueController.text,
                  ),
                );
              }, 'Submit');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListOfSupportRequests() {
    return FutureBuilder(
      future: CouchbaseServices().getAllSupportRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final requests = snapshot.data as List<SupportRequest>;
        if (requests.isEmpty) {
          return const Center(child: Text('No support requests found.'));
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              child: ExpansionTile(
                title: Text(
                  req.employeeId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                trailing: const Icon(Icons.arrow_drop_down_circle_outlined),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      req.message,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
