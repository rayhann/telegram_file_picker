import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:telegram_file_picker/camera_place_holder.dart';
import 'package:transparent_image/transparent_image.dart';

class GalleryPicker extends StatefulWidget {
  const GalleryPicker({Key? key}) : super(key: key);

  @override
  _GalleryPickerState createState() => _GalleryPickerState();
}

class _GalleryPickerState extends State<GalleryPicker> {
  List<Album>? _albums;
  bool _loading = false;
  bool _appBarVisibility = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
          await PhotoGallery.listAlbums(mediumType: MediumType.image);
      setState(() {
        _albums = albums;
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          if (!_appBarVisibility && notification.extent == 1) {
            setState(() {
              _appBarVisibility = true;
            });
          } else if (_appBarVisibility && notification.extent < 1) {
            setState(() {
              _appBarVisibility = false;
            });
          }
          return false;
        },
        child: DraggableScrollableSheet(
          maxChildSize: 1,
          minChildSize: 0.4,
          initialChildSize: 0.5,
          builder: (BuildContext context, ScrollController scrollController) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _appBarVisibility
                      ? BorderRadius.circular(0)
                      : BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12),
                        )),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SizeTransition(
                          child: child, sizeFactor: animation);
                    },
                    child: _appBarVisibility
                        ? AppBar(
                            backgroundColor: Colors.white,
                            toolbarHeight: 80,
                            title: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(
                                'Gallery',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            leading: Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                              width: 64,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : AlbumPage(
                            album: _albums!.first,
                            scrollController: scrollController,
                            isFullScreen: _appBarVisibility,
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AlbumPage extends StatefulWidget {
  final Album album;
  final ScrollController scrollController;
  final bool isFullScreen;

  AlbumPage(
      {required this.album,
      required this.scrollController,
      required this.isFullScreen});

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium>? _media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage mediaPage = await widget.album.listMedia();
    setState(() {
      _media = mediaPage.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(widget.isFullScreen ? 0 : 8),
          topLeft: Radius.circular(widget.isFullScreen ? 0 : 8),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return GridView.count(
              padding: const EdgeInsets.all(0),
              physics: BouncingScrollPhysics(),
              controller: widget.scrollController,
              crossAxisCount: 3,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: <Widget>[
                Container(
                  child: CameraPlaceHolder(),
                  height: constraints.maxHeight,
                ),
                ...?_media?.map(
                  (medium) => GestureDetector(
                    child: Container(
                      color: Colors.grey[300],
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        placeholder: MemoryImage(kTransparentImage),
                        image: ThumbnailProvider(
                          mediumId: medium.id,
                          mediumType: medium.mediumType,
                          highQuality: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
