import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_taxiapp/AllScreens/searchScreen.dart';
import 'package:flutter_taxiapp/AllWidgets/Divider.dart';
import 'package:flutter_taxiapp/AllWidgets/progressDialog.dart';
import 'package:flutter_taxiapp/Assistant/Methods.dart';
import 'package:flutter_taxiapp/DataHandler/appData.dart';
import 'package:flutter_taxiapp/Models/directionDetails.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {

  static const String idScn = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double riderDetailsContainerHeight = 0;
  double searchContainerHeight = 300.0;

  bool drawerOpen = true;

  resetApp(){
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      riderDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRiderDetailsContainer() async
  {
    await getPlaceDirections();

    setState(() {
      searchContainerHeight = 0;
      riderDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;

    });
  }


  void locatePosition()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    
    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssisMethods.searchCoordinateAddress(position, context);
    print("This is your Address: " +address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(7.8774222 , 80.7003428),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png",height: 65.0,width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name", style: TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Visit Profile"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              DividerWidget(),

              SizedBox(height: 12.0,),

              //Drawer Body Controllers
              ListTile(
                leading: Icon(Icons.history),
                title: Text("History", style: TextStyle(fontSize: 15.0),),
              ),

              ListTile(
                leading: Icon(Icons.person),
                title: Text("Visit Profile", style: TextStyle(fontSize: 15.0),),
              ),

              ListTile(
                leading: Icon(Icons.info),
                title: Text("About", style: TextStyle(fontSize: 15.0),),
              ),

            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });

              locatePosition();
            },
          ),

          //HamburgerButton for Drawer
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: (){
                if(drawerOpen){
                  scaffoldKey.currentState.openDrawer();
                }else
                  {
                      resetApp();
                  }

              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close, color: Colors.black,),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0),topRight: Radius.circular(18.0)),
                  boxShadow:[
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),

                    ),
                  ] ,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0),
                      Text("Hi There", style: TextStyle(fontSize: 10.0),),
                      Text("Where to?", style: TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () async
                        {
                          var res = await Navigator.push(context,MaterialPageRoute(builder: (context) => SearchScreen()));

                          if(res == "obtainDirection")
                            {
                              displayRiderDetailsContainer();
                            }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow:[
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7,0.7),

                              ),
                            ] ,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent,),
                                SizedBox(width: 10.0,),
                                Text("Search Drop Off")
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.0,),
                      Row(
                        children: [
                         Icon(Icons.home, color: Colors.grey,),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Provider.of<AppData>(context).pickupLocation != null
                              ? Provider.of<AppData>(context).pickupLocation.placeName
                              :"Add Home"),
                              SizedBox(height: 4.0,),
                              Text("Your living Home", style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0,),

                      DividerWidget(),

                      SizedBox(height: 16.0,),

                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey,),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(height: 4.0,),
                              Text("Your office address", style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: riderDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0),),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("images/taxi.png", height: 70.0, width: 80,),
                              SizedBox(width: 16.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Car", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold",),
                                  ),
                                  Text(
                                    ((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : ''), style: TextStyle(fontSize: 16.0, color: Colors.grey,),
                                  ),
                                ],
                              ),
                              Expanded(child: Container(),),
                              Text(
                                ((tripDirectionDetails != null) ? '\$${AssisMethods.calculateFares(tripDirectionDetails)}' : ''), style: TextStyle(fontFamily: "Brand-Bold",),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyBillAlt, size: 18.0, color: Colors.black54,),
                            SizedBox(width: 16.0,),
                            Text("Cash"),
                            SizedBox(width: 6.0,),
                            Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16.0,),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: RaisedButton(
                          onPressed: (){
                            print("clicked");
                          },
                          color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Request", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                Icon(FontAwesomeIcons.taxi, color: Colors.white, size: 26.0,),
                              ],
                            ),
                          ),
                        ),

                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirections() async
  {
    var initialPos = Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLapLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLapLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait..",)
    );

    var details = await AssisMethods.obtainPlaceDirectionsDetails(pickUpLapLng, dropOffLapLng);
   setState(() {
     tripDirectionDetails = details;
   });

    Navigator.pop(context);

    print("This is encoded points:: ");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResults = polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if(decodedPolyLinePointsResults.isNotEmpty)
      {
        decodedPolyLinePointsResults.forEach((PointLatLng pointLatLng) {
          pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });
      }
    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineId"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if(pickUpLapLng.latitude > dropOffLapLng.latitude && pickUpLapLng.longitude > dropOffLapLng.longitude)
      {
        latLngBounds = LatLngBounds(southwest: dropOffLapLng, northeast: pickUpLapLng);
      }
    else if(pickUpLapLng.longitude > dropOffLapLng.longitude)
      {
        latLngBounds = LatLngBounds(southwest: LatLng(pickUpLapLng.latitude, dropOffLapLng.longitude), northeast: LatLng(dropOffLapLng.latitude, pickUpLapLng.longitude));
      }
    else if(pickUpLapLng.latitude > dropOffLapLng.latitude)
      {
        latLngBounds = LatLngBounds(southwest: LatLng(dropOffLapLng.latitude, pickUpLapLng.longitude), northeast: LatLng(pickUpLapLng.latitude, dropOffLapLng.longitude));
      }
    else
      {
        latLngBounds = LatLngBounds(southwest: pickUpLapLng, northeast: dropOffLapLng);
      }

    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "my location"),
      position: pickUpLapLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "DropOff location"),
      position: dropOffLapLng,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);

    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.yellow,
      center: pickUpLapLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLapLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}



