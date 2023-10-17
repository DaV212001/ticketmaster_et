
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../functions/functions.dart';
import '../models/privacy_policy.dart';
import '../models/terms_and_conditions.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  List<TermsAndConditions> termsAndConditions = [];

  TermsAndConditionsScreen({super.key, required this.termsAndConditions});
  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<TermsAndConditions> termsAndConditions = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load login data after the widget has been built
      await Provider.of<LoginDataProvider>(context, listen: false).loadLoginData();

      print('TermsAndConditionsScreen termsAndConditions: ${widget.termsAndConditions}');
      print('TermsAndConditionsScreen termsAndConditions title: ${widget.termsAndConditions[0].title}');
      print('TermsAndConditionsScreen termsAndConditions id: ${widget.termsAndConditions[0].id}');

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
                itemCount: widget.termsAndConditions.length,
                itemBuilder: (context, index) {
              return Text(widget.termsAndConditions[index].title.toString(),
                  style:
                  Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.normal));
            }),
          ),
    );
  }
}
