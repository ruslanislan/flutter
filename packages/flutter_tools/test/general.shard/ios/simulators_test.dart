// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:file/memory.dart';
import 'package:flutter_tools/src/base/file_system.dart';
import 'package:flutter_tools/src/base/io.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/base/platform.dart';
import 'package:flutter_tools/src/base/process.dart';
import 'package:flutter_tools/src/build_info.dart';
import 'package:flutter_tools/src/devfs.dart';
import 'package:flutter_tools/src/device.dart';
import 'package:flutter_tools/src/device_port_forwarder.dart';
import 'package:flutter_tools/src/globals_null_migrated.dart' as globals;
import 'package:flutter_tools/src/ios/application_package.dart';
import 'package:flutter_tools/src/ios/plist_parser.dart';
import 'package:flutter_tools/src/ios/simulators.dart';
import 'package:flutter_tools/src/macos/xcode.dart';
import 'package:flutter_tools/src/project.dart';
<<<<<<< HEAD
import 'package:flutter_tools/src/protocol_discovery.dart';
import 'package:mockito/mockito.dart';
import 'package:process/process.dart';
=======
import 'package:test/fake.dart';
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645

import '../../src/common.dart';
import '../../src/context.dart';
import '../../src/fakes.dart';

final Platform macosPlatform = FakePlatform(
  operatingSystem: 'macos',
  environment: <String, String>{
    'HOME': '/'
  },
);

