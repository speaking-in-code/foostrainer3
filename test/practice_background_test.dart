import 'dart:io';

import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:ft3/drill_data.dart';
import 'package:ft3/practice_background.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';

import 'fake_path_provider_platform.dart';

final _simpleDrill = DrillData(
  name: "wall",
  type: "pass",
  possessionSeconds: 10,
  actions: [ActionData(label: "wall", audioAsset: "/dev/null")],
);

class _ProgressMatcher extends Matcher {
  static const _mismatchDesc = 'mismatchDesc';
  final PracticeProgress _progress;

  _ProgressMatcher(this._progress);

  Description describe(Description description) {
    description.add('matches $_progress');
    return description;
  }

  @override
  bool matches(covariant PracticeProgress found, Map matchState) {
    String err ='';
    err += _check('drill', found.drill, _progress.drill);
    err += _check('practiceState', found.practiceState, _progress.practiceState);
    err += _check('action', found.action, _progress.action);
    err += _check('lastAction', found.lastAction, _progress.lastAction);
    err += _check('results', found.results, _progress.results);
    err += _check('confirm', found.confirm, _progress.confirm);
    matchState[_mismatchDesc] = err;
    return err.isEmpty;
  }

  // Returns the error, or the empty string.
  String _check(String label, dynamic found, dynamic expected) {
    if (found == expected) {
      return '';
    }
    return 'had $label=$found, expected $label=$expected\n';
  }

  @override
  Description describeMismatch(covariant PracticeProgress found,
      Description mismatchDescription, Map matchState, bool verbose) {
    mismatchDescription.add(matchState[_mismatchDesc]);
    return mismatchDescription;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PracticeBackground tests', () {
    FakePathProviderPlatform? _pathProvider;
    PracticeBackground? _practice;

    setUp(() async {
      setupFirebaseCoreMocks();
      await Firebase.initializeApp();
      _pathProvider = await FakePathProviderPlatform.create();
      AudioServicePlatform.instance = FakeAudioServicePlatform();
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    tearDown(() async {
      _pathProvider?.cleanup();
      _practice?.stopPractice();
    });

    /*
    test('Starts and stops', () async {
      _practice = await PracticeBackground.init();
      expect(_practice, isNotNull);
      // _practice!.startPractice(_simpleDrill);
      _practice!.stopPractice();
      // TODO(beaton): play around with matchers for the state until this
      // seems right.
      expect(_practice!.progressStream,
          emits(_ProgressMatcher(PracticeProgress())));
      _practice = null;
    });
     */

    test('Starts drill', () async {
      _practice = await PracticeBackground.init();
      expect(_practice, isNotNull);
      await _practice!.startPractice(_simpleDrill);
      await _practice!.play();
      await Future.delayed(Duration(seconds: 16));

      // _practice!.stopPractice();
      expect(_practice!.progressStream,
          emits(_ProgressMatcher(PracticeProgress())));
      _practice = null;
    });
  });

  /*
  group('combine2', () {
    test('No right', () async {
      final left = BehaviorSubject<int>();
      final right = BehaviorSubject<int>();
      final combine = Rx.combineLatest2(left, right, (int l, int r) {
        print('Got $l and $r');
        return l + r;
      });
      left.add(10);
      right.add(1);
      right.add(2);
      expect(combine, emitsInOrder([11, 12]));
    });
  });
   */
}

class FakeAudioServicePlatform extends AudioServicePlatform {
  AudioHandlerCallbacks? _callbacks;
  ConfigureRequest? _configureRequest;
  SetQueueRequest? _queueRequest;
  SetStateRequest? _stateRequest;
  SetMediaItemRequest? _mediaItem;

  @override
  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) {
    _callbacks = callbacks;
  }

  @override
  Future<void> configure(ConfigureRequest request) async {
    _configureRequest = request;
  }

  @override
  Future<void> setQueue(SetQueueRequest request) async {
    _queueRequest = request;
  }

  @override
  Future<void> setState(SetStateRequest request) async {
    _stateRequest = request;
  }

  @override
  Future<void> setMediaItem(SetMediaItemRequest request) async {
    _mediaItem = request;
  }
}
