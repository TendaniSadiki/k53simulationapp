import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TestRequirementsScreen extends StatelessWidget {
  const TestRequirementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Requirements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '📋 IMPORTANT INFORMATION',
              children: [
                _buildInfoCard(
                  icon: Icons.info,
                  title: 'Booking Requirements',
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ID'),
                      Text('• Glasses if you wear'),
                      Text('• Black pen'),
                      Text('• Proof of address'),
                    ],
                  ),
                ),
                _buildInfoCard(
                  icon: Icons.account_balance,
                  title: 'Proof of Address Options',
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✅ Account in your name that displays your physical address'),
                      Text('   (like a bank statement) not older than 3 months'),
                      SizedBox(height: 8),
                      Text('📋 IF YOU DON\'T HAVE SUCH AN ACCOUNT THEN:'),
                      Text('• An account that displays physical address'),
                      Text('• Certified copy of account holder ID'),
                      Text('• Affidavit from the account holder confirming you stay there'),
                      Text('• MUST BE DONE BY SAP'),
                    ],
                  ),
                ),
                _buildInfoCard(
                  icon: Icons.event,
                  title: 'Test Day Requirements',
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ID'),
                      Text('• Booking confirmation'),
                      Text('• Photos (taken on the booking day)'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '💡 Additional Tips',
              children: [
                _buildTipCard(
                  'Arrive at least 30 minutes early for your test',
                ),
                _buildTipCard(
                  'Make sure all documents are original and valid',
                ),
                _buildTipCard(
                  'Dress comfortably and appropriately',
                ),
                _buildTipCard(
                  'Get a good night\'s sleep before your test',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required Widget content}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}