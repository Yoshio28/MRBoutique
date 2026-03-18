import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mr_boutique/core/constants/app_constants.dart';
import 'package:mr_boutique/features/home/presentation/widgets/header.dart';

class HomePage extends StatelessWidget {
  final void Function(int) onNavigateToTab;
  const HomePage({super.key, required this.onNavigateToTab});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: 16,
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                bottom: AppConstants.defaultPadding,
              ),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Header()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
