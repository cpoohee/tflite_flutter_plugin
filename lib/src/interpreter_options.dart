/// ADDITIONAL CODES here
import 'dart:ffi';
import 'dart:io';

import 'package:quiver/check.dart';
import '../tflite_flutter.dart';
import 'bindings/interpreter_options.dart';

/// ADDITIONAL IMPORTS
import 'bindings/flex_delegate.dart';
import 'delegates/flex_delegate.dart';
import 'dart:developer' as developer;
/// END ADDITIONAL IMPORTS

import 'bindings/types.dart';
import 'delegate.dart';

/// TensorFlowLite interpreter options.
class InterpreterOptions {
  final Pointer<TfLiteInterpreterOptions> _options;
  bool _deleted = false;

  Pointer<TfLiteInterpreterOptions> get base => _options;

  InterpreterOptions._(this._options);

  /// Creates a new options instance.
  factory InterpreterOptions() =>
      InterpreterOptions._(tfLiteInterpreterOptionsCreate());

  /// Destroys the options instance.
  void delete() {
    developer.log('DELETE DELEGATE');
    checkState(!_deleted, message: 'InterpreterOptions already deleted.');
    tfLiteInterpreterOptionsDelete(_options);
    _deleted = true;
  }

  /// Sets the number of CPU threads to use.
  set threads(int threads) =>
      tfLiteInterpreterOptionsSetNumThreads(_options, threads);

  /// TensorFlow version >= v2.2
  /// Set true to use NnApi Delegate for Android
  set useNnApiForAndroid(bool useNnApi) {
    if (Platform.isAndroid) {
      tfLiteInterpreterOptionsSetUseNNAPI(_options, 1);
    }
  }


  /// ADDITIONAL CODES
  set useFlexDelegateAndroid(bool useFlexDelegate){
    if (Platform.isAndroid) {
      tfLite_flex_initTensorflow();
      developer.log('INIT FLEX');
      addDelegate(Flex_Delegate());
    }
  }
  /// END ADDITIONAL CODES

  /// Set true to use Metal Delegate for iOS
  set useMetalDelegateForIOS(bool useMetal) {
    if (Platform.isIOS) {
      addDelegate(GpuDelegate());
    }
  }

  /// Adds delegate to Interpreter Options
  void addDelegate(Delegate delegate) {
    tfLiteInterpreterOptionsAddDelegate(_options, delegate.base);
  }

// Unimplemented:
// TfLiteInterpreterOptionsSetErrorReporter
// TODO: TfLiteInterpreterOptionsSetErrorReporter
// TODO: setAllowFp16PrecisionForFp32(bool allow)

// setAllowBufferHandleOutput(bool allow)
}
