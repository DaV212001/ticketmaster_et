import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/signup.dart';
import 'package:ticketmaster_et/screens/thankyouscreen.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import '../constants/app_constants.dart';
import '../constants/endpoints.dart';
import '../functions/functions.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';


String ticketNum = '';

class EventDetail extends StatefulWidget {
  EventDetail({super.key, required this.event});
final Event event;
  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {

  List<Category> categories = [];
  List<City> cities = [];
  List<Organizer> organizers = [];
  bool _isLoading = true;
  String? categoryname = 'Default';
  String? organizername = 'Default';
  String? cityname = 'Default';
  List<Event> events = [];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LoginDataProvider>(context, listen: false).loadLoginData();
      updatesForEventDetail();
      ticketNum = generateTicketNumber(widget.event.title!);
    });

  }


  void updatesForEventDetail() async {
    setState(() {
      _isLoading = true;
    });
    await getEventsbyID(widget.event.id!, Provider.of<SettingsProvider>(context, listen: false).languageCode).then((value) => setState((){
      events = value;
      print( 'VALUE OF THE EVENTS for event details page: $value');
    }));
    await getCategorySubCategory(Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
      categories = value;
      print('VALUE OF THE CATEGORY for event details page: $value');
    }));
    for (Category cat in categories){
      if(int.parse(widget.event.categoryId!) == 2? cat.id == 7: cat.id == int.parse(widget.event.categoryId!)){
        setState(() {
          categoryname = cat.name == 'Cinemas and Teather'? 'Cinema': cat.name;
        });
      }
    }
    await getCity(Provider.of<SettingsProvider>(context, listen: false).languageCode)
        .then((value) => setState(() {
      cities = value;
      print('VALUE OF THE CATEGORY for event details page: $value');
    }));
    for (City city in cities){
      if( city.id == int.parse(widget.event.cityId!)){
        setState(() {
          cityname = city.name;
        });
      }
    }
    await getOrganizers(Provider.of<SettingsProvider>(context, listen: false).languageCode).then((value) => setState((){
      organizers = value;
      print( 'VALUE OF THE ORGANIZERS for cat events: $value');
    }));
    for (Organizer org in organizers){
      if( org.id == int.parse(widget.event.organizerId!)){
        setState(() {
          organizername = org.name;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Here we start listening to changes in SettingsProvider
    Provider.of<SettingsProvider>(context).addListener(updatesForEventDetail);
  }

  @override
  void dispose() {
    if (mounted) {
      Provider.of<SettingsProvider>(context, listen: false).removeListener(updatesForEventDetail);
    }
    super.dispose();
  }
  Class? selectedClass;
  int selectedIndex = -1;
  void selectClass(Class classe, int index) {
  setState(() {
  selectedClass = classe;
  selectedIndex = index;
  });
  }






  @override
  Widget build(BuildContext context) {


    int? price =
    events.isNotEmpty?
    //events is not empty
    events[0].classes!.isNotEmpty?
    //events is not empty and the classes list of the event is not empty
    selectedClass != null?
    //events is not empty and classes list of the event is not empty and there is a selected class
    selectedClass?.price:
    //events is not empty and the classes list of the event is not empty but there is no selected class
    0
        :
    //events is not empty but the classes list of the event is empty
    0
        :
    //events is empty
    0
    ;
double deviceheight = MediaQuery.of(context).size.height;
double devicewidth = MediaQuery.of(context).size.width;
    final loginDataProvider = Provider.of<LoginDataProvider>(context);
    bool _isLoading = false;
    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity * 0.9,
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: !widget.event.image!.endsWith('.mp4')?Image.network(
                    fit: BoxFit.cover,
                    widget.event.image!.trim() == 'https://admin.ticketmaster-et.com/public/storage'
                        || widget.event.image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D'
                        || widget.event.image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/aaa'
                        ||widget.event.image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/'
                        ||widget.event.image!.trim() == 'https://admin.ticketmaster-et.com/public/storage/[value-2]'?
                    'https://i.postimg.cc/VkBQ3FS6/na-logo.png'
                        :
                    widget.event.image!.trim(),
                  )
                  :
                  VideoPlayerWidget(videoUrl: widget.event.image!),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    widget.event.desc!),
              ),
              TicketWidget (
                width: devicewidth/1.1,
                height: deviceheight/2.4,
                isCornerRounded: true,
                padding: EdgeInsets.all(20),
                child: TicketData(events: events, categoryname: categoryname!, cityname: cityname!, organizername: organizername!, selectClass: selectClass, selectedIndex: selectedIndex,),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    final accountProvider = Provider.of<LoginDataProvider>(context, listen: false);
                    String? phone = accountProvider.loginData?.phone?.replaceFirst("251", "0");
                    if(events.isNotEmpty && events[0].classes!.isNotEmpty) {
                      if (selectedClass != null) {
                        if (selectedClass?.price != 0) {
                          String txRef =
                          TxRefRandomGenerator.generate(prefix: 'ticketmaster');
                          // Access the generated transaction reference
                          String storedTxRef = TxRefRandomGenerator.gettxRef;
                          // Use the Chapa Flutter SDK to create a new transaction
                          loginDataProvider.loginData != null ||
                              loginDataProvider.isUserRegistered == true ?
                          await Chapa.getInstance.startPayment(
                            context: context,
                            onInAppPaymentSuccess: (successMsg) async {
                              BookingResponse l;
                              setState(() { // Call setState before bookEvent
                                _isLoading = true;
                              });
                              l = await bookEvent(
                                Booking(
                                    customerId: int.parse(phone!.replaceFirst("0", "251")),
                                    eventId: events[0].id,
                                    classId: selectedClass?.id,
                                    phone: phone.replaceFirst("0", "251"),
                                    ticketNumber: ticketNum, price: price
                                ),
                              );
                              setState(() { // Call setState after bookEvent
                                _isLoading =false;
                              });
                              print(
                                  'PAYMENT SUCCESS!'); // Handle success events
                              if(l.error==null){
                                // Show the pop-up card
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20)),
                                      title: const Text(
                                          "Ticket Purchase Successful!"),
                                      content:
                                      Text(
                                          "$price Birr Paid! Enjoy the event!"),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );} else{
                                setState(() {
                                  _isLoading =false;
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                    SnackBar(content: Text('Error Booking your ticket please try again')));

                              }
                            },

                            amount: '$price',
                            currency: 'ETB',
                            txRef: storedTxRef,
                            firstName: accountProvider.loginData?.firstName ?? '',
                            lastName: accountProvider.loginData?.lastName ?? '',
                            phoneNumber: '${phone??''}',
                            onInAppPaymentError: (errorMsg) {
                              print('PAYMENT FAILURE'); // Handle error
                            },

                          ) : Navigator.push(
                              context, MaterialPageRoute(builder: (context) {
                            return SignupScreen();
                          }));
                        }

                        else {
                          setState(() {
                            _isLoading = false;
                          });

                          BookingResponse l = await bookEvent(
                            Booking(
                                customerId: int.parse(phone!.replaceFirst("0", "251")),
                                eventId: events[0].id,
                                classId: selectedClass?.id,
                                phone: phone.replaceFirst("0", "251"),
                                ticketNumber: ticketNum,
                                price: price
                            ),
                          );
                          print(l);
                          if(l.error==null){
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) {
                              return ThankYouScreen(event: events[0]);
                            }));
                          }}
                      }
                      else {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                            SnackBar(content: Text('Please select a Class')));
                      }
                    }
                    else{
                      setState(() {
                        _isLoading = false;
                      });
                      BookingResponse l = await bookEvent(
                        Booking(
                            customerId: int.parse(phone!.replaceFirst("0", "251")),
                            eventId: events[0].id,
                            classId: selectedClass?.id,
                            phone: phone.replaceFirst("0", "251"),
                            ticketNumber: ticketNum,
                            price: price
                        ),
                      );
                      print(l);
                      if(l.error == null){
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) {
                          return ThankYouScreen(event: events[0]);
                        }));}
                    }
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStatePropertyAll(
                          Size(MediaQuery.of(context).size.width * 0.9, 50))),
                  child: _isLoading? CircularProgressIndicator(): Text(
                    selectedClass == null? 'Book Ticket':
                      'PAY $price BIRR'
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}



