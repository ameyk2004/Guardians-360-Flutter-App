import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:guardians_app/config/base_config.dart';
import 'package:guardians_app/utils/asset_suppliers/location_page_assets.dart';
import 'package:guardians_app/utils/global_variable.dart';
import 'package:http/http.dart' as http;
import '../../services/cache_service.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../utils/asset_suppliers/contacts_page_assets.dart';
import '../../utils/colors.dart';

class FriendLocationTrackingPage extends StatefulWidget {
  const FriendLocationTrackingPage({super.key});

  @override
  State<FriendLocationTrackingPage> createState() =>
      _FriendLocationTrackingPageState();
}

class _FriendLocationTrackingPageState
    extends State<FriendLocationTrackingPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  double? _latitude;
  double? _longitude;

  List friends = [];
  var userData = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getUserData();
    _getCurrentLocation();
    _startLocationPolling();
  }

  // Start polling the location every 2 seconds
  void _startLocationPolling() {
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      getFriendLocation();
    });
  }

  // Stop polling when the page is disposed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getUserData() async {
    await Future.delayed(Duration(milliseconds: 1500));
    String? userDataString = await CacheService().getData("user_data");

    if (userDataString == null || userDataString.isEmpty) {
      userDataString = '{}'; // Default empty JSON if no data is found
    }

    userData = jsonDecode(jsonDecode(userDataString));
    setState(() {});
    getFriendLocation();
  }

  Future<void> getFriendLocation() async {
    final url = Uri.parse(
        '${DevConfig().travelAlertServiceBaseUrl}location/${userData['userID']}/friends');
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      friends = responseBody["friends"];

      setState(() {
        _addMarkers(); // Ensure markers update after fetching friends' locations
      });
    } else {
      print(response.statusCode);
    }
  }

  Future<BitmapDescriptor> getAssetImageMarker(String assetPath,
      {int width = 180}) async {
    try {
      // Load image from assets
      ByteData data = await rootBundle.load(assetPath);
      Uint8List imageData = data.buffer.asUint8List();

      // Decode image
      final ui.Codec codec =
          await ui.instantiateImageCodec(imageData, targetWidth: width);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ByteData? byteData =
          await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

      // Convert to BitmapDescriptor
      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _addMarkers(); // Ensure user's location is added
      });
    }
  }

  Future<void> _addMarkers() async {
    Set<Marker> newMarkers = {};

    if (_latitude != null && _longitude != null) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(_latitude!, _longitude!),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    }

    for (int i = 0; i < friends.length; i++) {
      if (friends[i]["location"] != null) {
        String profileImageUrl = ContactsPageAssets.mapProfilePic;

        BitmapDescriptor friendIcon =
            await getAssetImageMarker(profileImageUrl);

        newMarkers.add(
          Marker(
            markerId: MarkerId('friend$i'),
            position: LatLng(
              friends[i]["location"]["latitude"],
              friends[i]["location"]["longitude"],
            ),
            icon: friendIcon,
            infoWindow: InfoWindow(
              title: "${friends[i]["first_name"]} ${friends[i]["last_name"]}",
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _focusOnFriend(int index) {
    final friendLocation = friends[index]["location"];
    if (friendLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(friendLocation["latitude"], friendLocation["longitude"]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(18.461442656444465, 73.86496711190787),
                zoom: 16.4746,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {

                travel_mode = friends[index]["travel_mode"];

                return InkWell(
                  onTap: () {
                    _focusOnFriend(index);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300), // The duration of the animation
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: travel_mode
                          ? Color(0xFF85A947) // Light washed green color when traveling
                          : AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(travel_mode ? 16.0 : 8.0), // Animate border radius
                      boxShadow: travel_mode
                          ? [BoxShadow(color: Colors.black54, blurRadius: 10.0)] // Shadow for traveling state
                          : null,
                      // Adding a gradient that simulates a moving effect
                      gradient: travel_mode
                          ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.1, 0.5, 1],
                        colors: [
                          Color(0xFF6DBE56), // Darker green with a natural, earthy feel
                          Color(0xFF4D9B7A), // Slightly muted green, giving depth
                          Color(0xFF6DBE56), // Darker green with a natural, earthy feel
                        ],
                        tileMode: TileMode.repeated, // Creates continuous gradient animation
                      )
                          : null, // No gradient if not traveling
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.orange,
                          backgroundImage: AssetImage(
                            ContactsPageAssets.userProfilePic,
                          ),
                          radius: 30,
                        ),
                        SizedBox(width: 16.0),
                        // Space between avatar and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${friends[index]["first_name"]} ${friends[index]["last_name"]}",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${friends[index]["phone_no"]}",
                                style: TextStyle(color: Colors.black38, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        // If traveling, show an animated icon, else nothing
                        travel_mode
                            ? Container(
                          height: 40,
                          width: 40,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.deepBlue,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(
                                    'https://cdn-icons-gif.flaticon.com/10606/10606367.gif'),
                                fit: BoxFit.cover),
                          ),
                        )
                            : Container(), // Empty container when not traveling
                      ],
                    ),
                  ),
                )
                ;
              },
            ),
          ),
        ],
      ),
    );
  }
}
