
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/faq.dart';
import '../provider/loginpersistence.dart';

class FAQScreen extends StatefulWidget {
  List<FAQ> faq = [];
   FAQScreen({super.key, required this.faq});
  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load login data after the widget has been built
      await Provider.of<LoginDataProvider>(context, listen: false).loadLoginData();

      print('FAQScreen faq title: ${widget.faq[0].title}');
      print('FAQScreen faq id: ${widget.faq[0].id}');
      print('FAQScreen faq description: ${widget.faq[0].description}');


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
                itemCount: widget.faq.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(widget.faq[index].title.toString()),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.faq[index].description.toString(),
                            style:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.normal)
                        ),
                      ),
                    ],
                  );
                }),
          ),
    );
  }
}
