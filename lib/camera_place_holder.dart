import 'package:camerawesome/camerapreview.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/material.dart';

class CameraPlaceHolder extends StatefulWidget {
  const CameraPlaceHolder({Key? key}) : super(key: key);

  @override
  _CameraPlaceHolderState createState() => _CameraPlaceHolderState();
}

class _CameraPlaceHolderState extends State<CameraPlaceHolder> {
  bool _showIcon = false;

  ValueNotifier<Size> _photoSize = ValueNotifier(Size(500, 500));
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<CameraOrientations> _orientation =
      ValueNotifier(CameraOrientations.PORTRAIT_UP);

  void _onOrientationChange(CameraOrientations? newOrientation) {
    if (newOrientation != null) {
      _orientation.value = newOrientation;
    }
  }

  void _onPermissionsResult(bool? granted) {
    if (!granted!) {
      AlertDialog alert = AlertDialog(
        title: Text('Error'),
        content: Text(
            'It seems you doesn\'t authorized some permissions. Please check on your settings and try again.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      print("granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          Positioned(
            top: -4,
            bottom: 0,
            left: 0,
            right: 0,
            child: Hero(
              tag: 'camera',
              child: CameraAwesome(
                onPermissionsResult: _onPermissionsResult,
                captureMode: _captureMode,
                photoSize: _photoSize,
                sensor: _sensor,
                onOrientationChanged: _onOrientationChange,
                onCameraStarted: () {
                  if (!_showIcon) {
                    setState(() {
                      _showIcon = true;
                    });
                  }
                },
              ),
            ),
          ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: _showIcon ? 1 : 0,
            child: Center(
                child: Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 36,
            )),
          )
        ],
      ),
    );
  }
}
