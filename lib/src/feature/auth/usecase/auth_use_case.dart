import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../common/exceptions/auth_exception.dart';
import '../../home/repository/chat_user.dart';

class AuthUseCase with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static ChatUser? _currentUser;
  static final _userStream = Stream<ChatUser?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();
    await for (final user in authChanges) {
      _currentUser = user == null ? null : _toChatUser(user);
      controller.add(_currentUser);
    }
  });

  ChatUser? get currentUser {
    return _currentUser;
  }

  Stream<ChatUser?> get userChanges {
    return _userStream;
  }

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

        _currentUser = _toChatUser(userCredential.user!, name, imageUrl);
        await _saveChatUser(_currentUser!);
      }

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

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<String?> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
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

  Future<void> _saveChatUser(ChatUser user) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return docRef.set({
      'name': user.name,
      'email': user.email,
      'imageUrl': user.imageUrl,
    });
  }

  static ChatUser _toChatUser(User user, [String? name, String? imageUrl]) {
    return ChatUser(
      id: user.uid,
      name: name ?? user.displayName ?? user.email!.split('@')[0],
      email: user.email!,
      imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
    );
  }
}