import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import './PhotoView.dart';

var file;

class ListOfPhotos extends StatefulWidget {
  var fetchedData;
  bool errorWhileLoading = false;

  ListOfPhotos({Key key, this.fetchedData, this.errorWhileLoading})
      : super(key: key);

  String returnData(position, String key) {
    switch (key) {
      case 'profile_name': return fetchedData[position]['user']['username']; break;
      case 'profile_photo': return fetchedData[position]['user']['profile_image']['small']; break;
      case 'created': return fetchedData[position]['created_at'].toString().split('T')[0]; break;
      case 'post_description': return fetchedData[position]['description']; break;
      case 'post_media': return fetchedData[position]['urls']['small']; break;
      case 'post_media_full': return fetchedData[position]['urls']['raw']; break;
      case 'post_likes': return fetchedData[position]['likes'].toString(); break;
      default: return null;
    }
  }

  @override
  _ListOfPhotosState createState() => _ListOfPhotosState();
}

class _ListOfPhotosState extends State<ListOfPhotos> {
  @override
  Widget build(BuildContext context) {
    return widget.errorWhileLoading
        ? _showErrorWhileLoading()
        : Padding(
            padding: EdgeInsets.only(right: 1),
            child: Scrollbar(
                child: ListView.builder(
                    itemCount: widget.fetchedData.length,
                    itemBuilder: (_, int position) {
                      return InkWell(
                          onTap: () => _goToFullscreenPage(position),
                          child: Card(
                              color: Colors.white,
                              elevation: 6,
                              margin: EdgeInsets.all(15.0),
                              child: new Column(
                                children: <Widget>[
                                  // CARD HEADER //////////////////////////
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 6.0, right: 6.0, top: 6.0),
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          new Row(children: <Widget>[
                                            new Image.network(
                                              widget.returnData(
                                                  position, 'profile_photo'),
                                              height: 25,
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 9.0),
                                                child: new Text(
                                                    widget.returnData(position,
                                                        'profile_name'))),
                                          ]),
                                          new Row(
                                            children: <Widget>[
                                              new Text(
                                                widget.returnData(
                                                    position, 'created'),
                                              ),
                                            ],
                                          ),
                                          new Row(children: <Widget>[
                                            IconButton(
                                                icon: new Icon(
                                                    Icons.favorite_border),
                                                onPressed: null),
                                            Text(widget.returnData(
                                                position, 'post_likes'))
                                          ]),
                                        ],
                                      )),

                                  // CARD CONTENT /////////////////////////
                                  widget.returnData(position, 'post_description') != null
                                      ? new ListTile(
                                          title: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0.0, 3.0, 0.0, 3.0),
                                              child: new Text(
                                                  '${widget.returnData(position, 'post_description')}')),
                                        )
                                      : Container(),
                                  widget.returnData(position, 'post_media') != null
                                      ? Padding(
                                          padding: EdgeInsets.all(15.0),
                                          child: Hero(
                                              tag: 'tag$position',
                                              flightShuttleBuilder:
                                                  (flightContext,animation,direction,fromContext,toContext) {
                                                if (direction == HeroFlightDirection.push) {
                                                  _cacheImage(widget.returnData(
                                                      position, 'post_media'));
                                                  return Center(
                                                      child: CircularProgressIndicator());
                                                } else if (direction ==
                                                    HeroFlightDirection.pop) {
                                                  return Image.file(file);
                                                }
                                              },
                                              child: new CachedNetworkImage(
                                                imageUrl: widget.returnData(
                                                    position, 'post_media'),
                                                placeholder: (context, url) =>
                                                    new CircularProgressIndicator(),
                                              )))
                                      : new Container(),
                                ],
                              )));
                    })));
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
    var photo = widget.returnData(position, 'post_media_full');
    var author = widget.returnData(position, 'profile_name');

    Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new PhotoViewScreen(
        position: position,
        photo: photo,
        author: author,
      );
    }));
  }

  _cacheImage(url) async {
    var newFile = await DefaultCacheManager().getSingleFile(url);
    file = newFile;
  }
}
