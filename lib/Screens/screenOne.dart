import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share/share.dart';

class ScreenOne extends StatefulWidget {
  final String path;
  ScreenOne(this.path);
  @override
  _ScreenOneState createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  PdfViewerController _pdfViewerController;
  PdfTextSearchResult _searchResult;
  OverlayEntry _overlayEntry;
  bool _isSearchbarVisible = false;
  TextEditingController _searchingText = TextEditingController();

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion.center.dy - 55,
        left: details.globalSelectedRegion.bottomLeft.dx,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            elevation: 10,
          ),
          child: Text('Copy', style: TextStyle(fontSize: 17)),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: details.selectedText));
            print('Text copied to clipboard: ' + details.selectedText);
            _pdfViewerController.clearSelection();
          },
        ),
      ),
    );
    _overlayState.insert(_overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(),
        preferredSize: Size.fromHeight(0),
      ),
      body: Column(
        children: [
          _isSearchbarVisible
              ? Container(
                  padding: EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 10,
                    right: 5,
                  ),
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
                  width: size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(right: 20),
                          child: TextField(
                            controller: _searchingText,
                            style: TextStyle(
                              color: Color(0xFF305F72),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () async {
                              _searchResult = await _pdfViewerController
                                  ?.searchText(_searchingText.text);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_rounded,
                            ),
                            onPressed: () {
                              _searchResult.previousInstance();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios_rounded,
                            ),
                            onPressed: () {
                              _searchResult.nextInstance();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : SizedBox(),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: SfPdfViewer.file(
                File(widget.path),
                controller: _pdfViewerController,
                searchTextHighlightColor: Colors.lightBlue,
                enableTextSelection: true,
                onTextSelectionChanged:
                    (PdfTextSelectionChangedDetails details) {
                  if (details.selectedText == null && _overlayEntry != null) {
                    _overlayEntry.remove();
                    _overlayEntry = null;
                  } else if (details.selectedText != null &&
                      _overlayEntry == null) {
                    setState(() {
                      _showContextMenu(context, details);
                    });
                  }
                },
              ),
            ),
          ),
          Container(
            height: size.height * 0.06,
            width: size.width,
            color: Colors.red,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Share.shareFiles([widget.path]);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isSearchbarVisible)
                        _isSearchbarVisible = false;
                      else
                        _isSearchbarVisible = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
