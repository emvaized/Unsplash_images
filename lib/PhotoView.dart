import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoViewScreen extends StatelessWidget {
  final photo;
  final position;
  final author;

  PhotoViewScreen({Key key, this.photo, this.position, this.author})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text(
            'Фото от @$author',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: new PhotoView(
          heroTag: 'tag$position',
          backgroundDecoration: BoxDecoration(color: Colors.black),
          imageProvider: CachedNetworkImageProvider(photo),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: 4.0,
          transitionOnUserGestures: true,
        ));
  }
}
