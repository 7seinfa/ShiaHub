import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:tinycolor2/tinycolor2.dart';

bool dark = true;
bool darkModeOn() {
  var brightness = SchedulerBinding.instance.window.platformBrightness;
  //return brightness==Brightness.light?false:true;
  return dark;
}

double titleSize(BuildContext context) {
  return MediaQuery.of(context).size.height * 0.04;
}

double toolbarSize(BuildContext context) {
  return MediaQuery.of(context).size.height * 0.06;
}

extension MyColors on Color {
  static Color background() {
    return darkModeOn() ? const Color(0xFF121212) : Colors.white;
  }

  static Color text() {
    return darkModeOn() ? Colors.white : Colors.black;
  }

  static Color card() {
    //return darkModeOn()?TinyColor.fromColor(Color(0xFF061d54)).darken(5).desaturate(30).color:TinyColor.fromColor(Color(0xFF2CBCF9)).brighten(50).desaturate(30).color;
    return darkModeOn()
        ? TinyColor.fromColor(emerald()[0]!).darken(15).color
        : TinyColor.fromColor(green()[-200]!).brighten(60).desaturate(20).color;
  }

  static Color sliderActive() {
    //return TinyColor.fromColor(lightGreen()[-100]).darken(20).color;
    return TinyColor.fromColor(appBar()).lighten(5).color;
  }

  static Color sliderInactive() {
    //return TinyColor.fromColor(lightGreen()[-200]).darken(20).color;
    return TinyColor.fromColor(appBar()).lighten(10).color;
  }

  static double darkModeMultiplyer = 0.4;

  static Color appBar() {
    //return darkModeOn()?TinyColor.fromColor(Color(0xFF3AA2F2)).darken(15).color:Color(0xFF3AA2F2);
    return green()[100]!;
  }

  static MaterialColor lightGreen() {
    int primaryValue = 0xFF01DF3C;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor green() {
    int primaryValue = 0xFF00b80e;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor springGreen() {
    int primaryValue = 0xFF00ffb0;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor sky() {
    int primaryValue = 0xFF008fff;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor darkBlue() {
    int primaryValue = 0xFF061d54;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor jungle() {
    int primaryValue = 0xFF3BAA87;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor blue() {
    int primaryValue = 0xFF3AA2F2;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor turquoise() {
    int primaryValue = 0xFF25D5E4;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor water() {
    int primaryValue = 0xFF38A8D1;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor emerald() {
    int primaryValue = 0xFF4ED37A;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }

  static MaterialColor lightBlue() {
    int primaryValue = 0xFF2CBCF9;
    return MaterialColor(
      primaryValue,
      darkModeOn()
          ? <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(5).color,
              -100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
              0: TinyColor.fromColor(Color(primaryValue)).darken(15).color,
              100: TinyColor.fromColor(Color(primaryValue)).darken(25).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(35).color,
            }
          : <int, Color>{
              -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
              -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
              0: Color(primaryValue),
              100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
              200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
            },
    );
  }
}

class HomeCard extends StatefulWidget {
  final LinearGradient? gradient;
  final String title;
  final String? description;
  final AssetImage? icon;
  final Color? iconBackground;
  final bool fullLength;
  final Function()? route;
  final bool isBlank;
  HomeCard(
      {Key? key,
      required this.title,
      this.description,
      this.gradient,
      this.icon,
      this.iconBackground,
      this.fullLength = false,
      this.route,
      this.isBlank = false})
      : super(key: key);

  @override
  _HomeCardState createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  Widget build(BuildContext context) {
    return Flexible(
        flex: 6,
        fit: FlexFit.tight,
        child: LayoutBuilder(builder: (context, constraint) {
          return Padding(
              padding: widget.fullLength
                  ? EdgeInsets.fromLTRB(
                      constraint.biggest.width * 0.03,
                      constraint.biggest.width * 0.01,
                      constraint.biggest.width * 0.03,
                      constraint.biggest.width * 0.01)
                  : EdgeInsets.all(constraint.biggest.width * 0.03),
              child: LayoutBuilder(builder: (context, constraint) {
                return widget.isBlank
                    ? Container()
                    : InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: widget.route,
                        child: Container(
                            height: widget.fullLength
                                ? constraint.biggest.width * 0.2
                                : constraint.biggest.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                gradient: widget.gradient,
                                color: widget.gradient == null
                                    ? MyColors.green()[0]
                                    : null),
                            padding: const EdgeInsets.fromLTRB(20.0, 10, 0, 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  widget.icon == null
                                      ? Container()
                                      : Flexible(
                                          flex: 4,
                                          fit: FlexFit.tight,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  color: widget.iconBackground,
                                                  border: Border.all(
                                                      width: constraint
                                                              .biggest.width *
                                                          0.02,
                                                      color:
                                                          Colors.transparent)),
                                              alignment: Alignment.topRight,
                                              child: LayoutBuilder(builder:
                                                  (context, constraintOfIcon) {
                                                return Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0,
                                                      0,
                                                      constraint.biggest.width *
                                                          0.05,
                                                      0),
                                                  child: ImageIcon(
                                                    widget.icon,
                                                    size: constraintOfIcon
                                                        .biggest.height,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }))),
                                  Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: LayoutBuilder(
                                          builder: (context, constraintOfIcon) {
                                        return Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.title,
                                              style: TextStyle(
                                                  fontSize: widget.fullLength
                                                      ? constraintOfIcon
                                                              .biggest.height *
                                                          0.4
                                                      : constraintOfIcon
                                                              .biggest.height *
                                                          0.38,
                                                  color: Colors.white),
                                            ));
                                      })),
                                  widget.description == null
                                      ? Container()
                                      : Flexible(
                                          flex: 4,
                                          fit: FlexFit.tight,
                                          child: LayoutBuilder(builder:
                                              (context, constraintOfText) {
                                            return Container(
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.fromLTRB(
                                                  constraintOfText
                                                          .biggest.width *
                                                      0.1,
                                                  0,
                                                  0,
                                                  0),
                                              child: Text(
                                                widget.description!,
                                                style: TextStyle(
                                                    fontSize: constraintOfText
                                                            .biggest.height *
                                                        0.3,
                                                    color: Colors.white),
                                              ),
                                            );
                                          })),
                                ])),
                      );
              }));
        }));
  }
}

