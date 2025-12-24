import 'package:flutter/material.dart';
import 'package:mech_pos/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> fetchProfile() async {
    try {
      final data = await ApiClient.get("restaurant.php");

      if (data["status"] == true && data["data"] != null) {
        nameController.text = data["data"]["name"] ?? "";
        addressController.text = data["data"]["address"] ?? "";
        phoneController.text = data["data"]["phone"] ?? "";
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> saveProfile() async {
    try {
      final data = await ApiClient.put("restaurant.php", {
        "name": nameController.text.trim(),
        "address": addressController.text.trim(),
        "phone": phoneController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"])));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Restaurant Name",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Address"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loading ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
