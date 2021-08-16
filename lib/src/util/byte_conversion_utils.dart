// ADDITIONAL CODES

import 'dart:typed_data';
import 'list_shape_extension.dart';
import 'package:tflite_flutter/src/bindings/types.dart';
import 'dart:convert' show utf8;
import 'dart:ffi';

class ByteConversionUtils {
  static Uint8List convertObjectToBytes(Object o, TfLiteType tfliteType) {
    if (o is Uint8List) {
      return o;
    }
    if (o is ByteBuffer) {
      return o.asUint8List();
    }
    List<int> bytes = <int>[];

    // special case for string
    if (tfliteType == TfLiteType.string){
      bytes = _convertElementToBytes(o, tfliteType); // let _convertElementToBytes handle possible multiple strings
      return Uint8List.fromList(bytes);
    }
    
    if (o is List) {
      for (var e in o) {
        bytes.addAll(convertObjectToBytes(e, tfliteType));
      }
    } else {
      return _convertElementToBytes(o, tfliteType);
    }
    return Uint8List.fromList(bytes);
  }

  static Uint8List _convertElementToBytes(Object o, TfLiteType tfliteType) {
    if (tfliteType == TfLiteType.float32) {
      if (o is double) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o, Endian.little);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.float32}');
      }
    } else if (tfliteType == TfLiteType.int32) {
      if (o is int) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt32(0, o, Endian.little);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.int32}');
      }
    } else if (tfliteType == TfLiteType.int64) {
      if (o is int) {
        var buffer = Uint8List(8).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt64(0, o, Endian.big);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.int32}');
      }
    } else if (tfliteType == TfLiteType.int16) {
      if (o is int) {
        var buffer = Uint8List(2).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt16(0, o, Endian.little);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.int32}');
      }
    } else if (tfliteType == TfLiteType.float16) {
      if (o is double) {
        var buffer = Uint8List(4).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setFloat32(0, o, Endian.little);
        return buffer.asUint8List().sublist(0, 2);
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.float32}');
      }
    } else if (tfliteType == TfLiteType.int8) {
      if (o is int) {
        var buffer = Uint8List(1).buffer;
        var bdata = ByteData.view(buffer);
        bdata.setInt8(0, o);
        return buffer.asUint8List();
      } else {
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.float32}');
      }
    }
    //////// ADDITIONAL CODES
    else if (tfliteType == TfLiteType.string){
      if (o is String || o is List ) {
        List<int> fullStringList = encodeTFStrings(o);
        return Uint8List.fromList(fullStringList);
      } else{
        throw ArgumentError(
            'The input element is ${o.runtimeType} while tensor data tfliteType is ${TfLiteType.string}');
      }
    }
    /////// END ADDITIONAL CODES
    else {
      throw ArgumentError(
          'The input data tfliteType ${o.runtimeType} is unsupported');
    }
  }

  static Object convertBytesToObject(
      Uint8List bytes, TfLiteType tfliteType, List<int> shape) {
    // stores flattened data
    List<dynamic> list = [];
    if (tfliteType == TfLiteType.int32) {
      for (var i = 0; i < bytes.length; i += 4) {
        list.add(ByteData.view(bytes.buffer).getInt32(i, Endian.little));
      }
      return list.reshape<int>(shape);
    } else if (tfliteType == TfLiteType.float32) {
      for (var i = 0; i < bytes.length; i += 4) {
        list.add(ByteData.view(bytes.buffer).getFloat32(i, Endian.little));
      }
      return list.reshape<double>(shape);
    } else if (tfliteType == TfLiteType.int16) {
      for (var i = 0; i < bytes.length; i += 2) {
        list.add(ByteData.view(bytes.buffer).getInt16(i, Endian.little));
      }
      return list.reshape<int>(shape);
    } else if (tfliteType == TfLiteType.float16) {
      Uint8List list32 = Uint8List(bytes.length * 2);
      for (var i = 0; i < bytes.length; i += 2) {
        list32[i] = bytes[i];
        list32[i + 1] = bytes[i + 1];
      }
      for (var i = 0; i < list32.length; i += 4) {
        list.add(ByteData.view(list32.buffer).getFloat32(i, Endian.little));
      }
      return list.reshape<double>(shape);
    } else if (tfliteType == TfLiteType.int8) {
      for (var i = 0; i < bytes.length; i += 1) {
        list.add(ByteData.view(bytes.buffer).getInt8(i));
      }
      return list.reshape<int>(shape);
    } else if (tfliteType == TfLiteType.int64) {
      for (var i = 0; i < bytes.length; i += 8) {
        list.add(ByteData.view(bytes.buffer).getInt64(i, Endian.little));
      }
      return list.reshape<int>(shape);
    }
    else if (tfliteType == TfLiteType.string){
      list.add(decodeTFStrings(bytes));
      return list.reshape<int>(shape);
    }
    throw UnsupportedError("$tfliteType is not Supported.");
  }

  static List<int> encodeTFStrings(Object o){
    // Following String encoding as listed on
    // https://github.com/tensorflow/tensorflow/blob/master/tensorflow/lite/string_util.h
    //
    // Util methods to read and write String tensors.
    // String tensors are considered to be char tensor with protocol.
    //   [0, 3] 4 bytes: N, num of strings in the tensor in little endian.
    //   [(i+1)*4, (i+1)*4+3] 4 bytes: offset of i-th string in little endian,
    //                                 for i from 0 to N-1.
    //   [(N+1)*4, (N+1)*4+3] 4 bytes: length of the whole char buffer.
    //   [offset(i), offset(i+1) - 1] : content of i-th string.
    // Example of a string tensor:
    // [
    //   2, 0, 0, 0,     # 2 strings.
    //   16, 0, 0, 0,    # 0-th string starts from index 16.
    //   18, 0, 0, 0,    # 1-st string starts from index 18.
    //   18, 0, 0, 0,    # total length of array.
    //   'A', 'B',       # 0-th string [16..17]: "AB"
    // ]                 # 1-th string, empty

    List<int> fully_encoded_string = [];
    List<dynamic> to_encode_list = []; // currently copying strings... hmm
    int num_string;
    if (o is List){
      num_string = o.length; // elements of strings in list
      to_encode_list.addAll(o);
    }else{
      num_string = 1; // let this be only string input
      to_encode_list.add(o);
    }

    List<List<int>> encodedStringList = [];
    for (int i = 0; i < to_encode_list.length; i++){
      if (to_encode_list.elementAt(i) is String) {
        List<int> encodedString = utf8.encode(to_encode_list.elementAt(i));
        encodedStringList.add(encodedString);
      }
      else{
        encodedStringList.add([]); // add blank
      }
    }
    // encode tensor string
    fully_encoded_string.addAll(encode32BitInt(num_string,Endian.little));  // [0, 3] 4 bytes: N, num of strings in the tensor in little endian.
    // calculate offset and encode
    int InitialStringOffset = (1 + num_string + 1)*sizeOf<Int32>(); // N + offsets of strings + totalsection
    List<int> offsets = [];
    int accumOffset = InitialStringOffset;
    for (List<int>encStr in encodedStringList){
      offsets.add(accumOffset);
      accumOffset = accumOffset + encStr.length;
    }

    // for example
    //   16, 0, 0, 0,    # 0-th string starts from index 16.
    //   18, 0, 0, 0,    # 1-st string starts from index 18.
    for (int offset in offsets){
      fully_encoded_string.addAll(encode32BitInt(offset,Endian.little));
    }

    // for example
    //   18, 0, 0, 0,    # total length of array.
    fully_encoded_string.addAll(encode32BitInt(accumOffset,Endian.little));

    // for example
    //   'A', 'B',       # 0-th string [16..17]: "AB"
    // ]                 # 1-th string, empty
    for (List<int>encStr in encodedStringList){
      fully_encoded_string.addAll(encStr);
    }
    return fully_encoded_string;
  }

  static List<int> encode32BitInt(int i, Endian e){
    var buffer32bit = Uint8List(sizeOf<Int32>()).buffer;
    var bdata32bit = ByteData.view(buffer32bit);
    bdata32bit.setInt32(0, i, e);
    return buffer32bit.asUint8List();
  }

  static List<String> decodeTFStrings(Uint8List bytes){
    List<String> decodedStrings = [];
    // get the first 32bit int representing num of strings
    int num_strings = ByteData.view(bytes.sublist(0,sizeOf<Int32>()).buffer).getInt32(0, Endian.little);
    // parse subsequent string position and sizes
    for(int s = 0; s < num_strings; s++){
      // get curr str index
      int startIdx = ByteData.view(bytes.sublist((1+s)*sizeOf<Int32>(),(2+s)*sizeOf<Int32>()).buffer).getInt32(0, Endian.little);
      // get next str index, or in last case the ending byte position
      int endIdx = ByteData.view(bytes.sublist((2+s)*sizeOf<Int32>(),(3+s)*sizeOf<Int32>()).buffer).getInt32(0, Endian.little);
      decodedStrings.add(utf8.decode(bytes.sublist(startIdx,endIdx)));
    }
    return decodedStrings;
  }
}

