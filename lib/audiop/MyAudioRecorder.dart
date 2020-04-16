import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/track_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_sound/flauto.dart';
import 'package:virus_chat_app/chat/chat.dart';


enum t_MEDIA {
  FILE,
  BUFFER,
  ASSET,
  STREAM,
  REMOTE_EXAMPLE_FILE,
}

class MyAudioRecorder {
  static FlutterSound flutterSoundModule;

  t_CODEC _codec = t_CODEC.CODEC_AAC;
  t_MEDIA _media = t_MEDIA.FILE;


  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;


  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  List<String> _path = [null, null, null, null, null, null, null];
  String mPath = '';


  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  ChatScreenState _chatScreenState;

  static const List<String> paths = [
    'sound.aac', // DEFAULT
    'sound.aac', // CODEC_AAC
    'sound.opus', // CODEC_OPUS
    'sound.caf', // CODEC_CAF_OPUS
    'sound.mp3', // CODEC_MP3
    'sound.ogg', // CODEC_VORBIS
    'sound.wav', // CODEC_PCM
  ];


  List<String> assetSample = [
    'assets/samples/sample.aac',
    'assets/samples/sample.aac',
    'assets/samples/sample.opus',
    'assets/samples/sample.caf',
    'assets/samples/sample.mp3',
    'assets/samples/sample.ogg',
    'assets/samples/sample.wav',
  ];


  bool _encoderSupported = true; // Optimist
  bool _decoderSupported = true; // Optimist

  MyAudioRecorder(ChatScreenState chatScreenState) {
    _chatScreenState = chatScreenState;
  }


  void initializeExample(FlutterSound module) async {
    flutterSoundModule = module;
    flutterSoundModule.initializeMediaPlayer();
    flutterSoundModule.setSubscriptionDuration(0.01);
    flutterSoundModule.setDbPeakLevelUpdate(0.8);
    flutterSoundModule.setDbLevelEnabled(true);
    initializeDateFormatting();
    setCodec(_codec);
  }

  void startRecorder() async {
    try {
      // String path = await flutterSoundModule.startRecorder
      // (
      //   paths[_codec.index],
      //   codec: _codec,
      //   sampleRate: 16000,
      //   bitRate: 16000,
      //   numChannels: 1,
      //   androidAudioSource: AndroidAudioSource.MIC,
      // );
      Directory tempDir = await getTemporaryDirectory();

      mPath = await flutterSoundModule.startRecorder(
        uri: '${tempDir.path}/${paths[_codec.index]}',
        codec: _codec,
      );
      print('startRecorder: $mPath');

      _recorderSubscription =
          flutterSoundModule.onRecorderStateChanged.listen((e) {
            DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                e.currentPosition.toInt(), isUtc: true);
            String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
            _recorderTxt = txt.substring(0, 8);
            /*  this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });*/
          });
      /*_dbPeakSubscription = flutterSoundModule.onRecorderDbPeakChanged.listen((value) {
        print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });
*/
      this._path[_codec.index] = mPath;

      /* this.setState(() {
        this._isRecording = true;
        this._path[_codec.index] = path;
      });*/
    } catch (err) {
      print('startRecorder error: $err');
     /* stopRecorder();
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }*/
      /*  setState(() {
        stopRecorder();
        this._isRecording = false;
        if (_recorderSubscription != null) {
          _recorderSubscription.cancel();
          _recorderSubscription = null;
        }
        if (_dbPeakSubscription != null) {
          _dbPeakSubscription.cancel();
          _dbPeakSubscription = null;
        }
      });*/
    }
  }

  void stopRecorder() async {
    try {
      String result = await flutterSoundModule.stopRecorder();
      print('stopRecorder: $result');
      _chatScreenState.audioListenerPath(mPath);
      cancelRecorderSubscriptions();
    } catch (err) {
      print('stopRecorder error: $err');
    }
    /*this.setState(() {
      this._isRecording = false;
    });*/
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }


  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
    /* if (_dbPeakSubscription != null) {
      _dbPeakSubscription.cancel();
      _dbPeakSubscription = null;
    }*/
  }


  Future<void> startPlayer() async {
    try {
      final exampleAudioFilePath = "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3";
      final albumArtPath = "https://file-examples.com/wp-content/uploads/2017/10/file_example_PNG_500kB.png";
      //final albumArtPath =
      //"https://file-examples.com/wp-content/uploads/2017/10/file_example_PNG_500kB.png";

      String path;
      Uint8List dataBuffer;
      String audioFilePath;
      _addListeners();

      if (_media == t_MEDIA.ASSET) {
        dataBuffer = (await rootBundle.load(assetSample[_codec.index])).buffer
            .asUint8List();
      } else if (_media == t_MEDIA.FILE) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(_path[_codec.index])) audioFilePath = this.mPath;
      } else if (_media == t_MEDIA.BUFFER) {
        // Do we want to play from buffer or from file ?
        if (await fileExists(mPath)) {
          dataBuffer = await makeBuffer(this.mPath);
          if (dataBuffer == null) {
            throw Exception('Unable to create the buffer');
          }
        }
      } else if (_media == t_MEDIA.REMOTE_EXAMPLE_FILE) {
        // We have to play an example audio file loaded via a URL
        audioFilePath = exampleAudioFilePath;
      }

      // Check whether the user wants to use the audio player features