class HomeCardList extends StatefulWidget {
  final List<Widget> cards;
  final Widget appbar;
  final bool fullLength;
  final String? title;
  HomeCardList(
      {Key? key,
      this.appbar = const SliverAppBar(
        title: Text(""), systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      required this.cards,
      this.fullLength = false,
      this.title})
      : super(key: key);

  @override
  _HomeCardStateList createState() => _HomeCardStateList();
}

class _HomeCardStateList extends State<HomeCardList> {
  Widget build(BuildContext context) {
    List<Widget> rows(int numPerRow) {
      List<Widget> rows = [];
      rows.add(Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
      ));
      for (int i = 0; i < widget.cards.length; i += numPerRow) {
        List<Widget> widgetInRows = [];
        int x = i;
        while (x < (i + numPerRow)) {
          widget.cards.length > x
              ? widgetInRows.add(widget.cards[x])
              : widgetInRows.add(HomeCard(
                  title: "",
                  isBlank: true,
                ));
          x++;
        }
        rows.add(Row(
          children: widgetInRows,
        ));
      }
      return rows;
    }

    return CustomScrollView(slivers: [
      widget.title == null
          ? widget.appbar
          : SliverAppBar(
              toolbarHeight: toolbarSize(context),
              bottom: PreferredSize(
                  // Add this code
                  preferredSize: Size(
                      double.infinity,
                      MediaQuery.of(context).size.height *
                          0.02), // Add this code
                  child: const Text("")),
              backgroundColor: MyColors.appBar(),
              leading: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.015),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              title: Padding(
                padding: EdgeInsets.fromLTRB(
                    0, MediaQuery.of(context).size.height * 0.016, 0, 0),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title!,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: titleSize(context)),
                        overflow: TextOverflow.visible,
                      ),
                    ]),
              ),
              actions: [
                Container(
                  width: 56,
                )
              ],
              centerTitle: false,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30))), systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
      SliverList(
          delegate: !widget.fullLength
              ? SliverChildListDelegate(
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? rows(2)
                      : rows(4))
              : SliverChildListDelegate(rows(1))),
    ]);
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
