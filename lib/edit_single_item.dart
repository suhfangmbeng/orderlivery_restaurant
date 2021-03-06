import 'dart:convert';
import 'dart:io';

import 'package:Restaurant/add_list.dart';
import 'package:Restaurant/add_list_without_prices.dart';
import 'package:Restaurant/edit_list_page.dart';
//import 'package:Restaurant/categories.dart';
import 'package:Restaurant/menu_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'dart:math' as math;

import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSingleItemPage extends StatefulWidget {
  final String id;
  EditSingleItemPage({this.id});
  _EditSingleItemPageState createState() => _EditSingleItemPageState();
}

Category chooseCategory = Category(name: 'Choose Category type');

class _EditSingleItemPageState extends State<EditSingleItemPage> {
  Category dropdownValue = chooseCategory;
  List<Category> items = [chooseCategory, Category(name: 'Two')];
  PricingType _character = PricingType.none;
  FocusNode descriptionNode = FocusNode();
  FocusNode flatPriceFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  FocusNode cookingTimeFocusNode = FocusNode();
  FocusNode priceAndQuantityFocusNode = FocusNode();
  FocusNode startingFromFocusNode = FocusNode();
  FocusNode minutesFocusNode = FocusNode();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController flatPriceController = TextEditingController();
  TextEditingController priceAndQuantityController = TextEditingController();
  TextEditingController startingFromController = TextEditingController();
  TextEditingController cookingTimeController = TextEditingController();
  TextEditingController minutesController = TextEditingController();
  List<ItemList> lists = [];
  StepperType stepperType = StepperType.horizontal;
  int currentStep = 0;
  bool complete = false;
  StepState stepOneState = StepState.editing;
  bool stepOneActive = true;
  StepState stepTwoState = StepState.disabled;
  bool stepTwoActive = true;
  StepState stepThreeState = StepState.disabled;
  bool stepThreeActive = true;
  StepState stepFourState = StepState.disabled;
  bool stepFourActive = true;
  StepState stepFiveState = StepState.disabled;
  bool stepFiveActive = true;
  StepState stepSixState = StepState.disabled;
  bool stepSixActive = true;
  ImagePicker imagePicker = ImagePicker();
  bool isVegan = false;
  bool isVegetarian = false;
  bool isGlutenFree = false;
  bool isHalal = false;
  bool isKosher = false;
  bool isSugarFree = false;
  bool isEgg = false;
  bool isFish = false;
  bool isShellFish = false;
  bool isMilk = false;
  bool isPeanut = false;
  bool isSoy = false;
  bool isTreenuts = false;
  bool isWheatOrGluten = false;
  String imageUrl = 'assets/images/menu.png';
  File imageFile;

  Future<void> updateFlatPriceMenu() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    String price = flatPriceController.text.trim();
    String cookingTime = minutesController.text.trim();
    String category_id = dropdownValue.id;
    List _lists = lists
        .map((itemList) => {
              'name': itemList.name,
              'description': itemList.description,
              'is_required': itemList.is_required,
              'minimum_length': itemList.minimum_length,
              'maximum_length': itemList.maximum_length,
              'items': itemList.items.map((item) {
                return {'name': item.name, 'price': item.price};
              }).toList()
            })
        .toList();
    print(_lists);
    print('hello');
    List<String> labels = [];
    if (isVegan) {
      labels.add('Vegan');
    }
    if (isVegetarian) {
      labels.add('Vegetarian');
    }
    if (isGlutenFree) {
      labels.add('Gluten Free');
    }
    if (isHalal) {
      labels.add('Halal');
    }
    if (isKosher) {
      labels.add('Kosher');
    }
    if (isSugarFree) {
      labels.add('Sugar Free');
    }
    List<String> allergens = [];
    if (isEgg) {
      allergens.add('Egg');
    }
    if (isFish) {
      allergens.add('Fish');
    }
    if (isShellFish) {
      allergens.add('ShellFish');
    }
    if (isMilk) {
      allergens.add('Milk');
    }
    if (isPeanut) {
      allergens.add('Peanut');
    }
    if (isSoy) {
      allergens.add('Soy');
    }
    if (isTreenuts) {
      allergens.add('Treenuts');
    }
    if (isWheatOrGluten) {
      allergens.add('Wheat');
      allergens.add('Gluten');
    }

