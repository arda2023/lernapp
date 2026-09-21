import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Every row in the database gets a client-generated UUID v4 primary key.
String newId() => _uuid.v4();
