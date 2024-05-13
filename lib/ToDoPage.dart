import 'package:flutter/material.dart';
import 'main.dart';
import 'DatabaseHelper.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<ToDoItem> toDoItems = [];
  List<Map<String, dynamic>> toDoItems2 = [];
  List<ToDoItem> filteredItems = [];
  static bool start = false;
  static String fixid="";
  static bool canceled =false;
  static List<Map<String, dynamic>> todoItemsToDo = [];
  static List<Map<String, dynamic>> todoItemsDoing = [];
  static  List<Map<String, dynamic>> todoItemsDone = [];
  static const String TODO="To Do";
  static const String DOING="Doing";
   static const String DONE="Done";

  @override
  Widget build(BuildContext context) {
    print( "start1 $start ");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'ToDo List',
          style: TextStyle(
            color: Color(0xff4e3169), // Customize the text color
            fontSize: 22, // Adjust the font size to increase width
            fontWeight: FontWeight.bold, // Optionally adjust font weight
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            color: Color(0xff4e3169),
            onPressed: () {
              // Show/hide quote banner
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            color: Color(0xff4e3169),
            onPressed: () {
              // Implement logout functionality
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
      body: Container(
        // color: Color(0xff4e3169),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/doit.png'),
            // Replace 'background_image.jpg' with your image file path
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            _buildStatusList(TODO, Icons.menu, Color(0xff4e3169)),
            _buildStatusList(DOING, Icons.flag, Colors.orange),
            _buildStatusList(DONE, Icons.done, Colors.green),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add item dialog
          _showAddItemDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController dueDateController = TextEditingController();
    TextEditingController estimateController = TextEditingController();
    TextEditingController unitController = TextEditingController();
    String importanceValue = 'Low';

    bool isTitleValid = true;
    bool isCategoryValid = true;
    bool isDueDateValid = true;
    bool isEstimateValid = true;
    void validateFields() {
      setState(() {
        print("etStann");
        isTitleValid = titleController.text.isNotEmpty;
        isCategoryValid = categoryController.text.isNotEmpty;
        isDueDateValid = DateTime.tryParse(dueDateController.text) != null;
        isEstimateValid = int.tryParse(estimateController.text) != null;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Item'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      errorText: isTitleValid ? null : 'Invalid title',
                    ),
                    //onChanged: (_) => validateFields(),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      errorText: isCategoryValid ? null : 'Invalid category',
                    ),
                   // onChanged: (_) => validateFields(),
                  ),
                  TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date yyyy-mm-dd',
                      errorText: isDueDateValid
                          ? null
                          : 'Invalid due date set a valid  form',
                    ),
                  //  onChanged: (_) => validateFields(),
                  ),
                  TextField(
                    controller: estimateController,
                    decoration: InputDecoration(
                      labelText: 'Effort',
                      errorText: isEstimateValid
                          ? null
                          : 'Invalid estimate should be a number ',
                    ),
                  //  onChanged: (_) => validateFields(),
                  ),
                  DropdownButtonFormField<String>(
                    value: importanceValue,
                    items: ['Low', 'Medium', 'High']
                        .map((value) =>
                        DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                        .toList(),
                    onChanged: (value) {
                      // setState(() {
                      importanceValue = value!;
                      // });
                    },
                    decoration: InputDecoration(labelText: 'Importance'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  validateFields();
                  // If all fields are valid, create a new ToDoItem
                  if (isTitleValid && isCategoryValid && isDueDateValid &&
                      isEstimateValid) {
                    var uuid = Uuid();
                    String newItemId = uuid.v4();
                    ToDoItem newItem = ToDoItem(
                      id: newItemId,
                      title: titleController.text,
                      category: categoryController.text,
                      dueDate: DateTime.parse(dueDateController.text),
                      estimate: estimateController.text,
                      unit: '',
                      importance: importanceValue,
                      status: 'To Do',
                    );
                    setState(() {
                      toDoItems.add(newItem);
                    });
                 //   setState(() {});
                    // Insert the new item into the database
                    await DatabaseHelper.insertTodoItem(newItem.toMap());
                    Navigator.of(context).pop();
                  } else {
                    onChanged:
                    setState(() {});
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  /*Widget _buildStatusList(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.getTodoItems(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // or any loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No items found.');
        } else {
          // Data has been fetched successfully
          List<Map<String, dynamic>> todoItems = snapshot.data!;
          List<ToDoItem> filteredItems = todoItems.map((item) {
            return ToDoItem.fromMap(item);
          }).toList();

          return DragTarget<ToDoItem>(
            onAccept: (data) {
              setState(() {
                // Remove the item from its previous list
                DatabaseHelper.updateTodoItemStatus(data.id, status);
                // No need to update the UI here because FutureBuilder will rebuild
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Icon(Icons.menu, color: Color(0xff4e3169)),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            status,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ...filteredItems.map((item) {
                    return Draggable<ToDoItem>(
                      data: item,
                      feedback: ToDoItemCard(item),
                      childWhenDragging: Container(),
                      child: ToDoItemCard(item),
                    );
                  }).toList(),
                ],
              );
            },
          );
        }
      },
    );
  }*/
  void setList(String status ,List<Map<String, dynamic>> dataList) {
    print("setList" + status);
    switch (status) {
      case TODO:
        todoItemsToDo=dataList;
        print("dle1: $todoItemsToDo.length");
        break;
      case DOING:
        todoItemsDoing=dataList;
        print( "dle2: $todoItemsDoing.length");
        break;
      case DONE:
        todoItemsDone=dataList;
        print( "dle3: $todoItemsDone.length");
        break;
      default:
        break;
    }
  }
  List<Map<String, dynamic>> getList(String status){
    print("getList " + status);
    print("len: ($todoItemsToDo.length)  ($todoItemsDoing.length)  ($todoItemsDone.length) ");
    switch (status) {
      case TODO:
        return todoItemsToDo;
      case DOING:
        return todoItemsDoing;
      case DONE:
        return todoItemsDone;
      default:
        return [];
    }
  }
  Widget _buildStatusList(String status, IconData icon, Color iconColor) {// onenddragged hy ymkn lzm sawi foya chi uff m m3i comp flutter
    print("fett" + status);
    print( "startx $start ");
    return DragTarget<ToDoItem>(
        onAccept: (data) async {
            start=false;
            print( "start5 $start ");
          // Update the status of the dropped item
          print("datnanostatus " + data.status);
          print("nanostatus " + status);
          await DatabaseHelper.updateTodoItemStatus(data.id, status);
          // Re-fetch the items from the database to reflect the changes
          setState(() {
            print("chuf10");
          });
        },
        //if (candidateData.isEmpty  )
      builder: (context, candidateData, rejectedData) {
         //famythrk //hta abl l db
            print( "start2 $start ");
            print("candidateData $candidateData.isEmpty " );
            print("chuf1");//
              return Column(
              //print("chuf1");
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xff1f1627),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Icon(icon, color: iconColor),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          status,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                if (start==true) //&& candidateData.isEmpty start==false
                buildDraggableItems(getList(status),status)
                else
                FutureBuilder<List<Map<String, dynamic>>>(// bfut lhon aktar ft martn bhy lch
                  future:start?Future.value(getList(status)):DatabaseHelper.getTodoItems(status),//hl lzm bara chi ?//nhot hy bra w 5ls aw kif
                  builder: (context, snapshot) {
           //  if (start==false && candidateData.isEmpty){
                    print( "start3 $start ");
                    print(candidateData.isEmpty );
                    print("chuf2");
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // or any loading indicator
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {// hon lzm zabt hdik fadiya m hk aw kif
                      setList(status, [] );
                      return Text('No items found.');
                    } else {
                      print("chuf3");//List<Map<String, dynamic>>
                       toDoItems2 = snapshot.data!;
                      setList(status, toDoItems2 ); //brki am nhot fiyon w m am nrj3 n3ml clear aw chi w am bdal fiyon m3lmt 8lat aw m b3rf mnn hl 1 srh
                      print("tull todo: ($todoItemsToDo.length) ,doing:($todoItemsDoing.length) , done:($todoItemsDone.length) ");//lrmv t3ti am tcht8lawlaa
                      print("chuf4");
                     return buildDraggableItems(toDoItems2,status);
                    };
                  },
                ),
              ],
            );
        }
    );
  }
  Widget buildDraggableItems(List<Map<String, dynamic>> toDoItems2,String status) {
    filteredItems = toDoItems2.map((item) => ToDoItem.fromMap(item)).toList();// List<ToDoItem>
    print(" buildDraggableItems");
    print("Number of items: ${filteredItems.length}  $status  ${toDoItems2.length}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 2.0),
        for (final item in filteredItems)
         if(!(start && item.id==fixid) || canceled)//aymt m yrsom iza canceled true bdi yrsom &&cancledm3on
          Draggable<ToDoItem>(
            data: item,
            feedback: ToDoItemCard(item),
            childWhenDragging: Container(),
            child: ToDoItemCard(item),
            onDragStarted: () {
              fixid =item.id;
              start=true;
              canceled=false;
              print("chuf31");
              setState(() {
                filteredItems.remove(item); // n3dl hdik kmn
                 print("chuf21");// chuf l list w m 5ali l item ela ybyn bmhlwehd if mbyn bkza mhl setstt aw m 5ali
              });
            },
            onDragUpdate:(DragUpdateDetails details){},
            onDragEnd: (DraggableDetails details){setState(() { print("nenddd");});},//fiyi chi 5ali yfut al db hon iza m kn fyt asln hon aymt bft
            onDraggableCanceled:(Velocity velocity, Offset offset){
              canceled=true;
              print("canceldn ");
              setState(() {});} ,
          ),
      ],
    );
  }
 /* void removeFromList(String status,ToDoItem item ) {
    print("removeFromList" + status);
    switch (status) {
      case "To Do":
      /*  int index = todoItemsToDo.indexWhere((element) => element['id']  == item.id); // Assuming ToDoItem has an 'id' property
        todoItemsToDo.removeAt(index);*/
        todoItemsToDo.removeWhere((element) => element['id'] == item.id);
        print("lerr1 ($todoItemsToDo.length)");
        //  todoItemsToDo.remove(item.toMap());
       // setList(status,todoItemsToDo);
        break;
      case "Doing":
       /* int index = todoItemsDoing.indexWhere((element) => element['id']  == item.id); // Assuming ToDoItem has an 'id' property
        todoItemsDoing.removeAt(index);*/
        todoItemsDoing.removeWhere((element) => element['id'] == item.id);
        print("lerr2 ($todoItemsDoing.length)");
       // todoItemsDoing.remove(item.toMap());
       //  setList(status,todoItemsDoing);
        break;
      case "Done":
       /* int index = todoItemsDone.indexWhere((element) => element['id']  == item.id); // Assuming ToDoItem has an 'id' property
        todoItemsDone.removeAt(index);*/
        todoItemsDone.removeWhere((element) => element['id'] == item.id);
        print("lerr3 ($todoItemsDone.length)");
       // todoItemsDone.remove(item.toMap());
        // setList(status,todoItemsDone);
        break;
      default:
        break;
    }
  }*/
}

class ToDoItem {
  late String id;
  late String title;
  late String category;
  late DateTime dueDate;
  late String estimate;
  late String unit;
  late String importance;
  late String status; // To Do, Doing, Done

  ToDoItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.estimate,
    required this.unit,
    required this.importance,
    required this.status,
  });

  // Define a factory constructor to create a ToDoItem from a map
  factory ToDoItem.fromMap(Map<String, dynamic> map) {
    return ToDoItem(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      dueDate: DateTime.parse(map['dueDate']),
      estimate: map['estimate'],
      unit: map['unit'],
      importance: map['importance'],
      status: map['status'],
    );
  }

  // Convert ToDoItem object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dueDate': dueDate.toIso8601String(), // Convert DateTime to string
      'estimate': estimate,
      'unit': unit,
      'importance': importance,
      'status': status,
    };
  }
}

