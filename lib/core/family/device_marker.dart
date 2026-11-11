import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Where this device keeps a copy of its family device id, out of reach of
/// Android backup and phone-to-phone transfer (`res/xml/*backup*`). When the
/// database says one id and the marker another (or nothing), the database
/// is a copy from another device and gets an id of its own.
abstract interface class DeviceMarker {
  Future<String?> read();

  Future<void> write(String id);
}

/// `files/family_device`, excluded from every backup.
class FileDeviceMarker implements DeviceMarker {
  const FileDeviceMarker();

  static const fileName = 'family_device';

  Future<File> _file() async => File('${(await getApplicationSupportDirectory()).path}/$fileName');

  @override
  Future<String?> read() async {
    try {
      final file = await _file();
      return await file.exists() ? (await file.readAsString()).trim() : null;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<void> write(String id) async {
    try {
      await (await _file()).writeAsString(id, flush: true);
    } on FileSystemException {
      // Without the marker the device simply keeps its id.
    }
  }
}
