import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/triage_form.dart';
import 'providers/providers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'EMS Triage Form',  // Title of the app
        theme: ThemeData.dark(),   // Theme of the app
        home: const TriageForm(),   // Home page of the app
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}