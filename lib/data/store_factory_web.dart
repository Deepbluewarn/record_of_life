// ignore: unnecessary_import
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

Future<Database> openAppDatabase() =>
    databaseFactoryWeb.openDatabase('record_of_life.db');
