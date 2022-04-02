import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_crud/data/dummy_users.dart';
import 'package:flutter_crud/models/user.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  static const _baseURL = "https://convidados-f2274-default-rtdb.firebaseio.com/";
  final Map<String, User> _items = {...DUMMY_USERS};

  List<User> get all {

    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  Future<void> put(User user) async {
    if (user == null) {
      return;
    }

    if (user.id != null &&
        user.id.trim().isNotEmpty &&
        _items.containsKey(user.id)) {
      await http.patch(
        Uri.parse("$_baseURL/convidados/${user.id}.json"),
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarURL': user.avatarUrl,
        }),
      );
      _items.update(
        user.id,
        (_) => User(
          id: user.id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    } else {
    final response = await http.post(
      Uri.parse("$_baseURL/convidados.json"),
      body: json.encode({
        'name': user.name,
        'email': user.email,
        'avatarURL': user.avatarUrl,
    }),
    );
    final id = json.decode(response.body)['name'];

      _items.putIfAbsent(
        id,
        () => User(
          id: id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    }
    notifyListeners();
  }

  void remove(User user)  async {
    if(user != null && user.id != null) {
      final response = await http.delete(
        Uri.parse("$_baseURL/convidados/${user.id}.json"),
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarURL': user.avatarUrl,
        }),
      );
      _items.remove(user.id);
      notifyListeners();
    }
  }
}
