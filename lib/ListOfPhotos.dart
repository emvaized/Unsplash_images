import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import './PhotoView.dart';


class ListOfPhotos extends StatefulWidget {
  final fetchedData;
  final errorWhileLoading;

  ListOfPhotos({Key key, this.fetchedData, this.errorWhileLoading})
      : super(key: key);

  @override
  _ListOfPhotosState createState() => _ListOfPhotosState();
}

class _ListOfPhotosState extends State<ListOfPhotos> {
  Timer _timer;
  var _opacity = 0.0;

  //Анимация проявления экрана при запуске приложения
  // или обновления страницы способом "Pull down to refresh"
  _ListOfPhotosState() {
    _opacity = 0.0;
    _timer = new Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  // Метод, для удобства возвращающий определенные поля из массива fetchedData
  returnData(position, String key) {
    switch (key) {
      case 'profile_name': return widget.fetchedData[position]['user']['username']; break;
      case 'profile_photo': return widget.fetchedData[position]['user']['profile_image']['small']; break;
      case 'created': return widget.fetchedData[position]['created_at'].toString().split('T')[0]; break;
      case 'description': return widget.fetchedData[position]['description']; break;
      case 'photo': return widget.fetchedData[position]['urls']['small']; break;
      case 'photo_full': return widget.fetchedData[position]['urls']['full']; break;
      case 'photo_height': return widget.fetchedData[position]['height']; break;
      case 'photo_width': return widget.fetchedData[position]['width']; break;
      case 'likes': return widget.fetchedData[position]['likes'].toString(); break;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.errorWhileLoading
        ? _showErrorWhileLoading()
        : Padding(
            padding: EdgeInsets.only(right: 0),
            child: AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 500),
                child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowGlow();
                    },
                    child: new CustomScrollView(
                      slivers: <Widget>[
                        const SliverAppBar(
                          backgroundColor: Colors.black,
                          centerTitle: true,
                          pinned: true,
                          expandedHeight: 120.0,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text("Unsplash Images"),
                            collapseMode: CollapseMode.pin,
                          ),
                        ),
                        new SliverList(
                            delegate: new SliverChildBuilderDelegate(
                                (_, int position) {
                          return InkWell(
                              onTap: () => _goToFullscreenPage(position),
                              child: Card(
                                  color: Colors.white,
                                  elevation: 10,
                                  margin: EdgeInsets.all(15.0),
                                  child: new Column(
                                    children: <Widget>[
                                      // CARD HEADER //////////////////////////
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 6.0,
                                              right: 6.0,
                                              bottom: 1.0),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              new Row(children: <Widget>[
                                                new Image.network(
                                                  returnData(position, 'profile_photo'),
                                                  height: 25,
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 9.0),
                                                    child: new Text(returnData(position, 'profile_name'))),
                                              ]),
                                              new Row(
                                                children: <Widget>[
                                                  new Text(
                                                    returnData(position, 'created'),
                                                  ),
                                                ],
                                              ),
                                              new Row(children: <Widget>[
                                                IconButton(
                                                    icon: new Icon(
                                                      Icons.favorite_border,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: null),
                                                Text(returnData(position, 'likes'))
                                              ]),
                                            ],
                                          )),

                                      // CARD CONTENT /////////////////////////
                                      returnData(position, 'description') != null
                                          ? new ListTile(
                                              title: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.0, 1.0, 0.0, 1.0),
                                                  child: new Text(
                                                      '${returnData(position, 'description')}')),
                                            )
                                          : Container(),
                                      returnData(position, 'photo') != null
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 12.0,
                                                  right: 12.0,
                                                  bottom: 12.0),
                                              child: Hero(
                                                  tag: 'tag$position',
                                                  child: new CachedNetworkImage(
                                                    height: returnData(position, 'photo_height') /
                                                        returnData(position, 'photo_width') * 360,
                                                    width: 400,
                                                    imageUrl: returnData(position, 'photo'),
                                                    placeholder: (context, url) => new CircularProgressIndicator(),
                                                  )))
                                          : new Container(),
                                    ],
                                  )));
                        }, childCount: widget.fetchedData.length))
                      ],
                    ))));
  }

  _showErrorWhileLoading() {
    return ListView(
      padding: EdgeInsets.only(top: 250),
      children: <Widget>[
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Padding(
            child: Icon(Icons.cancel),
            padding: EdgeInsets.all(8.0),
          ),
          Text('Ошибка при загрузке.'),
          Text('Потяните вниз для обновления.')
        ])
      ],
    );
  }

  _goToFullscreenPage(position) {
    var photo = returnData(position, 'photo_full');
    var author = returnData(position, 'profile_name');

    Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new PhotoViewScreen(
        position: position,
        photo: photo,
        author: author,
      );
    }));
  }
}
