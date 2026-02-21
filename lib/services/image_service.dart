import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickImageBytes() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  Future<String> uploadImage(Uint8List bytes, String reportId) async {
    final ref = _storage.ref().child('reports/$reportId.jpg');

    await ref.putData(bytes);

    return await ref.getDownloadURL();
  }
}