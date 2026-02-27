import 'package:flutter/material.dart';
import '../models/note.dart';

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleCtl = TextEditingController();
  final _contentCtl = TextEditingController();

  @override
  void dispose() {
    _titleCtl.dispose();
    _contentCtl.dispose();
    super.dispose();
  }

  void _autoSave() {
    final title = _titleCtl.text.trim();
    final content = _contentCtl.text.trim();

    // Nếu cả tiêu đề và nội dung đều trống thì không lưu
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Không có tiêu đề' : title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _autoSave();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ghi chú mới',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _autoSave,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F4FF), Color(0xFFFFE8F0)],
            ),
          ),
          // don't wrap the column in a scroll view; the Expanded below needs a
          // bounded height.  the previous layout placed an Expanded inside a
          // SingleChildScrollView which provided infinite vertical space and
          // caused children to never be laid out.
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề - Không viền, như tờ giấy trắng
                TextField(
                  controller: _titleCtl,
                  decoration: InputDecoration(
                    hintText: 'Tiêu đề',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Mới tạo lúc: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 24),
                // Nội dung - Không viền, multiline
                Expanded(
                  child: TextField(
                    controller: _contentCtl,
                    decoration: InputDecoration(
                      hintText: 'Bắt đầu nhập nội dung ghi chú...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    expands: true,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
