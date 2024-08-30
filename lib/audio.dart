  
import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

  AudioPlayer audioPlayer = AudioPlayer();

  enum PlayerState{stop, play, pause}

  PlayerState playerState = PlayerState.stop;

  Icon isPlay = const Icon(Icons.play_arrow);
  Color isLoop = Colors.grey;

  Refresh currentPage = Refresh((){});

  int curNum = 0;

  
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future<void> play(String kUrl, {bool isLocal = false, int curSong = 0}) async {
    curNum=curSong;
    if(isLocal){
      await audioPlayer.play(BytesSource(await File(kUrl).readAsBytes()));
    }else{
      print(kUrl);
      await audioPlayer.play(UrlSource(kUrl));
    }
    playerState = PlayerState.play;
    isPlay=const Icon(Icons.pause);
    //currentPage.ref;
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    playerState = PlayerState.pause;
  }

  Future<void> unpause() async {
    await audioPlayer.resume();
    playerState = PlayerState.play;
    
  }

  Future<void> stop() async {
    await audioPlayer.stop();
    playerState = PlayerState.stop;
    isPlay = const Icon(Icons.stop);
  }

  Future<void> newUrl(String kUrl) async {
    await audioPlayer.setSource(UrlSource(kUrl));
  }
  Future<void> release() async {
    await audioPlayer.release();
    playerState = PlayerState.stop;
  }

  class ControlAudio extends StatefulWidget{
    final bool isNext;
    final List<String>? filesList;

    const ControlAudio({Key? key, this.isNext=false, this.filesList}) : super (key: key);

    @override
    ControlAudioState createState()=> ControlAudioState();
  }

  class ControlAudioState extends State<ControlAudio>{

    @override
    void initState() async{
      super.initState();
      update();
      if(widget.isNext){
        audioPlayer.onPlayerComplete.listen((event){
          if(curNum+1==widget.filesList!.length){
            curNum=-1;
          }
          play(widget.filesList![curNum+1], curSong: curNum+1);
        });
      }
      duration = (await audioPlayer.getDuration())!;
      currentPage = Refresh(this.ref);
    }

    void update(){
      audioPlayer.onDurationChanged.listen((Duration d) {
        print('Max duration: $d');
        setState(() => duration = d);
      });
      audioPlayer.onPositionChanged.listen((Duration  p){
        print('Position: $p');
        setState(() => position = p);
      });
      audioPlayer.setReleaseMode(ReleaseMode.stop);
    }

    void ref(){
      setState(() {
              
            });
    }
    @override
    Widget build(BuildContext context){
      return BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: isPlay,
              onPressed: (){
                if(playerState==PlayerState.play) {
                  pause();
                  isPlay=const Icon(Icons.play_arrow);
                }
                else if(playerState==PlayerState.pause) {
                  unpause();
                  isPlay=const Icon(Icons.pause);
                }else{
                  isPlay = const Icon(Icons.stop);
                }
                setState(() {
                });
              },
            ),
            Flex(
              direction: Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: position.inMilliseconds.toDouble(),
                  onChanged: (double value) {
                      audioPlayer.seek(Duration(milliseconds: value.toInt()));
                      unpause();
                      isPlay =const Icon(Icons.pause);
                      setState(() {});
                      },
                  min: 0.0,
                  max: dur(),
                ),
              ]
            ),
            Text(pos()!=''?pos():'0:00/0:00'),
          ],
        ),
      );
    }

    String pos(){
      return '${position.inMinutes}:${secs(position)}/${duration.inMinutes}:${secs(duration)}';
    }

    String secs(Duration d){
      if(d.inSeconds%60<10) return '0${d.inSeconds%60}';
      return (d.inSeconds%60).toString();
    }

    double dur(){
      return duration.inMilliseconds.toDouble();
    }
  }

  class Refresh{
    Function ref;
    Refresh(this.ref);
  }

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<Directory> get localFileSave async {
  final path = await _localPath;
  final myDir = Directory('$path/saved');
  await Directory('$path/saved').create(recursive: true);
  return myDir;
}
Future<FileSystemEntity> get localFileSaveDel async {
  final path = await _localPath;
  
  Directory dir = Directory('$path/saved');
  return dir.delete(recursive: true);
}
Future<FileSystemEntity> deleteLocalFile(String path) async {
  File f = File(path);
  return f.delete(recursive: true);
}
Future<dynamic> downloadFile(String url, String songName, String singerName) async {
  String path = (await localFileSave).path;
  String temp = '$songName - $singerName';
  File file = File('$path/$temp.mp3');
  print('$path/$temp.mp3');

  var request = await http.get(Uri.parse(url));
  var bytes = request.bodyBytes;//close();
  await file.writeAsBytes(bytes);
  print("done");
}

  class ControlAudioQuran extends StatefulWidget{
    final String reciterLink;
    final String title;

    ControlAudioQuran({Key? key, this.reciterLink = '', this.title = ''}) : super (key: key);

    @override
    ControlAudioQuranState createState()=> ControlAudioQuranState();
  }

  class ControlAudioQuranState extends State<ControlAudioQuran>{
    bool loop=false;

    @override
    void initState() {
      super.initState();
      audioPlayer.setReleaseMode(ReleaseMode.release);
      currentPage = Refresh(this.ref);
      isPlay=const Icon(Icons.play_arrow);
      update();
    }

    void update(){
      audioPlayer.onDurationChanged.listen((Duration d) {
        print('Max duration: $d');
        setState(() => duration = d);
      });
      audioPlayer.onPositionChanged.listen((Duration  p){
        print('Position: $p');
        setState(() => position = p);
      });
      audioPlayer.setReleaseMode(ReleaseMode.stop);
    }

    void ref(){
      setState(() {
              
            });
    }
    @override
    Widget build(BuildContext context){
      return BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: isPlay,
                  onPressed: ()async{
                    if(playerState==PlayerState.play) {
                      pause();
                      isPlay=const Icon(Icons.play_arrow);
                    }
                    else if(playerState==PlayerState.pause) {
                      unpause();
                      isPlay=const Icon(Icons.pause);
                    }else if(playerState==PlayerState.stop){
                      isPlay = const Icon(Icons.play_arrow);
                      String path = (await localFileSave).path;
                      String name = widget.title;
                      String temp = "$path/$name.mp3";
                      File file = File(temp);
                      print(temp);
                      if(await file.exists()) {
                        play(temp, isLocal: true);
                      } else {
                        play(widget.reciterLink);
                      }
                      play(widget.reciterLink);
                    }
                    setState(() {
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.loop),
                  color: isLoop,
                  onPressed: (){
                    if(!loop) {
                      audioPlayer.setReleaseMode(ReleaseMode.loop);
                      isLoop=Colors.black;
                      loop=true;
                      setState(() {
                        
                      });
                    }else{
                      audioPlayer.setReleaseMode(ReleaseMode.release);
                      isLoop=Colors.grey;
                      loop=false;
                      setState(() {
                        
                      });
                    }
                  },
                ),
                Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      value: position.inMilliseconds.toDouble(),
                      onChanged: (double value) {
                          audioPlayer.seek( Duration(milliseconds: value.toInt()));
                          unpause();
                          isPlay =const Icon(Icons.pause);
                          setState(() {});
                          },
                      min: 0.0,
                      max: dur(),
                    ),
                  ]
                ),
                Text(pos()!=''?pos():'0:00/0:00'),
              ],
            )
          ]
        ),
      );
    }

    String pos(){
      return '${position.inMinutes}:${secs(position)}/${duration.inMinutes}:${secs(duration)}';
    }

    String secs(Duration d){
      return '0${d.inSeconds%60}';
    }

    double dur(){
      return duration.inMilliseconds.toDouble();
    }
  }