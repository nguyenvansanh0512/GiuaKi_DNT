import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageTools {
  static Future<String> prepare(XFile file) async {
    if (await file.length() > 8 * 1024 * 1024) {
      throw Exception('Ảnh gốc tối đa 8 MB. Hãy chọn ảnh nhỏ hơn.');
    }
    return compute(compressImage, await file.readAsBytes());
  }
}

String compressImage(Uint8List bytes) {
  final decoder = img.findDecoderForData(bytes);
  if (decoder is! img.JpegDecoder && decoder is! img.PngDecoder) {
    throw Exception('Chỉ hỗ trợ ảnh JPG hoặc PNG.');
  }
  final info = decoder!.startDecode(bytes);
  if (info == null || info.width * info.height > 16000000) {
    throw Exception('Ảnh không hợp lệ hoặc lớn hơn 16 megapixel.');
  }
  var picture = decoder.decodeFrame(0);
  if (picture == null) throw Exception('Không đọc được ảnh.');
  picture = img.bakeOrientation(picture);
  if (picture.width > 800 || picture.height > 800) {
    picture = img.copyResize(
      picture,
      width: picture.width >= picture.height ? 800 : null,
      height: picture.height > picture.width ? 800 : null,
    );
  }
  final encoded = img.encodeJpg(picture, quality: 78);
  if (encoded.length > 512 * 1024) {
    throw Exception('Ảnh sau nén vẫn vượt 512 KB. Hãy chọn ảnh nhỏ hơn.');
  }
  return 'data:image/jpeg;base64,${base64Encode(encoded)}';
}
