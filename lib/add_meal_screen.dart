
import 'package:catdiet/CatData.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({Key? key, required this.sheet, required this.data}) : super(key: key);

  final Spreadsheet sheet;
  final CatData data;

  @override
  State<AddMealScreen> createState() => AddMealState();
}

class AddMealState extends State<AddMealScreen> {

  List<Food> _foods = [];
  List<int> _selectedFoods = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _foods = widget.data.foods.where((f) => f.isInStock).toList();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Add a meal'),
        ),
        body: Stack(children: [
          Container(
              padding: EdgeInsets.only(left: 50, right: 50),
              child: Row(children: [
                Expanded(
                  // width: MediaQuery.of(context).size.width * 0.6,
                    flex: 6,
                    child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => SizedBox(height: 10),
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        itemCount: _foods.length,
                        itemBuilder: (context, index) {

                          var food = _foods[index];
                          var img = food.canPicUri != null
                              ? Image.network(food.canPicUri.toString())
                              : Image.asset('assets/cat1.png');
                          var isSelected = _selectedFoods.contains(index);

                          return Row(children: [
                            Expanded(
                              flex: 9,
                                child: Card(
                                elevation: isSelected ? 10 : 5,
                                shadowColor: isSelected ? Colors.blueAccent : Colors.black,
                                color: isSelected ? Colors.blueAccent : Colors.white,
                                child: ListTile(
                                    minVerticalPadding: 20,
                                    leading: Container(
                                      height: double.infinity,
                                      child: img,
                                    ),
                                    minLeadingWidth: 100,
                                    title: Text(
                                        '${food.brand} ${food.variety}',
                                        style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            fontSize: 24,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w300
                                        )),
                                    subtitle: Text(
                                        '${food.packageOz} oz\t${food.packageKcal} kcal',
                                        style: TextStyle(
                                            color: isSelected ? Colors.white70 : Colors.black54,
                                            fontSize: 13.5,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400
                                        )
                                    ),
                                    // trailing: isSelected ? Icon(Icons.check, color: Colors.blueAccent) : null,
                                    selected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        isSelected
                                            ? _selectedFoods.remove(index)
                                            : _selectedFoods.add(index);
                                      });
                                    }
                                )
                            )),
                            Expanded(
                                child: Icon(
                                  isSelected ? Icons.play_arrow : null,
                                  size: 40,
                                  color: Colors.blueAccent),
                                flex: 1)
                          ]);
                        }
                    )),
                // SizedBox(width: 30),
                Expanded(
                  // width: MediaQuery.of(context).size.width * 0.6,
                    flex: 5,
                    child: Card(
                        // margin: EdgeInsets.only(top: 50, bottom: 50),
                      margin: EdgeInsets.all(50),
                        color: Colors.white,
                        elevation: 15,
                        child: ListView.builder(
                            itemExtent: 55,
                            scrollDirection: Axis.vertical,
                            itemCount: _selectedFoods.length,
                            itemBuilder: (context, index) {
                              var food = _foods[_selectedFoods[index]];
                              return ListTile(
                                title: Text(
                                    '${food.brand} ${food.variety}',
                                    style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w300
                                    )
                                ),
                                subtitle: Text(
                                    '${food.packageOz} oz\t\t\t\t${food.packageKcal} kcal',
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 13,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w300
                                    )
                                ),
                              );
                            }
                        )
                    )
                )
              ])
          ),
          Container(
              alignment: Alignment.bottomRight,
              margin: const EdgeInsets.only(bottom: 20, right: 20),
              child: FloatingActionButton.large(
                child: const Icon(Icons.check, size: 80,),
                backgroundColor: Colors.green,
                onPressed: () {
                  Navigator.pop(context);
                },
              )
          )
        ])
    );
  }
}