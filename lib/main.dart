import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sayfalar/giris_sayfasi.dart';
import 'state/user_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider( 
      create: (_) => UserState(),
      child: const KampusUygulamasi(),
    ),
  );
}

class KampusUygulamasi extends StatelessWidget {
  const KampusUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {  
    return MaterialApp(
      title: 'KKÜ BUL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GirisSayfasi(),
    );
  }
}
