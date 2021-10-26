import 'package:firexcode/firexcode.dart';

class ExampleFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 'FloatingActionButton'.xTextColorWhite().toCenter().xScaffold(
          backgroundColor: Colors.white,
          appBar: 'Flaoting Action Button'.xTextColorBlack().xAppBar(
                brightness: Brightness.light,
                centerTitle: true,
                backgroundColor: Colors.white,
              ),
          floatingActionButton: <Widget>[
            Icons.add.xIcons().xFloatinActionExtend(),
            'extend'.text().xFloatinActionExtend()
          ].xRowSSB().xlp(value: 50.0),
        );
  }
}
