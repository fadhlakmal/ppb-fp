import 'dart:io';

import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/delivery/delivery.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
import 'package:myapp/app/models/cloudinary_response_model.dart';

class CloudinaryService {
  var cloudinary = Cloudinary.fromStringUrl(
    'cloudinary://699262278636257:rKOzMaKfR-J5FG9firNhfBDJJtM@dufpjkte2',
  );

  Future<CloudinaryUploadResponse?> uploadProfileImage(
    File imageFile,
    String uid,
  ) async {
    try {
      final response = await cloudinary.uploader().upload(
        imageFile,
        params: UploadParams(
          publicId: 'profile_images/user_$uid',
          folder: 'profile_images',
          overwrite: true,
          transformation:
              Transformation()
                ..resize(
                  Resize.limitFit()
                    ..width(800)
                    ..height(800),
                )
                ..delivery(Delivery.quality(85))
                ..delivery(Delivery.format('auto')),
        ),
      );

      if (response!.responseCode > 200) {
        return CloudinaryUploadResponse(
          publicId: response.data?.publicId ?? '',
          secureUrl: response.data?.secureUrl ?? '',
          url: response.data?.url ?? '',
          width: response.data?.width ?? 0,
          height: response.data?.height ?? 0,
          format: response.data?.format ?? '',
          bytes: response.data?.bytes ?? 0,
        );
      }
      return null;
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }
}
