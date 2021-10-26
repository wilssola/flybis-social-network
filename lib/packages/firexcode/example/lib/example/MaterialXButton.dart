import 'package:firexcode/firexcode.dart';

class ExampleMaterialXButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return <Widget>[
      MaterialXButton(
        color: Colors.red,
        height: 50.0,
        width: xwidth(context),
        onTap: () {},
        elavation: 10,
        rounded: 5,
        spreadRadius: 10,
        child: 'Submit'.xTextColorWhite(),
      ),
      50.0.sizedHeight(),
      'Submit'.xTextColorWhite().xButton(
            color: Color(0xFF3d6dfe),
            height: 50.0,
            width: xwidth(context),
            onTap: () {},
            rounded: 20,
            spreadRadius: 0,
          ),
    ].xColumnCC().xap(value: 20.0).xScaffold(
        backgroundColor: Colors.white,
        appBar: 'MaterialXButton'.xTextColorBlack().xAppBar(
              brightness: Brightness.light,
              centerTitle: true,
              backgroundColor: Colors.white,
            ));
  }
}
