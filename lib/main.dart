import 'dart:async';
import 'dart:developer' as log_print;
import 'dart:developer';
import 'dart:math' show cos, sqrt, asin;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_map_demo/permission_handler.dart';
import 'package:google_map_demo/users_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/link.dart';
import 'firestore_service.dart';

//google event
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebaseConnect();
  runApp(const MyApp());
}

Future<void> firebaseConnect() async {
  try {
    // await Firebase.initializeApp();
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyBZdCFrQAgcJJEJeW3WFWtF4Z297bjHN_g',
      appId: '1:229081834523:android:863556c5e15592a8dc84be',
      messagingSenderId: '229081834523',
      projectId: 'loyalty-app-ec079',
      storageBucket: "loyalty-app-ec079.appspot.com",
    ));
  } catch (e) {
    log_print.log('Firebase Catch --- ${e.toString()}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: MapPage(),
      // home: const MapScreen(),
      home: const MyHomePage(),
    );
  }
}

/*const LatLng SOURCE_LOCATION = LatLng(26.907524, 75.739639);
const LatLng DEST_LOCATION = LatLng(24.794500, 73.055000);
const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const double PIN_VISIBLE_POSITION = 20;
const double PIN_INVISIBLE_POSITION = -220;

class MapPage extends StatefulWidget {
  // SubCategory? subCategory;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  Set<Marker> _markers = Set<Marker>();
  double pinPillPosition = PIN_VISIBLE_POSITION;
  late LatLng currentLocation;
  late LatLng destinationLocation;
  bool userBadgeSelected = false;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    sourceIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    );
    destinationIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    );
    setInitialLocation();
  }

  // void setSourceAndDestinationMarkerIcons(BuildContext context) async {
  //   String parentCat = widget.subCategory!.imgName!.split("_")[0];
  //
  //   sourceIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.0),
  //       'assets/imgs/source_pin${Utils.deviceSuffix(context)}.png'
  //   );
  //
  //   destinationIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.0),
  //       'assets/imgs/destination_pin_${parentCat}${Utils.deviceSuffix(context)}.png'
  //   );
  // }

  void setInitialLocation() {
    currentLocation =
        LatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude);

    destinationLocation =
        LatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude);
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = const CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);

    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            myLocationEnabled: true,
            compassEnabled: false,
            tiltGesturesEnabled: false,
            polylines: _polylines,
            markers: _markers,
            mapType: MapType.normal,
            initialCameraPosition: initialCameraPosition,
            onTap: (LatLng loc) {
              setState(() {
                this.pinPillPosition = PIN_INVISIBLE_POSITION;
                this.userBadgeSelected = false;
              });
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);

              showPinsOnMap();
              setPolylines();
            },
          ),
        ),
        // Positioned(
        //   top: 100,
        //   left: 0,
        //   right: 0,
        //   child: MapUserBadge(
        //     isSelected: this.userBadgeSelected,
        //   ),
        // ),
        // AnimatedPositioned(
        //     duration: const Duration(milliseconds: 500),
        //     curve: Curves.easeInOut,
        //     left: 0,
        //     right: 0,
        //     bottom: this.pinPillPosition,
        //     child: MapBottomPill()
        // ),
        // Positioned(
        //     top: 0,
        //     left: 0,
        //     right: 0,
        //     child: MainAppBar(
        //       showProfilePic: false,
        //     )
        // )
      ],
    ));
  }

  void showPinsOnMap() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: currentLocation,
          icon: sourceIcon,
          onTap: () {
            setState(() {
              this.userBadgeSelected = true;
            });
          }));

      _markers.add(Marker(
          markerId: MarkerId('destinationPin'),
          position: destinationLocation,
          icon: destinationIcon,
          onTap: () {
            setState(() {
              this.pinPillPosition = PIN_VISIBLE_POSITION;
            });
          }));
    });
  }

  void setPolylines() async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          "<Google API Key>",
          PointLatLng(currentLocation.latitude, currentLocation.longitude),
          PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
          travelMode: TravelMode.driving);
      log('result --- > ${result.errorMessage}');
      if (result.status == 'OK') {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        setState(() {
          _polylines.add(Polyline(
              width: 10,
              polylineId: PolylineId('polyLine'),
              color: Color(0xFF08A5CB),
              points: polylineCoordinates));
        });
      }
    } catch (e) {
      log('Catch ----> ${e.toString()}');
    }
  }
}*/

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CalendarController _controller;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // clientId: '[501041666177-j3eunanijg6a52jvk5qmjfc44r89at9m.apps.googleusercontent.com]',
    scopes: <String>[GoogleAPI.CalendarApi.calendarScope],
    forceCodeForRefreshToken: true,
  );

  GoogleSignInAccount? _currentUser;
  int selectIndex = 0;
  late CalendarView selectCalendar;

  List calendarType = [
    CalendarView.day,
    CalendarView.week,
    CalendarView.month,
    CalendarView.timelineDay,
    CalendarView.workWeek,
    CalendarView.timelineWeek,
    CalendarView.timelineWorkWeek,
    CalendarView.timelineMonth,
    CalendarView.schedule,
  ];

  @override
  void initState() {
    super.initState();
    selectCalendar = CalendarView.day;
    _controller = CalendarController();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        // getGoogleEventsData();
      }
    });
    _googleSignIn.signInSilently();
  }

  Stream<List<GoogleAPI.Event>> getGoogleEventsData() async* {
    final List<GoogleAPI.Event> appointments = <GoogleAPI.Event>[];
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      log('googleUser ---> ${googleUser?.email}');
      final GoogleAPIClient httpClient =
          GoogleAPIClient(await googleUser!.authHeaders);

      final GoogleAPI.CalendarApi calendarApi =
          GoogleAPI.CalendarApi(httpClient);
      final GoogleAPI.Events calEvents = await calendarApi.events.list(
        "primary",
      );

      if (calEvents.items != null) {
        for (int i = 0; i < calEvents.items!.length; i++) {
          final GoogleAPI.Event event = calEvents.items![i];
          if (event.start == null) {
            continue;
          }
          log('Cal Event ---> ${event.description} .. ${event.status}');
          appointments.add(event);
        }
      }
      yield appointments;
    } catch (e) {
      log('Error --- > ${e.toString()}');
      yield appointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('calendarType[selectIndex] ---> ${calendarType[selectIndex]}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        actions: [
          Text('${calendarType[selectIndex]}'),
          IconButton(
              onPressed: () {
                log('Event ----- $selectIndex  ${selectIndex > calendarType.length}  ${calendarType.length}');
                if ((selectIndex + 1) < calendarType.length) {
                  log('Event ----- True');
                  selectIndex += 1;
                } else {
                  log('Event ----- False');
                  selectIndex = 0;
                }
                _controller = CalendarController();
                setState(() {});
              },
              icon: const Icon(Icons.calendar_month_rounded,
                  color: Colors.blue, size: 30))
        ],
      ),
      body: SizedBox.expand(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.day,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          SfCalendar(
                            onTap: (CalendarTapDetails details) async {
                              // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();

                              for (int i = 0;
                              i < details.appointments!.length;
                              i++) {
                                final GoogleAPI.Event event =
                                details.appointments![i];
                                log('Cal Event ---> ${event.description} .. ${event.status}');

                                final GoogleAPIClient httpClient =
                                GoogleAPIClient(
                                    await _currentUser!.authHeaders);
                                final GoogleAPI.CalendarApi calendarApi =
                                GoogleAPI.CalendarApi(httpClient);
                                await calendarApi.events
                                    .delete('primary', event.id.toString());
                                setState(() {});
                              }

                              // try {
                              //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                              //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                              //   // Delete the event.
                              //   await calendarApi.events.delete('primary', details..resource.id);
                              //   print('Event deleted successfully');
                              // } catch (e) {
                              //   print('Error deleting event: $e');
                              // } finally {
                              //   // Close the client to release resources.
                              //   client.close();
                              // }

                              if (details.targetElement ==
                                  CalendarElement.appointment) {
                                // An event is tapped
                                print(
                                    'Event tapped: ${details.appointments![0].subject}');
                                // You can perform actions here when an event is tapped
                              }
                            },
                            controller: _controller,
                            onViewChanged: (onViewChanged) {},
                            view: CalendarView.day,
                            initialDisplayDate: DateTime.now(),
                            //(2024, 1, 15, 9, 0, 0),
                            dataSource: GoogleDataSource(events: snapshot.data),
                            monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                            allowAppointmentResize: true,
                            showDatePickerButton: false,
                            showWeekNumber: true,
                            showNavigationArrow: true,
                            showCurrentTimeIndicator: true,
                            allowViewNavigation: false,
                            allowDragAndDrop: true,
                          ),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  )
                )),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.week,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          SfCalendar(
                            onTap: (CalendarTapDetails details) async {
                              // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();
                              if (details.appointments != null &&
                                  details.appointments!.isNotEmpty) {
                                for (int i = 0;
                                i < details.appointments!.length;
                                i++) {
                                  final GoogleAPI.Event event =
                                  details.appointments![i];
                                  log('Cal Event ---> ${event.description} .. ${event.status}');

                                  final GoogleAPIClient httpClient =
                                  GoogleAPIClient(
                                      await _currentUser!.authHeaders);
                                  final GoogleAPI.CalendarApi calendarApi =
                                  GoogleAPI.CalendarApi(httpClient);
                                  await calendarApi.events
                                      .delete('primary', event.id.toString());
                                  setState(() {});
                                }
                              }

                              // try {
                              //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                              //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                              //   // Delete the event.
                              //   await calendarApi.events.delete('primary', details..resource.id);
                              //   print('Event deleted successfully');
                              // } catch (e) {
                              //   print('Error deleting event: $e');
                              // } finally {
                              //   // Close the client to release resources.
                              //   client.close();
                              // }

                              if (details.targetElement ==
                                  CalendarElement.appointment) {
                                // An event is tapped
                                print(
                                    'Event tapped: ${details.appointments![0].subject}');
                                // You can perform actions here when an event is tapped
                              }
                            },
                            controller: _controller,
                            onViewChanged: (onViewChanged) {},
                            view: CalendarView.week,
                            initialDisplayDate: DateTime.now(),
                            //(2024, 1, 15, 9, 0, 0),
                            dataSource: GoogleDataSource(events: snapshot.data),
                            monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                            allowAppointmentResize: true,
                            showDatePickerButton: false,
                            showWeekNumber: true,
                            showNavigationArrow: true,
                            showCurrentTimeIndicator: true,
                            allowViewNavigation: false,
                            allowDragAndDrop: true,
                          ),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  )
                )),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.month,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          SfCalendar(
                            onTap: (CalendarTapDetails details) async {
                              // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();

                              for (int i = 0;
                              i < details.appointments!.length;
                              i++) {
                                final GoogleAPI.Event event =
                                details.appointments![i];
                                log('Cal Event ---> ${event.description} .. ${event.status}');

                                final GoogleAPIClient httpClient =
                                GoogleAPIClient(
                                    await _currentUser!.authHeaders);
                                final GoogleAPI.CalendarApi calendarApi =
                                GoogleAPI.CalendarApi(httpClient);
                                await calendarApi.events
                                    .delete('primary', event.id.toString());
                                setState(() {});
                              }

                              // try {
                              //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                              //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                              //   // Delete the event.
                              //   await calendarApi.events.delete('primary', details..resource.id);
                              //   print('Event deleted successfully');
                              // } catch (e) {
                              //   print('Error deleting event: $e');
                              // } finally {
                              //   // Close the client to release resources.
                              //   client.close();
                              // }

                              if (details.targetElement ==
                                  CalendarElement.appointment) {
                                // An event is tapped
                                print(
                                    'Event tapped: ${details.appointments![0].subject}');
                                // You can perform actions here when an event is tapped
                              }
                            },
                            controller: _controller,
                            onViewChanged: (onViewChanged) {},
                            view: CalendarView.month,
                            initialDisplayDate: DateTime.now(),
                            //(2024, 1, 15, 9, 0, 0),
                            dataSource: GoogleDataSource(events: snapshot.data),
                            monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                            allowAppointmentResize: true,
                            showDatePickerButton: false,
                            showWeekNumber: true,
                            showNavigationArrow: true,
                            showCurrentTimeIndicator: true,
                            allowViewNavigation: false,
                            allowDragAndDrop: true,
                          ),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  )
                )),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.workWeek,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          SfCalendar(
                            onTap: (CalendarTapDetails details) async {
                              // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();

                              for (int i = 0;
                              i < details.appointments!.length;
                              i++) {
                                final GoogleAPI.Event event =
                                details.appointments![i];
                                log('Cal Event ---> ${event.description} .. ${event.status}');

                                final GoogleAPIClient httpClient =
                                GoogleAPIClient(
                                    await _currentUser!.authHeaders);
                                final GoogleAPI.CalendarApi calendarApi =
                                GoogleAPI.CalendarApi(httpClient);
                                await calendarApi.events
                                    .delete('primary', event.id.toString());
                                setState(() {});
                              }

                              // try {
                              //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                              //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                              //   // Delete the event.
                              //   await calendarApi.events.delete('primary', details..resource.id);
                              //   print('Event deleted successfully');
                              // } catch (e) {
                              //   print('Error deleting event: $e');
                              // } finally {
                              //   // Close the client to release resources.
                              //   client.close();
                              // }

                              if (details.targetElement ==
                                  CalendarElement.appointment) {
                                // An event is tapped
                                print(
                                    'Event tapped: ${details.appointments![0].subject}');
                                // You can perform actions here when an event is tapped
                              }
                            },
                            controller: _controller,
                            onViewChanged: (onViewChanged) {},
                            view: CalendarView.workWeek,
                            initialDisplayDate: DateTime.now(),
                            //(2024, 1, 15, 9, 0, 0),
                            dataSource: GoogleDataSource(events: snapshot.data),
                            monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                            allowAppointmentResize: true,
                            showDatePickerButton: false,
                            showWeekNumber: true,
                            showNavigationArrow: true,
                            showCurrentTimeIndicator: true,
                            allowViewNavigation: false,
                            allowDragAndDrop: true,
                          ),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  ))),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.timelineDay,
                child: Expanded(child: StreamBuilder(
                  stream: getGoogleEventsData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return Stack(
                      children: [
                        SfCalendar(
                          onTap: (CalendarTapDetails details) async {
                            // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();
                            if (details.appointments != null &&
                                details.appointments!.isNotEmpty) {
                              for (int i = 0;
                              i < details.appointments!.length;
                              i++) {
                                final GoogleAPI.Event event =
                                details.appointments![i];
                                log('Cal Event ---> ${event.description} .. ${event.status}');

                                final GoogleAPIClient httpClient =
                                GoogleAPIClient(
                                    await _currentUser!.authHeaders);
                                final GoogleAPI.CalendarApi calendarApi =
                                GoogleAPI.CalendarApi(httpClient);
                                await calendarApi.events
                                    .delete('primary', event.id.toString());
                                setState(() {});
                              }
                            }

                            // try {
                            //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                            //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                            //   // Delete the event.
                            //   await calendarApi.events.delete('primary', details..resource.id);
                            //   print('Event deleted successfully');
                            // } catch (e) {
                            //   print('Error deleting event: $e');
                            // } finally {
                            //   // Close the client to release resources.
                            //   client.close();
                            // }

                            if (details.targetElement ==
                                CalendarElement.appointment) {
                              // An event is tapped
                              print(
                                  'Event tapped: ${details.appointments![0].subject}');
                              // You can perform actions here when an event is tapped
                            }
                          },
                          controller: _controller,
                          onViewChanged: (onViewChanged) {},
                          view: CalendarView.timelineDay,
                          initialDisplayDate: DateTime.now(),
                          //(2024, 1, 15, 9, 0, 0),
                          dataSource: GoogleDataSource(events: snapshot.data),
                          monthViewSettings: const MonthViewSettings(
                              appointmentDisplayMode:
                              MonthAppointmentDisplayMode.appointment),
                          allowAppointmentResize: true,
                          showDatePickerButton: false,
                          showWeekNumber: true,
                          showNavigationArrow: true,
                          showCurrentTimeIndicator: true,
                          allowViewNavigation: false,
                          allowDragAndDrop: true,
                        ),
                        snapshot.data != null
                            ? Container()
                            : const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  },
                ))),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.timelineWeek,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          SfCalendar(
                            onTap: (CalendarTapDetails details) async {
                              // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();

                              for (int i = 0;
                              i < details.appointments!.length;
                              i++) {
                                final GoogleAPI.Event event =
                                details.appointments![i];
                                log('Cal Event ---> ${event.description} .. ${event.status}');

                                final GoogleAPIClient httpClient =
                                GoogleAPIClient(
                                    await _currentUser!.authHeaders);
                                final GoogleAPI.CalendarApi calendarApi =
                                GoogleAPI.CalendarApi(httpClient);
                                await calendarApi.events
                                    .delete('primary', event.id.toString());
                                setState(() {});
                              }

                              // try {
                              //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                              //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                              //   // Delete the event.
                              //   await calendarApi.events.delete('primary', details..resource.id);
                              //   print('Event deleted successfully');
                              // } catch (e) {
                              //   print('Error deleting event: $e');
                              // } finally {
                              //   // Close the client to release resources.
                              //   client.close();
                              // }

                              if (details.targetElement ==
                                  CalendarElement.appointment) {
                                // An event is tapped
                                print(
                                    'Event tapped: ${details.appointments![0].subject}');
                                // You can perform actions here when an event is tapped
                              }
                            },
                            controller: _controller,
                            onViewChanged: (onViewChanged) {},
                            view: CalendarView.timelineWeek,
                            initialDisplayDate: DateTime.now(),
                            //(2024, 1, 15, 9, 0, 0),
                            dataSource:
                            GoogleDataSource(events: snapshot.data),
                            monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                            allowAppointmentResize: true,
                            showDatePickerButton: false,
                            showWeekNumber: true,
                            showNavigationArrow: true,
                            showCurrentTimeIndicator: true,
                            allowViewNavigation: false,
                            allowDragAndDrop: true,
                          ),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  )
                )),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.timelineMonth,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          SfCalendar(
                            onTap: (CalendarTapDetails details) async {
                              // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();
                              if (details.appointments != null &&
                                  details.appointments!.isNotEmpty) {
                                for (int i = 0;
                                i < details.appointments!.length;
                                i++) {
                                  final GoogleAPI.Event event =
                                  details.appointments![i];
                                  log('Cal Event ---> ${event.description} .. ${event.status}');

                                  final GoogleAPIClient httpClient =
                                  GoogleAPIClient(
                                      await _currentUser!.authHeaders);
                                  final GoogleAPI.CalendarApi calendarApi =
                                  GoogleAPI.CalendarApi(httpClient);
                                  await calendarApi.events
                                      .delete('primary', event.id.toString());
                                  setState(() {});
                                }
                              }

                              // try {
                              //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                              //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                              //   // Delete the event.
                              //   await calendarApi.events.delete('primary', details..resource.id);
                              //   print('Event deleted successfully');
                              // } catch (e) {
                              //   print('Error deleting event: $e');
                              // } finally {
                              //   // Close the client to release resources.
                              //   client.close();
                              // }

                              if (details.targetElement ==
                                  CalendarElement.appointment) {
                                // An event is tapped
                                print(
                                    'Event tapped: ${details.appointments![0].subject}');
                                // You can perform actions here when an event is tapped
                              }
                            },
                            controller: _controller,
                            onViewChanged: (onViewChanged) {},
                            view: CalendarView.timelineMonth,
                            initialDisplayDate: DateTime.now(),
                            //(2024, 1, 15, 9, 0, 0),
                            dataSource:
                            GoogleDataSource(events: snapshot.data),
                            monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                            allowAppointmentResize: true,
                            showDatePickerButton: false,
                            showWeekNumber: true,
                            showNavigationArrow: true,
                            showCurrentTimeIndicator: true,
                            allowViewNavigation: false,
                            allowDragAndDrop: true,
                          ),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  )
                )),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.timelineWorkWeek,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          Visibility(
                              visible: calendarType[selectIndex] ==
                                  CalendarView.timelineWorkWeek,
                              child: SfCalendar(
                                onTap: (CalendarTapDetails details) async {
                                  // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();
                                  if (details.appointments != null &&
                                      details.appointments!.isNotEmpty) {
                                    for (int i = 0;
                                    i < details.appointments!.length;
                                    i++) {
                                      final GoogleAPI.Event event =
                                      details.appointments![i];
                                      log('Cal Event ---> ${event.description} .. ${event.status}');

                                      final GoogleAPIClient httpClient =
                                      GoogleAPIClient(
                                          await _currentUser!.authHeaders);
                                      final GoogleAPI.CalendarApi calendarApi =
                                      GoogleAPI.CalendarApi(httpClient);
                                      await calendarApi.events
                                          .delete('primary', event.id.toString());
                                      setState(() {});
                                    }
                                  }

                                  // try {
                                  //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                                  //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                                  //   // Delete the event.
                                  //   await calendarApi.events.delete('primary', details..resource.id);
                                  //   print('Event deleted successfully');
                                  // } catch (e) {
                                  //   print('Error deleting event: $e');
                                  // } finally {
                                  //   // Close the client to release resources.
                                  //   client.close();
                                  // }

                                  if (details.targetElement ==
                                      CalendarElement.appointment) {
                                    // An event is tapped
                                    print(
                                        'Event tapped: ${details.appointments![0].subject}');
                                    // You can perform actions here when an event is tapped
                                  }
                                },
                                controller: _controller,
                                onViewChanged: (onViewChanged) {},
                                view: CalendarView.timelineWorkWeek,
                                initialDisplayDate: DateTime.now(),
                                //(2024, 1, 15, 9, 0, 0),
                                dataSource:
                                GoogleDataSource(events: snapshot.data),
                                monthViewSettings: const MonthViewSettings(
                                    appointmentDisplayMode:
                                    MonthAppointmentDisplayMode.appointment),
                                allowAppointmentResize: true,
                                showDatePickerButton: false,
                                showWeekNumber: true,
                                showNavigationArrow: true,
                                showCurrentTimeIndicator: true,
                                allowViewNavigation: false,
                                allowDragAndDrop: true,
                              )),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  )
                )),
            Visibility(
                visible: calendarType[selectIndex] == CalendarView.schedule,
                child: Expanded(
                  child: StreamBuilder(
                    stream: getGoogleEventsData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Stack(
                        children: [
                          SfCalendar(
                            onTap: (CalendarTapDetails details) async {
                              // details.appointments!.map((e) => log('On Tap --> ${e.first}')).toList();
                              if (details.appointments != null &&
                                  details.appointments!.isNotEmpty) {
                                for (int i = 0;
                                i < details.appointments!.length;
                                i++) {
                                  final GoogleAPI.Event event =
                                  details.appointments![i];
                                  log('Cal Event ---> ${event.description} .. ${event.status}');

                                  final GoogleAPIClient httpClient =
                                  GoogleAPIClient(
                                      await _currentUser!.authHeaders);
                                  final GoogleAPI.CalendarApi calendarApi =
                                  GoogleAPI.CalendarApi(httpClient);
                                  await calendarApi.events
                                      .delete('primary', event.id.toString());
                                  setState(() {});
                                }
                              }

                              // try {
                              //   final GoogleAPIClient httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
                              //   final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
                              //   // Delete the event.
                              //   await calendarApi.events.delete('primary', details..resource.id);
                              //   print('Event deleted successfully');
                              // } catch (e) {
                              //   print('Error deleting event: $e');
                              // } finally {
                              //   // Close the client to release resources.
                              //   client.close();
                              // }

                              if (details.targetElement ==
                                  CalendarElement.appointment) {
                                // An event is tapped
                                print(
                                    'Event tapped: ${details.appointments![0].subject}');
                                // You can perform actions here when an event is tapped
                              }
                            },
                            controller: _controller,
                            onViewChanged: (onViewChanged) {},
                            view: CalendarView.schedule,
                            initialDisplayDate: DateTime.now(),
                            //(2024, 1, 15, 9, 0, 0),
                            dataSource:
                            GoogleDataSource(events: snapshot.data),
                            monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                            allowAppointmentResize: true,
                            showDatePickerButton: false,
                            showWeekNumber: true,
                            showNavigationArrow: true,
                            showCurrentTimeIndicator: true,
                            allowViewNavigation: false,
                            allowDragAndDrop: true,
                          ),
                          snapshot.data != null
                              ? Container()
                              : const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  )
                )),
          ])),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final GoogleAPIClient httpClient =
                GoogleAPIClient(await _currentUser!.authHeaders);
            final GoogleAPI.CalendarApi calendarApi =
                GoogleAPI.CalendarApi(httpClient);
            var event = GoogleAPI.Event()
                  ..summary = 'Event Summary New '
                  ..description = 'Event Description New'
                  ..start = GoogleAPI.EventDateTime(
                      dateTime:
                          DateTime.now().subtract(const Duration(days: 1)),
                      timeZone: 'GMT')
                  // ..dateTime = DateTime.now().add(Duration(days: 1))
                  // ..timeZone = 'GMT'
                  ..end = GoogleAPI.EventDateTime(
                      dateTime:
                          DateTime.now().add(const Duration(days: 1, hours: 1)),
                      timeZone: 'GMT')
                // ..dateTime = DateTime.now().add(Duration(days: 1, hours: 1))
                // ..timeZone = 'GMT'
                ;

            var calendarId =
                'primary'; // Use 'primary' for the user's primary calendar
            final status = await calendarApi.events.insert(event, calendarId);
            setState(() {});
            print('Add Event Status --> ${status.description}');
          },
          label: const Text('Add Event',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20))),
    );
  }

  @override
  void dispose() {
    if (_googleSignIn.currentUser != null) {
      _googleSignIn.disconnect();
      _googleSignIn.signOut();
    }

    super.dispose();
  }
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event>? events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.start?.date ?? event.start!.dateTime!.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.endTimeUnspecified != null && event.endTimeUnspecified!
        ? (event.start?.date ?? event.start!.dateTime!.toLocal())
        : (event.end?.date != null
            ? event.end!.date!.add(const Duration(days: -1))
            : event.end!.dateTime!.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments![index].location ?? '';
  }

  @override
  String getNotes(int index) {
    return appointments![index].description ?? '';
  }

  @override
  String getSubject(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.summary == null || event.summary!.isEmpty
        ? 'No Title'
        : event.summary!;
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;
  Map<PolylineId, Polyline> polylines = {};
  final Set<Marker> markers = {};
  late PolylinePoints polylinePoints;

  static const CameraPosition _initialPosition = CameraPosition(
      target: LatLng(-18.9216855, 47.5725194),
      // Antananarivo, Madagascar LatLng 🇲🇬
      zoom: 1.4746,
      tilt: 50);

  late StreamSubscription<Position>? locationStreamSubscription;

  @override
  void initState() {
    super.initState();
    firebaseIni();
    polylinePoints = PolylinePoints();
    locationStreamSubscription =
        StreamLocationService.onLocationChanged?.listen(
      (position) async {
        print('Position ---> $position');
        log_print.log('Position ---> $position');
        await FirestoreService.updateUserLocation(
          'sQkWMX9usjO8HbI2VQCF',
          //Hardcoded uid but this is the uid of the connected user when using authentification service
          LatLng(position.latitude, position.longitude),
        );
      },
    );
    print('Position --->');
    // setState(() {});
  }

  firebaseIni() async {
    // await Firebase.initializeApp();
    try {
      // await Firebase.initializeApp();
      await Firebase.initializeApp(
          options: const FirebaseOptions(
        apiKey: 'AIzaSyBZdCFrQAgcJJEJeW3WFWtF4Z297bjHN_g',
        appId: '1:229081834523:android:863556c5e15592a8dc84be',
        messagingSenderId: '229081834523',
        projectId: 'loyalty-app-ec079',
        storageBucket: "loyalty-app-ec079.appspot.com",
      ));
    } catch (e) {
      log_print.log('Firebase Catch --- ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        StreamBuilder<List<User>>(
          stream: FirestoreService.userCollectionStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              return FutureBuilder(
                  future: buildwidget(snapshot.data),
                  builder: (_, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasData) {
                      return GoogleMap(
                        myLocationEnabled: true,
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        mapToolbarEnabled: true,
                        zoomControlsEnabled: true,
                        liteModeEnabled: false,
                        // Android Only
                        fortyFiveDegreeImageryEnabled: true,
                        // Web Only
                        myLocationButtonEnabled: true,
                        indoorViewEnabled: true,
                        trafficEnabled: true,
                        buildingsEnabled: true,
                        initialCameraPosition: _initialPosition,
                        markers: markers,
                        mapType: MapType.normal,
                        polylines: Set<Polyline>.of(polylines.values),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          newGoogleMapController = controller;
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  });
            }

            return const Center(child: CircularProgressIndicator());

            // return GoogleMap(
            //   myLocationEnabled: true,
            //   tiltGesturesEnabled: true,
            //   compassEnabled: true,
            //   scrollGesturesEnabled: true,
            //   zoomGesturesEnabled: true,
            //   rotateGesturesEnabled: true,
            //   mapToolbarEnabled: true,
            //   zoomControlsEnabled: true,
            //   liteModeEnabled: false, // Android Only
            //   fortyFiveDegreeImageryEnabled: true, // Web Only
            //   myLocationButtonEnabled: true,
            //   indoorViewEnabled: true,
            //   trafficEnabled: true,
            //   buildingsEnabled: true,
            //   initialCameraPosition: _initialPosition,
            //   markers: markers,
            //   mapType: MapType.normal,
            //   // polylines: Set<Polyline>.of(polylines.values),
            //   onMapCreated: (GoogleMapController controller) {
            //     _controller.complete(controller);
            //     newGoogleMapController = controller;
            //
            //   },
            // );
          },
        )
      ]),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return BottomSheetWidget(context);
              },
            );
          },
          child: const Icon(Icons.chat)),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }

  @override
  void dispose() {
    super.dispose();
    locationStreamSubscription?.cancel();
  }

  Future<int> buildwidget(List<User>? data) async {
    List<LatLng> polylineCoordinates = [];
    double totalDistance = 0.0;
    // markers.clear();
    // polylines.clear();

    for (var i = 0; i < data!.length; i++) {
      try {
        print(
            'Loop Calling....Len ${data.length} --- ${data.length - 1 == i}... ${data[i].name}  ${data[i].location?.lng}');
        final user = data[i];
        PolylineId id = const PolylineId("poly");
        // polylineCoordinates.add(LatLng(data![i].location!.lat,
        //     data![i].location!.lng));

        //Create PolyLine Route
        PolylineResult data1 = await polylinePoints.getRouteBetweenCoordinates(
            "AIzaSyBwgA1lUXJCuACf_9-Zy-fuYULV1W8HEqM",
            PointLatLng(data[i].location!.lat, data[i].location!.lng),
            (data.length - 1) == i
                ? PointLatLng(data[i].location!.lat, data[i].location!.lng)
                : PointLatLng(
                    data[i + 1].location!.lat, data[i + 1].location!.lng),
            travelMode: TravelMode.driving);

        for (var point in data1.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        Polyline polyline = Polyline(
            polylineId: id,
            color: Colors.red,
            width: 2,
            visible: true,
            jointType: JointType.mitered,
            geodesic: false,
            consumeTapEvents: false,
            points: polylineCoordinates);
        polylines[id] = polyline;

        //Count Distance
        totalDistance += _coordinateDistance(
          0 == i ? data[i].location?.lat : data[i - 1].location?.lat,
          0 == i ? data[i].location?.lng : data[i - 1].location?.lng,
          data[i].location?.lat,
          data[i].location?.lng,
        );

        //Time Calculate

        // Location loc1 = Location(lat: 0 == i ? data[i].location!.lat : data[i - 1].location!.lat, lng: 0 == i ? data[i].location!.lng : data[i - 1].location!.lng);
        // Location loc2 = Location(lat: data[i].location!.lat,lng: data[i].location!.lng,);
        // double distance = loc1.distanceTo(loc2);
        //
        // int speed=30;
        // float time = distance/speed;
        log_print.log('distanceInMeters --- > $totalDistance');
        markers.add(
          Marker(
            draggable: true,
            flat: false,
            infoWindow: InfoWindow(
                title: data[i].name, snippet: totalDistance.toStringAsFixed(2)),
            markerId: MarkerId('${user.name} position $i'),
            icon: user.name == '${data[0].name}'
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  )
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
            position: LatLng(user.location!.lat, user.location!.lng),
            onTap: () => {print("Marker Click --- > ")},
          ),
        );
      } catch (e) {
        print('Loop Calling.... Catch --- > ${e.toString()}');
      }
    }
    return 1;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

class BottomSheetWidget extends StatefulWidget {
  BuildContext context;

  BottomSheetWidget(this.context, {super.key});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? apiKey;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    // _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext? context, Widget? child) {
        return Transform.translate(
          offset: Offset(
              0.0,
              _animation.value *
                  MediaQuery.of(context!).size.height *
                  MediaQuery.of(context).size.height),
          child: SingleChildScrollView(
              child: SizedBox(
            // color: Colors.grey[200],
            height: MediaQuery.of(context).size.height * 0.9,
            child: switch (apiKey) {
              final providedKey? => ChatWidget(apiKey: providedKey),
              _ => ApiKeyWidget(onSubmitted: (key) {
                  setState(() => apiKey = key);
                })
            },
          )),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ApiKeyWidget extends StatelessWidget {
  ApiKeyWidget({required this.onSubmitted, super.key});

  final ValueChanged onSubmitted;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'To use the Gemini API, you\'ll need an API key. '
            'If you don\'t already have one, '
            'create a key in Google AI Studio.',
          ),
          const SizedBox(height: 8),
          Link(
            uri: Uri.https('makersuite.google.com', '/app/apikey'),
            target: LinkTarget.blank,
            builder: (context, followLink) => TextButton(
              onPressed: followLink,
              child: const Text('Get an API Key'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration:
                      textFieldDecoration(context, 'Enter your API key'),
                  controller: _textController,
                  onSubmitted: (value) {
                    onSubmitted(value);
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  onSubmitted(_textController.value.text);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    )));
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({required this.apiKey, super.key});

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: widget.apiKey,
    );
    _chat = _model.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = _chat.history.toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, idx) {
                final content = history[idx];
                final text = content.parts
                    .whereType<TextPart>()
                    .map<String>((e) => e.text)
                    .join('');
                return MessageWidget(
                  text: text,
                  isFromUser: content.role == 'user',
                );
              },
              itemCount: history.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    focusNode: _textFieldFocus,
                    decoration:
                        textFieldDecoration(context, 'Enter a prompt...'),
                    controller: _textController,
                    onSubmitted: (String value) {
                      _sendChatMessage(value);
                    },
                  ),
                ),
                const SizedBox.square(dimension: 15),
                if (!_loading)
                  IconButton(
                    onPressed: () async {
                      _sendChatMessage(_textController.text);
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      final text = response.text;

      if (text == null) {
        _showError('Empty response.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            margin: const EdgeInsets.only(bottom: 8),
            child: MarkdownBody(data: text),
          ),
        ),
      ],
    );
  }
}

InputDecoration textFieldDecoration(BuildContext context, String hintText) =>
    InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
