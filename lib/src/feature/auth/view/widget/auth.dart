import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../common/exceptions/auth_exception.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  Future<String?> signup(
      String name, String email, String password, File image) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final imageUrl = await uploadImageToFirebaseStorage(image);

      await updateUserProfile(name, imageUrl);

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

  Future<String> uploadImageToFirebaseStorage(File image) async {
    final storage = FirebaseStorage.instance;
    final ref =
        storage.ref().child('user_images/${_auth.currentUser!.uid}/image.jpg');
    await ref.putFile(image);
    final imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> updateUserProfile(String name, String photoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'photoUrl': photoUrl,
        }, SetOptions(merge: true));
      }
    } catch (error) {
      return;
    }
  }
}
