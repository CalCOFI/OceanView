import 'package:flutter/widgets.dart';
import '../models/picture.dart';

/*
  Pictures are used to save temporary photos locally which could
  be accessed when the app is accidentally closed
 */
class Pictures with ChangeNotifier{
  List<Picture> _items = [];

  List<Picture> get items {
    return [..._items];
  }
  storeImage(
      Picture pickedImage
      )  {

    final newImage = Picture(
      picName: pickedImage.picName,
    );
    _items.add(newImage);
    notifyListeners();
  }
}