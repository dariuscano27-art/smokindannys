import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smokin Dannys Terms & Conditions', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Smokin Dannys BBQ & Grill. By creating an account, placing an order, or using our Android POS system, you agree to comply with and be bound by the following terms and conditions.\n\n'
              '1. Account Security: You are responsible for maintaining the confidentiality of your account credentials and password.\n\n'
              '2. Ordering & Pricing: All prices are listed in Philippine Pesos (₱) and include applicable taxes and service charges as configured by the restaurant. The backend validates final pricing during checkout.\n\n'
              '3. Payments: Cash on delivery/pickup, POS cash, and verified electronic payments (GCash/QR Ph) are supported according to business rules.\n\n'
              '4. Privacy Policy: We collect and secure your profile data, delivery addresses, and order history strictly for food ordering and restaurant fulfillment operations.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I Understand'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
