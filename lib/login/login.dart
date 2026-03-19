import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;

  Future<void> logins() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
        body: jsonEncode({"email": email.text, "password": password.text}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // This is the "Delivery Truck" that carries data back to UserScreen
        Navigator.pop(context, data); 
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(hintText: "Email")),
            TextField(controller: password, decoration: const InputDecoration(hintText: "Password")),
            const SizedBox(height: 20),
            isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: logins, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}