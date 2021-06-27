// Flex Additional codes

import 'dart:ffi';

import 'package:quiver/check.dart';
import '../bindings/flex_delegate.dart';
import '../bindings/types.dart';
import '../delegate.dart';

//import 'dart:developer' as developer;

/// Flex Delegate for Android
class Flex_Delegate implements Delegate {
  Pointer<TfLiteDelegate> _delegate;
  bool _deleted = false;

  @override
  Pointer<TfLiteDelegate> get base => _delegate;

  Flex_Delegate._(this._delegate);

  factory Flex_Delegate() {
    return Flex_Delegate._(tfLite_flex_createDelegate());
  }

  @override
  void delete() {
    checkState(!_deleted,
        message: 'TfLiteFlex_delegate already deleted.');

    //developer.log('tfLite_flex_deleteDelegate');
    tfLite_flex_deleteDelegate(_delegate);
    _deleted = true;
  }
}
