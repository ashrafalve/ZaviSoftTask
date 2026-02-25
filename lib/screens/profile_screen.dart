import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Color(0xFFFF6F00),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFF6F00).withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 50, color: Color(0xFFFF6F00)),
            ),
            SizedBox(height: 16),
            Text(
              'Demo User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'user@daraz.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            _buildMenuItem(context, icon: Icons.shopping_bag_outlined, title: 'My Orders', onTap: () => _showComingSoon(context)),
            _buildMenuItem(context, icon: Icons.favorite_outline, title: 'My Wishlist', onTap: () => _showComingSoon(context)),
            _buildMenuItem(context, icon: Icons.location_on_outlined, title: 'Shipping Addresses', onTap: () => _showComingSoon(context)),
            _buildMenuItem(context, icon: Icons.payment_outlined, title: 'Payment Methods', onTap: () => _showComingSoon(context)),
            _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Settings', onTap: () => _showComingSoon(context)),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFFF6F00)),
        title: Text(title),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coming soon!')));
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
    }
  }
}
