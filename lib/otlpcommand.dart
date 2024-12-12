
import 'dart:async';

import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart';


Future<int> calculate() async {
  final exporter = CollectorExporter(Uri.parse('http://localhost:9411/api/v2/spans')); 
  print('exporter: $exporter');
  final processor = SimpleSpanProcessor(exporter);
  final provider = TracerProviderBase(processors: [processor]);
  print("provider: $provider");

  final tracer = provider.getTracer('seankang-otlp-sample-name');
      var context = Context.current;

  // A trace starts with a root span which has no parent.
    final parentSpan = tracer.startSpan('parent-span');
    print("parentSpan: $parentSpan");
  // A new context can be created in order to propagate context manually.
    context = contextWithSpan(context, parentSpan);
    print("context: $context");

    // The [traceContext] and [traceContextSync] functions will automatically
    // propagate context, capture errors, and end the span.
    await traceContext('child-span', (_) {
      print("child-span");
        tracer.startSpan('grandchild-span').end();
        print("grandchild-span");
        return Future.delayed(Duration(milliseconds: 100));
    }, context: context, tracer: tracer);

  // Spans must be ended or they will not be exported.
  parentSpan.end();
  return 6 * 7;
}