void main() {
  FakePlatform osx;
  FileSystemUtils fsUtils;
  MemoryFileSystem fileSystem;

  setUp(() {
    osx = FakePlatform(
      environment: <String, String>{},
      operatingSystem: 'macos',
    );
    fileSystem = MemoryFileSystem.test();
    fsUtils = FileSystemUtils(fileSystem: fileSystem, platform: osx);
  });

  group('_IOSSimulatorDevicePortForwarder', () {
    FakeSimControl simControl;
    Xcode xcode;

    setUp(() {
      simControl = FakeSimControl();
      xcode = Xcode.test(processManager: FakeProcessManager.any());
    });

    testUsingContext('dispose() does not throw an exception', () async {
      final IOSSimulator simulator = IOSSimulator(
        '123',
        simControl: simControl,
      );
      final DevicePortForwarder portForwarder = simulator.portForwarder;
      await portForwarder.forward(123);
      await portForwarder.forward(124);
      expect(portForwarder.forwardedPorts.length, 2);
      try {
        await portForwarder.dispose();
      } on Exception catch (e) {
        fail('Encountered exception: $e');
      }
      expect(portForwarder.forwardedPorts.length, 0);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
<<<<<<< HEAD
      Xcode: () => mockXcode,
=======
      Xcode: () => xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    }, testOn: 'posix');
  });

  testUsingContext('simulators only support debug mode', () async {
    final IOSSimulator simulator = IOSSimulator(
      '123',
      simControl: FakeSimControl(),
    );

    expect(simulator.supportsRuntimeMode(BuildMode.debug), true);
    expect(simulator.supportsRuntimeMode(BuildMode.profile), false);
    expect(simulator.supportsRuntimeMode(BuildMode.release), false);
    expect(simulator.supportsRuntimeMode(BuildMode.jitRelease), false);
  }, overrides: <Type, Generator>{
    Platform: () => osx,
    FileSystem: () => fileSystem,
    ProcessManager: () => FakeProcessManager.any(),
  });

  group('logFilePath', () {
    FakeSimControl simControl;

    setUp(() {
      simControl = FakeSimControl();
    });

    testUsingContext('defaults to rooted from HOME', () {
      osx.environment['HOME'] = '/foo/bar';
      final IOSSimulator simulator = IOSSimulator(
        '123',
        simControl: simControl,
      );
      expect(simulator.logFilePath, '/foo/bar/Library/Logs/CoreSimulator/123/system.log');
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystemUtils: () => fsUtils,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    }, testOn: 'posix');

    testUsingContext('respects IOS_SIMULATOR_LOG_FILE_PATH', () {
      osx.environment['HOME'] = '/foo/bar';
      osx.environment['IOS_SIMULATOR_LOG_FILE_PATH'] = '/baz/qux/%{id}/system.log';
      final IOSSimulator simulator = IOSSimulator(
        '456',
        simControl: simControl,
      );
      expect(simulator.logFilePath, '/baz/qux/456/system.log');
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystemUtils: () => fsUtils,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });
  });

  group('compareIosVersions', () {
    testWithoutContext('compares correctly', () {
      // This list must be sorted in ascending preference order
      final List<String> testList = <String>[
        '8', '8.0', '8.1', '8.2',
        '9', '9.0', '9.1', '9.2',
        '10', '10.0', '10.1',
      ];

      for (int i = 0; i < testList.length; i++) {
        expect(compareIosVersions(testList[i], testList[i]), 0);
      }

      for (int i = 0; i < testList.length - 1; i++) {
        for (int j = i + 1; j < testList.length; j++) {
          expect(compareIosVersions(testList[i], testList[j]), lessThan(0));
          expect(compareIosVersions(testList[j], testList[i]), greaterThan(0));
        }
      }
    });
  });

  group('compareIphoneVersions', () {
    testWithoutContext('compares correctly', () {
      // This list must be sorted in ascending preference order
      final List<String> testList = <String>[
        'com.apple.CoreSimulator.SimDeviceType.iPhone-4s',
        'com.apple.CoreSimulator.SimDeviceType.iPhone-5',
        'com.apple.CoreSimulator.SimDeviceType.iPhone-5s',
        'com.apple.CoreSimulator.SimDeviceType.iPhone-6strange',
        'com.apple.CoreSimulator.SimDeviceType.iPhone-6-Plus',
        'com.apple.CoreSimulator.SimDeviceType.iPhone-6',
        'com.apple.CoreSimulator.SimDeviceType.iPhone-6s-Plus',
        'com.apple.CoreSimulator.SimDeviceType.iPhone-6s',
      ];

      for (int i = 0; i < testList.length; i++) {
        expect(compareIphoneVersions(testList[i], testList[i]), 0);
      }

      for (int i = 0; i < testList.length - 1; i++) {
        for (int j = i + 1; j < testList.length; j++) {
          expect(compareIphoneVersions(testList[i], testList[j]), lessThan(0));
          expect(compareIphoneVersions(testList[j], testList[i]), greaterThan(0));
        }
      }
    });
  });

  group('sdkMajorVersion', () {
    FakeSimControl simControl;

    setUp(() {
      simControl = FakeSimControl();
    });

    // This new version string appears in SimulatorApp-850 CoreSimulator-518.16 beta.
    testWithoutContext('can be parsed from iOS-11-3', () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'com.apple.CoreSimulator.SimRuntime.iOS-11-3',
        simControl: simControl,
      );

      expect(await device.sdkMajorVersion, 11);
    });

    testWithoutContext('can be parsed from iOS 11.2', () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'iOS 11.2',
        simControl: simControl,
      );

      expect(await device.sdkMajorVersion, 11);
    });

    testWithoutContext('Has a simulator category', () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'iOS 11.2',
        simControl: simControl,
      );

      expect(device.category, Category.mobile);
    });
  });

  group('IOSSimulator.isSupported', () {
    FakeSimControl simControl;

    setUp(() {
      simControl = FakeSimControl();
    });

    testUsingContext('Apple TV is unsupported', () {
      final IOSSimulator simulator = IOSSimulator(
        'x',
        name: 'Apple TV',
        simControl: simControl,
      );
      expect(simulator.isSupported(), false);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('Apple Watch is unsupported', () {
      expect(IOSSimulator(
        'x',
        name: 'Apple Watch',
        simControl: simControl,
      ).isSupported(), false);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('iPad 2 is supported', () {
      expect(IOSSimulator(
        'x',
        name: 'iPad 2',
        simControl: simControl,
      ).isSupported(), true);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('iPad Retina is supported', () {
      expect(IOSSimulator(
        'x',
        name: 'iPad Retina',
        simControl: simControl,
      ).isSupported(), true);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('iPhone 5 is supported', () {
      expect(IOSSimulator(
        'x',
        name: 'iPhone 5',
        simControl: simControl,
      ).isSupported(), true);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('iPhone 5s is supported', () {
      expect(IOSSimulator(
        'x',
        name: 'iPhone 5s',
        simControl: simControl,
      ).isSupported(), true);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('iPhone SE is supported', () {
      expect(IOSSimulator(
        'x',
        name: 'iPhone SE',
        simControl: simControl,
      ).isSupported(), true);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('iPhone 7 Plus is supported', () {
      expect(IOSSimulator(
        'x',
        name: 'iPhone 7 Plus',
        simControl: simControl,
      ).isSupported(), true);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });

    testUsingContext('iPhone X is supported', () {
      expect(IOSSimulator(
        'x',
        name: 'iPhone X',
        simControl: simControl,
      ).isSupported(), true);
    }, overrides: <Type, Generator>{
      Platform: () => osx,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => mockXcode,
    });
  });

  group('Simulator screenshot', () {
    testWithoutContext('supports screenshots', () async {
      final Xcode xcode = Xcode.test(processManager: FakeProcessManager.any());
      final Logger logger = BufferLogger.test();
      final FakeProcessManager fakeProcessManager = FakeProcessManager.list(<FakeCommand>[
        const FakeCommand(
          command: <String>[
            'xcrun',
            'simctl',
            'io',
            'x',
            'screenshot',
            'screenshot.png',
          ],
        ),
      ]);

      // Test a real one. Screenshot doesn't require instance states.
      final SimControl simControl = SimControl(
<<<<<<< HEAD
        processManager: mockProcessManager,
        logger: mockLogger,
        xcode: mockXcode,
=======
        processManager: fakeProcessManager,
        logger: logger,
        xcode: xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      );
      // Doesn't matter what the device is.
      final IOSSimulator deviceUnderTest = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simControl: simControl,
      );
<<<<<<< HEAD
      when(mockXcode.xcrunCommand()).thenReturn(<String>['xcrun']);
    });

    testWithoutContext(
      "old Xcode doesn't support screenshot",
      () {
        when(mockXcode.majorVersion).thenReturn(7);
        when(mockXcode.minorVersion).thenReturn(1);
        expect(deviceUnderTest.supportsScreenshot, false);
      },
    );

    testWithoutContext(
      'Xcode 8.2+ supports screenshots',
      () async {
        when(mockXcode.majorVersion).thenReturn(8);
        when(mockXcode.minorVersion).thenReturn(2);
        expect(deviceUnderTest.supportsScreenshot, true);
        final MockFile mockFile = MockFile();
        when(mockFile.path).thenReturn(fs.path.join('some', 'path', 'to', 'screenshot.png'));
        await deviceUnderTest.takeScreenshot(mockFile);
        verify(mockProcessManager.run(
          <String>[
            'xcrun',
            'simctl',
            'io',
            'x',
            'screenshot',
            fs.path.join('some', 'path', 'to', 'screenshot.png'),
          ],
          environment: null,
          workingDirectory: null,
        ));
      },
    );
=======

      final File screenshot = MemoryFileSystem.test().file('screenshot.png');
      await deviceUnderTest.takeScreenshot(screenshot);
      expect(fakeProcessManager.hasRemainingExpectations, isFalse);
    });
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
  });

  group('device log tool', () {
    FakeProcessManager fakeProcessManager;
    FakeSimControl simControl;

    setUp(() {
<<<<<<< HEAD
      mockProcessManager = MockProcessManager();
      when(mockProcessManager.start(any, environment: null, workingDirectory: null))
        .thenAnswer((Invocation invocation) => Future<Process>.value(MockProcess()));
      mockSimControl = MockSimControl();
      mockXcode = MockXcode();
      when(mockXcode.xcrunCommand()).thenReturn(<String>['xcrun']);
=======
      fakeProcessManager = FakeProcessManager.empty();
      simControl = FakeSimControl();
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });

    testUsingContext('syslog uses tail', () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'iOS 9.3',
        simControl: simControl,
      );
      fakeProcessManager.addCommand(const FakeCommand(command: <String>[
        'tail',
        '-n',
        '0',
        '-F',
        '/Library/Logs/CoreSimulator/x/system.log',
      ]));
      await launchDeviceSystemLogTool(device);
      expect(fakeProcessManager.hasRemainingExpectations, isFalse);
    },
    overrides: <Type, Generator>{
      ProcessManager: () => fakeProcessManager,
      FileSystem: () => fileSystem,
      Platform: () => macosPlatform,
      FileSystemUtils: () => FileSystemUtils(
        fileSystem: fileSystem,
        platform: macosPlatform,
      ),
<<<<<<< HEAD
      Xcode: () => mockXcode,
=======
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });

    testUsingContext('unified logging with app name', () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'iOS 11.0',
        simControl: simControl,
      );
      const String expectedPredicate = 'eventType = logEvent AND '
<<<<<<< HEAD
        'processImagePath ENDSWITH "My Super Awesome App" AND '
        '(senderImagePath ENDSWITH "/Flutter" OR senderImagePath ENDSWITH "/libswiftCore.dylib" OR processImageUUID == senderImageUUID) AND '
        'NOT(eventMessage CONTAINS ": could not find icon for representation -> com.apple.") AND '
        'NOT(eventMessage BEGINSWITH "assertion failed: ") AND '
        'NOT(eventMessage CONTAINS " libxpc.dylib ")';

      final List<String> command = verify(mockProcessManager.start(captureAny, environment: null, workingDirectory: null)).captured.single as List<String>;
      expect(command, <String>[
=======
          'processImagePath ENDSWITH "My Super Awesome App" AND '
          '(senderImagePath ENDSWITH "/Flutter" OR senderImagePath ENDSWITH "/libswiftCore.dylib" OR processImageUUID == senderImageUUID) AND '
          'NOT(eventMessage CONTAINS ": could not find icon for representation -> com.apple.") AND '
          'NOT(eventMessage BEGINSWITH "assertion failed: ") AND '
          'NOT(eventMessage CONTAINS " libxpc.dylib ")';
      fakeProcessManager.addCommand(const FakeCommand(command: <String>[
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
        'xcrun',
        'simctl',
        'spawn',
        'x',
        'log',
        'stream',
        '--style',
        'json',
        '--predicate',
        expectedPredicate,
      ]));

      await launchDeviceUnifiedLogging(device, 'My Super Awesome App');
      expect(fakeProcessManager.hasRemainingExpectations, isFalse);
    },
      overrides: <Type, Generator>{
      ProcessManager: () => fakeProcessManager,
      FileSystem: () => fileSystem,
      Xcode: () => mockXcode,
    });

    testUsingContext('unified logging without app name', () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'iOS 11.0',
        simControl: simControl,
      );
      const String expectedPredicate = 'eventType = logEvent AND '
<<<<<<< HEAD
        '(senderImagePath ENDSWITH "/Flutter" OR senderImagePath ENDSWITH "/libswiftCore.dylib" OR processImageUUID == senderImageUUID) AND '
        'NOT(eventMessage CONTAINS ": could not find icon for representation -> com.apple.") AND '
        'NOT(eventMessage BEGINSWITH "assertion failed: ") AND '
        'NOT(eventMessage CONTAINS " libxpc.dylib ")';

      final List<String> command = verify(mockProcessManager.start(captureAny, environment: null, workingDirectory: null)).captured.single as List<String>;
      expect(command, <String>[
=======
          '(senderImagePath ENDSWITH "/Flutter" OR senderImagePath ENDSWITH "/libswiftCore.dylib" OR processImageUUID == senderImageUUID) AND '
          'NOT(eventMessage CONTAINS ": could not find icon for representation -> com.apple.") AND '
          'NOT(eventMessage BEGINSWITH "assertion failed: ") AND '
          'NOT(eventMessage CONTAINS " libxpc.dylib ")';
      fakeProcessManager.addCommand(const FakeCommand(command: <String>[
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
        'xcrun',
        'simctl',
        'spawn',
        'x',
        'log',
        'stream',
        '--style',
        'json',
        '--predicate',
        expectedPredicate,
      ]));

      await launchDeviceUnifiedLogging(device, null);
      expect(fakeProcessManager.hasRemainingExpectations, isFalse);
    },
      overrides: <Type, Generator>{
        ProcessManager: () => fakeProcessManager,
        FileSystem: () => fileSystem,
        Xcode: () => mockXcode,
      });
  });

  group('log reader', () {
    FakeProcessManager fakeProcessManager;
    FakeIosProject mockIosProject;
    FakeSimControl simControl;
    Xcode xcode;

    setUp(() {
<<<<<<< HEAD
      fakeProcessManager = FakeProcessManager.list(<FakeCommand>[]);
      mockIosProject = MockIosProject();
      mockSimControl = MockSimControl();
      mockXcode = MockXcode();
      when(mockXcode.xcrunCommand()).thenReturn(<String>['xcrun']);
=======
      fakeProcessManager = FakeProcessManager.empty();
      mockIosProject = FakeIosProject();
      simControl = FakeSimControl();
      xcode = Xcode.test(processManager: FakeProcessManager.any());
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });

    group('syslog', () {
      setUp(() {
        final File syslog = fileSystem.file('system.log')..createSync();
        osx.environment['IOS_SIMULATOR_LOG_FILE_PATH'] = syslog.path;
      });

      testUsingContext('simulator can parse Xcode 8/iOS 10-style logs', () async {
        fakeProcessManager
          ..addCommand(const FakeCommand(
            command:  <String>['tail', '-n', '0', '-F', 'system.log'],
            stdout: '''
Dec 20 17:04:32 md32-11-vm1 My Super Awesome App[88374]: flutter: Observatory listening on http://127.0.0.1:64213/1Uoeu523990=/
Dec 20 17:04:32 md32-11-vm1 Another App[88374]: Ignore this text'''
          ))
          ..addCommand(const FakeCommand(
            command:  <String>['tail', '-n', '0', '-F', '/private/var/log/system.log']
          ));

        final IOSSimulator device = IOSSimulator(
          '123456',
          simulatorCategory: 'iOS 10.0',
          simControl: simControl,
        );
        final DeviceLogReader logReader = device.getLogReader(
          app: await BuildableIOSApp.fromProject(mockIosProject, null),
        );

        final List<String> lines = await logReader.logLines.toList();
        expect(lines, <String>[
          'flutter: Observatory listening on http://127.0.0.1:64213/1Uoeu523990=/',
        ]);
        expect(fakeProcessManager.hasRemainingExpectations, isFalse);
      }, overrides: <Type, Generator>{
        ProcessManager: () => fakeProcessManager,
        FileSystem: () => fileSystem,
        Platform: () => osx,
<<<<<<< HEAD
        Xcode: () => mockXcode,
=======
        Xcode: () => xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      });

      testUsingContext('simulator can output `)`', () async {
        fakeProcessManager
          ..addCommand(const FakeCommand(
            command:  <String>['tail', '-n', '0', '-F', 'system.log'],
            stdout: '''
2017-09-13 15:26:57.228948-0700  localhost My Super Awesome App[37195]: (Flutter) Observatory listening on http://127.0.0.1:57701/
2017-09-13 15:26:57.228948-0700  localhost My Super Awesome App[37195]: (Flutter) ))))))))))
2017-09-13 15:26:57.228948-0700  localhost My Super Awesome App[37195]: (Flutter) #0      Object.noSuchMethod (dart:core-patch/dart:core/object_patch.dart:46)'''
          ))
          ..addCommand(const FakeCommand(
            command:  <String>['tail', '-n', '0', '-F', '/private/var/log/system.log']
          ));

        final IOSSimulator device = IOSSimulator(
          '123456',
          simulatorCategory: 'iOS 10.3',
          simControl: simControl,
        );
        final DeviceLogReader logReader = device.getLogReader(
          app: await BuildableIOSApp.fromProject(mockIosProject, null),
        );

        final List<String> lines = await logReader.logLines.toList();
        expect(lines, <String>[
          'Observatory listening on http://127.0.0.1:57701/',
          '))))))))))',
          '#0      Object.noSuchMethod (dart:core-patch/dart:core/object_patch.dart:46)',
        ]);
        expect(fakeProcessManager.hasRemainingExpectations, isFalse);
      }, overrides: <Type, Generator>{
        ProcessManager: () => fakeProcessManager,
        FileSystem: () => fileSystem,
        Platform: () => osx,
<<<<<<< HEAD
        Xcode: () => mockXcode,
=======
        Xcode: () => xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      });

      testUsingContext('multiline messages', () async {
        fakeProcessManager
          ..addCommand(const FakeCommand(
            command:  <String>['tail', '-n', '0', '-F', 'system.log'],
            stdout: '''
2017-09-13 15:26:57.228948-0700  localhost My Super Awesome App[37195]: (Flutter) Single line message
2017-09-13 15:26:57.228948-0700  localhost My Super Awesome App[37195]: (Flutter) Multi line message
  continues...
  continues...
2020-03-11 15:58:28.207175-0700  localhost My Super Awesome App[72166]: (libnetwork.dylib) [com.apple.network:] [28 www.googleapis.com:443 stream, pid: 72166, tls] cancelled
	[28.1 64A98447-EABF-4983-A387-7DB9D0C1785F 10.0.1.200.57912<->172.217.6.74:443]
	Connected Path: satisfied (Path is satisfied), interface: en18
	Duration: 0.271s, DNS @0.000s took 0.001s, TCP @0.002s took 0.019s, TLS took 0.046s
	bytes in/out: 4468/1933, packets in/out: 11/10, rtt: 0.016s, retransmitted packets: 0, out-of-order packets: 0
2017-09-13 15:36:57.228948-0700  localhost My Super Awesome App[37195]: (Flutter) Multi line message again
  and it goes...
  and goes...
2017-09-13 15:36:57.228948-0700  localhost My Super Awesome App[37195]: (Flutter) Single line message, not the part of the above
'''
          ))
          ..addCommand(const FakeCommand(
            command:  <String>['tail', '-n', '0', '-F', '/private/var/log/system.log']
          ));

        final IOSSimulator device = IOSSimulator(
          '123456',
          simulatorCategory: 'iOS 10.3',
          simControl: simControl,
        );
        final DeviceLogReader logReader = device.getLogReader(
          app: await BuildableIOSApp.fromProject(mockIosProject, null),
        );

        final List<String> lines = await logReader.logLines.toList();
        expect(lines, <String>[
          'Single line message',
          'Multi line message',
          '  continues...',
          '  continues...',
          'Multi line message again',
          '  and it goes...',
          '  and goes...',
          'Single line message, not the part of the above'
        ]);
        expect(fakeProcessManager.hasRemainingExpectations, isFalse);
      }, overrides: <Type, Generator>{
        ProcessManager: () => fakeProcessManager,
        FileSystem: () => fileSystem,
        Platform: () => osx,
<<<<<<< HEAD
        Xcode: () => mockXcode,
=======
        Xcode: () => xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      });
    });

    group('unified logging', () {
      testUsingContext('log reader handles escaped multiline messages', () async {
        const String logPredicate = 'eventType = logEvent AND processImagePath ENDSWITH "My Super Awesome App" '
          'AND (senderImagePath ENDSWITH "/Flutter" OR senderImagePath ENDSWITH "/libswiftCore.dylib" '
          'OR processImageUUID == senderImageUUID) AND NOT(eventMessage CONTAINS ": could not find icon '
          'for representation -> com.apple.") AND NOT(eventMessage BEGINSWITH "assertion failed: ") '
          'AND NOT(eventMessage CONTAINS " libxpc.dylib ")';
        fakeProcessManager.addCommand(const FakeCommand(
            command:  <String>[
              'xcrun',
              'simctl',
              'spawn',
              '123456',
              'log',
              'stream',
              '--style',
              'json',
              '--predicate',
              logPredicate,
            ],
            stdout: r'''
},{
  "traceID" : 37579774151491588,
  "eventMessage" : "Single line message",
  "eventType" : "logEvent"
},{
  "traceID" : 37579774151491588,
  "eventMessage" : "Multi line message\n  continues...\n  continues..."
},{
  "traceID" : 37579774151491588,
  "eventMessage" : "Single line message, not the part of the above",
  "eventType" : "logEvent"
},{
'''
          ));

        final IOSSimulator device = IOSSimulator(
          '123456',
          simulatorCategory: 'iOS 11.0',
          simControl: simControl,
        );
        final DeviceLogReader logReader = device.getLogReader(
          app: await BuildableIOSApp.fromProject(mockIosProject, null),
        );

        final List<String> lines = await logReader.logLines.toList();
        expect(lines, <String>[
          'Single line message', 'Multi line message\n  continues...\n  continues...',
          'Single line message, not the part of the above'
        ]);
        expect(fakeProcessManager.hasRemainingExpectations, isFalse);
      }, overrides: <Type, Generator>{
        ProcessManager: () => fakeProcessManager,
        FileSystem: () => fileSystem,
        Xcode: () => mockXcode,
      });
    });
  });

  group('SimControl', () {
    const String validSimControlOutput = '''
{
  "devices" : {
    "watchOS 4.3" : [
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "Apple Watch - 38mm",
        "udid" : "TEST-WATCH-UDID"
      }
    ],
    "iOS 11.4" : [
      {
        "state" : "Booted",
        "availability" : "(available)",
        "name" : "iPhone 5s",
        "udid" : "TEST-PHONE-UDID"
      }
    ],
    "tvOS 11.4" : [
      {
        "state" : "Shutdown",
        "availability" : "(available)",
        "name" : "Apple TV",
        "udid" : "TEST-TV-UDID"
      }
    ]
  }
}
    ''';

    FakeProcessManager fakeProcessManager;
    Xcode xcode;
    SimControl simControl;
    const String deviceId = 'smart-phone';
    const String appId = 'flutterApp';

    setUp(() {
<<<<<<< HEAD
      mockLogger = MockLogger();
      mockProcessManager = MockProcessManager();
      when(mockProcessManager.run(any)).thenAnswer((Invocation _) async {
        return ProcessResult(mockPid, 0, validSimControlOutput, '');
      });

      mockXcode = MockXcode();
      when(mockXcode.xcrunCommand()).thenReturn(<String>['xcrun']);
      simControl = SimControl(
        logger: mockLogger,
        processManager: mockProcessManager,
        xcode: mockXcode,
=======
      fakeProcessManager = FakeProcessManager.empty();
      xcode = Xcode.test(processManager: FakeProcessManager.any());
      simControl = SimControl(
        logger: BufferLogger.test(),
        processManager: fakeProcessManager,
        xcode: xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      );
    });

    testWithoutContext('getDevices succeeds', () async {
      fakeProcessManager.addCommand(const FakeCommand(
        command: <String>[
          'xcrun',
          'simctl',
          'list',
          '--json',
          'devices',
        ],
        stdout: validSimControlOutput,
      ));

      final List<SimDevice> devices = await simControl.getDevices();

      final SimDevice watch = devices[0];
      expect(watch.category, 'watchOS 4.3');
      expect(watch.state, 'Shutdown');
      expect(watch.availability, '(available)');
      expect(watch.name, 'Apple Watch - 38mm');
      expect(watch.udid, 'TEST-WATCH-UDID');
      expect(watch.isBooted, isFalse);

      final SimDevice phone = devices[1];
      expect(phone.category, 'iOS 11.4');
      expect(phone.state, 'Booted');
      expect(phone.availability, '(available)');
      expect(phone.name, 'iPhone 5s');
      expect(phone.udid, 'TEST-PHONE-UDID');
      expect(phone.isBooted, isTrue);

      final SimDevice tv = devices[2];
      expect(tv.category, 'tvOS 11.4');
      expect(tv.state, 'Shutdown');
      expect(tv.availability, '(available)');
      expect(tv.name, 'Apple TV');
      expect(tv.udid, 'TEST-TV-UDID');
      expect(tv.isBooted, isFalse);
      expect(fakeProcessManager.hasRemainingExpectations, isFalse);
    });

    testWithoutContext('getDevices handles bad simctl output', () async {
      fakeProcessManager.addCommand(const FakeCommand(
        command: <String>[
          'xcrun',
          'simctl',
          'list',
          '--json',
          'devices',
        ],
        stdout: 'Install Started',
      ));

      final List<SimDevice> devices = await simControl.getDevices();

      expect(devices, isEmpty);
      expect(fakeProcessManager.hasRemainingExpectations, isFalse);
    });

    testWithoutContext('sdkMajorVersion defaults to 11 when sdkNameAndVersion is junk', () async {
      final IOSSimulator iosSimulatorA = IOSSimulator(
        'x',
        name: 'Testo',
        simulatorCategory: 'NaN',
        simControl: simControl,
      );

      expect(await iosSimulatorA.sdkMajorVersion, 11);
    });

    testWithoutContext('.install() handles exceptions', () async {
<<<<<<< HEAD
      when(mockProcessManager.run(
        <String>['xcrun', 'simctl', 'install', deviceId, appId],
        environment: anyNamed('environment'),
        workingDirectory: anyNamed('workingDirectory'),
      )).thenThrow(const ProcessException('xcrun', <String>[]));
=======
      fakeProcessManager.addCommand(const FakeCommand(
        command: <String>[
          'xcrun',
          'simctl',
          'install',
          deviceId,
          appId,
        ],
        exception: ProcessException('xcrun', <String>[]),
      ));

>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      expect(
        () async => simControl.install(deviceId, appId),
        throwsToolExit(message: r'Unable to install'),
      );
    });

    testWithoutContext('.uninstall() handles exceptions', () async {
<<<<<<< HEAD
      when(mockProcessManager.run(
        <String>['xcrun', 'simctl', 'uninstall', deviceId, appId],
        environment: anyNamed('environment'),
        workingDirectory: anyNamed('workingDirectory'),
      )).thenThrow(const ProcessException('xcrun', <String>[]));
=======
      fakeProcessManager.addCommand(const FakeCommand(
        command: <String>[
          'xcrun',
          'simctl',
          'uninstall',
          deviceId,
          appId,
        ],
        exception: ProcessException('xcrun', <String>[]),
      ));

>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      expect(
        () async => simControl.uninstall(deviceId, appId),
        throwsToolExit(message: r'Unable to uninstall'),
      );
    });

    testWithoutContext('.launch() handles exceptions', () async {
<<<<<<< HEAD
      when(mockProcessManager.run(
        <String>['xcrun', 'simctl', 'launch', deviceId, appId],
        environment: anyNamed('environment'),
        workingDirectory: anyNamed('workingDirectory'),
      )).thenThrow(const ProcessException('xcrun', <String>[]));
=======
      fakeProcessManager.addCommand(const FakeCommand(
        command: <String>[
          'xcrun',
          'simctl',
          'launch',
          deviceId,
          appId,
        ],
        exception: ProcessException('xcrun', <String>[]),
      ));

>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
      expect(
        () async => simControl.launch(deviceId, appId),
        throwsToolExit(message: r'Unable to launch'),
      );
    });
  });

  group('startApp', () {
<<<<<<< HEAD
    SimControl simControl;
    MockXcode mockXcode;
    MockPrototcolDiscovery mockPrototcolDiscovery;

    setUp(() {
      simControl = MockSimControl();
      mockXcode = MockXcode();
      when(mockXcode.xcrunCommand()).thenReturn(<String>['xcrun']);
      mockPrototcolDiscovery = MockPrototcolDiscovery();
=======
    FakePlistParser testPlistParser;
    FakeSimControl simControl;
    Xcode xcode;

    setUp(() {
      simControl = FakeSimControl();
      xcode = Xcode.test(processManager: FakeProcessManager.any());
      testPlistParser = FakePlistParser();
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });

    testUsingContext("startApp uses compiled app's Info.plist to find CFBundleIdentifier", () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'iOS 11.2',
        simControl: simControl,
      );
<<<<<<< HEAD
      when(globals.plistParser.getValueFromFile(any, any)).thenReturn('correct');
      when(mockPrototcolDiscovery.uri)
          .thenAnswer((_) async => Uri.parse('http://localhost:5678'));
=======
      testPlistParser.setProperty('CFBundleIdentifier', 'correct');
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645

      final Directory mockDir = globals.fs.currentDirectory;
      final IOSApp package = PrebuiltIOSApp(projectBundleId: 'incorrect', bundleName: 'name', bundleDir: mockDir);

      const BuildInfo mockInfo = BuildInfo(BuildMode.debug, 'flavor', treeShakeIcons: false);
      final DebuggingOptions mockOptions =
          DebuggingOptions.enabled(mockInfo, hostVmServicePort: 8888);
      await device.startApp(package, prebuiltApplication: true, debuggingOptions: mockOptions);

<<<<<<< HEAD
      verify(simControl.launch(any, 'correct', <String>[
        '--enable-dart-profiling',
        '--enable-checked-mode',
        '--verify-entry-points',
        '--observatory-port=8888',
      ]));
=======
      expect(simControl.requests.single.appIdentifier, 'correct');
    }, overrides: <Type, Generator>{
      PlistParser: () => testPlistParser,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
      Xcode: () => xcode,
    });

    testUsingContext('startApp respects the enable software rendering flag', () async {
      final IOSSimulator device = IOSSimulator(
        'x',
        name: 'iPhone SE',
        simulatorCategory: 'iOS 11.2',
        simControl: simControl,
      );

      final Directory mockDir = globals.fs.currentDirectory;
      final IOSApp package = PrebuiltIOSApp(projectBundleId: 'incorrect', bundleName: 'name', bundleDir: mockDir);

      const BuildInfo mockInfo = BuildInfo(BuildMode.debug, 'flavor', treeShakeIcons: false);
      final DebuggingOptions mockOptions = DebuggingOptions.enabled(mockInfo, enableSoftwareRendering: true);
      await device.startApp(package, prebuiltApplication: true, debuggingOptions: mockOptions);

      expect(simControl.requests.single.launchArgs, contains('--enable-software-rendering'));
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    }, overrides: <Type, Generator>{
      PlistParser: () => testPlistParser,
      FileSystem: () => fileSystem,
      ProcessManager: () => FakeProcessManager.any(),
<<<<<<< HEAD
      Xcode: () => mockXcode,
=======
      Xcode: () => xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });
  });

  group('IOSDevice.isSupportedForProject', () {
    FakeSimControl simControl;
    Xcode xcode;

    setUp(() {
      simControl = FakeSimControl();
      xcode = Xcode.test(processManager: FakeProcessManager.any());
    });

    testUsingContext('is true on module project', () async {
      globals.fs.file('pubspec.yaml')
        ..createSync()
        ..writeAsStringSync(r'''
name: example

flutter:
  module: {}
''');
      globals.fs.file('.packages').createSync();
      final FlutterProject flutterProject = FlutterProject.fromDirectoryTest(globals.fs.currentDirectory);

      final IOSSimulator simulator = IOSSimulator(
        'test',
        simControl: simControl,
      );
      expect(simulator.isSupportedForProject(flutterProject), true);
    }, overrides: <Type, Generator>{
      FileSystem: () => MemoryFileSystem.test(),
      ProcessManager: () => FakeProcessManager.any(),
<<<<<<< HEAD
      Xcode: () => mockXcode,
=======
      Xcode: () => xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });


    testUsingContext('is true with editable host app', () async {
      globals.fs.file('pubspec.yaml').createSync();
      globals.fs.file('.packages').createSync();
      globals.fs.directory('ios').createSync();
      final FlutterProject flutterProject = FlutterProject.fromDirectoryTest(globals.fs.currentDirectory);

      final IOSSimulator simulator = IOSSimulator(
        'test',
        simControl: simControl,
      );
      expect(simulator.isSupportedForProject(flutterProject), true);
    }, overrides: <Type, Generator>{
      FileSystem: () => MemoryFileSystem.test(),
      ProcessManager: () => FakeProcessManager.any(),
<<<<<<< HEAD
      Xcode: () => mockXcode,
=======
      Xcode: () => xcode,
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });

    testUsingContext('is false with no host app and no module', () async {
      globals.fs.file('pubspec.yaml').createSync();
      globals.fs.file('.packages').createSync();
      final FlutterProject flutterProject = FlutterProject.fromDirectoryTest(globals.fs.currentDirectory);

      final IOSSimulator simulator = IOSSimulator(
        'test',
        simControl: simControl,
      );
      expect(simulator.isSupportedForProject(flutterProject), false);
    }, overrides: <Type, Generator>{
      FileSystem: () => MemoryFileSystem.test(),
      ProcessManager: () => FakeProcessManager.any(),
<<<<<<< HEAD
      Xcode: () => mockXcode,
=======
      Xcode: () => xcode,
    });

    testUsingContext('createDevFSWriter returns a LocalDevFSWriter', () {
      final IOSSimulator simulator = IOSSimulator(
        'test',
        simControl: simControl,
      );

      expect(simulator.createDevFSWriter(null, ''), isA<LocalDevFSWriter>());
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
    });
  });
}

<<<<<<< HEAD
class MockPrototcolDiscovery extends Mock implements ProtocolDiscovery {}
class MockBuildSystem extends Mock implements BuildSystem {}
=======
class FakeIosProject extends Fake implements IosProject {
  @override
  Future<String> productBundleIdentifier(BuildInfo buildInfo) async => 'com.example.test';

  @override
  Future<String> hostAppBundleName(BuildInfo buildInfo) async => 'My Super Awesome App.app';
}

class FakeSimControl extends Fake implements SimControl {
  final List<LaunchRequest> requests = <LaunchRequest>[];

  @override
  Future<RunResult> launch(String deviceId, String appIdentifier, [ List<String> launchArgs ]) async {
    requests.add(LaunchRequest(deviceId, appIdentifier, launchArgs));
    return RunResult(ProcessResult(0, 0, '', ''), <String>['test']);
  }

  @override
  Future<RunResult> install(String deviceId, String appPath) async {
    return RunResult(ProcessResult(0, 0, '', ''), <String>['test']);
  }
}

class LaunchRequest {
  const LaunchRequest(this.deviceId, this.appIdentifier, this.launchArgs);

  final String deviceId;
  final String appIdentifier;
  final List<String> launchArgs;
}
>>>>>>> 18116933e77adc82f80866c928266a5b4f1ed645
