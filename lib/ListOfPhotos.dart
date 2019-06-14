import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  returnData(position, String key) {
    switch (key) {case 'profile_name': return widget.fetchedData[position]['user']['username']; break;
      case 'profile_photo': return widget.fetchedData[position]['user']['profile_image']['small']; break;
      case 'created': return widget.fetchedData[position]['created_at'].toString().split('T')[0]; break;
      case 'description': return widget.fetchedData[position]['description']; break;
      case 'photo': return widget.fetchedData[position]['urls']['small']; break;
      case 'photo_full': return widget.fetchedData[position]['urls']['full']; break;
      case 'photo_height': return widget.fetchedData[position]['height']; break;
      case 'photo_width': return widget.fetchedData[position]['width']; break;
      case 'post_likes': return widget.fetchedData[position]['likes'].toString(); break;
      default: return null;
    }
  }

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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  // CARD HEADER //////////////////////////
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 6.0,
                                          right: 6.0,
                                          bottom: 1.0),
                                      child: new Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          new Row(
                                            children: <Widget>[
                                              new Text(
                                                returnData(position, 'created'),
                                              ),
                                            ],
                                          ),
                                          new Row(children: <Widget>[
                                            new Image.network(
                                              returnData(position, 'profile_photo'),
                                              height: 25,
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 9.0),
                                                child: new Text(
                                                    returnData(position, 'profile_name'))
                                            ),
                                          ]),

                                          new Row(children: <Widget>[
                                            IconButton(
                                                icon: new Icon(Icons.favorite_border),
                                                onPressed: null),
                                            Text(returnData(
                                                position, 'post_likes'))
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
                                                  '${returnData(position, 'description')}', textAlign: TextAlign.center,)),
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
                                                        returnData(position,'photo_width') * 360,
                                                width: 400,
                                                imageUrl: returnData(position, 'photo'),
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
    var photo = returnData(position, 'photo_full');
    var author = returnData(position, 'profile_name');

    Navigator.of(context).push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new PhotoViewScreen(
        position: position,
        photo: photo,
        author: author,
      );
    }));
  }
}
