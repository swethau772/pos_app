import 'package:flutter/material.dart';

void main() => runApp(const POSApp());

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Billing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'title': 'Sales Bill', 'icon': Icons.receipt_long, 'page': const BillingScreen(docType: 'Sales Bill')},
      {'title': 'Inventory & QR', 'icon': Icons.qr_code_scanner, 'page': const InventoryScreen()},
      {'title': 'Quotation', 'icon': Icons.request_quote, 'page': const BillingScreen(docType: 'Quotation')},
      {'title': 'Delivery Challan', 'icon': Icons.local_shipping, 'page': const BillingScreen(docType: 'Delivery Challan')},
      {'title': 'Customer Ledger', 'icon': Icons.account_balance_wallet, 'page': const LedgerScreen()},
      {'title': 'Sales Summary', 'icon': Icons.bar_chart, 'page': const LedgerScreen()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('POS Billing Software'), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['page'] as Widget),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData, size: 44, color: Colors.indigo),
                  const SizedBox(height: 10),
                  Text(item['title'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BillingScreen extends StatefulWidget {
  final String docType;
  const BillingScreen({super.key, required this.docType});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final List<Map<String, dynamic>> _cart = [];
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _receivedCtrl = TextEditingController(text: '0');
  String _paymentMode = 'Cash';

  double get _total => _cart.fold(0, (sum, item) => sum + (item['price'] as double));
  double get _received => double.tryParse(_receivedCtrl.text) ?? 0;
  double get _balance => _total - _received;

  void _addItem() {
    final price = double.tryParse(_priceCtrl.text);
    if (_nameCtrl.text.isNotEmpty && price != null) {
      setState(() {
        _cart.add({'name': _nameCtrl.text, 'price': price});
        _nameCtrl.clear();
        _priceCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.docType)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Item / Barcode'))),
                const SizedBox(width: 8),
                SizedBox(width: 95, child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price'))),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.indigo, size: 32), onPressed: _addItem),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Add items or scan barcode to start'))
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(_cart[i]['name']),
                        trailing: Text('₹${_cart[i]['price'].toStringAsFixed(2)}'),
                      ),
                    ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment:', style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Cash', label: Text('Cash')),
                    ButtonSegment(value: 'UPI', label: Text('UPI')),
                  ],
                  selected: {_paymentMode},
                  onSelectionChanged: (val) => setState(() => _paymentMode = val.first),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _receivedCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Received Amount (₹)', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ₹${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('Balance: ₹${_balance.toStringAsFixed(2)}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _balance > 0 ? Colors.red : Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Map<String, String>> _items = [];
  final _itemCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory & Barcode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _itemCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'Barcode / QR Number')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_itemCtrl.text.isNotEmpty) {
                  setState(() {
                    _items.add({'name': _itemCtrl.text, 'code': _codeCtrl.text});
                    _itemCtrl.clear();
                    _codeCtrl.clear();
                  });
                }
              },
              child: const Text('Save to Inventory'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(_items[i]['name']!),
                  subtitle: Text('Code: ${_items[i]['code']}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Ledger')),
      body: const Center(child: Text('Pending balances from bills appear here.')),
    );
  }
}
