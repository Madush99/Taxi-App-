
import 'package:flutter_taxiapp/Assistant/requestAssit.dart';
import 'package:flutter_taxiapp/DataHandler/appData.dart';
import 'package:flutter_taxiapp/Models/address.dart';
import 'package:flutter_taxiapp/Models/directionDetails.dart';
import 'package:flutter_taxiapp/configMaps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class AssisMethods{

  static Future<String>searchCoordinateAddress(Position position,context)async
  {
    String placeAddress = "";
    String st1,st2,st3,st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyDURx5hDJH0kWkFrydwqRpAupXG687hfNQ";

    var response = await RequestAssistance.getRequest(url);

    if(response != "failed")
      {
       // placeAddress = response["results"][0]["formatted_address"]; shows the full address which is a user privacy issue
       st1 = placeAddress = response["results"][0]["address_components"][4]["long_name"]; //house no,flat no, office no
       st2 = placeAddress = response["results"][0]["address_components"][7]["long_name"]; //street number
       st3 = placeAddress = response["results"][0]["address_components"][6]["long_name"]; //city
       st4 = placeAddress = response["results"][0]["address_components"][9]["long_name"]; //country
       placeAddress = st1 +", "+ st2 +", " + st3+ ", "+st4;


        Address userPickUpAddress = new Address();
        userPickUpAddress.longitude = position.longitude;
        userPickUpAddress.latitude = position.latitude;
        userPickUpAddress.placeName = placeAddress;


        Provider.of<AppData>(context, listen: false).updatePickupLocationAddress(userPickUpAddress);

      }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionsDetails(LatLng initialPosition, LatLng finalPosition)async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude} &key=$mapKey";

    var res = await RequestAssistance.getRequest(directionUrl);

    if(res == "failed")
      {
        return null;
      }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints =  res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =  res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =  res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.distanceText =  res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.distanceValue =  res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails)
  {
    double timeTraveledFare = (directionDetails.durationValue /  60)  * 0.20;
    double distanceTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    return totalFareAmount.truncate();

  }

}

