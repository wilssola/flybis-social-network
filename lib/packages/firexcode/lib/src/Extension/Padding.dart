import 'package:flutter/material.dart';

extension Paddings on Widget {
  Widget xap({required double value}) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  Widget xlp({required double value}) {
    return Padding(
      padding: EdgeInsets.only(left: value),
      child: this,
    );
  }

  Widget xrp({required double value}) {
    return Padding(
      padding: EdgeInsets.only(
        right: value,
      ),
      child: this,
    );
  }

  Widget xtp({required double value}) {
    return Padding(
      padding: EdgeInsets.only(
        top: value,
      ),
      child: this,
    );
  }

  Widget xbp({required double value}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: value,
      ),
      child: this,
    );
  }

  Widget xtbp({required double t, required double b}) {
    return Padding(
      padding: EdgeInsets.only(top: t, bottom: b),
      child: this,
    );
  }

  Widget xltp({required double l, required double t}) {
    return Padding(
      padding: EdgeInsets.only(top: t, left: l),
      child: this,
    );
  }

  Widget xrtp({required double r, required double t}) {
    return Padding(
      padding: EdgeInsets.only(top: t, right: r),
      child: this,
    );
  }

  Widget xlbp({required double l, required double b}) {
    return Padding(
      padding: EdgeInsets.only(left: l, bottom: b),
      child: this,
    );
  }

  Widget xlrp({required double l, required double r}) {
    return Padding(
      padding: EdgeInsets.only(left: l, right: r),
      child: this,
    );
  }

  Widget xrbp({required double r, required double b}) {
    return Padding(
      padding: EdgeInsets.only(right: r, bottom: b),
      child: this,
    );
  }

  Widget xrbtp({required double r, required double b, required double t}) {
    return Padding(
      padding: EdgeInsets.only(
        right: r,
        bottom: b,
        top: t,
      ),
      child: this,
    );
  }

  Widget xlbtp({required double l, required double b, required double t}) {
    return Padding(
      padding: EdgeInsets.only(
        left: l,
        bottom: b,
        top: t,
      ),
      child: this,
    );
  }

  Widget xlrtp({required double l, required double r, required double t}) {
    return Padding(
      padding: EdgeInsets.only(
        left: l,
        right: r,
        top: t,
      ),
      child: this,
    );
  }

  Widget xlrbp({required double l, required double r, required double b}) {
    return Padding(
      padding: EdgeInsets.only(
        left: l,
        right: r,
        bottom: b,
      ),
      child: this,
    );
  }

  Widget xlrbtp({required double l, required double r, required double b, required double t}) {
    return Padding(
      padding: EdgeInsets.only(left: l, right: r, bottom: b, top: t),
      child: this,
    );
  }

  Widget xhp({required double value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  Widget xvp({required double value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  Widget xhvp({required double h, required double v}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
      child: this,
    );
  }
}