    var _json = {
      'name': name,
      'description': description,
      'flat_price': double.parse(price),
      'category_id': category_id,
      'lists': _lists,
      'health_labels': labels,
      'allergens': allergens,
      "item_id": widget.id
    };
    if (imageFile != null) {
      _json['base64'] = base64Encode(imageFile.readAsBytesSync().cast<int>());
    }
    if (cookingTime.isNotEmpty) {
      _json['cooking_time'] = cookingTime;
    }
    print(_json);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        '${Constants.apiBaseUrl}/restaurants/update-menu',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode(_json));
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Item was updated!');
    }
  }

  bool validatePricesAndQuantities() {
    String price_and_quantity_text = priceAndQuantityController.text.trim();
    List<String> pq = price_and_quantity_text.split(',');
    if (pq.isEmpty) return false;
    try {
      pq.map((e) {
        e = e.trim();
        double quantity = double.parse(e.split('/')[0].split(' ')[0]);
        String measurement_label = e.split('/')[0].split(' ')[1];
        String k = e.split('/')[1];
        String price = k.substring(1, k.length);
        return {
          'quantity': quantity,
          'measurement_label': measurement_label,
          'price': price
        };
      }).toList();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updatePriceAndQuantityMenu() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    List pq = priceAndQuantityController.text.trim().split(', ');
    if (!validatePricesAndQuantities()) {
      setState(() {
        currentStep = 0;
        stepOneActive = true;
        stepOneState = StepState.editing;
        FocusScope.of(context).requestFocus(priceAndQuantityFocusNode);
      });
      return;
    }
    List prices_and_quantities = pq.map((e) {
      double quantity = double.parse(e.split('/')[0].split(' ')[0]);
      String measurement_label = e.split('/')[0].split(' ')[1];
      String k = e.split('/')[1];
      String price = k.substring(1, k.length);
      return {
        'quantity': quantity,
        'measurement_label': measurement_label,
        'price': price
      };
    }).toList();
    String cookingTime = minutesController.text.trim();
    String category_id = dropdownValue.id;
    List _lists = lists
        .map((itemList) => {
              'name': itemList.name,
              'description': itemList.description,
              'is_required': itemList.is_required,
              'minimum_length': itemList.minimum_length,
              'maximum_length': itemList.maximum_length,
              'items': itemList.items
                  .map((item) => {'name': item.name, 'price': item.price})
                  .toList()
            })
        .toList();
    List<String> labels = [];
    if (isVegan) {
      labels.add('Vegan');
    }
    if (isVegetarian) {
      labels.add('Vegetarian');
    }
    if (isGlutenFree) {
      labels.add('Gluten Free');
    }
    if (isHalal) {
      labels.add('Halal');
    }
    if (isKosher) {
      labels.add('Kosher');
    }
    if (isSugarFree) {
      labels.add('Sugar Free');
    }
    List<String> allergens = [];
    if (isEgg) {
      allergens.add('Egg');
    }
    if (isFish) {
      allergens.add('Fish');
    }
    if (isShellFish) {
      allergens.add('ShellFish');
    }
    if (isMilk) {
      allergens.add('Milk');
    }
    if (isPeanut) {
      allergens.add('Peanut');
    }
    if (isSoy) {
      allergens.add('Soy');
    }
    if (isTreenuts) {
      allergens.add('Treenuts');
    }
    if (isWheatOrGluten) {
      allergens.add('Wheat');
      allergens.add('Gluten');
    }
    var _json = {
      'name': name,
      'description': description,
      'quantities_and_prices': prices_and_quantities,
      'category_id': category_id,
      'lists': _lists,
      'health_labels': labels,
      'allergens': allergens,
      "item_id": widget.id
    };
    if (imageFile != null) {
      _json['base64'] = base64Encode(imageFile.readAsBytesSync().cast<int>());
    }
    if (cookingTime.isNotEmpty) {
      _json['cooking_time'] = cookingTime;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        '${Constants.apiBaseUrl}/restaurants/update-menu',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode(_json));
    print(response.body);
  }

  Future<void> updateStartingFromMenu() async {
    String name = nameController.text.trim();
    String description = descriptionController.text.trim();
    String price = startingFromController.text.trim();
    String cookingTime = minutesController.text.trim();
    String category_id = dropdownValue.id;
    List _lists = lists
        .map((itemList) => {
              'name': itemList.name,
              'description': itemList.description,
              'is_required': itemList.is_required,
              'minimum_length': itemList.minimum_length,
              'maximum_length': itemList.maximum_length,
              'items': itemList.items
                  .map((item) => {'name': item.name, 'price': item.price})
                  .toList()
            })
        .toList();
    List<String> labels = [];
    if (isVegan) {
      labels.add('Vegan');
    }
    if (isVegetarian) {
      labels.add('Vegetarian');
    }
    if (isGlutenFree) {
      labels.add('Gluten Free');
    }
    if (isHalal) {
      labels.add('Halal');
    }
    if (isKosher) {
      labels.add('Kosher');
    }
    if (isSugarFree) {
      labels.add('Sugar Free');
    }
    List<String> allergens = [];
    if (isEgg) {
      allergens.add('Egg');
    }
    if (isFish) {
      allergens.add('Fish');
    }
    if (isShellFish) {
      allergens.add('ShellFish');
    }
    if (isMilk) {
      allergens.add('Milk');
    }
    if (isPeanut) {
      allergens.add('Peanut');
    }
    if (isSoy) {
      allergens.add('Soy');
    }
    if (isTreenuts) {
      allergens.add('Treenuts');
    }
    if (isWheatOrGluten) {
      allergens.add('Wheat');
      allergens.add('Gluten');
    }
    var _json = {
      'name': name,
      'description': description,
      'starting_price': double.parse(price),
      'category_id': category_id,
      'lists': _lists,
      'health_labels': labels,
      'allergens': allergens,
      "item_id": widget.id
    };
    if (imageFile != null) {
      _json['base64'] = base64Encode(imageFile.readAsBytesSync().cast<int>());
    }
    if (cookingTime.isNotEmpty) {
      _json['cooking_time'] = cookingTime;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        '${Constants.apiBaseUrl}/restaurants/update-menu',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode(_json));
    print(response.body);
  }

  updateMenuItem() async {
    if (_character == PricingType.flat_price) {
      await updateFlatPriceMenu();
    }
    if (_character == PricingType.price_and_quantity) {
      await updatePriceAndQuantityMenu();
    }
    if (_character == PricingType.starting_from) {
      await updateStartingFromMenu();
    }
  }

  next() async {
    if (currentStep == 0) {
      if (nameController.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(nameFocusNode);
        return;
      }
//      if (descriptionController.text.trim().isEmpty) {
//        FocusScope.of(context).requestFocus(descriptionNode);
//        return;
//      }
      if (_character == PricingType.none) {
        return;
      }
      if (_character == PricingType.flat_price) {
        if (flatPriceController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(flatPriceFocusNode);
          return;
        }
      }
      if (_character == PricingType.price_and_quantity) {
        if (priceAndQuantityController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(priceAndQuantityFocusNode);
          return;
        }
        if (!validatePricesAndQuantities()) {
          setState(() {
            currentStep = 0;
            stepOneActive = true;
            stepOneState = StepState.editing;
            FocusScope.of(context).requestFocus(priceAndQuantityFocusNode);
          });
          return;
        }
      }
      if (_character == PricingType.starting_from) {
        if (startingFromController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(startingFromFocusNode);
          return;
        }
      }
      setState(() {
        stepOneActive = true;
        stepOneState = StepState.complete;

        stepTwoActive = true;
        stepTwoState = StepState.editing;
      });
    }
    if (currentStep == 1) {
      if (dropdownValue.name.toLowerCase().contains('type')) {
        return;
      }
      setState(() {
        stepTwoActive = true;
        stepTwoState = StepState.complete;

        stepThreeActive = true;
        stepThreeState = StepState.editing;
        FocusScope.of(context).unfocus();
      });
    }
    if (currentStep == 2) {
      setState(() {
        stepThreeActive = true;
        stepThreeState = StepState.complete;

        stepFourActive = true;
        stepFourState = StepState.editing;
      });
    }
    if (currentStep == 3) {
      setState(() {
        stepFourActive = true;
        stepFourState = StepState.complete;

        stepFiveActive = true;
        stepFiveState = StepState.editing;
      });
    }
    if (currentStep == 4) {
      setState(() {
        stepFiveActive = true;
        stepFiveState = StepState.complete;

        stepSixActive = true;
        stepSixState = StepState.editing;
      });
    }
    if (currentStep == 5) {
      setState(() {
        stepSixActive = true;
        stepSixState = StepState.complete;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
                backgroundColor: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpinKitRing(
                      color: Colors.white,
                      size: 50.0,
                      lineWidth: 2,
                    )
                  ],
                ));
          });
      await updateMenuItem();
      Navigator.pop(context);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
      return;
    }
    currentStep + 1 != 6
        ? goTo(currentStep + 1)
        : setState(() => complete = true);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  @override
  initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
          state: stepOneState,
          isActive: stepOneActive,
          title: Text('Item name, description and pricing'),
          content: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('What\'s the name of the item?'),
                SizedBox(
                  height: 5,
                ),
                Container(
                  alignment: Alignment.topCenter,
                  child: _TextFormField(
                    focusNode: nameFocusNode,
                    inputFormatters: [],
                    hintText: 'Item name',
                    onChanged: (String value) {
//                          _formKey.currentState.validate();
                    },
                    controller: nameController,
                    validator: (String value) {
                      if (value.length < 1) {
                        return 'Enter the name of your menu';
                      }
                      return null;
                    },
                    onSaved: (String value) {},
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text('How would you describe this item to customers?'),
                SizedBox(
                  height: 0,
                ),
                TextFormField(
                  onChanged: (String value) {},
                  focusNode: descriptionNode,
                  controller: descriptionController,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      hintText:
                          'How would you describe this item to your customers? (Optional)',
                      hintMaxLines: 200,
                      border: InputBorder.none,
                      disabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.3, color: Colors.orange)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.3, color: Colors.grey))),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Select a pricing type'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 40,
                      child: ListTile(
                        title: GestureDetector(
                          onTap: () {
                            setState(() {
                              _character = PricingType.flat_price;
                            });
                          },
                          child: const Text('Flat Price'),
                        ),
                        leading: Radio(
                          value: PricingType.flat_price,
                          groupValue: _character,
                          onChanged: (PricingType value) {
                            setState(() {
                              _character = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      child: ListTile(
                        title: GestureDetector(
                          onTap: () {
                            setState(() {
                              _character = PricingType.price_and_quantity;
                            });
                          },
                          child: const Text('Price and Quantity'),
                        ),
                        leading: Radio(
                          value: PricingType.price_and_quantity,
                          groupValue: _character,
                          onChanged: (PricingType value) {
                            setState(() {
                              _character = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Container(
                        height: 40,
                        child: Center(
                          child: ListTile(
                            title: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _character = PricingType.starting_from;
                                });
                              },
                              child: const Text('Starting from'),
                            ),
                            leading: Radio(
                              value: PricingType.starting_from,
                              groupValue: _character,
                              onChanged: (PricingType value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                            ),
                          ),
                        )),
                    toggledPriceWidget(_character)
                  ],
                ),
              ]))),
      Step(
        state: stepTwoState,
        isActive: stepTwoActive,
        title: const Text('Category and Cooking Time'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  value: dropdownValue,
                  icon: Icon(LineIcons.angle_down),
                  iconSize: 15,
                  elevation: 16,
                  style: TextStyle(color: Colors.black),
                  underline: Padding(
                    padding: EdgeInsets.only(top: 20, right: 20),
                    child: Container(
                      height: 1,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  onChanged: (Category newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items:
                      items.map<DropdownMenuItem<Category>>((Category value) {
                    return DropdownMenuItem<Category>(
                      value: value,
                      child: Text(
                        value.name,
                        style: TextStyle(fontSize: 19),
                      ),
                    );
                  }).toList(),
                ),
              ),
              width: MediaQuery.of(context).size.width,
            ),
            SizedBox(
              height: 20,
            ),
            Text('What\'s the average cooking time of this item?'),
            Row(
              children: [
                Text('Minutes: '),
                Expanded(
                  child: _TextFormField(
                    focusNode: minutesFocusNode,
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    hintText: 'Average cooking time',
                  ),
                )
              ],
            )
          ],
        ),
      ),
      Step(
        state: stepThreeState,
        isActive: stepThreeActive,
        title: const Text('Add Lists'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
                'You can create of options. Ex: Flavors of Wings, Sauce, Dressings, etc.'),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                final act = CupertinoActionSheet(
                    title: Text('What type of list do you want to create?'),
                    actions: <Widget>[
                      CupertinoActionSheetAction(
                        child: Text(
                          'List with Prices',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          ItemList list = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AddListWithPricePage()));
                          setState(() {
                            if (list != null) {
                              lists.add(list);
                            }
                          });
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: Text(
                          'List without Prices',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          ItemList list = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AddListWithoutPricesPage()));
                          setState(() {
                            if (list != null) {
                              lists.add(list);
                            }
                          });
                        },
                      )
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ));
                showCupertinoModalPopup(
                    context: context, builder: (BuildContext context) => act);
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'ADD LIST',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text('Added ${lists.length} lists'),
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  ItemList item = lists[index];
                  return ListTile(
                    title: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditListPage(
                                      list_id: item.id,
                                      first_required: item.is_required,
                                      minimum_length:
                                          lists[index].minimum_length,
                                      maximum_length:
                                          lists[index].maximum_length,
                                    )));

                        setState(() {
                          int minimum_length = result['minimum_length'] as int;
                          int maximum_length = result['maximum_length'] as int;

                          lists[index].is_required = result['is_required'];
                          lists[index].minimum_length = minimum_length;
                          lists[index].maximum_length = maximum_length;
                        });
                      },
                      child: Text(item.name),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        setState(() {
                          lists.removeAt(index);
                        });
                      },
                      child: Icon(LineIcons.trash),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      Step(
        state: stepFourState,
        isActive: stepFourActive,
        title: const Text('Upload a bright image of the menu item'),
        content: Column(
          children: <Widget>[
            imageUrl.startsWith('http')
                ? Container(
                    height: 200,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                final image =
                    await imagePicker.getImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    imageFile = File(image.path);
                  });
                  setState(() {
                    imageUrl = image.path;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                height: 50,
                child: Center(
                  child: Text(
                    'UPDATE PHOTO',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Step(
          state: stepFiveState,
          isActive: stepFiveActive,
          title: const Text('Health & Safety Labels'),
          content: Container(
            height: 350,
            child: ListView(
              children: [
                CheckboxListTile(
                  title: Text('Vegan'),
                  value: isVegan,
                  onChanged: (newValue) {
                    setState(() {
                      isVegan = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Vegetarian'),
                  value: isVegetarian,
                  onChanged: (newValue) {
                    setState(() {
                      isVegetarian = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Gluten Free'),
                  value: isGlutenFree,
                  onChanged: (newValue) {
                    setState(() {
                      isGlutenFree = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Halal'),
                  value: isHalal,
                  onChanged: (newValue) {
                    setState(() {
                      isHalal = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Kosher'),
                  value: isKosher,
                  onChanged: (newValue) {
                    setState(() {
                      isKosher = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Sugar Free'),
                  value: isSugarFree,
                  onChanged: (newValue) {
                    setState(() {
                      isSugarFree = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                )
              ],
            ),
          )),
      Step(
          state: stepSixState,
          isActive: stepSixActive,
          title: const Text('Allergens'),
          content: Container(
            height: 450,
            child: ListView(
              children: [
                CheckboxListTile(
                  title: Text('Egg'),
                  value: isEgg,
                  onChanged: (newValue) {
                    setState(() {
                      isEgg = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Fish'),
                  value: isFish,
                  onChanged: (newValue) {
                    setState(() {
                      isFish = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('ShellFish'),
                  value: isShellFish,
                  onChanged: (newValue) {
                    setState(() {
                      isShellFish = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Milk'),
                  value: isMilk,
                  onChanged: (newValue) {
                    setState(() {
                      isMilk = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Peanut'),
                  value: isPeanut,
                  onChanged: (newValue) {
                    setState(() {
                      isPeanut = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Soy'),
                  value: isSoy,
                  onChanged: (newValue) {
                    setState(() {
                      isSoy = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Treenuts'),
                  value: isTreenuts,
                  onChanged: (newValue) {
                    setState(() {
                      isTreenuts = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                CheckboxListTile(
                  title: Text('Wheat / Gluten'),
                  value: isWheatOrGluten,
                  onChanged: (newValue) {
                    setState(() {
                      isWheatOrGluten = newValue;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                )
              ],
            ),
          )),
    ];

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'Edit A La Carte Item',
            textAlign: TextAlign.center,
          ),
          shadowColor: Colors.transparent,
          actions: [
            GestureDetector(
              onTap: () {
                updateFlatPriceMenu();
              },
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  )),
            )
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.only(left: 75),
                child: Stepper(
                  currentStep: currentStep,
                  onStepContinue: next,
                  steps: steps,
                  onStepTapped: (step) => goTo(step),
                  onStepCancel: cancel,
                ))));
  }

  switchStepType() {
    setState(() => stepperType == StepperType.horizontal
        ? stepperType = StepperType.vertical
        : stepperType = StepperType.horizontal);
  }

  Widget toggledPriceWidget(PricingType type) {
    if (type == PricingType.flat_price) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Text('Flat Price'),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text('\$ '),
              Expanded(
                child: _TextFormField(
                  hintText: 'Enter the price in USD',
                  controller: flatPriceController,
                  focusNode: flatPriceFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                ),
              )
            ],
          )
        ],
      );
    }
    if (type == PricingType.starting_from) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Text('Starting from Price'),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text('\$ '),
              Expanded(
                child: _TextFormField(
                  hintText: 'Enter the starting price',
                  controller: startingFromController,
                  focusNode: startingFromFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    DecimalTextInputFormatter(decimalRange: 2),
                  ],
                ),
              )
            ],
          )
        ],
      );
    }
    if (type == PricingType.price_and_quantity) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Text('Enter quantities and prices separated by commas and spaces'),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 60,
            width: 250,
            child: Row(
              children: [
                Expanded(
                  child: _TextFormField(
                    hintText:
                        '3 Pieces/\$5.75, 7.5 Pieces/\$10.75, 10 Pieces/\$15',
                    controller: priceAndQuantityController,
                    focusNode: priceAndQuantityFocusNode,
                    textInputAction: TextInputAction.done,
                  ),
                )
              ],
            ),
          )
        ],
      );
    } else {
      return SizedBox();
    }
  }

  void getItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        '${Constants.apiBaseUrl}/restaurants/get-item',
        headers: {
          'token': prefs.getString('token'),
          'Content-Type': 'application/json'
        },
        body: json.encode({'item_id': widget.id}));
    var menu = json.decode(response.body)['menus'][0];
    dropdownValue = items
        .where((element) => element.id == menu['category_id'] as String)
        .first;
    nameController.text = menu['name'] as String;
    descriptionController.text = menu['description'] as String;

    if ((menu['flat_price']) != null) {
      _character = PricingType.flat_price;
      flatPriceController.text = '${menu['flat_price']}';
    }

    if ((menu['starting_price']) != null) {
      _character = PricingType.starting_from;
      startingFromController.text = '${menu['starting_price']}';
    }
    Iterable qps = menu['quantities_and_prices'];

    List<QuantityAndPrice> qps_list =
        qps.map((e) => QuantityAndPrice.fromJson(e)).toList();
    if (qps.isNotEmpty) {
      _character = PricingType.price_and_quantity;
      priceAndQuantityController.text =
          '${qps_list.map((e) => '${e.quantity} ${e.measurementLabel}/\$${e.price}').toList().join(', ')}';
    }

    if ((menu['cooking_time']) != null) {
      minutesController.text = '${menu['cooking_time'] as int}';
    }

    if ((menu['lists'] as List) != null) {
      Iterable items = menu['lists'];
      print('${items.length} bar');
      lists = items.map((e) => ItemList.fromJson(e)).toList();
      print('${lists.length} foo');
    }
    if ((menu['image_url']) != null) {
      imageUrl = '${menu['image_url']}';
    }

    print('the id is ' + dropdownValue.id);
    Iterable health_labels = menu['health_labels'];
    var labels = health_labels.map((e) => e as String).toList();
    labels.forEach((element) {
      if (element == 'Vegan') {
        isVegan = true;
      }
      if (element == 'Vegetarian') {
        isVegetarian = true;
      }
      if (element == 'Gluten Free') {
        isGlutenFree = true;
      }
      if (element == 'Halal') {
        isHalal = true;
      }
      if (element == 'Kosher') {
        isKosher = true;
      }
      if (element == 'Sugar Free') {
        isSugarFree = true;
      }
    });

    Iterable allergens = menu['allergens'];
    var _allergens = allergens.map((e) => e as String).toList();
    _allergens.forEach((element) {
      if (element == 'Egg') {
        isEgg = true;
      }
      if (element == 'Fish') {
        isFish = true;
      }
      if (element == 'ShellFish') {
        isShellFish = true;
      }
      if (element == 'Milk') {
        isMilk = true;
      }
      if (element == 'Peanut') {
        isPeanut = true;
      }
      if (element == 'Soy') {
        isSoy = true;
      }
      if (element == 'Treenuts') {
        isTreenuts = true;
      }
      if (element.contains('Wheat')) {
        isWheatOrGluten = true;
      }
    });
    setState(() {});
  }

  void getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http
        .post('${Constants.apiBaseUrl}/restaurants/get-categories', headers: {
      'token': prefs.getString('token'),
      'Content-Type': 'application/json'
    });
    Iterable categories = json.decode(response.body)['categories'];
    setState(() {
      items = [chooseCategory] +
          categories.map((e) => Category.fromJson(e)).toList().toList();
      getItem();
    });
  }
}

List<String> titleList = ['Flat Price', 'Price and Quantity', 'Starting From'];

class _TextFormField extends StatelessWidget {
  final String hintText;
  final Function validator;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;
  final Iterable<String> autofillHints;
  final TextEditingController controller;
  final Function onChanged;
  final FocusNode focusNode;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final Iterable<TextInputFormatter> inputFormatters;

  _TextFormField(
      {this.hintText,
      this.validator,
      this.onSaved,
      this.isPassword = false,
      this.isEmail = false,
      this.controller,
      this.autofillHints,
      this.onChanged,
      this.inputFormatters,
      this.focusNode,
      this.enabled,
      this.keyboardType,
      this.textInputAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
          ),
          child: TextFormField(
              enabled: enabled,
              textInputAction: textInputAction,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.none,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              autofillHints: autofillHints,
              style: TextStyle(fontSize: 20),
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                  helperText: ' ',
                  hintText: hintText,
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 0, bottom: 5),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.3, color: Colors.grey))),
              obscureText: isPassword ? true : false,
              keyboardType: keyboardType),
        ));
  }
}

enum PricingType { flat_price, price_and_quantity, starting_from, none }

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);
  final int decimalRange;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;
    if (decimalRange != null) {
      String value = newValue.text;
      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";
        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }
      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

enum Healh_and_Safety_Labels {
  vegan,
  vegetarian,
  gluten_free,
  halal,
  kosher,
  sugar_free,
}

enum Allergens {
  egg,
  fish,
  shellfish,
  milk,
  peanut,
  soy,
  treenuts,
  wheat_or_gluten
}
