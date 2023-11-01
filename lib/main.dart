import 'package:flutter/material.dart';
import 'package:sqlite/home.dart';
import 'package:sqlite/modelo.dart';

final dbHelper = DatabaseHelper();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize the database
  await dbHelper.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map> items = [];

  int _selectedId = 0;
  String _selectedName = '';
  int _selectedAge = 0;

  @override
  void initState() {
    dbHelper.init().then((value) => _fetchData());
    super.initState();
  }

  void _fetchData() async {
    List<Map> results = await dbHelper.fecthAll();
    print(results);
    setState(() {
      items = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sqflite'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _insert(context),
              child: const Text('insert'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _query,
              child: const Text('query'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _update,
              child: const Text('update'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _delete,
              child: const Text('delete'),
            ),
            const SizedBox(
              height: 50,
            ),
            items.isNotEmpty
                ? FutureBuilder(
                    future: dbHelper.fecthAll(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else {
                        List<Map> data = snapshot.data ?? <Map>[];
                        return Container(
                          height: 400,
                          child: ListView.builder(
                            shrinkWrap:
                                true, // Important to prevent scrolling issues inside ListView
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              Map item =
                                  data[index]; // Iterate through the data
                              return GestureDetector(
                                onTap: () {
                                  //Update the selected record
                                  _selectedId = item['_id'];
                                  _selectedName = item['_name'];
                                  _selectedAge = item['_age'];

                                  //Here the user must click the Update Button
                                },
                                child: Card(
                                  color: Colors.grey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Text(
                                              item['_id'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              item['_name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Text(
                                              item['_age'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  )
                : const Text('There is no data to show here'),
          ],
        ),
      ),
    );
  }

  void _insert(BuildContext context) async {
    final name = TextEditingController();
    final age = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insertar nuevo usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nombre'),
              TextFormField(
                controller: name,
                obscureText: false,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person),
                    errorText: null),
                onChanged: (texto) {},
              ),
              const SizedBox(
                height: 20,
              ),
              Text('Años(int)'),
              TextFormField(
                controller: age,
                obscureText: false,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person),
                    errorText: null),
                onChanged: (texto) {},
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el AlertDialog
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // row to insert
                Map<String, dynamic> row = {
                  DatabaseHelper.columnName: name.text,
                  DatabaseHelper.columnAge: int.parse(age.text)
                };
                Model modelo = Model.fromJson(row);

                final id = await dbHelper.insert(modelo);

                debugPrint('inserted row id: $id');
                if (!id.isNegative) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Se agrego correctamente el usuario ${name.text} con the id: $id',
                      ),
                    ),
                  );
                }
                Navigator.of(context).pop(); // Cerrar el AlertDialog
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('query all rows:');
    for (final row in allRows) {
      debugPrint(row.toString());
    }
  }

  void _update() async {
    // row to update
    final name = TextEditingController();
    final age = TextEditingController();

    name.text = _selectedName;
    age.text = _selectedAge.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nombre'),
              TextFormField(
                controller: name,
                obscureText: false,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person),
                    errorText: null),
                onChanged: (texto) {},
              ),
              const SizedBox(
                height: 20,
              ),
              Text('Años(int)'),
              TextFormField(
                controller: age,
                obscureText: false,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person),
                    errorText: null),
                onChanged: (texto) {},
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el AlertDialog
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // row to update
                Map<String, dynamic> row = {
                  DatabaseHelper.columnId: _selectedId,
                  DatabaseHelper.columnName: name.text,
                  DatabaseHelper.columnAge: int.parse(age.text)
                };
                Model modelo = Model.fromJson(row);

                final rowsAffected = await dbHelper.update(modelo);
                debugPrint('updated $rowsAffected row(s)');

                Navigator.of(context).pop(); // Cerrar el AlertDialog
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _delete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Nombre: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_selectedName),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Edad(int): ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_selectedAge.toString()),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el AlertDialog
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // row to update
                Map<String, dynamic> row = {
                  DatabaseHelper.columnId: _selectedId,
                  DatabaseHelper.columnName: _selectedName,
                  DatabaseHelper.columnAge: _selectedAge,
                };
                Model modelo = Model.fromJson(row);
                final rowsDeleted = await dbHelper.delete(modelo);

                //After insertion close the dialog
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
              child: const Text(
                'Borrar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
