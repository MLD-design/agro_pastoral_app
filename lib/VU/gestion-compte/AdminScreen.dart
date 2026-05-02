import 'package:flutter/material.dart';
import '../../models/gestion-compte/modeluser.dart';
import '../../services/gestion-compte/servicesusers.dart';
import './users_page.dart';


class AdminScreen extends StatefulWidget {
  final User user;
  AdminScreen({required this.user});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<User> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final users = await UserService().listUsers(widget.user.token);
    setState(() { _users = users.cast<User>(); _loading = false; });
  }

  void _deleteUser(int id) async {
    final ok = await UserService().deleteUser(widget.user.token, id);
    if (ok) _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des comptes")),
      body: _loading ? Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u = _users[i];
          return ListTile(
            title: Text("${u.username} (${u.role})"),
            subtitle: Text("Exploitation: ${u.code_expl}"),
            trailing: IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteUser(u.id)),
            onTap: () {
              // TODO: ouvrir un écran de modification
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreateUserScreen(admin: widget.user))).then((_) => _loadUsers());
        },
      ),
    );
  }
}
