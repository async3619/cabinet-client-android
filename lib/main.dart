import 'package:cabinet/routes/home/main.dart';
import 'package:cabinet/routes/no_server_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'entities/object_box.dart';
import 'entities/thread_read_status.dart';
import 'models/config.dart';
import 'models/thread.dart';

void main() async {
  await initHiveForFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  final objectBox = await ObjectBox.create();

  final configModel = ConfigModel();
  final threadModel = ThreadModel(
    readStatusBox: objectBox.store.box<ThreadReadStatus>(),
  );

  await configModel.initialize();
  await threadModel.initialize();

  final app = const MyApp();
  ValueNotifier<GraphQLClient>? client;
  if (configModel.serverUrl != null) {
    final HttpLink httpLink = HttpLink(configModel.serverUrl!);
    client = ValueNotifier(
      GraphQLClient(link: httpLink, cache: GraphQLCache(store: HiveStore())),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ConfigModel>(create: (_) => configModel),
        ChangeNotifierProvider<ThreadModel>(create: (_) => threadModel),
      ],
      child: client == null ? app : GraphQLProvider(client: client, child: app),
    ),
  );
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    GraphQLClient? client;
    try {
      client = GraphQLProvider.of(context).value;
    } catch (_) {}

    return MaterialApp(
      title: 'Cabinet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: false,
      ),
      home: client == null ? const NoServerUrlRoute() : const HomeRoute(),
    );
  }
}
