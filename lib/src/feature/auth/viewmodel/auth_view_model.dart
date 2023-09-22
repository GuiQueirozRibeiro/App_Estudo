import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../common/exceptions/auth_exception.dart';
import '../repository/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static UserModel? _currentUser;

  static final _userStream = Stream<UserModel?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();
    await for (final user in authChanges) {
      _currentUser = user == null ? null : await _toUser(user);
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
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadCurrentUser();
    } on FirebaseAuthException catch (error) {
      final authException = AuthException.fromFirebaseAuthException(error);
      return authException.toString();
    } catch (error) {
      return error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    if (_auth.currentUser != null) {
      _currentUser = await _toUser(_auth.currentUser!);
      notifyListeners();
    }
  }

  static Future<UserModel> _toUser(User user) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    return UserModel(
        id: user.uid,
        name: userData?['name'],
        classroom: userData?['classroom'],
        imageUrl: userData?['imageUrl'],
        isProfessor: userData?['isProfessor']);
  }

  Future<String?> changeUserImage(File newImage) async {
    _isLoading = true;

    try {
      String imageName = _currentUser?.id ?? '';
      String? imageUrl =
          await uploadImage(newImage, imageName, _currentUser!.imageUrl);

      if (imageUrl != null) {
        await _saveUser(UserModel(
          id: _currentUser?.id ?? '',
          name: _currentUser!.name,
          classroom: _currentUser!.classroom,
          imageUrl: imageUrl,
          isProfessor: _currentUser!.isProfessor,
        ));
        await _loadCurrentUser();
      }
    } catch (error) {
      return error.toString();
    } finally {
      _isLoading = false;
    }

    return null;
  }

  Future<String?> uploadImage(
      File? image, String imageName, String oldImage) async {
    if (image == null) return null;

    final storage = FirebaseStorage.instance;
    try {
      await _deleteOldImage(oldImage);
      final imageRef = storage.ref().child('user_images/$imageName.jpeg');

      await imageRef.putFile(image);
      return await imageRef.getDownloadURL();
    } catch (error) {
      return 'Erro ao fazer upload da imagem: $error';
    }
  }

  Future<void> _deleteOldImage(String imageUrl) async {
    final storage = FirebaseStorage.instance;
    final imageRef = storage.refFromURL(imageUrl);
    await imageRef.delete();
  }

  Future<void> _saveUser(UserModel user) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return docRef.set({
      'name': user.name,
      'classroom': user.classroom,
      'imageUrl': user.imageUrl,
      'isProfessor': user.isProfessor,
    });
  }
}
