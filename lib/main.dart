import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://tyrdrjhmjfjmunipdfwc.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5cmRyamhtamZqbXVuaXBkZndjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTAwOTIzNDAsImV4cCI6MjAwNTY2ODM0MH0.GA3QMcVyeQKyPaCznp07JnTj4e_wZiJNoNC8xOszTPU",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _notesStream =
      Supabase.instance.client.from("Notes").stream(primaryKey: ["id"]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _notesStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final notes = snapshot.data;
            return ListView.builder(
                itemCount: notes?.length,
                itemBuilder: (context, index) {
                  final noteID = notes?[index]["id"];
                  return ListTile(
                    leading: IconButton(
                      onPressed: () async {
                        await Supabase.instance.client
                            .from("Notes")
                            .delete()
                            .match({"id": noteID});
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    title: Text(notes?[index]["body"]),
                  );
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: ((context) {
              return SimpleDialog(
                title: Text("Add note"),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) async {
                      await Supabase.instance.client
                          .from("Notes")
                          .insert({"body": value});
                    },
                  ),
                ],
              );
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
