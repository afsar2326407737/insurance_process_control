import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_p_c/components/font_style.dart';
import 'package:i_p_c/model/user_model.dart';
import 'package:i_p_c/repository/couchbase_helper.dart';
import 'package:i_p_c/repository/couchbase_services.dart';
import 'package:i_p_c/repository/database_helper.dart';
import 'package:i_p_c/repository/sharedpref_helper.dart';
import 'package:i_p_c/screens/change_password.dart';
import 'package:i_p_c/screens/new_inspection_screen.dart';
import 'package:i_p_c/screens/profile_screen.dart';
import 'package:i_p_c/screens/properties_home_screen.dart';
import 'package:i_p_c/screens/login_screen.dart';
import 'package:i_p_c/screens/properties_detail_screen.dart';
import 'package:i_p_c/screens/upload_report_screen.dart';
import 'package:i_p_c/screens/search_screen.dart';
import 'package:i_p_c/screens/settings_drawer.dart';
import 'package:i_p_c/screens/signup_page.dart';
import 'bloc/inspection_bloc/inspection_bloc.dart';
import 'bloc/search/search_bloc.dart';
import 'bloc/user_bloc/user_bloc.dart';
import 'model/inspection_detailes_model.dart';
import 'package:cbl_flutter/cbl_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Couchbase only once here
  await CouchbaseLiteFlutter.init();
  await CouchbaseHelper().initCouchbase();
  //push the initial data to the emulator
  await runOnceOnFirstInstall();
  // Check login state
  final email = await DatabaseHelper().getLoggedInUserEmail();
  final initialLocation = (email != null) ? '/home' : '/';

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InspectionBloc()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MyApp(initialLocation: initialLocation, initialEmail: email ?? ''),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialLocation;
  final String initialEmail;

  MyApp({super.key, required this.initialLocation, required this.initialEmail});

  late final GoRouter _router = GoRouter(
    initialLocation: initialLocation,

    ///used the switch statemet for the optimization
    routes: [
      GoRoute(path: '/', builder: (context, state) => LoginScreen()),
      GoRoute(
        path: '/:page',
        builder: (context, state) {
          final page = state.pathParameters['page'] ?? '';
          switch (page) {
            case 'uploadreport':
              final extra = state.extra as String;
              final inspectionId = extra;
              if (inspectionId.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('Missing inspection ID')),
                );
              }
              return UploadReportScreen(insuranceId: inspectionId);
            case 'signup':
              return SignupPage();
            case 'home':
              return HomeScreen();
            case 'details':
              final extra = state.extra as Map<String, dynamic>?;
              final inspection = extra?['inspection'] as Inspection?;
              final heroTag =
                  (extra?['heroTag'] as String?) ??
                  'inspection-${inspection?.inspectionId ?? 'unknown'}';
              if (inspection == null) {
                return const Scaffold(
                  body: Center(child: Text('Missing inspection data')),
                );
              }
              return InspectionDetailsScreen(
                inspection: inspection,
                heroTag: heroTag,
              );
            case 'profile':
              final extra = state.extra as Map<String, dynamic>?;
              final user = extra?['user'] as User?;
              if (user == null) {
                return const Scaffold(
                  body: Center(child: Text('Missing user data')),
                );
              }
              return ProfileScreen(user: user);
            case 'search':
              return BlocProvider(
                create: (context) => SearchBloc(),
                child: SearchScreen(),
              );
            case 'newinspection':
              return NewInspectionScreen();
            case 'changepassword':
              final extra = state.extra as String?;
              final empId = extra ?? '';
              if (empId.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('Missing employee ID')),
                );
              }
              return ChangePassword(empId: empId);
            default:
              return const Scaffold(
                body: Center(child: Text('Page not found')),
              );
          }
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return MaterialApp.router(

      title: 'IPC',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: _router,
    );
  }
}
