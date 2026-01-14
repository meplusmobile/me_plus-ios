import 'package:flutter/foundation.dart';
import 'package:me_plus/data/repositories/parent_repository.dart';
import 'package:me_plus/data/models/child_model.dart';

class ChildrenProvider with ChangeNotifier {
  final ParentRepository _repository = ParentRepository();

  List<Child> _children = [];
  bool _isLoading = false;
  String? _error;

  List<Child> get children => _children;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasChildren => _children.isNotEmpty;

  Future<void> loadChildren() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _children = await _repository.getChildren();
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _children = [];
      notifyListeners();
    }
  }

  void clearChildren() {
    _children = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Child? getChildById(String id) {
    try {
      return _children.firstWhere((child) => child.id == id);
    } catch (e) {
      return null;
    }
  }
}
