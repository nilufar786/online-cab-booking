import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/infoHandler/app_info.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/trips_history_model.dart';
import 'package:users_app/models/user_model.dart';

import '../global/map_key.dart';
import 'package:http/http.dart' as http;

class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    String humanReadableAddress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if(requestResponse != "Error Occured, Failed. No response.")
      {
        humanReadableAddress = requestResponse["results"][0]["formatted_address"];
        Directions userPickupAddress = Directions();
        userPickupAddress.locationLatitude = position.latitude;
        userPickupAddress.locationLongitude = position.longitude;
        userPickupAddress.locationName = humanReadableAddress;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);

      }
    return humanReadableAddress;
  }
  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }
  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
  
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error Occured, Failed. No response.")
      {
        return null;
      }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.1;

    //1 USD = 120
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount * 120;

    return double.parse(localCurrencyTotalFare.toStringAsFixed(1));
  }

  static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context) async
  {
    String destinaionAddress = userDropOffAddress;

    Map<String, String> headerNotification =
        {
          'Content-Type' : 'application/json',
          'Authorization' : cloudMessagingServerToken,
        };
    Map bodyNotification =
        {
          "body":"Destination Address : \n$destinaionAddress.",
          "title":"New Trip Request"
        };

    Map dataMap =
        {
          "click_action" : "FLUTTER_NOTIFICATION_CLICK",
          "id" : "1",
          "status": "done",
          "rideRequestId" : userRideRequestId
        };

    Map officialNotificationFormat =
        {
          "notification": bodyNotification,
          "data" : dataMap,
          "priority" :"high",
          "to" : deviceRegistrationToken,
        };
    var responseNotification = http.post(
     Uri.parse( "https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }
  
  //retrieve the trips keys for online users
  //trip key = ride request key
  static void readTripsKeysForOnlineUser(context)
  {
  FirebaseDatabase.instance.ref()
      .child("All Ride Requests")
      .orderByChild("userName")
      .equalTo(userModelCurrentInfo!.name)
      .once()
      .then((snap)
  {
    if(snap.snapshot.value != null)
      {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with provider
       int overAllTripsCounter =  keysTripsId.length;
       Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

       //share trip keys with provider
        List<String> tripKeysList = [];
        keysTripsId.forEach((key, value)
        {
          tripKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripKeysList);

        //get trip keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static  void readTripsHistoryInformation(context)
  {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripKeysList;

    for(String eachKey in tripsAllKeys)
      {
        FirebaseDatabase.instance.ref()
            .child("All Ride Requests")
            .child(eachKey)
            .once()
            .then((snap)
        {
          var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

          if((snap.snapshot.value as Map)["status"] == "ended")
            {
              //update - add each history to overallTrips history data
              Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
            }

        });
      }
    }
 }