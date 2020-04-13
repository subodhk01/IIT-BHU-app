import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:iit_app/model/appConstants.dart';
import 'package:iit_app/model/built_post.dart';
import 'package:iit_app/screens/home/home_widgets.dart';
import 'package:iit_app/data/workshop.dart';

class ClubPage extends StatefulWidget {
  final int clubId;
  final bool editMode;
  const ClubPage({Key key, @required this.clubId, this.editMode = false})
      : super(key: key);
  @override
  _ClubPageState createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  TextStyle tempStyle = TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold);
  var clubMap;
  @override
  void initState() {
    print("Club opened in edit mode:${widget.editMode}");
    fetchClubDataById();
    super.initState();
  }

  void fetchClubDataById() async {
    // print('AppConstants.djangoToken : ${AppConstants.djangoToken}');
    Response<BuiltClubPost> snapshots = await AppConstants.service
        .getClub(widget.clubId, "token ${AppConstants.djangoToken}")
        .catchError((onError) {
      print("Error in fetching clubs: ${onError.toString()}");
    });
    // print(snapshots.body);
    clubMap = snapshots.body;
    setState(() {});
  }

  void toggleSubscription() async {
    await AppConstants.service
        .toggleClubSubscription(
            widget.clubId, "token ${AppConstants.djangoToken}")
        .then((snapshot) {
      print("status of club subscription: ${snapshot.statusCode}");
    }).catchError((onError) {
      print("Error in toggleing: ${onError.toString()}");
    });
    fetchClubDataById();
    setState(() {});
  }

  final divide = Divider(height: 8.0, thickness: 2.0, color: Colors.blue);
  final space = SizedBox(height: 8.0);
  final headingStyle = TextStyle(
      fontSize: 30.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0);
  Widget template({String imageUrl, String name, String desg}) {
    return Column(
      children: <Widget>[
        space,
        Center(
            child: CircleAvatar(
          backgroundImage: imageUrl == null
              ? AssetImage('assets/iitbhu.jpeg')
              : NetworkImage(imageUrl),
          radius: 30.0,
          backgroundColor: Colors.transparent,
        )),
        Container(
          child: Text(name, textAlign: TextAlign.center),
          width: 100,
        ),
        Text(desg, textAlign: TextAlign.center),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.grey[300],
              floating: true,
              expandedHeight: MediaQuery.of(context).size.height / 4,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    clubMap == null
                        ? Container(
                            height: MediaQuery.of(context).size.height / 4,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height / 4,
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Image(
                                image: clubMap.large_image_url == null
                                    ? AssetImage('assets/iitbhu.jpeg')
                                    : NetworkImage(clubMap.large_image_url),
                                fit: BoxFit.fill,
                              ),
                              elevation: 2.5,
                            ),
                          ),
                    clubMap == null
                        ? Container()
                        : Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              child: FloatingActionButton(
                                elevation: 3.0,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                onPressed: () {},
                                child: Image(
                                  image: clubMap.council.small_image_url == null
                                      ? AssetImage('assets/iitbhu.jpeg')
                                      : NetworkImage(
                                          clubMap.council.small_image_url,
                                        ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  space,
                  clubMap == null
                      ? Container()
                      : Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                clubMap.name,
                                style: headingStyle,
                              ),
                              InkWell(
                                splashColor: clubMap.is_subscribed
                                    ? Colors.black87
                                    : Colors.red,
                                onTap: () => toggleSubscription(),
                                child: IconButton(
                                    color: Colors.red,
                                    iconSize: 30.0,
                                    icon: Icon(
                                      Icons.subscriptions,
                                      color: clubMap.is_subscribed
                                          ? Colors.red
                                          : Colors.black38,
                                    ),
                                    onPressed: null),
                              )
                            ],
                          ),
                        ),
                  space,
                  clubMap == null
                      ? Container(
                          height: MediaQuery.of(context).size.height / 4,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              clubMap.secy == null
                                  ? Container()
                                  : template(
                                      name: clubMap.secy.name,
                                      desg: 'Secy',
                                      imageUrl: clubMap.secy.photo_url),
                              // template(
                              //     name: clubMap.joint_secy[0].name,
                              //     desg: 'JointSecy',
                              //     imageUrl: clubMap.joint_secy[0].photo_url),
                              // template(
                              //     name: clubMap.joint_secy[1].name,
                              //     desg: 'JointSecy',
                              //     imageUrl: clubMap.joint_secy[1].photo_url),
                            ],
                          ),
                        ),
                  Center(
                    child: Text(
                      'Description',
                      style: headingStyle,
                    ),
                  ),
                  divide,
                  clubMap == null
                      ? Container()
                      : Text('${clubMap.description}',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                  space,
                  widget.editMode
                      ? Center(
                          child: Text(
                            'Edit Workshops HERE!',
                            style: headingStyle,
                          ),
                        )
                      : SizedBox(height: 1),
                  Center(
                    child: Text(
                      'Active Workshops',
                      style: headingStyle,
                    ),
                  ),
                  clubMap == null
                      ? Container(
                          height: MediaQuery.of(context).size.height / 4,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: clubMap.active_workshops.length,
                          // posts.length,
                          padding: EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return HomeWidgets.getWorkshopCard(
                              context,
                              w: Workshop.createWorkshopFromMap(
                                  clubMap.active_workshops[index]),
                              editMode: widget.editMode,
                            );
                          },
                        ),
                  Center(
                    child: Text(
                      'Past Workshops',
                      style: headingStyle,
                    ),
                  ),
                  clubMap == null
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: clubMap.past_workshops.length,
                          // posts.length,
                          padding: EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return HomeWidgets.getWorkshopCard(
                              context,
                              w: Workshop.createWorkshopFromMap(
                                  clubMap.past_workshops[index]),
                              editMode: widget.editMode,
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}