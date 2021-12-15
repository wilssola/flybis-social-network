import 'package:flutter/material.dart';

extension ColumnWudget on List<Widget?> {
  Widget xColumn(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
      MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnSS(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnBS(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: MainAxisAlignment.start,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnES(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnSTS(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      key: key,
      children: this as List<Widget>,
    );
  }

  //----------------------------------------------------------  end  start

  Widget xColumnSTC(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnSC(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnEC(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnCC(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnBC(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: MainAxisAlignment.center,
      key: key,
      children: this as List<Widget>,
    );
  }

  // ------------------------------------------------------------ emd center

  Widget xColumnSTE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.end,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnSE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnEE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnCE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnBE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: MainAxisAlignment.end,
      key: key,
      children: this as List<Widget>,
    );
  }

  // ------------------------------------------------------------ emd end

  Widget xColumnSTSA(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnSSA(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnESA(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnCSA(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnBSA(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      key: key,
      children: this as List<Widget>,
    );
  }

  // ------------------------------------------------------------- end spaceAround

  Widget xColumnSTSB(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnSSB(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnESB(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnCSB(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnBSB(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      key: key,
      children: this as List<Widget>,
    );
  }

  // ------------------------------------------------------------- end spaceBetween
  Widget xColumnSTSE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnSSE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnESE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnCSE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      key: key,
      children: this as List<Widget>,
    );
  }

  Widget xColumnBSE(
      {Key? key,
      MainAxisSize mainAxisSize = MainAxisSize.max,
      TextBaseline? textBaseline,
      TextDirection? textDirection,
      VerticalDirection verticalDirection = VerticalDirection.down}) {
    return Column(
      mainAxisSize: mainAxisSize,
      textBaseline: textBaseline,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      key: key,
      children: this as List<Widget>,
    );
  }
}
