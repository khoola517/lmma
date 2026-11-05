import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class StorageService {
  StorageService._();

  static final ImagePicker _picker = ImagePicker();
  static const String servicesBucket = 'service-images';

  /// اختيار عدة صور من جهاز المستخدم
  static Future<List<XFile>> pickImagesFromDevice() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return images;
    } catch (e) {
      debugPrint('Error picking images from device: $e');
      return [];
    }
  }

  /// اختيار صورة واحدة من جهاز المستخدم
  static Future<XFile?> pickSingleImageFromDevice({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking single image from device: $e');
      return null;
    }
  }

  /// رفع صورة إلى مساحة تخزين Supabase والحصول على الرابط العام
  static Future<String?> uploadServiceImage({
    required Uint8List bytes,
    required String originalName,
    String? customPath,
  }) async {
    try {
      final ext = originalName.contains('.')
          ? originalName.split('.').last.toLowerCase()
          : 'jpg';

      String contentType = 'image/jpeg';
      if (ext == 'png') {
        contentType = 'image/png';
      } else if (ext == 'webp') {
        contentType = 'image/webp';
      } else if (ext == 'gif') {
        contentType = 'image/gif';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = originalName
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\.]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      final path = customPath ?? 'services/${timestamp}_$safeName';

      await SupabaseConfig.client.storage.from(servicesBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl =
          SupabaseConfig.client.storage.from(servicesBucket).getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading service image to Supabase: $e');
      return null;
    }
  }

  /// حذف صورة من مساحة التخزين عبر رابطها
  static Future<bool> deleteServiceImageByUrl(String imageUrl) async {
    try {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null) return false;

      // Extract storage path after bucket name
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(servicesBucket);
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        final relativePath = segments.sublist(bucketIndex + 1).join('/');
        await SupabaseConfig.client.storage
            .from(servicesBucket)
            .remove([relativePath]);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image from Supabase storage: $e');
      return false;
    }
  }
}
