import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../common/exceptions/auth_exception.dart';
import '../../home/repository/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static UserModel? _currentUser;
  static final _userStream = Stream<UserModel?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();
    await for (final user in authChanges) {
      _currentUser = user == null ? null : _toUser(user);
      controller.add(_currentUser);
    }
  });

  bool get isLoading => _isLoading;

  UserModel? get currentUser {
    return _currentUser;
  }

  Stream<UserModel?> get userChanges {
    return _userStream;
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      final authException = AuthException.fromFirebaseAuthException(error);
      return authException.toString();
    } catch (error) {
      return error.toString();
    } finally {
      _isLoading = false;
    }

    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  static UserModel _toUser(User user, [String? name, String? imageUrl]) {
    return UserModel(
      id: user.uid,
      name: name ?? user.displayName ?? user.email!.split('@')[0],
      email: user.email!,
      imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
    );
  }

/*

  Future<String?> _uploadImage(File? image, String imageName) async {
    if (image == null) return null;

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(imageName);
    await imageRef.putFile(image).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }

  Future<void> _saveUser(UserModel user) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return docRef.set({
      'name': user.name,
      'email': user.email,
      'imageUrl': user.imageUrl,
    });
  }
*/
}
