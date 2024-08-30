import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'audio.dart';
import 'theme.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:audioplayers/audioplayers.dart' as ap;

class JuzOrSurah extends StatefulWidget {
  const JuzOrSurah({Key? key}) : super(key: key);

  @override
  _JuzOrSurahState createState() => _JuzOrSurahState();
}

class _JuzOrSurahState extends State<JuzOrSurah> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeCardList(
        title: "Quran",
        cards: [
          HomeCard(
            title: "Quran by Juz'",
            fullLength: true,
            route: () {
              Navigator.of(context).pushNamed("/quran/juz/");
            },
          ),
          HomeCard(
            title: "Quran by Surah",
            fullLength: true,
            route: () {
              Navigator.of(context).pushNamed("/quran/surah/");
            },
          ),
        ],
        fullLength: true,
      ),
    );
  }
}

class Juz extends StatefulWidget {
  const Juz({Key? key}) : super(key: key);

  @override
  _JuzState createState() => _JuzState();
}

class _JuzState extends State<Juz> {
  List<HomeCard> cards = [];
  var engAyas = [];
  var urAyas = [];
  var faAyas = [];

  List<String> ayasInSura = [];
  List<String> engAyasInSura = [];
  List<String> faAyasInSura = [];
  List<String> urAyasInSura = [];
  bool eng = false;
  bool ur = false;
  bool fa = false;
  var engTranslation;
  String engValue = '';
  var urTranslation;
  String urValue = '';
  var faTranslation;
  String faValue = '';
  var startSurah;
  var startAya;
  var endSurah;
  var endAya;
  var surahList;
  var juzNums;
  List<String> reciterNames = [];
  List<String> recitations = [];
  List<DropdownMenuItem> recites = [];
  String curName = '';
  String curRecite = '';

  Future<String> loadSurahInfo(String link) async {
    return await rootBundle.loadString(link);
  }

  @override
  void initState() {
    loadInfo();
    super.initState();
  }

