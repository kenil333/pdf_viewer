import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:simple_permissions/simple_permissions.dart';

import './screenOne.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var files;
  bool _gridvisible = false;
  bool _fileLengthAvailable = false;
  bool _readPermissions;
  bool _writePermission;

  void checkPermissionAndGetFile() async {
    bool rp =
        await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    bool wp = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    setState(() {
      _readPermissions = rp;
      _writePermission = wp;
    });
    if (_readPermissions && _writePermission) {
      getFiles();
    } else {
      if (!_readPermissions) {
        await SimplePermissions.requestPermission(
            Permission.ReadExternalStorage);
      }
      if (!_writePermission) {
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
      }
      checkPermissionAndGetFile();
    }
  }

  void getFiles() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    String root = storageInfo[0].rootDir;
    FileManager fm = FileManager(root: Directory(root));
    files = await fm.filesTree(
      excludedPaths: ["/storage/emulated/0/Android"],
      extensions: ["pdf"],
    );
    setState(() {
      _gridvisible = true;
      if (files.length != 0) {
        _fileLengthAvailable = true;
      }
    });
  }

  @override
  void initState() {
    checkPermissionAndGetFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(),
        preferredSize: Size.fromHeight(0),
      ),
      body: _gridvisible
          ? _fileLengthAvailable
              ? GridView.builder(
                  padding:
                      EdgeInsets.only(top: 15, bottom: 20, left: 15, right: 15),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    childAspectRatio: 3 / 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: files.length,
                  itemBuilder: (ctx, i) => InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ScreenOne(files[i].path.toString()),
                        ),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 20,
                            color: Color(0xFF305F72).withOpacity(0.23),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.red,
                            size: 40,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                files[i].path.split('/').last,
                                style: TextStyle(
                                  color: Color(0xFF305F72),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'Files Not Found !!!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF305F72),
                    ),
                  ),
                )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFF305F72),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
