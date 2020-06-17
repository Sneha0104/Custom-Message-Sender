import 'package:custom_message_sender/main.dart';
import 'package:flutter/material.dart';
import 'db_halper.dart';
import 'add_note_view.dart';
import 'package:custom_message_sender/util/sharedprefs.dart';
import 'package:custom_message_sender/views/myhomepage.dart';
import 'note.dart';

final routeObserver = RouteObserver<PageRoute>();
final duration = const Duration(milliseconds: 300);

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with RouteAware {
  MyHomePageState home = MyHomePageState();
  GlobalKey _fabKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  final DatabaseHelper databaseHelper = DatabaseHelper();
  //_MyHomePageState home = _MyHomePageState();

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  //List<Note> noteList = databaseHelper.getNoteList();
  //AsyncSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    databaseHelper.initlizeDatabase();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Notes'),
      ),
      body: Container(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.882,
                  child: FutureBuilder(
                      future: databaseHelper.getNoteList(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Text('Loading');
                        } else {
                          if (snapshot.data.length < 1) {
                            return Center(
                              child: Text('No Messages, Create New one'),
                            );
                          }
                          return ReorderableListView(
                              children: List.generate(
                                snapshot.data.length,
                                (index) {
                                  return ListTile(
                                    key: Key('$index'),
                                    title: Text(
                                      snapshot.data[index].title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    subtitle: Text(snapshot.data[index].note,
                                        maxLines: 4),
                                    trailing: InkWell(
                                      child: Icon(Icons.check,
                                          color: Colors.green),
                                      onTap: () {
                                        TextEditingController txt =
                                            TextEditingController();

                                        txt.text = snapshot.data[index].note;
                                        print(txt);
                                        Route route = MaterialPageRoute(
                                            builder: (context) =>
                                                MyHomePage(custMessage: txt));
                                        Navigator.push(context, route);
                                        // addNewMessageDialog(txt);
                                      },
                                    ),
                                    isThreeLine: true,
                                    onTap: () {
                                      Route route = MaterialPageRoute(
                                          builder: (context) => AddNote(
                                                note: snapshot.data[index],
                                              ));
                                      Navigator.push(context, route);
                                    },
                                  );
                                },
                              ).toList(),
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final item = snapshot.data.removeAt(oldIndex);
                                  snapshot.data.insert(newIndex, item);
                                });
                              }

                              //Divider(color: Theme.of(context).accentColor),
                              );
                        }
                      }))
            ],
          )),
      floatingActionButton: _buildFAB(context, key: _fabKey),
    );
  }

  Widget _buildFAB(context, {key}) => FloatingActionButton(
        elevation: 0,
        key: key,
        onPressed: () => _onFabTap(context),
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      );

  _onFabTap(BuildContext context) {
    final RenderBox fabRenderBox = _fabKey.currentContext.findRenderObject();
    final fabSize = fabRenderBox.size;
    final fabOffset = fabRenderBox.localToGlobal(Offset.zero);

    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: duration,
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          AddNote(),
      transitionsBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) =>
          _buildTransition(child, animation, fabSize, fabOffset),
    ));
  }

  Widget _buildTransition(
    Widget page,
    Animation<double> animation,
    Size fabSize,
    Offset fabOffset,
  ) {
    if (animation.value == 1) return page;

    final borderTween = BorderRadiusTween(
      begin: BorderRadius.circular(fabSize.width / 2),
      end: BorderRadius.circular(0.0),
    );
    final sizeTween = SizeTween(
      begin: fabSize,
      end: MediaQuery.of(context).size,
    );
    final offsetTween = Tween<Offset>(
      begin: fabOffset,
      end: Offset.zero,
    );

    final easeInAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    );
    final easeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    final radius = borderTween.evaluate(easeInAnimation);
    final offset = offsetTween.evaluate(animation);
    final size = sizeTween.evaluate(easeInAnimation);

    final transitionFab = Opacity(
      opacity: 1 - easeAnimation.value,
      child: _buildFAB(context),
    );

    Widget positionedClippedChild(Widget child) => Positioned(
        width: size.width,
        height: size.height,
        left: offset.dx,
        top: offset.dy,
        child: ClipRRect(
          borderRadius: radius,
          child: child,
        ));

    return Stack(
      children: [
        positionedClippedChild(page),
        positionedClippedChild(transitionFab),
      ],
    );
  }
}
