import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class YoutubeItem {
  String type;
  String title;
  String itemId;
  String description;
  String thumbnail;
  String link;

  YoutubeItem(
      {this.type,
      this.title,
      this.itemId,
      this.description,
      this.thumbnail,
      this.link});
}

class YouTubeFeed extends StatefulWidget {
  @override
  _YouTubeFeedState createState() => _YouTubeFeedState();
}

class _YouTubeFeedState extends State<YouTubeFeed> {
  List<YoutubeItem> items = new List();

  Future<String> _fetchItems() async {
    String uri =
        'https://www.googleapis.com/youtube/v3/search?key=AIzaSyDMzJvdj7xH40CMVnoW6kZPgVpXhn93aA8&channelId=UCwW9nPcEM2wGfsa06LTYlFg&part=snippet,id&order=date&maxResults=50';
    var response = await http.get(uri);
    var body = jsonDecode(response.body);
    items.clear();
    for (var item in body['items']) {
      String temp = item['id']['kind'].substring(8);
      String id =
          (temp == 'video') ? item['id']['videoId'] : item['id']['playlistId'];
      String link = (temp == 'video')
          ? 'https://www.youtube.com/watch?v=$id'
          : 'https://www.youtube.com/watch?v=I5y-v_QDmwg&list=$id';
      items.add(new YoutubeItem(
          type: temp,
          title: item['snippet']['title'],
          itemId: id,
          description: item['snippet']['description'],
          thumbnail: item['snippet']['thumbnails']['medium']['url'],
          link: link));
    }
    return 'success';
  }

  _launchURL(url) async {
    print('URL launched: $url');
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == 'success') {
          return Column(
            children: <Widget>[
              Center(
                child: Text(
                  "YouTube Feed",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)),
              Center(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(height * 0.4),
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 35.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: SizedBox(
                          width: width * 0.75,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: width * 0.75,
                                height: width * 0.75 / 1.77,
                                margin: EdgeInsets.only(right: 10.0),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _launchURL(items[index].link),
                                      child: Image.network(
                                        items[index].thumbnail,
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                  padding: EdgeInsets.only(right: 20.0),
                                  child: Center(
                                    child: Text(
                                      items[index].type == 'playlist'?'Playlist: '+items[index].title:items[index].title,
                                      style: TextStyle(fontSize: 20.0),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          );
        } else {
          return Container(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.red,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
}
