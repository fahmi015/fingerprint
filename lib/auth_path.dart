import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthPath extends StatefulWidget {
  const AuthPath({Key key}) : super(key: key);

  @override
  State<AuthPath> createState() => _AuthPathState();
}

class _AuthPathState extends State<AuthPath> {


  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String _platformVersion = 'Unknown';
  Future<void> initformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {

    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }


  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);

      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:':'Failed to get platform version.'
      };
    }

    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.release': build.version.release,
      'fingerprint': build.host,
      'h':build.id,
      'b':build.type,
      'c':build.device,
      's':build.model,
      'e':build.hardware,
      'y':build.product,
      'z':build.brand,
      'A':build.supported32BitAbis

    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
      'id':data.identifierForVendor
    };
  }

  @override
  void initState() {
    initPlatformState();
    initformState();

    super.initState();
  }








  bool _hasBioSensor;
  LocalAuthentication authentication = LocalAuthentication();
  Future _checkBio() async{
    try{
      _hasBioSensor  = await authentication.canCheckBiometrics;
      print(_hasBioSensor);
      if(_hasBioSensor){
        _getAuth();
      }
    }on PlatformException catch(e){
      print(e);
    }
  }
  Future _getAuth() async{
    final List<BiometricType> availableBiometrics =
    await authentication.getAvailableBiometrics();
    bool isAuth = false;
    try{
      isAuth = await authentication.authenticate(
          localizedReason: 'Scan your finger print to access the app',
          options: AuthenticationOptions(
          useErrorDialogs: true,
          biometricOnly: true
        )
      );
      if(isAuth){
      print(availableBiometrics);
      }
      print(isAuth);
    }on PlatformException catch(e){
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3C3E52),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Login',style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 48
          ),),
          SizedBox(height: 20,),
          Image.asset('assets/fingerprint.png'),
          SizedBox(height: 15,),
          Text('Fingerprint Auth',style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 20
          ),),
          SizedBox(height: 30,),
          Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              height: 70,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  child: const Text('Check Auth'),
                  onPressed: () {
                    _checkBio();
                  },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder(), primary: Colors.green))),
        ],
      ),
    );
  }
}
