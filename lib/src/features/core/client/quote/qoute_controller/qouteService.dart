import 'package:flutter/foundation.dart';
import 'package:innolab/src/features/core/client/quote/screens/user_quote_screen.dart';






class QuoteService{

  static void processQouteRequest(List<QuoteItem> items){

    if(items.isEmpty){
      if(kDebugMode) print('Attempt to submit an empty qoute');
      return;
    }

    print('Total Items: ${items.length}');

    for(var i = 0; i < items.length; i++){
      final item = items[i];
      print("Item #${i + 1}:");
      print("  - ID: ${item.id}");
      print("  - Material: ${item.material.name}");
      print("  - Weight: ${item.grams}g");
      print("  - Print Time: ${item.hours}h");
      print("  - Quantity: ${item.quantity}");
      print("  - Finish: ${item.selectedFinish ?? 'None'}");
      print("  - Tolerance: ${item.selectedTolerance ?? 'Standard'}");
      print("  - Layer Height: ${item.selectedLayer ?? 'Standard'}");
      print("  - Calculated Item Total: ₱${item.totalCost.toStringAsFixed(2)}");
      print("-----------------------------------");
    }

    double grandTotal = items.fold(0, (sum, item) => sum + item.totalCost);
    print("Total: ₱${grandTotal.toStringAsFixed(2)}");
    
  }
}



