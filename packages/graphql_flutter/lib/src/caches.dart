import 'dart:async' show FutureOr;

import 'package:meta/meta.dart';
import 'mobile_storage.dart' if (dart.library.html) 'web_storage.dart';
// import 'package:path_provider/path_provider.dart'
//    show getApplicationDocumentsDirectory;

import 'package:graphql/client.dart' as client;

final FutureOr<String> flutterStoragePrefix = plattformStorage.prefix(); 

class InMemoryCache extends client.InMemoryCache {
  InMemoryCache({
    FutureOr<String> storagePrefix,
  }) : super(storagePrefix: storagePrefix ?? flutterStoragePrefix);
}

class NormalizedInMemoryCache extends client.NormalizedInMemoryCache {
  NormalizedInMemoryCache({
    @required client.DataIdFromObject dataIdFromObject,
    String prefix = '@cache/reference',
  }) : super(
          dataIdFromObject: dataIdFromObject,
          prefix: prefix,
          storagePrefix: flutterStoragePrefix,
        );
}

class OptimisticCache extends client.OptimisticCache {
  OptimisticCache({
    @required client.DataIdFromObject dataIdFromObject,
    String prefix = '@cache/reference',
  }) : super(
          dataIdFromObject: dataIdFromObject,
          prefix: prefix,
          storagePrefix: flutterStoragePrefix,
        );
}
