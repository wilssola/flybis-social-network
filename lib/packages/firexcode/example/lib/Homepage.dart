import 'package:firexcode/firexcode.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return '$value'.text().toCenter().xScaffold(
        floatingActionButton:
            Icons.add.xIcons().xFloationActiobButton(onTap: () {}));
  }

  var value = 0;
  void increment() {
    setState(() {
      value++;
    });
  }
}
