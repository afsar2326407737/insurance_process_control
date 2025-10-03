import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_p_c/components/font_style.dart';
import 'package:i_p_c/screens/properties_home_screen.dart';
import 'package:i_p_c/screens/login_screen.dart';
import 'package:i_p_c/screens/properties_detail_screen.dart';
import 'package:i_p_c/screens/report_upload_screen.dart';
import 'package:i_p_c/screens/settings_screen.dart';
import 'package:i_p_c/screens/signup_page.dart';
import 'bloc/inspection_bloc/inspection_bloc.dart';
import 'bloc/user_bloc/user_bloc.dart';
import 'model/inspection_detailes_model.dart';
import 'package:cbl_flutter/cbl_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await CouchbaseLiteFlutter.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InspectionBloc()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    //used the switch statemet for the optimization
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>  LoginScreen(),
      ),
      GoRoute(
        path: '/:page',
        builder: (context, state) {
          final page = state.pathParameters['page'] ?? '';
          switch (page) {
            case 'uploadreport':
              return ReportUploadScreen();
            case 'signup':
              return SignupPage();
            case 'home':
              return HomeScreen();
            case 'settings':
              return SettingsScreen();
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
