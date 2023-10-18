import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/event_model.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import '../constants/app_constants.dart';
import '../functions/functions.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';
import 'event_detail.dart';

class UserTickets extends StatefulWidget {
  const UserTickets({super.key});

  @override
  State<UserTickets> createState() => _UserTicketsState();
}

class _UserTicketsState extends State<UserTickets> {
  List<Ticket> tickets = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateCategories();
    });
  }

  void updateCategories() {
    setState(() {
      _isLoading = true;
    });
    final accountProvider = Provider.of<LoginDataProvider>(context, listen: false);
    String? phone = accountProvider.loginData?.phone;
    getTickets(phone!, Provider.of<SettingsProvider>(context, listen: false).languageCode).then((value) => setState((){
      tickets = value;
      print( 'VALUE OF THE EVENTS: $value');
    }));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Here we start listening to changes in SettingsProvider
    Provider.of<SettingsProvider>(context).addListener(updateCategories);
  }

  @override
  void dispose() {
    Provider.of<SettingsProvider>(context).removeListener(updateCategories);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();


    return Scaffold(
        body: ListView.builder(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: tickets.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                },
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 3.0,
                      left: 10,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: SizedBox(
                                width: 130,
                                height: 130,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: tickets[index].eventImage == null
                                      ||tickets[index].eventImage! == 'https://admin.ticketmaster-et.com/public/storage' || tickets[index].eventImage! == 'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' || tickets[index].eventImage! == 'https://admin.ticketmaster-et.com/public/storage/aaa'||tickets[index].eventImage! == 'https://admin.ticketmaster-et.com/public/storage/'||tickets[index].eventImage! == 'https://admin.ticketmaster-et.com/public/storage/[value-2]'?
                                  Image.asset(
                                          'assets/images/na_logo.jpg',
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          //  cacheManager: cacheProp(),
                                          fadeOutDuration: const Duration(
                                              milliseconds: 300),
                                          fadeOutCurve: Curves.easeOut,
                                          fadeInDuration: const Duration(
                                              milliseconds: 700),
                                          fadeInCurve: Curves.easeIn,
                                          imageUrl: tickets[index].eventImage!.trim() == 'https://admin.ticketmaster-et.com/public/storage' || tickets[index].eventImage!.trim() == 'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' || tickets[index].eventImage!.trim() == 'https://admin.ticketmaster-et.com/public/storage/aaa'||tickets[index].eventImage!.trim() == 'https://admin.ticketmaster-et.com/public/storage/'||tickets[index].eventImage!.trim() == 'https://admin.ticketmaster-et.com/public/storage/[value-2]'? 'https://i.postimg.cc/VkBQ3FS6/na-logo.png': tickets[index].eventImage!.trim(),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          // placeholder: (context, url) =>
                                          //     mainPageVerticalScrollImageShimmer(
                                          //         isDark),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Image.asset(
                                            'assets/images/na_logo.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tickets[index].eventName!,
                                    style: const TextStyle(
                                        fontFamily: 'PoppinsSB',
                                        fontSize: 15,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(tickets[index].eventTime!),
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.calendar_month,
                                      ),
                                      Text(
                                        tickets[index].eventDate!,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins'),
                                      ),
                                    ],
                                  ),
                                  Text(tickets[index].eventPlace??' '),
                                  Text(tickets[index].ticket_number??' '),
                                ],
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          //  color: !isDark ? Colors.black54 : Colors.white54,
                          color: Colors.white54,
                          thickness: 1,
                          endIndent: 20,
                          indent: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }
}
