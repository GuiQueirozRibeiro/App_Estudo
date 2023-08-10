import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../common/exceptions/auth_exception.dart';
import '../../home/repository/chat_user.dart';
import '../../home/usecase/chat_use_case.dart';

class AuthUseCase with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ChatUseCase? _chatUseCase;
  ChatUser? _currentUser;
  User? _user;

  User? get user => _user;
  ChatUser? get currentUser => _currentUser;

  Future<String?> signup(
      String name, String email, String password, File image) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final imageName = '${userCredential.user!.uid}.jpg';
        final imageUrl = await _uploadUserImage(image, imageName);

        await userCredential.user?.updateDisplayName(name);
        await userCredential.user?.updatePhotoURL(imageUrl);

        await login(email, password);

        _currentUser =
            ChatUseCase.toChatUser(userCredential.user!, name, imageUrl);
        await _chatUseCase!.saveChatUser(_currentUser!);
      }

      _user = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      final authException = AuthException.fromFirebaseAuthException(error);
      return authException.toString();
    } catch (error) {
      return error.toString();
    }
    return null;
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = _auth.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      final authException = AuthException.fromFirebaseAuthException(error);
      return authException.toString();
    } catch (error) {
      return error.toString();
    }
    return null;
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );
    } on FirebaseAuthException catch (error) {
      final authException = AuthException.fromFirebaseAuthException(error);
      return authException.toString();
    } catch (error) {
      return error.toString();
    }
    return null;
  }

  Future<void> tryAutoLogin() async {
    final user = _auth.currentUser;
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<String?> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
      _user = null;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      final authException = AuthException.fromFirebaseAuthException(error);
      return authException.toString();
    } catch (error) {
      return error.toString();
    }
    return null;
  }

  Future<String?> _uploadUserImage(File? image, String imageName) async {
    if (image == null) return null;

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(imageName);
    await imageRef.putFile(image).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }
}
