import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/models/user_model.dart';



final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList =[]; //online-active drivers key information list
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId = "";
String cloudMessagingServerToken = "key=AAAA5r6dUu8:APA91bEb3qV0Vavhfsgbttmx6cAQ78di928YScPbZRmrrrOG3f9gCVLum9h4npOPgK2vth5Ub5qTUrI6ALFknRJW35Dr9EpRgIcN-jnx_dMFznsL12TwK00lWHHX-Q_Dngb3auR1S7hC";
String userDropOffAddress = "";
String driverCarDetails="";
String driverName="";
String driverPhone="";
double countRatingStars=0.0;
String titleStarsRating="";