  void loadInfo() async {
    surahList = json
        .decode(await loadSurahInfo('assets/jsons/quran/quranUthmani.json'));
    for (int i = 0; i <= 29; i++) {
      cards.add(HomeCard(
        title: "Juz' ${i + 1}",
        fullLength: true,
        route: () async {
          var prefs = await SharedPreferences.getInstance();
          if (prefs.containsKey("eng") &&
              prefs.containsKey("fa") &&
              prefs.containsKey("ur")) {
            if (prefs.getBool("eng")!) {
              eng = true;
              if (prefs.getString("engTrans") == "sarwar") {
                engTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/sarwar.json'));
                //engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
                engValue = "sarwar";
              } else if (prefs.getString("engTrans") == "qarai") {
                engTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/qarai.json'));
                //engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
                engValue = "qarai";
              } else if (prefs.getString("engTrans") == "en.ali") {
                engTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/en.ali.json'));
                //engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
                engValue = "en.ali";
              } else {
                engTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/qarai.json'));
                eng = false;
                //engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
                engValue = "none";
              }
            } else {
              eng = false;
              engValue = "none";
            }
            if (prefs.getBool("ur")!) {
              ur = true;
              if (prefs.getString("urTrans") == "najafi") {
                urTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/najafi.json'));
                //urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
                urValue = "najafi";
              } else if (prefs.getString("urTrans") == "jawadi") {
                urTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/jawadi.json'));
                //urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
                urValue = "jawadi";
              } else if (prefs.getString("urTrans") == "ur.ali") {
                urTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/ur.ali.json'));
                //urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
                urValue = "ur.ali";
              } else {
                urTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/najafi.json'));
                //urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
                urValue = "none";
              }
            } else {
              ur = false;
              urValue = "none";
            }
            if (prefs.getBool("fa")!) {
              fa = true;
              if (prefs.getString("faTrans") == "makarem") {
                faTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/makarem.json'));
                //faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
                faValue = "makarem";
              } else if (prefs.getString("faTrans") == "ansarian") {
                faTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/ansarian.json'));
                //faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
                faValue = "ansarian";
              } else if (prefs.getString("faTrans") == "tehrani") {
                faTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/tehrani.json'));
                //faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
                faValue = "tehrani";
              } else {
                faTranslation = json.decode(
                    await loadSurahInfo('assets/jsons/quran/makarem.json'));
                //faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
                faValue = "none";
              }
            } else {
              fa = false;
              faValue = "none";
            }
          } else {
            prefs.setString("engTrans", "none");
            prefs.setString("urTrans", "none");
            prefs.setString("faTrans", "none");
            prefs.setBool("eng", false);
            eng = false;
            prefs.setBool("ur", false);
            ur = false;
            prefs.setBool("fa", false);
            fa = false;
          }
          juzNums =
              json.decode(await loadSurahInfo('assets/jsons/quran/juz.json'));
          ayasInSura = [];
          engAyasInSura = [];
          faAyasInSura = [];
          urAyasInSura = [];
          startSurah = juzNums[i]["beginning"]["surahNum"] - 1;
          startAya = juzNums[i]["beginning"]["ayaNum"] - 1;
          endSurah = juzNums[i]["end"]["surahNum"] - 1;
          endAya = juzNums[i]["end"]["ayaNum"] - 1;
          if (startSurah == endSurah) {
            ayasInSura.add(surahList["quran"]["sura"][0]["aya"][0]["-text"]);
            if (startSurah == juzNums[i]["beginning"]["surahNum"]) {
              for (int x = startAya; x <= endAya; x++) {
                ayasInSura.add(surahList["quran"]["sura"][startSurah]["aya"][x]
                            ["-text"]
                        .replaceAll('\u06ED', '') +
                    "\n﴿" +
                    engNumToArb((x + 1).toString()) +
                    "﴾");
              }
            } else {
              for (int x = startAya; x <= endAya; x++) {
                ayasInSura.add(surahList["quran"]["sura"][endSurah]["aya"][x]
                            ["-text"]
                        .replaceAll('\u06ED', '') +
                    "\n﴿" +
                    engNumToArb((x + 1).toString()) +
                    "﴾");
              }
            }
          } else {
            for (int x = startSurah; x < endSurah; x++) {
              if (x != 0 && x != 8) {
                ayasInSura.add(surahList["quran"]["sura"][0]["aya"][0]["-text"]
                    .replaceAll('\u06ED', ''));
              } else if (x == 8) {
                ayasInSura.add("");
              }
              for (int y = startAya;
                  y < surahList["quran"]["sura"][x]["aya"].length;
                  y++) {
                ayasInSura.add(surahList["quran"]["sura"][x]["aya"][y]["-text"]
                        .replaceAll('\u06ED', '') +
                    "\n﴿" +
                    engNumToArb((y + 1).toString()) +
                    "﴾");
              }
            }
            if (endSurah != 0 && endSurah != 8) {
              ayasInSura.add(surahList["quran"]["sura"][0]["aya"][0]["-text"]
                  .replaceAll('\u06ED', ''));
            } else if (endSurah == 8) {
              ayasInSura.add("");
            }
            for (int x = 0; x <= endAya; x++) {
              ayasInSura.add(surahList["quran"]["sura"][endSurah]["aya"][x]
                          ["-text"]
                      .replaceAll('\u06ED', '') +
                  "\n﴿" +
                  engNumToArb((x + 1).toString()) +
                  "﴾");
            }
          }
          if (eng) {
            loadEngAyas(i);
          }
          if (ur) {
            loadUrAyas(i);
          }
          if (fa) {
            loadFaAyas(i);
          }

          reciterNames = [];
          recitations = [];
          recites = [];
          for (int x = 0; x < juzNums[i]["reciters"].entries.length; x++) {
            reciterNames.add(juzNums[i]["reciters"].entries.elementAt(x).key);
            recitations.add(juzNums[i]["reciters"].entries.elementAt(x).value);
            if (prefs.getString("defJuzReciter") != null) {
              if (prefs.getString("defJuzReciter") == reciterNames[x]) {
                curName = reciterNames[x];
                curRecite = recitations[x];
              }
            } else {
              prefs.setString("defJuzReciter", reciterNames[0]);
              curName = reciterNames[0];
              curRecite = recitations[0];
            }

            recites.add(DropdownMenuItem(
              value: juzNums[i]["reciters"].entries.elementAt(x).value,
              onTap: () {
                curName = juzNums[i]["reciters"].entries.elementAt(x).key;
                prefs.setString("defJuzReciter", curName);
              },
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                    width: constraints.maxWidth,
                    child: Text(
                      juzNums[i]["reciters"].entries.elementAt(x).key,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyColors.text()),
                    ));
              }),
            ));
          }

          var route = MaterialPageRoute(
              builder: (BuildContext context) => JuzView(
                    juzIndex: i,
                    ayasInSura: ayasInSura,
                    engAyasInSura: engAyasInSura,
                    urAyasInSura: urAyasInSura,
                    faAyasInSura: faAyasInSura,
                    eng: eng,
                    fa: fa,
                    ur: ur,
                    engValue: engValue,
                    faValue: faValue,
                    urValue: urValue,
                    recitations: recitations,
                    reciterNames: reciterNames,
                    recites: recites,
                    curName: curName,
                    curRecite: curRecite,
                  ));
          Navigator.of(context).push(route);
        },
      ));
    }
    setState(() {});
  }

  void loadEngAyas(int x) {
    engAyasInSura = [];

    if (startSurah == endSurah) {
      engAyasInSura.add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      if (startSurah == juzNums[x]["beginning"]["surahNum"]) {
        for (int i = startAya; i <= endAya; i++) {
          engAyasInSura.add(
              engTranslation["quran"]["sura"][startSurah]["aya"][i]["-text"]);
        }
      } else {
        for (int i = startAya; i <= endAya; i++) {
          engAyasInSura.add(
              engTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
        }
      }
    } else {
      for (int i = startSurah; i < endSurah; i++) {
        if (i != 0 && i != 8) {
          engAyasInSura
              .add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
        } else if (i == 8) {
          engAyasInSura.add("");
        }
        for (int x = startAya;
            x < engTranslation["quran"]["sura"][i]["aya"].length;
            x++) {
          engAyasInSura
              .add(engTranslation["quran"]["sura"][i]["aya"][x]["-text"]);
        }
      }
      if (endSurah != 0 && endSurah != 8) {
        engAyasInSura
            .add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      } else if (endSurah == 8) {
        engAyasInSura.add("");
      }
      for (int i = 0; i <= endAya; i++) {
        engAyasInSura
            .add(engTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
      }
    }
    eng = true;
  }

  void loadUrAyas(int x) {
    urAyasInSura = [];

    if (startSurah == endSurah) {
      urAyasInSura.add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      if (startSurah == juzNums[x]["beginning"]["surahNum"]) {
        for (int i = startAya; i <= endAya; i++) {
          urAyasInSura.add(
              urTranslation["quran"]["sura"][startSurah]["aya"][i]["-text"]);
        }
      } else {
        for (int i = startAya; i <= endAya; i++) {
          urAyasInSura
              .add(urTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
        }
      }
    } else {
      for (int i = startSurah; i < endSurah; i++) {
        if (i != 0 && i != 8) {
          urAyasInSura
              .add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
        } else if (i == 8) {
          urAyasInSura.add("");
        }
        for (int x = startAya;
            x < urTranslation["quran"]["sura"][i]["aya"].length;
            x++) {
          urAyasInSura
              .add(urTranslation["quran"]["sura"][i]["aya"][x]["-text"]);
        }
      }
      if (endSurah != 0 && endSurah != 8) {
        urAyasInSura.add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      } else if (endSurah == 8) {
        urAyasInSura.add("");
      }
      for (int i = 0; i <= endAya; i++) {
        urAyasInSura
            .add(urTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
      }
    }
    ur = true;
  }

  void loadFaAyas(int x) {
    faAyasInSura = [];

    if (startSurah == endSurah) {
      faAyasInSura.add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      if (startSurah == juzNums[x]["beginning"]["surahNum"]) {
        for (int i = startAya; i <= endAya; i++) {
          faAyasInSura.add(
              faTranslation["quran"]["sura"][startSurah]["aya"][i]["-text"]);
        }
      } else {
        for (int i = startAya; i <= endAya; i++) {
          faAyasInSura
              .add(faTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
        }
      }
    } else {
      for (int i = startSurah; i < endSurah; i++) {
        if (i != 0 && i != 8) {
          faAyasInSura
              .add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
        } else if (i == 8) {
          faAyasInSura.add("");
        }
        for (int x = startAya;
            x < faTranslation["quran"]["sura"][i]["aya"].length;
            x++) {
          faAyasInSura
              .add(faTranslation["quran"]["sura"][i]["aya"][x]["-text"]);
        }
      }
      if (endSurah != 0 && endSurah != 8) {
        faAyasInSura.add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      } else if (endSurah == 8) {
        faAyasInSura.add("");
      }
      for (int i = 0; i <= endAya; i++) {
        faAyasInSura
            .add(faTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
      }
    }
    fa = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeCardList(
        title: "Quran by Juz'",
        cards: cards,
        fullLength: true,
      ),
    );
  }
}

class JuzView extends StatefulWidget {
  final int juzIndex;
  final List<String>? ayasInSura;
  final List<String>? engAyasInSura;
  final List<String>? faAyasInSura;
  final List<String>? urAyasInSura;
  final bool eng;
  final bool ur;
  final bool fa;
  final String engValue;
  final String urValue;
  final String faValue;
  final List<String>? reciterNames;
  final List<String>? recitations;
  final List<DropdownMenuItem>? recites;
  final String curRecite;
  final String curName;
  const JuzView(
      {Key? key,
      this.juzIndex=0,
      this.ayasInSura,
      this.engAyasInSura,
      this.faAyasInSura,
      this.urAyasInSura,
      this.eng=false,
      this.ur=false,
      this.fa=false,
      this.engValue='',
      this.urValue='',
      this.faValue='',
      this.reciterNames,
      this.recitations,
      this.recites,
      this.curName='',
      this.curRecite=''})
      : super(key: key);

  @override
  _JuzViewState createState() => _JuzViewState();
}

class _JuzViewState extends State<JuzView> {
  List<Widget> ayas = [];
  bool eng = false;
  bool ur = false;
  bool fa = false;
  BehaviorSubject<bool> engS = BehaviorSubject<bool>();
  BehaviorSubject<bool> urS = BehaviorSubject<bool>();
  BehaviorSubject<bool> faS = BehaviorSubject<bool>();

  String engValue = "none";
  String urValue = "none";
  String faValue = "none";

  bool done = false;
  var engAyasInSura;
  List<Widget> engAyas = [];
  var urAyasInSura;
  List<Widget> urAyas = [];
  var faAyasInSura;
  List<Widget> faAyas = [];

  var ayasInSura;

  var engTranslation;
  var urTranslation;
  var faTranslation;
  double arabicSize=0;
  double farsiSize=0;
  double englishSize=0;
  double urduSize=0;
  bool font=false;

  SharedPreferences? prefs;

  var tafsir;
  var surahTafsir;

  List<HomeCard> cards = [];

  var juzNums;
  var startSurah;
  var startAya;
  var endSurah;
  var endAya;

  List<String> reciterNames = [];
  List<String> recitations = [];
  List<DropdownMenuItem> recites = [];
  String curRecite = "testing";
  String curName = "testing";

  @override
  void initState() {
    this.getJsonData();
    super.initState();
  }

  @override
  void dispose() {
    release();
    super.dispose();
  }

  Future<String> loadSurahInfo(String link) async {
    return await rootBundle.loadString(link);
  }

  Future<String> getJsonData() async {
    audioPlayer = ap.AudioPlayer();
    engS = BehaviorSubject<bool>();
    urS = BehaviorSubject<bool>();
    faS = BehaviorSubject<bool>();

    engAyas = [];
    urAyas = [];
    faAyas = [];
    done = false;
    prefs = await SharedPreferences.getInstance();

    juzNums = json.decode(await loadSurahInfo('assets/jsons/quran/juz.json'));
    startSurah = juzNums[widget.juzIndex]["beginning"]["surahNum"] - 1;
    startAya = juzNums[widget.juzIndex]["beginning"]["ayaNum"] - 1;
    endSurah = juzNums[widget.juzIndex]["end"]["surahNum"] - 1;
    endAya = juzNums[widget.juzIndex]["end"]["ayaNum"] - 1;

    tafsir = json.decode(await loadSurahInfo('assets/jsons/quran/tafsir.json'));
    //surahTafsir = tafsir[widget.surahNum];
    loadTafsir();

    //var ayasInSura = surahList["quran"]["sura"][widget.surahNum]["aya"];
    ayasInSura = widget.ayasInSura;
    engAyasInSura = widget.engAyasInSura;
    faAyasInSura = widget.faAyasInSura;
    urAyasInSura = widget.urAyasInSura;
    eng = widget.eng;
    fa = widget.fa;
    ur = widget.ur;
    engValue = widget.engValue;
    urValue = widget.urValue;
    faValue = widget.faValue;
    recitations = widget.recitations!;
    reciterNames = widget.reciterNames!;
    recites = widget.recites!;
    curName = widget.curName;
    curRecite = widget.curRecite;
    if (prefs!.getDouble("quranEnglishFont") == null) {
      prefs!.setDouble("quranEnglishFont", 28);
    }
    if (prefs!.getDouble("quranFarsiFont") == null) {
      prefs!.setDouble("quranFarsiFont", 28);
    }
    if (prefs!.getDouble("quranUrduFont") == null) {
      prefs!.setDouble("quranUrduFont", 28);
    }
    if (prefs!.getDouble("quranArabicFont") == null) {
      prefs!.setDouble("quranArabicFont", 34);
    }
    arabicSize = prefs!.getDouble("quranArabicFont")!;
    englishSize = prefs!.getDouble("quranEnglishFont")!;
    farsiSize = prefs!.getDouble("quranFarsiFont")!;
    urduSize = prefs!.getDouble("quranUrduFont")!;

    if (prefs!.getBool("qurFont") != null) {
      if (prefs!.getBool("qurFont")!) {
        font = true;
      } else {
        font = false;
      }
    } else {
      prefs!.setBool("qurFont", true);
      font = true;
    }
    for (int i = 0; i < ayasInSura.length; i++) {
      ayas.add(Expanded(
        child: Container(
          child: LayoutBuilder(builder: (context, constraint) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  constraint.biggest.width * 0.03,
                  constraint.biggest.width * 0.01,
                  constraint.biggest.width * 0.03,
                  constraint.biggest.width * 0.01),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      colors: [
                        MyColors.color1()[0]!,
                        MyColors.color1()[200]!
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        constraint.biggest.width * 0.03,
                        constraint.biggest.width * 0.04,
                        constraint.biggest.width * 0.03,
                        constraint.biggest.width * 0.01),
                    child: Column(
                      children: [
                        Text(
                          font
                              ? ayasInSura[i]
                                  .replaceAll('لَٰٓ', 'لَـٰۤـ')
                                  .replaceAll('ٱلْءَا', 'ٱلۡـَٔا')
                              : engNumToInd(
                                  ayasInSura[i].replaceAll('ٌ ۖ', 'ٌ   ۖ')),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyColors.text(),
                              fontSize: prefs!.getDouble("quranArabicFont"),
                              fontFamily: font ? "Kitab" : "IndoPak",
                              fontFamilyFallback: ["Quran"]),
                        ),
                        StreamBuilder(
                          stream: engS.stream.asBroadcastStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            return snapshot.data!
                                ? Column(
                                    children: [
                                      Divider(
                                        thickness: 1,
                                        color: MyColors.text(),
                                        height: 32,
                                      ),
                                      Text(
                                        engAyasInSura[i],
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: MyColors.text(),
                                            fontSize: prefs!
                                                .getDouble("quranEnglishFont")),
                                      )
                                    ],
                                  )
                                : Container();
                          },
                          initialData: false,
                        ),
                        StreamBuilder(
                          stream: urS.stream.asBroadcastStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            return snapshot.data!
                                ? Column(
                                    children: [
                                      Divider(
                                        thickness: 1,
                                        color: MyColors.text(),
                                        height: 32,
                                      ),
                                      Text(
                                        urAyasInSura[i],
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: MyColors.text(),
                                            fontSize: prefs!
                                                .getDouble("quranUrduFont")),
                                      )
                                    ],
                                  )
                                : Container();
                          },
                          initialData: false,
                        ),
                        StreamBuilder(
                          stream: faS.stream.asBroadcastStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            return snapshot.data!
                                ? Column(
                                    children: [
                                      Divider(
                                        thickness: 1,
                                        color: MyColors.text(),
                                        height: 32,
                                      ),
                                      Text(
                                        faAyasInSura[i],
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: MyColors.text(),
                                            fontSize: prefs!
                                                .getDouble("quranFarsiFont")),
                                      )
                                    ],
                                  )
                                : Container();
                          },
                          initialData: false,
                        ),
                        Divider(
                          thickness: 1,
                          color: MyColors.text(),
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.info_outline,
                                  size:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                iconSize:
                                    MediaQuery.of(context).size.height * 0.03,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Tafsir",
                                          style:
                                              TextStyle(color: MyColors.text()),
                                        ),
                                        content: SingleChildScrollView(
                                          child: Text(surahTafsir[i],
                                              style: TextStyle(
                                                  fontSize: englishSize * .6,
                                                  color: MyColors.text())),
                                        ),
                                        actions: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              IconButton(
                                                icon: const Icon(Icons.content_copy),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                          ClipboardData(
                                                              text: surahTafsir[
                                                                  i]))
                                                      .then((result) {
                                                    Navigator.of(context).pop();
                                                    const snackBar = SnackBar(
                                                      content: Text(
                                                          'Copied to Clipboard'),
                                                    );
                                                    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                  });
                                                },
                                              ),
                                              TextButton(
                                                child: Text("Back",
                                                    style: TextStyle(
                                                        color:
                                                            MyColors.text())),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          )
                                        ],
                                        backgroundColor: MyColors.color1()[200],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                      );
                                    },
                                  );
                                }),
                            IconButton(
                              icon: Icon(
                                Icons.content_copy,
                                size: MediaQuery.of(context).size.height * 0.03,
                              ),
                              iconSize:
                                  MediaQuery.of(context).size.height * 0.03,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Copy to Clipboard",
                                          style:
                                              TextStyle(color: MyColors.text()),
                                        ),
                                        content: SingleChildScrollView(
                                            child: Column(
                                          children: [
                                            InkWell(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    48,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                alignment: Alignment.center,
                                                child: Text("Copy Arabic",
                                                    style: TextStyle(
                                                        fontSize:
                                                            englishSize * 0.7,
                                                        color: MyColors.text()),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                        text: ayasInSura[i]))
                                                    .then((result) {
                                                  Navigator.of(context).pop();
                                                  const snackBar = SnackBar(
                                                    content: Text(
                                                        'Copied to Clipboard'),
                                                  );
                                                  ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                });
                                              },
                                            ),
                                            eng
                                                ? InkWell(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              48,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                          "Copy English",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  englishSize *
                                                                      0.7,
                                                              color: MyColors
                                                                  .text()),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    onTap: () {
                                                      Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      engAyasInSura[
                                                                          i]))
                                                          .then((result) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        const snackBar =
                                                            SnackBar(
                                                          content: Text(
                                                              'Copied to Clipboard'),
                                                        );
                                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                      });
                                                    },
                                                  )
                                                : Container(),
                                            ur
                                                ? InkWell(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              48,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text("Copy Urdu",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  englishSize *
                                                                      0.7,
                                                              color: MyColors
                                                                  .text()),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    onTap: () {
                                                      Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      urAyasInSura[
                                                                          i]))
                                                          .then((result) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        const snackBar =
                                                            SnackBar(
                                                          content: Text(
                                                              'Copied to Clipboard'),
                                                        );
                                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                      });
                                                    },
                                                  )
                                                : Container(),
                                            fa
                                                ? InkWell(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              48,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text("Copy Farsi",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  englishSize *
                                                                      0.7,
                                                              color: MyColors
                                                                  .text()),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    onTap: () {
                                                      Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      faAyasInSura[
                                                                          i]))
                                                          .then((result) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        const snackBar =
                                                            SnackBar(
                                                          content: Text(
                                                              'Copied to Clipboard'),
                                                        );
                                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                      });
                                                    },
                                                  )
                                                : Container(),
                                          ],
                                        )),
                                        actions: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              TextButton(
                                                child: Text("Back",
                                                    style: TextStyle(
                                                        color:
                                                            MyColors.text())),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          )
                                        ],
                                        backgroundColor: MyColors.color1()[200],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                      );
                                    });
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )),
            );
          }),
        ),
      ));
    }

    engS.add(eng);
    faS.add(fa);
    urS.add(ur);

    /*reciterNames=[];
    recitations=[];
    recites=[];
    for(int i = 0; i<juzNums[widget.juzIndex]["reciters"].entries.length; i++){
      reciterNames.add(juzNums[widget.juzIndex]["reciters"].entries.elementAt(i).key);
      recitations.add(juzNums[widget.juzIndex]["reciters"].entries.elementAt(i).value);
      if(prefs!.getString("defJuzReciter")!=null){
        if(prefs!.getString("defJuzReciter")==reciterNames[i]){
          curName = reciterNames[i];
          curRecite = recitations[i];
        }
      }else{
        prefs!.setString("defJuzReciter", reciterNames[0]);
        curName = reciterNames[0];
        curRecite = recitations[0];
      }
      
      recites.add(
        DropdownMenuItem(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                width: constraints.maxWidth,
                child:Text(juzNums[widget.juzIndex]["reciters"].entries.elementAt(i).key, overflow: TextOverflow.clip, textAlign: TextAlign.center, style: TextStyle(
                  color: MyColors.text()
                ),)
              );
            }
          ),
          value: juzNums[widget.juzIndex]["reciters"].entries.elementAt(i).value,
          onTap: (){
            curName = juzNums[widget.juzIndex]["reciters"].entries.elementAt(i).key;
            prefs!.setString("defJuzReciter", curName);
          },
        )
      );
    }*/
    done = true;
    currentPage = Refresh(this.ref);
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
    setState(() {});
    return 'success';
  }

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  void update() async {
    isPlay = const Icon(Icons.play_arrow);
    String path = (await localFileSave).path;
    String name = "Juz ${widget.juzIndex + 1} - $curName";
    String temp = "$path/$name.mp3";
    File file = File(temp);
    print(temp);
    if (await file.exists()) {
      await play(temp, isLocal: true);
      var snackBar = const SnackBar(
        content: Text('Loaded Offline'),
      );

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
    } else {
      await play(curRecite);
      var snackBar = const SnackBar(
        content: Text('Loaded Online'),
      );

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
    }
    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => duration = d);
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      print('Position: $p');
      setState(() => position = p);
    });

    audioPlayer.setReleaseMode(ap.ReleaseMode.stop);
    await audioPlayer.pause();
    playerState = PlayerState.pause;
    isPlay = const Icon(Icons.play_arrow);
    duration = (await audioPlayer.getDuration())!;
    setState((){});
  }

  void ref() {
    setState(() {});
  }

  void loadEngAyas() {
    engAyasInSura = [];

    if (startSurah == endSurah) {
      engAyasInSura.add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      if (startSurah == juzNums[widget.juzIndex + 1]["beginning"]["surahNum"]) {
        for (int i = startAya; i <= endAya; i++) {
          engAyasInSura.add(
              engTranslation["quran"]["sura"][startSurah]["aya"][i]["-text"]);
        }
      } else {
        for (int i = startAya; i <= endAya; i++) {
          engAyasInSura.add(
              engTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
        }
      }
    } else {
      for (int i = startSurah; i < endSurah; i++) {
        if (i != 0 && i != 8) {
          engAyasInSura
              .add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
        } else if (i == 8) {
          engAyasInSura.add("");
        }
        for (int x = startAya;
            x < engTranslation["quran"]["sura"][i]["aya"].length;
            x++) {
          engAyasInSura
              .add(engTranslation["quran"]["sura"][i]["aya"][x]["-text"]);
        }
      }
      if (endSurah != 0 && endSurah != 8) {
        engAyasInSura
            .add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      } else if (endSurah == 8) {
        engAyasInSura.add("");
      }
      for (int i = 0; i <= endAya; i++) {
        engAyasInSura
            .add(engTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
      }
    }
    eng = true;
    engS.add(eng);
  }

  void loadUrAyas() {
    urAyasInSura = [];

    if (startSurah == endSurah) {
      urAyasInSura.add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      if (startSurah == juzNums[widget.juzIndex + 1]["beginning"]["surahNum"]) {
        for (int i = startAya; i <= endAya; i++) {
          urAyasInSura.add(
              urTranslation["quran"]["sura"][startSurah]["aya"][i]["-text"]);
        }
      } else {
        for (int i = startAya; i <= endAya; i++) {
          urAyasInSura
              .add(urTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
        }
      }
    } else {
      for (int i = startSurah; i < endSurah; i++) {
        if (i != 0 && i != 8) {
          urAyasInSura
              .add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
        } else if (i == 8) {
          urAyasInSura.add("");
        }
        for (int x = startAya;
            x < urTranslation["quran"]["sura"][i]["aya"].length;
            x++) {
          urAyasInSura
              .add(urTranslation["quran"]["sura"][i]["aya"][x]["-text"]);
        }
      }
      if (endSurah != 0 && endSurah != 8) {
        urAyasInSura.add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      } else if (endSurah == 8) {
        urAyasInSura.add("");
      }
      for (int i = 0; i <= endAya; i++) {
        urAyasInSura
            .add(urTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
      }
    }
    ur = true;
    urS.add(ur);
  }

  void loadFaAyas() {
    faAyasInSura = [];

    if (startSurah == endSurah) {
      faAyasInSura.add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      if (startSurah == juzNums[widget.juzIndex + 1]["beginning"]["surahNum"]) {
        for (int i = startAya; i <= endAya; i++) {
          faAyasInSura.add(
              faTranslation["quran"]["sura"][startSurah]["aya"][i]["-text"]);
        }
      } else {
        for (int i = startAya; i <= endAya; i++) {
          faAyasInSura
              .add(faTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
        }
      }
    } else {
      for (int i = startSurah; i < endSurah; i++) {
        if (i != 0 && i != 8) {
          faAyasInSura
              .add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
        } else if (i == 8) {
          faAyasInSura.add("");
        }
        for (int x = startAya;
            x < faTranslation["quran"]["sura"][i]["aya"].length;
            x++) {
          faAyasInSura
              .add(faTranslation["quran"]["sura"][i]["aya"][x]["-text"]);
        }
      }
      if (endSurah != 0 && endSurah != 8) {
        faAyasInSura.add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      } else if (endSurah == 8) {
        faAyasInSura.add("");
      }
      for (int i = 0; i <= endAya; i++) {
        faAyasInSura
            .add(faTranslation["quran"]["sura"][endSurah]["aya"][i]["-text"]);
      }
    }
    fa = true;
    faS.add(fa);
  }

  void loadTafsir() {
    surahTafsir = [];

    if (startSurah == endSurah) {
      surahTafsir.add(tafsir[0][0]["text"]);
      if (startSurah == juzNums[widget.juzIndex + 1]["beginning"]["surahNum"]) {
        for (int i = startAya; i <= endAya; i++) {
          surahTafsir.add(tafsir[startSurah][i]["text"]);
        }
      } else {
        for (int i = startAya; i <= endAya; i++) {
          surahTafsir.add(tafsir[endSurah][i]["text"]);
        }
      }
    } else {
      for (int i = startSurah; i < endSurah; i++) {
        if (i != 0 && i != 8) {
          surahTafsir.add(tafsir[0][0]["text"]);
        } else if (i == 8) {
          surahTafsir.add("");
        }
        for (int x = startAya; x < tafsir[i].length; x++) {
          surahTafsir.add(tafsir[i][x]["text"]);
        }
      }
      if (endSurah != 0 && endSurah != 8) {
        surahTafsir.add(tafsir[0][0]["text"]);
      } else if (endSurah == 8) {
        surahTafsir.add("");
      }
      for (int i = 0; i <= endAya; i++) {
        surahTafsir.add(tafsir[endSurah][i]["text"]);
      }
    }
  }

  String secs(Duration d) {
    if (d.inSeconds % 60 < 10) return '0${d.inSeconds % 60}';
    return (d.inSeconds % 60).toString();
  }

  String pos() {
    return '${position.inMinutes}:${secs(position)}/${duration.inMinutes}:${secs(duration)}';
  }

  double dur() {
    return duration.inMilliseconds.toDouble();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isSettings = false;
  ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);
  double scroll = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows(int numPerRow) {
      List<Widget> rows = [];
      rows.add(Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
      ));
      for (int i = 0; i < ayas.length; i += numPerRow) {
        List<Widget> widgetInRows = [];
        int x = i;
        while (x < (i + numPerRow)) {
          ayas.length > x
              ? widgetInRows.add(ayas[x])
              : widgetInRows.add(HomeCard(
                  title: "",
                  isBlank: true,
                ));
          x++;
        }
        rows.add(KeepWidgetAlive(Row(
          children: widgetInRows,
        )));
      }
      rows.add(Container(
        height: MediaQuery.of(context).size.height * 0.12,
      ));
      return rows;
    }

    return isSettings
        ? settings()
        : Scaffold(
            key: _scaffoldKey,
            body: CustomScrollView(controller: _scrollController, slivers: [
              SliverAppBar(
                toolbarHeight: toolbarSize(context),
                backgroundColor: MyColors.appBar(),
                title: Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, MediaQuery.of(context).size.height * 0.015, 0, 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Juz' ${widget.juzIndex + 1}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontSize: titleSize(context))),
                      ]),
                ),

                flexibleSpace: Container(
                decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              MyColors.appBarNew()[-200]!,
                              MyColors.appBarNew()[0]!,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))
                        ),
                child: FlexibleSpaceBar(
                  background: Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.025,
                          MediaQuery.of(context).size.height * 0.11,
                          MediaQuery.of(context).size.width * 0.025,
                          0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                        Text(
                                          'English',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              color: Colors.white),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: MyColors.background(),
                                          ),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            dropdownColor:
                                                MyColors.background(),
                                            underline: Container(),
                                            iconEnabledColor: MyColors.text(),
                                            items: [
                                              DropdownMenuItem(
                                                value: "none",
                                                onTap: () async {
                                                  eng = false;
                                                  engS.add(eng);
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "None",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "qarai",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "engTrans", "qarai");
                                                  engTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/qarai.json'));
                                                  loadEngAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Ali Quli Qarai",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "en.ali",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "engTrans", "en.ali");
                                                  engTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/en.ali.json'));
                                                  loadEngAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Mir Ahmed Ali",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "sarwar",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "engTrans", "sarwar");
                                                  engTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/sarwar.json'));
                                                  loadEngAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Muhammad Sarwar",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              engValue = value!;
                                              if (value != "none") {
                                                eng = true;
                                              } else {
                                                eng = false;
                                              }
                                              prefs!.setBool("eng", eng);
                                              prefs!.setString(
                                                  "engTrans", value);
                                              setState(() {});
                                            },
                                            value: engValue,
                                          ),
                                        )
                                      ])),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                        Text(
                                          'Urdu',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              color: Colors.white),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: MyColors.background(),
                                          ),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            dropdownColor:
                                                MyColors.background(),
                                            underline: Container(),
                                            iconEnabledColor: MyColors.text(),
                                            items: [
                                              DropdownMenuItem(
                                                value: "none",
                                                onTap: () async {
                                                  ur = false;
                                                  urS.add(ur);
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "None",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "najafi",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "urTrans", "najafi");
                                                  urTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/najafi.json'));
                                                  loadUrAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Ayatollah Muhammad Hussain Najafi",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "ur.ali",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "urTrans", "ur.ali");
                                                  urTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/ur.ali.json'));
                                                  loadUrAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Mir Ahmed Ali",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "jawadi",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "urTrans", "jawadi");
                                                  urTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/jawadi.json'));
                                                  loadUrAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Syed Zeeshan Haider Jawadi",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              urValue = value!;
                                              if (value != "none") {
                                                ur = true;
                                              } else {
                                                ur = false;
                                              }
                                              prefs!.setBool("ur", ur);
                                              prefs!.setString("urTrans", value);
                                              setState(() {});
                                            },
                                            value: urValue,
                                          ),
                                        )
                                      ])),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      Text(
                                        'Farsi',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            color: Colors.white),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: MyColors.background(),
                                        ),
                                        child: DropdownButton(
                                          isExpanded: true,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          dropdownColor: MyColors.background(),
                                          underline: Container(),
                                          iconEnabledColor: MyColors.text(),
                                          items: [
                                            DropdownMenuItem(
                                              value: "none",
                                              onTap: () async {
                                                fa = false;
                                                faS.add(fa);
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "None",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                            DropdownMenuItem(
                                              value: "makarem",
                                              onTap: () async {
                                                await prefs!.setString(
                                                    "faTrans", "makarem");
                                                faTranslation = json.decode(
                                                    await loadSurahInfo(
                                                        'assets/jsons/quran/makarem.json'));
                                                loadFaAyas();
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "Ayatollah Naser Makarem Shirazi",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                            DropdownMenuItem(
                                              value: "ansarian",
                                              onTap: () async {
                                                await prefs!.setString(
                                                    "faTrans", "ansarian");
                                                faTranslation = json.decode(
                                                    await loadSurahInfo(
                                                        'assets/jsons/quran/ansarian.json'));
                                                loadFaAyas();
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "Sheikh Hossein Ansarian",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                            DropdownMenuItem(
                                              value: "tehrani",
                                              onTap: () async {
                                                await prefs!.setString(
                                                    "faTrans", "tehrani");
                                                faTranslation = json.decode(
                                                    await loadSurahInfo(
                                                        'assets/jsons/quran/tehrani.json'));
                                                loadFaAyas();
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "Ayatollah Mohammad Sadeghi Tehrani",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            faValue = value!;
                                            if (value != "none") {
                                              fa = true;
                                            } else {
                                              fa = false;
                                            }
                                            prefs!.setBool("fa", fa);
                                            prefs!.setString("faTrans", value);
                                            setState(() {});
                                          },
                                          value: faValue,
                                        ),
                                      )
                                    ])),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                fit: FlexFit.tight,
                                child: Text('Reciter',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white),
                                    textAlign: TextAlign.center),
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 4,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: MyColors.background(),
                                      ),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        dropdownColor: MyColors.background(),
                                        underline: Container(),
                                        items: recites,
                                        iconEnabledColor: MyColors.text(),
                                        onChanged: (value) async {
                                          curRecite = value!;
                                          release();
                                          isPlay = const Icon(Icons.play_arrow);
                                          String path =
                                              (await localFileSave).path;
                                          String name = "Juz ${widget.juzIndex + 1} - $curName";
                                          String temp = "$path/$name.mp3";
                                          File file = File(temp);
                                          print(temp);
                                          if (await file.exists()) {
                                            await pause();
                                            await play(temp, isLocal: true);
                                            var snackBar = const SnackBar(
                                              content: Text('Playing Offline'),
                                            );

                                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                          } else {
                                            await pause();
                                            await play(curRecite);
                                            var snackBar = const SnackBar(
                                              content: Text('Playing Online'),
                                            );

                                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                          }
                                          setState(() {});
                                        },
                                        value: curRecite,
                                      ),
                                    ),
                                  )),
                              Flexible(
                                  fit: FlexFit.tight,
                                  child: IconButton(
                                      icon: const Icon(Icons.file_download,
                                          color: Colors.white),
                                      onPressed: () async {
                                        var snackBar = const SnackBar(
                                            content: Text(
                                                'Downloading, please wait.'),
                                            duration: Duration(days: 365));

                                        // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                        await downloadFile(
                                            curRecite,
                                            "Juz ${widget.juzIndex + 1}",
                                            curName);
                                        snackBar = const SnackBar(
                                          content: Text('Downloaded'),
                                        );

                                        // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).removeCurrentSnackBar();
                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                      }))
                            ],
                          )
                        ],
                      )),
                  centerTitle: true,
                ),
                ),
                centerTitle: true,
                //pinned: true,
                floating: true,
                expandedHeight: MediaQuery.of(context).size.height * 0.25,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30))),
                bottom: PreferredSize(
                    // Add this code
                    preferredSize: Size(
                        double.infinity,
                        MediaQuery.of(context).size.height *
                            0.02), // Add this code
                    child: const Text("")),
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
                actions: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        initializeTheme();
                        isSettings = true;
                        scroll = _scrollController.position.pixels;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SliverList(delegate: SliverChildListDelegate(rows(1))),
            ]),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: MyColors.background(),
              ),
              width: MediaQuery.of(context).size.width * 0.93,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: IconButton(
                      icon: isPlay,
                      color: MyColors.text(),
                      onPressed: () async {
                        if (playerState == PlayerState.play) {
                          pause();
                          isPlay = const Icon(Icons.play_arrow);
                        } else if (playerState == PlayerState.pause) {
                          unpause();
                          isPlay = const Icon(Icons.pause);
                        } else if (playerState == PlayerState.stop) {
                          isPlay = const Icon(Icons.play_arrow);
                          String path = (await localFileSave).path;
                          String name = "Juz ${widget.juzIndex + 1} - $curName";
                          String temp = "$path/$name.mp3";
                          File file = File(temp);
                          print(temp);
                          if (await file.exists()) {
                            await pause();
                            await play(temp, isLocal: true);
                            var snackBar = const SnackBar(
                              content: Text('Playing Offline'),
                            );
                            await unpause();

                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                          } else {
                            await pause();
                            await play(curRecite);
                            var snackBar = const SnackBar(
                              content: Text('Playing Online'),
                            );
                            await unpause();

                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                          }
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 8,
                    child: Flex(
                        direction: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: position.inMilliseconds.toDouble(),
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            onChanged: (double value) {
                              audioPlayer.seek(
                                  Duration(milliseconds: value.toInt()));
                              unpause();
                              isPlay = const Icon(Icons.pause);
                              setState(() {});
                            },
                            min: 0.0,
                            max: dur(),
                          ),
                        ]),
                  ),
                  done
                      ? Flexible(
                          fit: FlexFit.tight,
                          flex: 3,
                          child: Text(
                            pos() != '' ? pos() : '0:00/0:00',
                            style: TextStyle(color: MyColors.text()),
                          ),
                        )
                      : Container()
                ],
              ),
            ));
  }

  Future<void> initializeTheme() async {
    if (prefs!.getDouble("quranArabicFont") == null) {
      prefs!.setDouble("quranArabicFont", 48);
    }
    if (prefs!.getDouble("quranEnglishFont") == null) {
      prefs!.setDouble("quranEnglishFont", 28);
    }
    if (prefs!.getDouble("quranFarsiFont") == null) {
      prefs!.setDouble("quranFarsiFont", 28);
    }
    if (prefs!.getDouble("quranUrduFont") == null) {
      prefs!.setDouble("quranUrduFont", 28);
    }
    if (prefs!.getBool("qurFont") == null) {
      prefs!.setBool("qurFont", true);
    }
    font = prefs!.getBool("qurFont")!;
    arabicSize = prefs!.getDouble("quranArabicFont")!;
    englishSize = prefs!.getDouble("quranEnglishFont")!;
    farsiSize = prefs!.getDouble("quranFarsiFont")!;
    urduSize = prefs!.getDouble("quranUrduFont")!;
    setState(() {});
  }

  Widget settings() {
    return Scaffold(
        backgroundColor: MyColors.background(),
        body: CustomScrollView(slivers: [
          SliverAppBar(
              toolbarHeight: toolbarSize(context),
              backgroundColor: MyColors.appBar(),
              leading: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.015),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    isSettings = false;
                    setState(() {});
                  },
                ),
              ),
              title: Padding(
                padding: EdgeInsets.fromLTRB(
                    0, MediaQuery.of(context).size.height * 0.015, 0, 0),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Settings",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontSize: titleSize(context))),
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
                      BorderRadius.vertical(bottom: Radius.circular(30))),
              bottom: PreferredSize(
                  // Add this code
                  preferredSize: Size(
                      double.infinity,
                      MediaQuery.of(context).size.height *
                          0.02), // Add this code
                  child: const Text(""))),
          SliverToBoxAdapter(
              child: WillPopScope(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Arabic Font Type",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "IndoPak",
                                style: TextStyle(color: MyColors.text()),
                              ),
                              Switch(
                                value: font,
                                onChanged: (d) async {
                                  prefs!.setBool("qurFont", d);
                                  font = d;
                                  setState(() {});
                                },
                                activeColor: MyColors.sliderInactive(),
                                activeTrackColor: MyColors.sliderActive(),
                                inactiveThumbColor: MyColors.sliderActive(),
                                inactiveTrackColor: MyColors.sliderInactive(),
                              ),
                              Text(
                                "Uthmani",
                                style: TextStyle(color: MyColors.text()),
                              ),
                            ],
                          ),
                          Text(
                            "Arabic Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: arabicSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 16,
                            max: 64,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranArabicFont", d);
                            },
                            onChanged: (d) async {
                              arabicSize = d;
                              setState(() {});
                            },
                          ),
                          const Divider(
                            height: 16,
                          ),
                          Text(
                            "English Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: englishSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 6,
                            max: 48,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranEnglishFont", d);
                            },
                            onChanged: (d) async {
                              englishSize = d;

                              setState(() {});
                            },
                          ),
                          const Divider(
                            height: 16,
                          ),
                          Text(
                            "Urdu Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: urduSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 6,
                            max: 48,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranUrduFont", d);
                            },
                            onChanged: (d) async {
                              urduSize = d;

                              setState(() {});
                            },
                          ),
                          const Divider(
                            height: 16,
                          ),
                          Text(
                            "Farsi Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: farsiSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 6,
                            max: 48,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranFarsiFont", d);
                            },
                            onChanged: (d) async {
                              farsiSize = d;

                              setState(() {});
                            },
                          ),
                        ])),
              ],
            ),
            onWillPop: () {
              isSettings = false;
              _scrollController = ScrollController(
                  initialScrollOffset: scroll, keepScrollOffset: true);
              setState(() {});
              return Future.value(false);
            },
          ))
        ]));
  }
}

