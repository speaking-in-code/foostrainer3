

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

String _getWhyFailed(Element element, Pattern label) {
  if (element is! RenderObjectElement) {
    return 'Not RenderObjectElement';
  }
  final String? semanticsLabel = element.renderObject.debugSemantics?.label;
  if (semanticsLabel == null) {
    return 'Null Semantics Label';
  }
  if (label is RegExp) {
    if (label.hasMatch(semanticsLabel)) {
      return 'Matched RegExp';
    }
    return 'Ummatched RegExp';
  }
  if (label == semanticsLabel) {
    return 'Matched other';
  }
  return 'Unmatched ${label.runtimeType} [$label] != ${semanticsLabel.runtimeType} [$semanticsLabel]';
}

void debugDump(WidgetTester tester, String label, {Finder? finder}) {
  for (final el in tester.allElements) {
    final widget = el.widget;
    final extra = <String>[];
    if (widget is Semantics) {
      extra.add('semantics_label=${widget.properties.label}');
    }
    if (widget is Text) {
      extra.add('text=${widget.data}');
    }
    if (widget.key != null) {
      extra.add('key=${widget.key}');
    }
    if (finder != null) {
      bool matches = finder.apply([el]).isNotEmpty;
      extra.add('finder_match=$matches');
    }
    String info = extra.join(', ');
    print('BEE debugDump $label info=$info, $widget');
  }
}