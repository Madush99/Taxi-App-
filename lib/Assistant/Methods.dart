
import 'package:flutter_taxiapp/Assistant/requestAssit.dart';
import 'package:flutter_taxiapp/DataHandler/appData.dart';
import 'package:flutter_taxiapp/Models/address.dart';
import 'package:geolocator/geolocator.dart';
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
       st1 = placeAddress = response["results"][0]["address_components"][0]["long_name"]; //house no,flat no, office no
       st2 = placeAddress = response["results"][0]["address_components"][4]["long_name"]; //street number
       st3 = placeAddress = response["results"][0]["address_components"][5]["long_name"]; //city
       st4 = placeAddress = response["results"][0]["address_components"][6]["long_name"]; //country
       placeAddress = st1 +", "+ st2 +", " + st3+ ", "+st4;


        Address userPickUpAddress = new Address();
        userPickUpAddress.longitude = position.longitude;
        userPickUpAddress.latitude = position.latitude;
        userPickUpAddress.placeName = placeAddress;


        Provider.of<AppData>(context, listen: false).updatePickupLocationAddress(userPickUpAddress);

      }
    return placeAddress;
  }
}