//      if (_isAudioPlayer) {
      String albumArtUrl;
      String albumArtAsset;
      if (_media == t_MEDIA.REMOTE_EXAMPLE_FILE)
        albumArtUrl = albumArtPath;
      else {
        if (Platform.isIOS) {
          albumArtAsset = 'AppIcon';
        } else if (Platform.isAndroid) {
          albumArtAsset = 'AppIcon.png';
        }
      }

      final track = Track(
        trackPath: audioFilePath,
        dataBuffer: dataBuffer,
        codec: _codec,
        trackTitle: "This is a record",
        trackAuthor: "from flutter_sound",
        albumArtUrl: albumArtUrl,
        albumArtAsset: albumArtAsset,
      );


      Flauto flauto = flutterSoundModule;
      path = await flauto.startPlayerFromTrack(
        track,
        /*canSkipForward:true, canSkipBackward:true,*/
        whenFinished: () {
          print('I hope you enjoyed listening to this song');
        },
        onSkipBackward: () {
          print('Skip backward');
          stopPlayer();
          startPlayer();
        },
        onSkipForward: () {
          print('Skip forward');
          stopPlayer();
          startPlayer();
        },
      );
      /* } else {
        if (audioFilePath != null) {
          path = await flutterSoundModule.startPlayer(audioFilePath, codec: _codec, whenFinished: () {
            print('Play finished');
//            setState(() {});
          });
        } else if (dataBuffer != null) {
          path = await flutterSoundModule.startPlayerFromBuffer(dataBuffer, codec: _codec, whenFinished: () {
            print('Play finished');
//            setState(() {});
          });
        }

        if (path == null) {
          print('Error starting player');
          return;
        }
      }*/

      print('startPlayer: $path');
      // await flutterSoundModule.setVolume(1.0);
    } catch (err) {
      print('error: $err');
    }
//    setState(() {});
  }


  // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
  Future<Uint8List> makeBuffer(String path) async {
    try {
      if (!await fileExists(path)) return null;
      File file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      print('The file is ${contents.length} bytes long.');
      return contents;
    } catch (e) {
      print(e);
      return null;
    }
  }


  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = flutterSoundModule.onPlayerStateChanged.listen((e) {
      if (e != null) {
        sliderCurrentPosition = e.currentPosition;
        maxDuration = e.duration;

        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(), isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
//        this.setState(() {
        //this._isPlaying = true;
        _playerTxt = txt.substring(0, 8);
        print('_playerTxt $_playerTxt');
//        });
      }
    });
  }

  setCodec(t_CODEC codec) async {
    _encoderSupported = await flutterSoundModule.isEncoderSupported(codec);
    _decoderSupported = await flutterSoundModule.isDecoderSupported(codec);

//    setState(() {
    _codec = codec;
//    });
  }

  onStartPlayerPressed() {
    if (_media == t_MEDIA.FILE ||
        _media == t_MEDIA.BUFFER) // A file must be already recorded to play it
        {
      if (_path[_codec.index] == null) return null;
    }
    if (_media == t_MEDIA.REMOTE_EXAMPLE_FILE && _codec !=
        t_CODEC.CODEC_MP3) // in this example we use just a remote mp3 file
      return null;

    // Disable the button if the selected codec is not supported
    if (!_decoderSupported) return null;
    return flutterSoundModule.audioState == t_AUDIO_STATE.IS_STOPPED
        ? startPlayer
        : null;
  }

  Future<void> stopPlayer() async {
    try {
      String result = await flutterSoundModule.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } catch (err) {
      print('error: $err');
    }
//    this.setState(() {
    //this._isPlaying = false;
//    });
  }

  Widget audioMessage(String content) {
    mPath = content;
    print('MPATH $mPath');
    return Row(
      children: <Widget>[
        Container(
            child: IconButton(
                icon: Icon(Icons.record_voice_over), onPressed: () async {
              print('audioMessage');
              await flutterPlaySound(mPath);
//            startPlayer();
            })
        ),
        Slider(
            value: sliderCurrentPosition,
            min: 0.0,
            max: maxDuration,
            onChanged: (double value) async {
              print("Playing Mohan $value");
              sliderCurrentPosition = value;
              await flutterSoundModule.seekToPlayer(value.toInt());
            },
            divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()),
      ],
    );
  }

  FlutterSound flutterSound = FlutterSound();

  flutterPlaySound(url) async {
    await flutterSound.startPlayer(url);

    flutterSound.onPlayerStateChanged.listen((e) {
      if(flutterSound.isPlaying) {
        this.sliderCurrentPosition = e.currentPosition;
        this.maxDuration = e.duration;
      }else{
        flutterSound.stopPlayer();
        sliderCurrentPosition= 0.0;
        maxDuration = 0.0;
      }
      if (sliderCurrentPosition == maxDuration) {
        flutterSound.stopPlayer();
        sliderCurrentPosition= 0.0;
        maxDuration = 0.0;
      }
      print(
          "Playing NUlllllllllllllllllllll $maxDuration ____ $sliderCurrentPosition _____$e");
      if(e == null){
//        setState(() {
//          this.isPlaying = false;
//        });
      }
      else{
//        setState(() {
//          this.isPlaying = false;
//        });
      }
    });
  }

  Future<dynamic> flutterStopPlayer(url) async {
    await flutterSound.stopPlayer().then(
            (value) {
          print('VALUEEEEEEEEEEEEEEEEEEEEEEEE $value');
//          flutterPlaySound(url);
        }
    );
  }

}