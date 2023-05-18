import 'package:drivers_app/authentication/car_info_screen.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/widgets/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}




class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool _obsecureText = true;

  validateForm()
  {
    if(nameTextEditingController.text.length<3)
      {
        Fluttertoast.showToast(msg: "name must be atleast 3 Characters.");
      }
    else if(!emailTextEditingController.text.contains("@"))
      {
        Fluttertoast.showToast(msg: "Email address is not Valid.");

      }
    else if(phoneTextEditingController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Phone Number is required.");

    }
    else if(phoneTextEditingController.text.length<10)
    {
      Fluttertoast.showToast(msg: "Phone Number must be 10 digits");
    }
    else if(passwordTextEditingController.text.length < 8)
    {
      Fluttertoast.showToast(msg: "Password must be atleast 8 Characters.");

    }
    else
      {
        saveDriverInfoNow();
      }
  }

 saveDriverInfoNow() async
 {
   showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext c)
       {
         return ProgressDialog(message: "Processing, Please Wait...",);
       }
   );

   final User? firebaseUser = (
       await fAuth.createUserWithEmailAndPassword(
         email: emailTextEditingController.text.trim(),
         password: passwordTextEditingController.text.trim(),
       ).catchError((msg){
         Navigator.pop(context);
         Fluttertoast.showToast(msg: "Error:" + msg.toString());
       })
   ).user;
   if(firebaseUser != null)
   {
     Map driverMap =
     {
       "id": firebaseUser.uid,
       "name": nameTextEditingController.text.trim(),
       "email": emailTextEditingController.text.trim(),
       "phone": phoneTextEditingController.text.trim(),
     };

     DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
     driversRef.child(firebaseUser.uid).set(driverMap);

     currentFirebaseUser = firebaseUser;
     Fluttertoast.showToast(msg: "Account has been Created.");
     Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));

   }
   else
     {
       Navigator.pop(context);
       Fluttertoast.showToast(msg: "Account has not been Created.");
     }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              const SizedBox(height: 10,),

              Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo.png"),
              ),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Register as a Driver",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,

                ),
              ),
              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Name",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.email),
                  labelText: "E-mail",
                  hintText: "E-mail",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.phone),
                  labelText: "Phone",
                  hintText: "Phone",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: _obsecureText,
                style: const TextStyle(
                  color: Colors.grey,
                ),
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: (){
                      setState(() {
                        _obsecureText = !_obsecureText;
                      });
                    },
                    child: Icon(_obsecureText ?Icons.visibility : Icons.visibility_off),
                  ),
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),

                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20,),


              ElevatedButton(
                onPressed: ()
                {
                  validateForm();
                 // Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));
                },
                style: ElevatedButton.styleFrom(
                  primary : Colors.lightGreenAccent,
                ),
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),


              TextButton(
                child: const Text(
                  "Allready have an Account? Login Here",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
