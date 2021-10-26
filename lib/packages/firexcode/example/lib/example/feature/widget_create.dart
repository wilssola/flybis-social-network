import 'package:firexcode/xServices.dart';

List stlessName = ['profile', 'homePage', 'setting']; // create array page name
List stfullName = ['profile', 'homePage', 'setting'];
void main() {
  stlessName.forEach((f) {
    xStless(f + 'Stless', 'lib/X'); // that is state less
  });
  stfullName.forEach((f) {
    xStfull(f + 'Stfull', 'lib/X'); // that is stateful
  });
  print('"done');
}
