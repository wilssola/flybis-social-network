import 'dart:typed_data';

import '../filters/filters.dart';

///The [ImageSubFilter] class is the abstract class to define any ImageSubFilter.
mixin ImageSubFilter on SubFilter {
  ///Apply the [SubFilter] to an Image.
  void apply(Uint8List pixels);
}

class ImageFilter extends Filter {
  List<ImageSubFilter> subFilters;

  ImageFilter({String name})
      : subFilters = [],
        super(name: name);

  ///Apply the [SubFilter] to an Image.
  @override
  void apply(Uint8List pixels) {
    for (ImageSubFilter subFilter in subFilters) {
      subFilter.apply(pixels);
    }
  }
}
