import 'dart:convert';
import 'package:api_integration/login/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/users"));
      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(int id, int index) async {
    // 1. Tell the server to delete
    final response = await http.delete(
      Uri.parse("https://jsonplaceholder.typicode.com/users/$id"),
    );

    if (response.statusCode == 200) {
      // 2. Remove from local list so the UI updates
      setState(() {
        users.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Deleted")));
    }
  }


  Future<void> updateUser(int id, int index, String newName, String newEmail) async {
    final response = await http.put(
      Uri.parse("https://jsonplaceholder.typicode.com/users/$id"),
      body: jsonEncode({"name": newName,"email": newEmail,}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Update local UI
      setState(() {
        users[index]['name'] = newName;
        users[index]['email'] = newEmail;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Updated")));
    }
  }

  void showUpdateDialog(int id, int index, String currentName, String currentEmail) {
  // Initialize controllers with the current values
  TextEditingController nameController = TextEditingController(text: currentName);
  TextEditingController emailController = TextEditingController(text: currentEmail);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit User Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Keeps the dialog small
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Full Name"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email Address"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // Pass both values to our update function
            updateUser(id, index, nameController.text, emailController.text);
            Navigator.pop(context);
          },
          child: const Text("Update"),
        )
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Catch the data coming back from Login
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
              );

              // If result isn't null, update the list manually
              if (result != null) {
                setState(() {
                  // We create a map that matches the UI expectations
                  users.insert(0, {
                    "id": result['id'],
                    "name": result['email'].split('@')[0], // Using part of email as a name
                    "email": result['email'],
                  });
                });
              }
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user['name'][0].toUpperCase())),
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => showUpdateDialog(user['id'], index, user['name'],user['email'],),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteUser(user['id'], index),
                      ),

                    ],
                  ),
                );
              },
            ),
    );
  }
}