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
    return darkModeOn() ? const Color(0xFF191A19) : Colors.white;
  }

  static Color text() {
    return darkModeOn() ? Colors.white : Colors.black;
  }

  static Color sliderActive() {
    //return TinyColor.fromColor(lightGreen()[-100]).darken(20).color;
    return color1()[200]!;
  }

  static Color sliderInactive() {
    //return TinyColor.fromColor(lightGreen()[-200]).darken(20).color;
    return color1()[-200]!;
  }

  static double darkModeMultiplyer = 0.4;

  static Color appBar() {
    //return darkModeOn()?TinyColor.fromColor(Color(0xFF3AA2F2)).darken(15).color:Color(0xFF3AA2F2);
    return appBarNew()[-100]!;
  }

  static MaterialColor color1() {
    int primaryValue = 0xFF6F9069;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor color2() {
    int primaryValue = 0xFF68898F;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor color3() {
    int primaryValue = 0xFF69688F;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor color4() {
    int primaryValue = 0xFF888F68;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor color5() {
    int primaryValue = 0xFF688F89;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor color6() {
    int primaryValue = 0xFF8F6868;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor color7() {
    int primaryValue = 0xFF8F8668;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(20).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(10).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor appBarNew() {
    int primaryValue = 0xFF133319;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(15).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
          200: TinyColor.fromColor(Color(primaryValue)).darken(20).color,
        },
    );
  }

  static MaterialColor hint() {
    int primaryValue = 0xFFDADADA;
    return MaterialColor(
      primaryValue,
      <int, Color>{
          -200: TinyColor.fromColor(Color(primaryValue)).brighten(15).color,
          -100: TinyColor.fromColor(Color(primaryValue)).brighten(10).color,
          0: Color(primaryValue),
          100: TinyColor.fromColor(Color(primaryValue)).darken(5).color,
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
                                borderRadius: BorderRadius.circular(27.0),
                                gradient: widget.gradient ?? LinearGradient(
                                      colors: [
                                        MyColors.color1()[100]!,
                                        MyColors.color1()[-200]!
                                      ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                /*color: widget.gradient == null
                                    ? MyColors.color1()[100]
                                    : null*/),
                            padding: const EdgeInsets.fromLTRB(20.0, 10, 0, 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  widget.icon == null
                                      ? Container()
                                      : Flexible(
                                          flex: 7,
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
                                                          0.00,
                                                      color:
                                                          Colors.transparent)),
                                              alignment: Alignment.topRight,
                                              child: LayoutBuilder(builder:
                                                  (context, constraintOfIcon) {
                                                return Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0,
                                                      constraint.biggest.width *
                                                          0.015,
                                                      constraint.biggest.width *
                                                          0.08,
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
                                      flex: 10,
                                      fit: FlexFit.tight,
                                      child: LayoutBuilder(
                                          builder: (context, constraintOfIcon) {
                                        return Container(
                                            alignment: Alignment.centerLeft,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
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
                                              )
                                            ));
                                      })),
                                  widget.description == null
                                      ? Container()
                                      : Flexible(
                                          flex: 8,
                                          fit: FlexFit.tight,
                                          child: LayoutBuilder(builder:
                                              (context, constraintOfText) {
                                            return Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.fromLTRB(
                                                  constraintOfText
                                                          .biggest.width *
                                                      0.15,
                                                  0,
                                                  constraintOfText
                                                          .biggest.width *
                                                      0.04,
                                                  0),
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(
                                                  widget.description!,
                                                  style: TextStyle(
                                                      color: MyColors.text()),
                                                ),
                                              )
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
