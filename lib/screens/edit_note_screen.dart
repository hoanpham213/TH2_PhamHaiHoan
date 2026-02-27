import 'package:flutter/material.dart';
import '../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  EditNoteScreen({required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleCtl;
  late TextEditingController _contentCtl;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.note.title);
    _contentCtl = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _contentCtl.dispose();
    super.dispose();
  }

  void _autoSave() {
    final title = _titleCtl.text.trim();
    final content = _contentCtl.text.trim();

    final updated = Note(
      id: widget.note.id,
      title: title.isEmpty ? 'Không có tiêu đề' : title,
      content: content,
      createdAt: widget.note.createdAt,
      updatedAt: DateTime.now(),
    );
    Navigator.pop(context, updated);
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text('Xóa ghi chú?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actionsPadding: EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      Navigator.pop(context, 'delete:${widget.note.id}');
    }
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
          title: Text('Sửa ghi chú',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _autoSave,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline, size: 24),
              onPressed: _confirmDelete,
              tooltip: 'Xóa ghi chú',
              color: Colors.red.shade200,
            ),
            SizedBox(width: 8),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0F4FF), Color(0xFFFFE8F0)],
            ),
          ),
          child: SingleChildScrollView(
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
                    'Tạo: ${widget.note.createdAt.day}/${widget.note.createdAt.month}/${widget.note.createdAt.year} ${widget.note.createdAt.hour}:${widget.note.createdAt.minute.toString().padLeft(2, '0')} | Sửa: ${widget.note.updatedAt.day}/${widget.note.updatedAt.month}/${widget.note.updatedAt.year} ${widget.note.updatedAt.hour}:${widget.note.updatedAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Nội dung - Không viền, multiline
                  TextField(
                    controller: _contentCtl,
                    decoration: InputDecoration(
                      hintText: 'Nội dung ghi chú...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