class ToDoItemCard extends StatelessWidget {
  final ToDoItem item;

  ToDoItemCard(this.item);

  @override
  Widget build(BuildContext context) {
    TextEditingController tittleController = TextEditingController(text: item.title);
    TextEditingController categoryController = TextEditingController(text: item.category);
    TextEditingController dueDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(item.dueDate));
    TextEditingController effortController = TextEditingController(text: item.estimate.toString());
    TextEditingController importanceController = TextEditingController(text: item.importance);

    return Card(
      child: Container(
        width: 260,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Color(0xff4c4b4d),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12.0),
                ),
                Text(tittleController.text, style: TextStyle(fontSize: 20.0, color: Colors.white)),
              ],
            ),
            SizedBox(height: 1.0),
            Row(
              children: [
                Text('Category', style: TextStyle(fontSize: 16.0)),
                SizedBox(width: 16.0), // Add spacing between the label and the input
                Expanded(
                  child: TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Make the underline invisible
                      hintText: 'Enter category', // Placeholder text
                    ),
                  ),
                ),
              ],
            ),
           // SizedBox(height:1.0),
            Row(
              children: [
                Text('Due Date', style: TextStyle(fontSize: 16.0)),
                SizedBox(width: 16.0), // Add spacing between the label and the input
                Expanded(
                  child: TextFormField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Make the underline invisible
                      hintText: 'due date', // Placeholder text
                    ),
                  ),
                ),
              ],
            ),
           // SizedBox(height:1.0),
            Row(
              children: [
                Text('Effort', style: TextStyle(fontSize: 16.0)),
                SizedBox(width: 16.0), // Add spacing between the label and the input
                Expanded(
                  child: TextFormField(
                    controller: effortController,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Make the underline invisible
                      hintText: 'Enter effort', // Placeholder text
                    ),
                  ),
                ),
              ],
            ),
            //SizedBox(height:1.0),
            Row(
              children: [
                Text('Importance', style: TextStyle(fontSize: 16.0)),
                SizedBox(width: 16.0), // Add spacing between the label and the button

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getButtonColor(importanceController.text), // Set button color dynamically
                  ),
                  child: Text(importanceController.text),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color getButtonColor(String importance) {
    switch (importance) {
      case 'Low':
        return Colors.yellow;
      case 'Medium':
        return Colors.green;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey; // Default color (adjust as needed)
    }
  }
}
