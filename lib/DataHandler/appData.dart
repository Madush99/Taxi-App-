import 'package:flutter/cupertino.dart';
import 'package:flutter_taxiapp/Models/address.dart';

class AppData extends ChangeNotifier
{
  Address pickupLocation,dropOffLocation;

  void updatePickupLocationAddress(Address pickupAddress)
  {
    pickupLocation = pickupAddress;
    notifyListeners();
  }

  void updateDropOffLocation(Address dropOffAddress)
  {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

}