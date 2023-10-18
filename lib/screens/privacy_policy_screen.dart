
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../functions/functions.dart';
import '../models/privacy_policy.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  List<PrivacyPolicy> privacyPolicy = [];

  PrivacyPolicyScreen({super.key, required this.privacyPolicy});
  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // List<PrivacyPolicy> privacyPolicy = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load login data after the widget has been built
      await Provider.of<LoginDataProvider>(context, listen: false).loadLoginData();

      print('PrivacyPolicyScreen privacyPolicy: ${widget.privacyPolicy}');
      print('PrivacyPolicyScreen privacyPolicy title: ${widget.privacyPolicy[0].title}');
      print('PrivacyPolicyScreen privacyPolicy id: ${widget.privacyPolicy[0].id}');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.pop(context);
        },color: Colors.green),
      ),
    body: Container(
  padding: const EdgeInsets.all(8),
  child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.privacyPolicy.length,
        itemBuilder: (context, index) {
     return Text(widget.privacyPolicy[index].title.toString(),
         style:
         Theme.of(context).textTheme.bodyLarge!.copyWith(
       fontSize: 16,
       fontWeight: FontWeight.normal
     ));
    }),
  ),
    );
  }
}
