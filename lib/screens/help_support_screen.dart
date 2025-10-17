import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/bloc/support_req/support_req_bloc.dart';
import 'package:i_p_c/utils/button_fun.dart';

class HelpSupportScreen extends StatefulWidget {
  String employeeId;
  HelpSupportScreen({super.key, required this.employeeId});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _issueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                      if ( state is SupportReqSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Support request submitted successfully')),
                        );
                        _issueController.clear();
                        context.pop();
                      } else if ( state is SupportReqFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit request: ${state.error}')),
                        );
                      }
                    },
                    builder: (context, state) {
                      if ( state is SupportReqLoading) {
                        return const CircularProgressIndicator();
                      }
                      return ButtonsFun(() {
                        context.read<SupportReqBloc>().add(SubmitSupportRequestEvent(
                          employeeId: widget.employeeId,
                          message: _issueController.text,
                        ));
                      }, 'Submit');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