class Surah extends StatefulWidget {
  const Surah({Key? key}) : super(key: key);

  @override
  _SurahState createState() => _SurahState();
}

class _SurahState extends State<Surah> {
  List<HomeCard> cards = [];

  bool eng = false;
  bool ur = false;
  bool fa = false;

  String engValue = "none";
  String urValue = "none";
  String faValue = "none";

  bool done = false;
  var tafsirAfter;
  double arabicSize = 0;
  double farsiSize = 0;
  double englishSize = 0;
  double urduSize = 0;
  bool font = false;

  SharedPreferences? prefs;

  List<String> reciterNames = [];
  List<String> recitations = [];
  List<DropdownMenuItem> recites = [];
  String curRecite = "testing";
  String curName = "testing";

  var reciteJson;

  Future<String> loadSurahInfo(String link) async {
    return await rootBundle.loadString(link);
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  Future<void> load() async {
    var surahList = json
        .decode(await loadSurahInfo('assets/jsons/quran/quranUthmani.json'));
    var surahs =
        json.decode(await loadSurahInfo('assets/jsons/quran/surahinfo.json'));
    for (int i = 0; i <= 113; i++) {
      cards.add(HomeCard(
        title: "${i + 1}. Surah " + surahs[i]["title"],
        fullLength: true,
        route: () async {
          prefs = await SharedPreferences.getInstance();
          var engAyasInSura;
          List<String> engAyas = [];
          var urAyasInSura;
          List<String> urAyas = [];
          var faAyasInSura;
          List<String> faAyas = [];
          List<String> arAyas = [];

          var ayasInSura;

          var engTranslation;
          var urTranslation;
          var faTranslation;

          engAyas = [];
          urAyas = [];
          faAyas = [];
          done = false;

          ayasInSura = surahList["quran"]["sura"][i]["aya"];
          engAyasInSura = [];
          faAyasInSura = [];
          urAyasInSura = [];
          tafsirAfter = [];

          reciteJson = surahs;
          eng = true;
          if (prefs!.getString("engTrans") == "sarwar") {
            engTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/sarwar.json'));
            engAyasInSura = engTranslation["quran"]["sura"][i]["aya"];
            engValue = "sarwar";
          } else if (prefs!.getString("engTrans") == "qarai") {
            engTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/qarai.json'));
            engAyasInSura = engTranslation["quran"]["sura"][i]["aya"];
            engValue = "qarai";
          } else if (prefs!.getString("engTrans") == "en.ali") {
            engTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/en.ali.json'));
            engAyasInSura = engTranslation["quran"]["sura"][i]["aya"];
            engValue = "en.ali";
          } else {
            engTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/qarai.json'));
            eng = false;
            engAyasInSura = engTranslation["quran"]["sura"][i]["aya"];
            engValue = "none";
            eng = false;
          }
          if (!prefs!.containsKey("eng")) {
            eng = false;
            engValue = "none";
            prefs!.setBool("eng", false);
            prefs!.setString("engTrans", "none");
          }
          ur = true;
          if (prefs!.getString("urTrans") == "najafi") {
            urTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/najafi.json'));
            urAyasInSura = urTranslation["quran"]["sura"][i]["aya"];
            urValue = "najafi";
          } else if (prefs!.getString("urTrans") == "jawadi") {
            urTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/jawadi.json'));
            urAyasInSura = urTranslation["quran"]["sura"][i]["aya"];
            urValue = "jawadi";
          } else if (prefs!.getString("urTrans") == "ur.ali") {
            urTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/ur.ali.json'));
            urAyasInSura = urTranslation["quran"]["sura"][i]["aya"];
            urValue = "ur.ali";
          } else {
            urTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/najafi.json'));
            urAyasInSura = urTranslation["quran"]["sura"][i]["aya"];
            urValue = "none";
            ur = false;
          }
          if (!prefs!.containsKey("ur")) {
            ur = false;
            urValue = "none";
            prefs!.setBool("ur", false);
            prefs!.setString("urTrans", "none");
          }
          fa = true;
          if (prefs!.getString("faTrans") == "makarem") {
            faTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/makarem.json'));
            faAyasInSura = faTranslation["quran"]["sura"][i]["aya"];
            faValue = "makarem";
          } else if (prefs!.getString("faTrans") == "ansarian") {
            faTranslation = json.decode(
                await loadSurahInfo('assets/jsons/quran/ansarian.json'));
            faAyasInSura = faTranslation["quran"]["sura"][i]["aya"];
            faValue = "ansarian";
          } else if (prefs!.getString("faTrans") == "tehrani") {
            faTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/tehrani.json'));
            faAyasInSura = faTranslation["quran"]["sura"][i]["aya"];
            faValue = "tehrani";
          } else {
            faTranslation = json
                .decode(await loadSurahInfo('assets/jsons/quran/makarem.json'));
            faAyasInSura = faTranslation["quran"]["sura"][i]["aya"];
            faValue = "none";
            fa = false;
          }
          if (!prefs!.containsKey("fa")) {
            fa = false;
            faValue = "none";
            prefs!.setBool("fa", false);
            prefs!.setString("faTrans", "none");
          }
          if (i != 0 && i != 8) {
            arAyas.add(surahList["quran"]["sura"][0]["aya"][0]["-text"]);
            engAyas.add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
            urAyas.add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
            faAyas.add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
          }
          for (int x = 0; x < ayasInSura.length; x++) {
            arAyas.add(ayasInSura[x]["-text"].replaceAll('\u06ED', '') +
                "\n﴿" +
                engNumToArb((x + 1).toString()) +
                "﴾");
            engAyas.add(engAyasInSura[x]["-text"]);
            urAyas.add(urAyasInSura[x]["-text"]);
            faAyas.add(faAyasInSura[x]["-text"]);
          }

          reciteJson = json
              .decode(await loadSurahInfo('assets/jsons/quran/surahinfo.json'));

          reciterNames = [];
          recitations = [];
          recites = [];
          for (int x = 0; x < reciteJson[i]["reciters"].entries.length; x++) {
            reciterNames
                .add(reciteJson[i]["reciters"].entries.elementAt(x).key);
            recitations
                .add(reciteJson[i]["reciters"].entries.elementAt(x).value);
            if (prefs!.getString("defSurahReciter") != null) {
              if (prefs!.getString("defSurahReciter") == reciterNames[x]) {
                curName = reciterNames[x];
                curRecite = recitations[x];
              }
            } else {
              prefs!.setString("defSurahReciter", reciterNames[0]);
              curName = reciterNames[0];
              curRecite = recitations[0];
            }

            recites.add(DropdownMenuItem(
              value: reciteJson[i]["reciters"].entries.elementAt(x).value,
              onTap: () {
                curName = reciteJson[i]["reciters"].entries.elementAt(x).key;
                prefs!.setString("defSurahReciter", curName);
              },
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                    width: constraints.maxWidth,
                    child: Text(
                      reciteJson[i]["reciters"].entries.elementAt(x).key,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyColors.text()),
                    ));
              }),
            ));
          }

          var route = MaterialPageRoute(
              builder: (BuildContext context) => SurahView(
                    surahNum: i,
                    ayasInSura: arAyas,
                    engAyasInSura: engAyas,
                    urAyasInSura: urAyas,
                    faAyasInSura: faAyas,
                    eng: eng,
                    fa: fa,
                    ur: ur,
                    engValue: engValue,
                    faValue: faValue,
                    urValue: urValue,
                    recitations: recitations,
                    reciterNames: reciterNames,
                    recites: recites,
                    curName: curName,
                    curRecite: curRecite,
                  ));
          Navigator.of(context).push(route);
        },
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeCardList(
        title: "Quran by Surah",
        cards: cards != [] ? cards : [HomeCard(title: "")],
        fullLength: true,
      ),
    );
  }
}

