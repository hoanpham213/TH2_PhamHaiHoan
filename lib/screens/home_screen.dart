import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  String searchQuery = '';
  late SharedPreferences prefs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    final jsonString = prefs.getString('notes') ?? '';
    setState(() {
      notes = Note.listFromJsonString(jsonString);
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      filteredNotes = notes;
      isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    await prefs.setString('notes', Note.listToJsonString(notes));
  }

  void _filterNotes(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredNotes = notes;
      } else {
        filteredNotes = notes
            .where((note) => note.title.toLowerCase().contains(searchQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Smart Note',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Phạm Hải Hoàn - 2251172350',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: TextField(
              onChanged: _filterNotes,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // List of Notes
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_outlined,
                            size: 80, color: Colors.grey.shade300),
                        SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'Bạn chưa có ghi chú nào,\nhãy tạo mới nhé!'
                              : 'Không tìm thấy ghi chú nào',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF0F4FF), Color(0xFFFFE8F0)],
                      ),
                    ),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      padding: EdgeInsets.all(16),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return _buildNoteCard(note, index);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            _createRoute(AddNoteScreen()),
          );
          if (newNote is Note) {
            setState(() {
              notes.insert(0, newNote);
              filteredNotes = notes;
            });
            await _saveNotes();
          }
        },
        icon: Icon(Icons.add),
        label: Text('Thêm'),
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Xóa ghi chú?',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
      },
      onDismissed: (_) async {
        setState(() => filteredNotes.removeAt(index));
        notes.removeWhere((n) => n.id == note.id);
        await _saveNotes();
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            _createRoute(EditNoteScreen(note: Note.copy(note))),
          );
          if (result is Note) {
            final idx = notes.indexWhere((n) => n.id == result.id);
            if (idx != -1) {
              setState(() {
                notes[idx] = result;
                notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                _filterNotes(searchQuery);
              });
              await _saveNotes();
            }
          } else if (result is String && result.startsWith('delete:')) {
            final noteId = result.substring(7); // remove 'delete:' prefix
            setState(() {
              notes.removeWhere((n) => n.id == noteId);
              _filterNotes(searchQuery);
            });
            await _saveNotes();
          }
        },
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCardColor(index),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note.title.isEmpty ? 'Không có tiêu đề' : note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '${note.updatedAt.day.toString().padLeft(2, '0')}/${note.updatedAt.month.toString().padLeft(2, '0')}/${note.updatedAt.year} ${note.updatedAt.hour.toString().padLeft(2, '0')}:${note.updatedAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCardColor(int index) {
    final colors = [
      Color(0xFFFFE8E8),
      Color(0xFFE8F5FF),
      Color(0xFFE8FFF8),
      Color(0xFFFFF8E8),
    ];
    return colors[index % colors.length];
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(
          begin: Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: Duration(milliseconds: 350),
      reverseTransitionDuration: Duration(milliseconds: 250),
    );
  }
}
