import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart/controllers/product_provider.dart';
import 'package:shopping_cart/view/product_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return Builder(builder: (BuildContext context){
     return MultiProvider(
       providers: [
         ChangeNotifierProvider(create: (_) => ProductProvider()),
       ],
       child: MaterialApp(
         title: 'Flutter Demo',
         debugShowCheckedModeBanner: false,
         theme: ThemeData(
           primarySwatch: Colors.blue,
         ),
         home: const ProductListScreen(),
       ),
     );
   });
  }
}

