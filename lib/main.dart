import 'dart:async';
import 'dart:developer' as log_print;
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
      home: const MapScreen(),
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
          "AIzaSyCKM6nu9hXYksgFuz1flo2zQtPRC_lw7NM",
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
        print('Position ---> ${position}');
        log_print.log('Position ---> ${position}');
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
        print('Loop Calling....Len ${data.length} --- ${data.length-1 == i}... ${data[i].name}  ${data[i].location?.lng}');
        final user = data[i];
        PolylineId id = const PolylineId("poly");
        // polylineCoordinates.add(LatLng(data![i].location!.lat,
        //     data![i].location!.lng));

        //Create PolyLine Route
        PolylineResult data1 = await polylinePoints.getRouteBetweenCoordinates(
            "AIzaSyBwgA1lUXJCuACf_9-Zy-fuYULV1W8HEqM",
            PointLatLng(data[i].location!.lat, data[i].location!.lng),
            (data.length-1) == i
                ? PointLatLng(data[i].location!.lat, data[i].location!.lng)
                : PointLatLng(
                    data[i + 1].location!.lat, data[i + 1].location!.lng),
            travelMode: TravelMode.driving);

        data1.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

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
        log_print.log('distanceInMeters --- > ${totalDistance}');
        markers.add(
          Marker(
            draggable: true,
            flat: false,
            infoWindow: InfoWindow(title: data[i].name, snippet: totalDistance.toStringAsFixed(2)),
            markerId: MarkerId('${user.name} position $i'),
            icon: user.name == '${data![0].name}'
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