String generateTicketNumber(String eventTitle) {
  const chars = '0123456789';
  Random rnd = Random();
  String randomDigits = String.fromCharCodes(Iterable.generate(
      4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  String firstFourLettersOfTitle = eventTitle.length >= 4
      ? eventTitle.substring(0, 4).toUpperCase()
      : eventTitle.toUpperCase();

  return 'TM-$firstFourLettersOfTitle-$randomDigits';
}





class TicketData extends StatefulWidget {
  TicketData({
    Key? key, required this.events, required this.categoryname, required this.organizername, required this.cityname, required this.selectClass, required this.selectedIndex
  }) : super(key: key);
  final List<Event> events;
  final String categoryname;
  final String organizername;
  final String cityname;
  final Function(Class, int) selectClass;
  final int selectedIndex;

  @override
  _TicketDataState createState() => _TicketDataState();
}

class _TicketDataState extends State<TicketData> {

  bool isSelected= false;
  @override
  Widget build(BuildContext context) {
    double devicewidth = MediaQuery.of(context).size.width;
    Class? selectedClass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120.0,
              height: 35.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(width: 1.0, color: Colors.green),
              ),
              child: Center(
                child: Text(
                  widget.categoryname,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green,),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  widget.cityname,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            widget.events.isNotEmpty?
            widget.events[0].title!: '',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                  child: ticketDetailsWidget(
                      'Organizer', '${widget.organizername}', 'Date', widget.events.isNotEmpty?widget.events[0].date!:''),
                ),
                ticketDetailsWidget('Place', widget.events.isNotEmpty?widget.events[0].place!:'', 'Time', widget.events.isNotEmpty?widget.events[0].time!:''),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ticketDetailsWidget('Ticket', widget.events.isNotEmpty&&widget.events[0].classes!.isNotEmpty?'$ticketNum': '$ticketNum', 'Available', widget.events.isNotEmpty&&widget.events[0].classes!.isNotEmpty?'${widget.events[0].classes?[0].availableTicket} tickets left':''),
                ),
                widget.events.isNotEmpty? widget.events[0].classes!.isNotEmpty?Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 52.0, bottom: 0, left: 10),
                  child: Text('Class',
                  style: TextStyle(color: Colors.grey),),
                ): SizedBox(height: 5,): SizedBox(height: 5,) ,
                Padding(
                  padding: const EdgeInsets.only(top: 0, right: 53.0),
                  child:
                  widget.events.isNotEmpty?
                  SizedBox(
                    height: 50,
                    width: devicewidth,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: widget.events[0].classes!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index){
                        return Row(
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    widget.selectClass(widget.events[0].classes![index], index);
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    backgroundColor: widget.selectedIndex == index?
                                         MaterialStatePropertyAll(Colors.green)
                                        : MaterialStatePropertyAll(Colors.black),
                                  ),
                                  child: Center(
                                    child: Text('${widget.events[0].classes?[index].title} - ${widget.events[0].classes?[index].price}',
                                        style: TextStyle(
                                          color: widget.selectedIndex == index? Colors.black : Colors.white,
                                        )),
                                  ),
                                ),
                                SizedBox(width: 5,)
                              ],
                            )
                          ]
                        );
                      },

                    ),
                  ):
                   CircularProgressIndicator()
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



Widget ticketDetailsWidget(String firstTitle, String firstDesc,
    String secondTitle, String secondDesc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firstTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                firstDesc,
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              secondTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                secondDesc,
                style: const TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      )
    ],
  );
}


class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final VideoPlayerController? controller;

  VideoPlayerWidget({Key? key, required this.videoUrl, this.controller}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _chewieController = ChewieController(
      videoPlayerController: widget.controller!=null? widget.controller! : _controller,
      aspectRatio: 13/24,
      showControls: false,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }
}
