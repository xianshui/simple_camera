import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import './preview_page.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  FlashMode flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  @override
  void dispose() {
    if (controller != null) {
      controller.dispose();
    }

    super.dispose();
  }

  void initCamera() async {
    /*Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();*/

    cameras =  await availableCameras();

    print('length : ${cameras.length}');

    if (cameras.length > 0) {
      setState(() {
        selectedCameraIdx = 0;
      });

      initCameraController(cameras[selectedCameraIdx]);
    }
  }

  Future initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }


    try {
      controller = CameraController(cameraDescription, ResolutionPreset.high);

      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }

        if (controller.value.hasError) {
          print('Camera error ${controller.value.errorDescription}');
        }
      });

      await controller.initialize();

    } on CameraException catch (e) {
      print(e.description);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildHeaderBar() {
    return Container(
      color: Color(0x33000000),
      width: double.infinity,
      height: 40.w,
      child: buildCameraTogglesRow(),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Container(
      color: Color(0x33000000),
      width: 320.w,
      height: 50.w,
      child: Center(
        child: FlatButton.icon(
        onPressed: () {
          onPressedCapture(context);
        },
        icon: Icon(Icons.camera_alt, color: Colors.white, size: 32.w,),
        label: Text("")
        ),
      ),
    );
  }

  Widget buildCameraTogglesRow() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlatButton.icon(
              onPressed: onSwitchCamera,
              icon: Icon(getCameraLensIcon(lensDirection), color: Colors.white,),
              label: Text("")
          ),
          selectedCameraIdx == 0 ? FlatButton.icon(
              onPressed: onSwitchFlashMode,
              icon: Icon(flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on, color: Colors.white,),
              label: Text("")
          ) : Container(),

        ],
      )
    );
  }


  Widget buildCameraPreview(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: Text(
          'Loading',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
          ),
        )
      );
    }

    final size = MediaQuery.of(context).size;
    return AspectRatio(
      aspectRatio: size.width / size.height,
      child: CameraPreview(controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (ScreenUtil() == null) {
      ScreenUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: buildCameraPreview(context),
              ),
              cameras.length > 0 ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: buildHeaderBar()
              ) : Container(),
              cameras.length > 0 ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: buildBottomBar(context)
              ) : Container(),
            ],
          ),
        ),
      )
    );
  }


  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void onSwitchCamera() {
    selectedCameraIdx = selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    initCameraController(selectedCamera);
  }

  void onSwitchFlashMode() {
    setState(() {
      flashMode = flashMode == FlashMode.off ? FlashMode.always : FlashMode.off;
      controller.setFlashMode(flashMode);
    });
  }

  void onPressedCapture(BuildContext context) async {
    try {
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.jpg',
      );

      final file = await controller.takePicture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(path: file.path),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

}
