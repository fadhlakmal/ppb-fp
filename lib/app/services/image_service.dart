import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  Future<File?> pickGalleryImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return null;
    return File(image.path);
  }
}