class SurahView extends StatefulWidget {
  final int surahNum;
  final List<String>? ayasInSura;
  final List<String>? engAyasInSura;
  final List<String>? faAyasInSura;
  final List<String>? urAyasInSura;
  final bool eng;
  final bool ur;
  final bool fa;
  final String engValue;
  final String urValue;
  final String faValue;
  final List<String>? reciterNames;
  final List<String>? recitations;
  final List<DropdownMenuItem>? recites;
  final String curRecite;
  final String curName;
  const SurahView(
      {Key? key,
      this.surahNum=0,
      this.ayasInSura,
      this.engAyasInSura,
      this.faAyasInSura,
      this.urAyasInSura,
      this.eng=false,
      this.ur=false,
      this.fa=false,
      this.engValue='',
      this.urValue='',
      this.faValue='',
      this.reciterNames,
      this.recitations,
      this.recites,
      this.curName='',
      this.curRecite=''})
      : super(key: key);

  @override
  _SurahViewState createState() => _SurahViewState();
}

class _SurahViewState extends State<SurahView> {
  List<Widget> ayas = [];
  bool eng = false;
  bool ur = false;
  bool fa = false;
  BehaviorSubject<bool> engS = BehaviorSubject<bool>();
  BehaviorSubject<bool> urS= BehaviorSubject<bool>();
  BehaviorSubject<bool> faS= BehaviorSubject<bool>();

  String engValue = "none";
  String urValue = "none";
  String faValue = "none";

  bool done = false;
  var engAyasInSura;
  var engAyas = [];
  var urAyasInSura;
  var urAyas = [];
  var faAyasInSura;
  var faAyas = [];
  var arAyas = [];

  var ayasInSura;

  var engTranslation;
  var urTranslation;
  var faTranslation;
  var tafsirAfter;
  double arabicSize = 0;
  double farsiSize = 0;
  double englishSize = 0;
  double urduSize = 0;
  bool font = false;

  SharedPreferences? prefs;

  var tafsir;
  var surahTafsir;

  List<String> reciterNames = [];
  List<String> recitations = [];
  List<DropdownMenuItem> recites = [];
  String curRecite = "testing";
  String curName = "testing";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List reciteJson = [];

  @override
  void initState() {
    this.getJsonData();
    super.initState();
  }

  @override
  void dispose() {
    release();
    super.dispose();
  }

  Future<String> loadSurahInfo(String link) async {
    return await rootBundle.loadString(link);
  }

  Future<String> getJsonData() async {
    audioPlayer = ap.AudioPlayer();
    engS = BehaviorSubject<bool>();
    urS = BehaviorSubject<bool>();
    faS = BehaviorSubject<bool>();
    prefs = await SharedPreferences.getInstance();
    /*engAyas = [];
    urAyas = [];
    faAyas = [];
    done=false;*/

    tafsir = json.decode(await loadSurahInfo('assets/jsons/quran/tafsir.json'));
    surahTafsir = tafsir[widget.surahNum];
    reciteJson =
        json.decode(await loadSurahInfo('assets/jsons/quran/surahinfo.json'));
    //var surahList = json.decode(await loadSurahInfo('assets/jsons/quran/quran.json'));

    /*var surahList = json.decode(await loadSurahInfo('assets/jsons/quran/quran.json'));
    ayasInSura = surahList["quran"]["sura"][widget.surahNum]["aya"];
    engAyasInSura = [];
    faAyasInSura = [];
    urAyasInSura = [];*/
    ayasInSura = widget.ayasInSura;
    engAyasInSura = widget.engAyasInSura;
    faAyasInSura = widget.faAyasInSura;
    urAyasInSura = widget.urAyasInSura;
    tafsirAfter = [];
    arAyas = widget.ayasInSura!;
    engAyas = widget.engAyasInSura!;
    faAyas = widget.faAyasInSura!;
    urAyas = widget.urAyasInSura!;
    eng = widget.eng;
    fa = widget.fa;
    ur = widget.ur;
    engValue = widget.engValue;
    urValue = widget.urValue;
    faValue = widget.faValue;
    recitations = widget.recitations!;
    reciterNames = widget.reciterNames!;
    recites = widget.recites!;
    curName = widget.curName;
    curRecite = widget.curRecite;

    if (prefs!.getDouble("quranArabicFont") == null) {
      prefs!.setDouble("quranArabicFont", 48);
    }
    if (prefs!.getDouble("quranEnglishFont") == null) {
      prefs!.setDouble("quranEnglishFont", 28);
    }
    if (prefs!.getDouble("quranFarsiFont") == null) {
      prefs!.setDouble("quranFarsiFont", 28);
    }
    if (prefs!.getDouble("quranUrduFont") == null) {
      prefs!.setDouble("quranUrduFont", 28);
    }
    arabicSize = prefs!.getDouble("quranArabicFont")!;
    englishSize = prefs!.getDouble("quranEnglishFont")!;
    farsiSize = prefs!.getDouble("quranFarsiFont")!;
    urduSize = prefs!.getDouble("quranUrduFont")!;

    if (prefs!.getBool("qurFont") != null) {
      if (prefs!.getBool("qurFont")!) {
        font = true;
      } else {
        font = false;
      }
    } else {
      prefs!.setBool("qurFont", true);
      font = true;
    }
    /*
    eng=true;
    if(prefs!.getString("engTrans")=="sarwar"){
      engTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/sarwar.json'));
      engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
      engValue = "sarwar";
    }else if(prefs!.getString("engTrans")=="qarai"){
      engTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/qarai.json'));
      engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
      engValue = "qarai";
    }else if(prefs!.getString("engTrans")=="en.ali"){
      engTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/en.ali.json'));
      engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
      engValue = "en.ali";
    }else{
      engTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/qarai.json'));
      eng=false;
      engAyasInSura = engTranslation["quran"]["sura"][widget.surahNum]["aya"];
      engValue = "qarai";
    }
    if(!prefs!.getBool("eng")){
      eng=false;
      engValue = "none";
    }
    ur=true;
    if(prefs!.getString("urTrans")=="najafi"){
      urTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/najafi.json'));
      urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
      urValue = "najafi";
    }else if(prefs!.getString("urTrans")=="jawadi"){
      urTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/jawadi.json'));
      urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
      urValue = "jawadi";
    }else if(prefs!.getString("urTrans")=="ur.ali"){
      urTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/ur.ali.json'));
      urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
      urValue = "ur.ali";
    }else{
      urTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/najafi.json'));
      urAyasInSura = urTranslation["quran"]["sura"][widget.surahNum]["aya"];
      urValue = "najafi";
    }
    if(!prefs!.getBool("ur")){
      ur=false;
      urValue = "none";
    }
    fa=true;
    if(prefs!.getString("faTrans")=="makarem"){
      faTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/makarem.json'));
      faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
      faValue = "makarem";
    }else if(prefs!.getString("faTrans")=="ansarian"){
      faTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/ansarian.json'));
      faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
      faValue = "ansarian";
    }else if(prefs!.getString("faTrans")=="tehrani"){
      faTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/tehrani.json'));
      faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
      faValue = "tehrani";
    }else{
      faTranslation = json.decode(await loadSurahInfo('assets/jsons/quran/makarem.json'));
      faAyasInSura = faTranslation["quran"]["sura"][widget.surahNum]["aya"];
      faValue = "makarem";
    }
    if(!prefs!.getBool("fa")){
      fa=false;
      faValue = "none";
    }*/
    if (widget.surahNum != 0 && widget.surahNum != 8) {
      /*arAyas.add(surahList["quran"]["sura"][0]["aya"][0]["-text"]);
      engAyas.add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      urAyas.add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
      faAyas.add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);*/
      tafsirAfter.add(tafsir[0][0]["text"]);
    }
    for (int i = 0; i < surahTafsir.length; i++) {
      /*arAyas.add(ayasInSura[i]["-text"] + "\n﴿" + engNumToArb((i+1).toString()) + "﴾");
      engAyas.add(engAyasInSura[i]["-text"]);
      urAyas.add(urAyasInSura[i]["-text"]);
      faAyas.add(faAyasInSura[i]["-text"]);*/
      tafsirAfter.add(surahTafsir[i]["text"]);
    }

    for (int i = 0; i < tafsirAfter.length; i++) {
      ayas.add(Expanded(
        child: Container(
          child: LayoutBuilder(builder: (context, constraint) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  constraint.biggest.width * 0.03,
                  constraint.biggest.width * 0.01,
                  constraint.biggest.width * 0.03,
                  constraint.biggest.width * 0.01),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      colors: [
                        MyColors.color1()[0]!,
                        MyColors.color1()[200]!
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        constraint.biggest.width * 0.03,
                        constraint.biggest.width * 0.05,
                        constraint.biggest.width * 0.03,
                        constraint.biggest.width * 0.01),
                    child: Column(
                      children: [
                        Builder(builder: (context) {
                          return Text(
                            font
                                ? arAyas[i]
                                    .replaceAll('لَٰٓ', 'لَـٰۤـ')
                                    .replaceAll('ٱلْءَا', 'ٱلۡـَٔا')
                                : engNumToInd(
                                    arAyas[i].replaceAll('ٌ ۖ', 'ٌ   ۖ')),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: MyColors.text(),
                                fontSize: prefs!.getDouble("quranArabicFont"),
                                fontFamily: font ? "Kitab" : "IndoPak",
                                fontFamilyFallback: ["Quran"]),
                          );
                        }),
                        StreamBuilder(
                          stream: engS.stream.asBroadcastStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            return snapshot.data!
                                ? Column(
                                    children: [
                                      Divider(
                                        thickness: 1,
                                        color: MyColors.text(),
                                        height: 32,
                                      ),
                                      Text(
                                        engAyas[i],
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: MyColors.text(),
                                            fontSize: prefs!
                                                .getDouble("quranEnglishFont")),
                                      )
                                    ],
                                  )
                                : Container();
                          },
                          initialData: false,
                        ),
                        StreamBuilder(
                          stream: urS.stream.asBroadcastStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            return snapshot.data!
                                ? Column(
                                    children: [
                                      Divider(
                                        thickness: 1,
                                        color: MyColors.text(),
                                        height: 32,
                                      ),
                                      Text(
                                        urAyas[i],
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: MyColors.text(),
                                            fontSize: prefs!
                                                .getDouble("quranUrduFont")),
                                      )
                                    ],
                                  )
                                : Container();
                          },
                          initialData: false,
                        ),
                        StreamBuilder(
                          stream: faS.stream.asBroadcastStream(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            return snapshot.data!
                                ? Column(
                                    children: [
                                      Divider(
                                        thickness: 1,
                                        color: MyColors.text(),
                                        height: 32,
                                      ),
                                      Text(
                                        faAyas[i],
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: MyColors.text(),
                                            fontSize: prefs!
                                                .getDouble("quranFarsiFont")),
                                      )
                                    ],
                                  )
                                : Container();
                          },
                          initialData: false,
                        ),
                        Divider(
                          thickness: 1,
                          color: MyColors.text(),
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.info_outline,
                                  size:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                iconSize:
                                    MediaQuery.of(context).size.height * 0.03,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Tafsir",
                                          style:
                                              TextStyle(color: MyColors.text()),
                                        ),
                                        content: SingleChildScrollView(
                                          child: Text(tafsirAfter[i],
                                              style: TextStyle(
                                                  fontSize: englishSize * .6,
                                                  color: MyColors.text())),
                                        ),
                                        actions: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              IconButton(
                                                icon: const Icon(Icons.content_copy),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                          ClipboardData(
                                                              text: tafsirAfter[
                                                                  i]))
                                                      .then((result) {
                                                    Navigator.of(context).pop();
                                                    const snackBar = SnackBar(
                                                      content: Text(
                                                          'Copied to Clipboard'),
                                                    );
                                                    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                  });
                                                },
                                              ),
                                              TextButton(
                                                child: Text("Back",
                                                    style: TextStyle(
                                                        color:
                                                            MyColors.text())),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          )
                                        ],
                                        backgroundColor: MyColors.color1()[200],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                      );
                                    },
                                  );
                                }),
                            IconButton(
                              icon: Icon(
                                Icons.content_copy,
                                size: MediaQuery.of(context).size.height * 0.03,
                              ),
                              iconSize:
                                  MediaQuery.of(context).size.height * 0.03,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Copy to Clipboard",
                                          style:
                                              TextStyle(color: MyColors.text()),
                                        ),
                                        content: SingleChildScrollView(
                                            child: Column(
                                          children: [
                                            InkWell(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    48,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                alignment: Alignment.center,
                                                child: Text("Copy Arabic",
                                                    style: TextStyle(
                                                        fontSize:
                                                            englishSize * 0.7,
                                                        color: MyColors.text()),
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                        text: ayasInSura[i]))
                                                    .then((result) {
                                                  Navigator.of(context).pop();
                                                  const snackBar = SnackBar(
                                                    content: Text(
                                                        'Copied to Clipboard'),
                                                  );
                                                  ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                });
                                              },
                                            ),
                                            eng
                                                ? InkWell(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              48,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                          "Copy English",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  englishSize *
                                                                      0.7,
                                                              color: MyColors
                                                                  .text()),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    onTap: () {
                                                      Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      engAyasInSura[
                                                                          i]))
                                                          .then((result) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        const snackBar =
                                                            SnackBar(
                                                          content: Text(
                                                              'Copied to Clipboard'),
                                                        );
                                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                      });
                                                    },
                                                  )
                                                : Container(),
                                            ur
                                                ? InkWell(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              48,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text("Copy Urdu",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  englishSize *
                                                                      0.7,
                                                              color: MyColors
                                                                  .text()),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    onTap: () {
                                                      Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      urAyasInSura[
                                                                          i]))
                                                          .then((result) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        const snackBar =
                                                            SnackBar(
                                                          content: Text(
                                                              'Copied to Clipboard'),
                                                        );
                                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                      });
                                                    },
                                                  )
                                                : Container(),
                                            fa
                                                ? InkWell(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              48,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text("Copy Farsi",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  englishSize *
                                                                      0.7,
                                                              color: MyColors
                                                                  .text()),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    onTap: () {
                                                      Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      faAyasInSura[
                                                                          i]))
                                                          .then((result) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        const snackBar =
                                                            SnackBar(
                                                          content: Text(
                                                              'Copied to Clipboard'),
                                                        );
                                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                                      });
                                                    },
                                                  )
                                                : Container(),
                                          ],
                                        )),
                                        actions: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              TextButton(
                                                child: Text("Back",
                                                    style: TextStyle(
                                                        color:
                                                            MyColors.text())),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          )
                                        ],
                                        backgroundColor: MyColors.color1()[200],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                      );
                                    });
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )),
            );
          }),
        ),
      ));
    }

    engS.add(eng);
    faS.add(fa);
    urS.add(ur);

    /*
    reciterNames=[];
    recitations=[];
    recites=[];
    for(int i = 0; i<reciteJson[widget.surahNum]["reciters"].entries.length; i++){
      reciterNames.add(reciteJson[widget.surahNum]["reciters"].entries.elementAt(i).key);
      recitations.add(reciteJson[widget.surahNum]["reciters"].entries.elementAt(i).value);
      if(prefs!.getString("defSurahReciter")!=null){
        if(prefs!.getString("defSurahReciter")==reciterNames[i]){
          curName = reciterNames[i];
          curRecite = recitations[i];
        }
      }else{
        prefs!.setString("defSurahReciter", reciterNames[0]);
        curName = reciterNames[0];
        curRecite = recitations[0];
      }
      
      recites.add(
        DropdownMenuItem(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                width: constraints.maxWidth,
                child:Text(reciteJson[widget.surahNum]["reciters"].entries.elementAt(i).key, overflow: TextOverflow.clip, textAlign: TextAlign.center, style: TextStyle(
                  color: MyColors.text()
                ),)
              );
            }
          ),
          value: reciteJson[widget.surahNum]["reciters"].entries.elementAt(i).value,
          onTap: (){
            curName = reciteJson[widget.surahNum]["reciters"].entries.elementAt(i).key;
            prefs!.setString("defSurahReciter", curName);
          },
        )
      );
    }*/
    done = true;
    currentPage = Refresh(this.ref);
    setState(() {});
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => update());

    return 'success';
  }

  void loadEngAyas() {
    engAyas = [];
    if (widget.surahNum != 0 && widget.surahNum != 8) {
      engAyas.add(engTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
    }
    for (int i = 0;
        i < engTranslation["quran"]["sura"][widget.surahNum]["aya"].length;
        i++) {
      engAyas.add(
          engTranslation["quran"]["sura"][widget.surahNum]["aya"][i]["-text"]);
    }
    engS.add(true);
  }

  void loadUrAyas() {
    urAyas = [];
    if (widget.surahNum != 0 && widget.surahNum != 8) {
      urAyas.add(urTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
    }
    for (int i = 0;
        i < urTranslation["quran"]["sura"][widget.surahNum]["aya"].length;
        i++) {
      urAyas.add(
          urTranslation["quran"]["sura"][widget.surahNum]["aya"][i]["-text"]);
    }
    urS.add(true);
  }

  void loadFaAyas() {
    faAyas = [];
    if (widget.surahNum != 0 && widget.surahNum != 8) {
      faAyas.add(faTranslation["quran"]["sura"][0]["aya"][0]["-text"]);
    }
    for (int i = 0;
        i < faTranslation["quran"]["sura"][widget.surahNum]["aya"].length;
        i++) {
      faAyas.add(
          faTranslation["quran"]["sura"][widget.surahNum]["aya"][i]["-text"]);
    }
    faS.add(true);
  }

  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  update() async {
    isPlay = const Icon(Icons.play_arrow);
    String path = (await localFileSave).path;
    String name =
        "${"Surah " + reciteJson[widget.surahNum]["title"]} - $curName";
    String temp = "$path/$name.mp3";
    File file = File(temp);
    print(temp);
    if (await file.exists()) {
      await play(temp, isLocal: true);
      var snackBar = const SnackBar(
        content: Text('Loaded Offline'),
      );

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
    } else {
      await play(curRecite);
      var snackBar = const SnackBar(
        content: Text('Loaded Online'),
      );

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
    }
    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      duration = d;
      setState(() {});
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      print('Position: $p');
      position = p;
      setState(() {});
    });

    audioPlayer.setReleaseMode(ap.ReleaseMode.stop);
    await audioPlayer.pause();
    playerState = PlayerState.pause;
    isPlay = const Icon(Icons.play_arrow);
    duration = (await audioPlayer.getDuration())!;
    setState((){});
  }

  void ref() {
    setState(() {});
  }

  String secs(Duration d) {
    if (d.inSeconds % 60 < 10) return '0${d.inSeconds % 60}';
    return (d.inSeconds % 60).toString();
  }

  String pos() {
    return '${position.inMinutes}:${secs(position)}/${duration.inMinutes}:${secs(duration)}';
  }

  double dur() {
    return duration.inMilliseconds.toDouble();
  }

  bool isSettings = false;
  ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);
  double scroll = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> rows(int numPerRow) {
      List<Widget> rows = [];
      rows.add(Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
      ));
      for (int i = 0; i < ayas.length; i += numPerRow) {
        List<Widget> widgetInRows = [];
        int x = i;
        while (x < (i + numPerRow)) {
          ayas.length > x
              ? widgetInRows.add(ayas[x])
              : widgetInRows.add(HomeCard(
                  title: "",
                  isBlank: true,
                ));
          x++;
        }
        rows.add(KeepWidgetAlive(Row(
          children: widgetInRows,
        )));
      }
      rows.add(Container(
        height: MediaQuery.of(context).size.height * 0.12,
      ));
      return rows;
    }

    return isSettings
        ? settings()
        : Scaffold(
            key: _scaffoldKey,
            body: CustomScrollView(controller: _scrollController, slivers: [
              SliverAppBar(
                toolbarHeight: toolbarSize(context),
                backgroundColor: MyColors.appBar(),
                title: Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, MediaQuery.of(context).size.height * 0.015, 0, 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                                "Surah " + reciteJson[widget.surahNum]["title"],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontSize: titleSize(context)),
                                overflow: TextOverflow.visible,
                              )
                      ]),
                ),

                flexibleSpace: Container(
                decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              MyColors.appBarNew()[-200]!,
                              MyColors.appBarNew()[0]!,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))
                        ),
                child: FlexibleSpaceBar(
                  background: Padding(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width * 0.025,
                          MediaQuery.of(context).size.height * 0.11,
                          MediaQuery.of(context).size.width * 0.025,
                          0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                        Text(
                                          'English',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              color: Colors.white),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: MyColors.background(),
                                          ),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            dropdownColor:
                                                MyColors.background(),
                                            underline: Container(),
                                            iconEnabledColor: MyColors.text(),
                                            items: [
                                              DropdownMenuItem(
                                                value: "none",
                                                onTap: () async {
                                                  eng = false;
                                                  engS.add(eng);
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "None",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "qarai",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "engTrans", "qarai");
                                                  engTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/qarai.json'));
                                                  loadEngAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Ali Quli Qarai",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "en.ali",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "engTrans", "en.ali");
                                                  engTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/en.ali.json'));
                                                  loadEngAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Mir Ahmed Ali",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "sarwar",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "engTrans", "sarwar");
                                                  engTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/sarwar.json'));
                                                  loadEngAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Muhammad Sarwar",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              engValue = value!;
                                              if (value != "none") {
                                                eng = true;
                                              } else {
                                                eng = false;
                                              }
                                              prefs!.setBool("eng", eng);
                                              prefs!.setString(
                                                  "engTrans", value);
                                              setState(() {});
                                            },
                                            value: engValue,
                                          ),
                                        )
                                      ])),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                        Text(
                                          'Urdu',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              color: Colors.white),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: MyColors.background(),
                                          ),
                                          child: DropdownButton(
                                            isExpanded: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            dropdownColor:
                                                MyColors.background(),
                                            underline: Container(),
                                            iconEnabledColor: MyColors.text(),
                                            items: [
                                              DropdownMenuItem(
                                                value: "none",
                                                onTap: () async {
                                                  ur = false;
                                                  urS.add(ur);
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "None",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "najafi",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "urTrans", "najafi");
                                                  urTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/najafi.json'));
                                                  loadUrAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Ayatollah Muhammad Hussain Najafi",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "ur.ali",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "urTrans", "ur.ali");
                                                  urTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/ur.ali.json'));
                                                  loadUrAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Mir Ahmed Ali",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                              DropdownMenuItem(
                                                value: "jawadi",
                                                onTap: () async {
                                                  await prefs!.setString(
                                                      "urTrans", "jawadi");
                                                  urTranslation = json.decode(
                                                      await loadSurahInfo(
                                                          'assets/jsons/quran/jawadi.json'));
                                                  loadUrAyas();
                                                },
                                                child: LayoutBuilder(builder:
                                                    (BuildContext context,
                                                        BoxConstraints
                                                            constraints) {
                                                  return Container(
                                                      width:
                                                          constraints.maxWidth,
                                                      child: Text(
                                                        "Syed Zeeshan Haider Jawadi",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: MyColors
                                                                .text()),
                                                      ));
                                                }),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              urValue = value!;
                                              if (value != "none") {
                                                ur = true;
                                              } else {
                                                ur = false;
                                              }
                                              prefs!.setBool("ur", ur);
                                              prefs!.setString("urTrans", value);
                                              setState(() {});
                                            },
                                            value: urValue,
                                          ),
                                        )
                                      ])),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                      Text(
                                        'Farsi',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                            color: Colors.white),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: MyColors.background(),
                                        ),
                                        child: DropdownButton(
                                          isExpanded: true,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          dropdownColor: MyColors.background(),
                                          underline: Container(),
                                          iconEnabledColor: MyColors.text(),
                                          items: [
                                            DropdownMenuItem(
                                              value: "none",
                                              onTap: () async {
                                                fa = false;
                                                faS.add(fa);
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "None",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                            DropdownMenuItem(
                                              value: "makarem",
                                              onTap: () async {
                                                await prefs!.setString(
                                                    "faTrans", "makarem");
                                                faTranslation = json.decode(
                                                    await loadSurahInfo(
                                                        'assets/jsons/quran/makarem.json'));
                                                loadFaAyas();
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "Ayatollah Naser Makarem Shirazi",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                            DropdownMenuItem(
                                              value: "ansarian",
                                              onTap: () async {
                                                await prefs!.setString(
                                                    "faTrans", "ansarian");
                                                faTranslation = json.decode(
                                                    await loadSurahInfo(
                                                        'assets/jsons/quran/ansarian.json'));
                                                loadFaAyas();
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "Sheikh Hossein Ansarian",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                            DropdownMenuItem(
                                              value: "tehrani",
                                              onTap: () async {
                                                await prefs!.setString(
                                                    "faTrans", "tehrani");
                                                faTranslation = json.decode(
                                                    await loadSurahInfo(
                                                        'assets/jsons/quran/tehrani.json'));
                                                loadFaAyas();
                                              },
                                              child: LayoutBuilder(builder:
                                                  (BuildContext context,
                                                      BoxConstraints
                                                          constraints) {
                                                return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      "Ayatollah Mohammad Sadeghi Tehrani",
                                                      overflow:
                                                          TextOverflow.clip,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              MyColors.text()),
                                                    ));
                                              }),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            faValue = value!;
                                            if (value != "none") {
                                              fa = true;
                                            } else {
                                              fa = false;
                                            }
                                            prefs!.setBool("fa", fa);
                                            prefs!.setString("faTrans", value);
                                            setState(() {});
                                          },
                                          value: faValue,
                                        ),
                                      )
                                    ])),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                fit: FlexFit.tight,
                                child: Text('Reciter',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: Colors.white),
                                    textAlign: TextAlign.center),
                              ),
                              Flexible(
                                  fit: FlexFit.tight,
                                  flex: 4,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                        bottom:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: MyColors.background(),
                                      ),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        dropdownColor: MyColors.background(),
                                        underline: Container(),
                                        items: recites,
                                        iconEnabledColor: MyColors.text(),
                                        onChanged: (value) async {
                                          print(value);
                                          curRecite = value!;
                                          release();
                                          isPlay = const Icon(Icons.play_arrow);
                                          String path =
                                              (await localFileSave).path;
                                          String name = "${"Surah " +
                                              reciteJson[widget.surahNum]
                                                  ["title"]} - $curName";
                                          String temp = "$path/$name.mp3";
                                          File file = File(temp);
                                          print(temp);
                                          if (await file.exists()) {
                                            await pause();
                                            await play(temp, isLocal: true);
                                            var snackBar = const SnackBar(
                                              content: Text('Playing Offline'),
                                            );

                                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                          } else {
                                            await pause();
                                            await play(curRecite);
                                            var snackBar = const SnackBar(
                                              content: Text('Playing Online'),
                                            );

                                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                          }
                                          setState(() {});
                                        },
                                        value: curRecite,
                                      ),
                                    ),
                                  )),
                              Flexible(
                                  fit: FlexFit.tight,
                                  child: IconButton(
                                      icon: const Icon(Icons.file_download,
                                          color: Colors.white),
                                      onPressed: () async {
                                        var snackBar = const SnackBar(
                                            content: Text(
                                                'Downloading, please wait.'),
                                            duration: Duration(days: 365));

                                        // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                        await downloadFile(
                                            curRecite,
                                            "Surah " +
                                                reciteJson[widget.surahNum]
                                                    ["title"],
                                            curName);
                                        snackBar = const SnackBar(
                                          content: Text('Downloaded'),
                                        );

                                        // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).clearSnackBars();
                                        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                                      }))
                            ],
                          )
                        ],
                      )),
                  centerTitle: true,
                ),
                ),
                centerTitle: true,
                //pinned: true,
                floating: true,
                expandedHeight: MediaQuery.of(context).size.height * 0.25,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30))),
                bottom: PreferredSize(
                    // Add this code
                    preferredSize: Size(
                        double.infinity,
                        MediaQuery.of(context).size.height *
                            0.02), // Add this code
                    child: const Text("")),
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
                actions: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015),
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        initializeTheme();
                        isSettings = true;
                        scroll = _scrollController.position.pixels;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SliverList(delegate: SliverChildListDelegate(rows(1))),
            ]),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: MyColors.background(),
              ),
              width: MediaQuery.of(context).size.width * 0.93,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: IconButton(
                      icon: isPlay,
                      color: MyColors.text(),
                      onPressed: () async {
                        if (playerState == PlayerState.play) {
                          pause();
                          isPlay = const Icon(Icons.play_arrow);
                        } else if (playerState == PlayerState.pause) {
                          unpause();
                          isPlay = const Icon(Icons.pause);
                        } else if (playerState == PlayerState.stop) {
                          isPlay = const Icon(Icons.play_arrow);
                          String path = (await localFileSave).path;
                          String name = "${"Surah " +
                              reciteJson[widget.surahNum + 1]["title"]} - $curName";
                          String temp = "$path/$name.mp3";
                          File file = File(temp);
                          print(temp);
                          if (await file.exists()) {
                            await pause();
                            await play(temp, isLocal: true);
                            var snackBar = const SnackBar(
                              content: Text('Playing Offline'),
                            );
                            await unpause();

                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                          } else {
                            await pause();
                            await play(curRecite);
                            var snackBar = const SnackBar(
                              content: Text('Playing Online'),
                            );

                            // Find the Scaffold in the widget tree and use it to show a SnackBar.
                            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar);
                            await unpause();
                          }
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 8,
                    child: Flex(
                        direction: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: position.inMilliseconds.toDouble(),
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            onChanged: (double value) {
                              audioPlayer.seek(
                                  Duration(milliseconds: value.toInt()));
                              unpause();
                              isPlay = const Icon(Icons.pause);
                              setState(() {});
                            },
                            min: 0.0,
                            max: dur(),
                          ),
                        ]),
                  ),
                  done
                      ? Flexible(
                          fit: FlexFit.tight,
                          flex: 3,
                          child: Text(
                            pos() != '' ? pos() : '0:00/0:00',
                            style: TextStyle(color: MyColors.text()),
                          ),
                        )
                      : Container()
                ],
              ),
            ));
  }

  Future<void> initializeTheme() async {
    if (prefs!.getDouble("quranArabicFont") == null) {
      prefs!.setDouble("quranArabicFont", 48);
    }
    if (prefs!.getDouble("quranEnglishFont") == null) {
      prefs!.setDouble("quranEnglishFont", 28);
    }
    if (prefs!.getDouble("quranFarsiFont") == null) {
      prefs!.setDouble("quranFarsiFont", 28);
    }
    if (prefs!.getDouble("quranUrduFont") == null) {
      prefs!.setDouble("quranUrduFont", 28);
    }
    if (prefs!.getBool("qurFont") == null) {
      prefs!.setBool("qurFont", true);
    }
    font = prefs!.getBool("qurFont")!;
    arabicSize = prefs!.getDouble("quranArabicFont")!;
    englishSize = prefs!.getDouble("quranEnglishFont")!;
    farsiSize = prefs!.getDouble("quranFarsiFont")!;
    urduSize = prefs!.getDouble("quranUrduFont")!;
    setState(() {});
  }

  Widget settings() {
    return Scaffold(
        backgroundColor: MyColors.background(),
        body: CustomScrollView(slivers: [
          SliverAppBar(
              toolbarHeight: toolbarSize(context),
              backgroundColor: MyColors.appBar(),
              leading: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.015),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    isSettings = false;
                    setState(() {});
                  },
                ),
              ),
              title: Padding(
                padding: EdgeInsets.fromLTRB(
                    0, MediaQuery.of(context).size.height * 0.015, 0, 0),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Settings",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontSize: titleSize(context))),
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
                      BorderRadius.vertical(bottom: Radius.circular(30))),
              bottom: PreferredSize(
                  // Add this code
                  preferredSize: Size(
                      double.infinity,
                      MediaQuery.of(context).size.height *
                          0.02), // Add this code
                  child: const Text(""))),
          SliverToBoxAdapter(
              child: WillPopScope(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Arabic Font Type",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "IndoPak",
                                style: TextStyle(color: MyColors.text()),
                              ),
                              Switch(
                                value: font,
                                onChanged: (d) async {
                                  prefs!.setBool("qurFont", d);
                                  font = d;
                                  setState(() {});
                                },
                                activeColor: MyColors.sliderInactive(),
                                activeTrackColor: MyColors.sliderActive(),
                                inactiveThumbColor: MyColors.sliderActive(),
                                inactiveTrackColor: MyColors.sliderInactive(),
                              ),
                              Text(
                                "Uthmani",
                                style: TextStyle(color: MyColors.text()),
                              ),
                            ],
                          ),
                          Text(
                            "Arabic Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: arabicSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 16,
                            max: 64,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranArabicFont", d);
                            },
                            onChanged: (d) async {
                              arabicSize = d;
                              setState(() {});
                            },
                          ),
                          const Divider(
                            height: 16,
                          ),
                          Text(
                            "English Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: englishSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 6,
                            max: 48,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranEnglishFont", d);
                            },
                            onChanged: (d) async {
                              englishSize = d;

                              setState(() {});
                            },
                          ),
                          const Divider(
                            height: 16,
                          ),
                          Text(
                            "Urdu Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: urduSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 6,
                            max: 48,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranUrduFont", d);
                            },
                            onChanged: (d) async {
                              urduSize = d;

                              setState(() {});
                            },
                          ),
                          const Divider(
                            height: 16,
                          ),
                          Text(
                            "Farsi Font Size",
                            style: TextStyle(color: MyColors.text()),
                          ),
                          Slider(
                            value: farsiSize,
                            inactiveColor: MyColors.sliderActive(),
                            activeColor: MyColors.sliderInactive(),
                            min: 6,
                            max: 48,
                            onChangeEnd: (d) {
                              prefs!.setDouble("quranFarsiFont", d);
                            },
                            onChanged: (d) async {
                              farsiSize = d;

                              setState(() {});
                            },
                          ),
                        ])),
              ],
            ),
            onWillPop: () {
              isSettings = false;
              _scrollController = ScrollController(
                  initialScrollOffset: scroll, keepScrollOffset: true);
              setState(() {});
              return Future.value(false);
            },
          ))
        ]));
  }
}

class KeepWidgetAlive extends StatefulWidget {
  Widget widgetToKeep;
  KeepWidgetAlive(this.widgetToKeep, {Key? key}) : super(key: key);

  @override
  _KeepWidgetAliveState createState() => _KeepWidgetAliveState();
}

class _KeepWidgetAliveState extends State<KeepWidgetAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.widgetToKeep;
  }

  @override
  bool get wantKeepAlive => true;
}

String engNumToArb(String s) {
  List<String> t = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  List<String> f = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];

  for (int i = 0; i < f.length; i++) {
    s = s.replaceAll(t[i], f[i]);
  }
  return s;
}

String engNumToInd(String s) {
  List<String> t = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
  List<String> f = ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"];

  for (int i = 0; i < f.length; i++) {
    s = s.replaceAll(t[i], f[i]);
  }
  print(s);
  return s;
}
