import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store3/widgets/test10.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  double _width = 50;
  double _height = 50;
  Color _color = Colors.green;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      height: _expanded? min(widget.order.products.length * 20.0 + 110, 200):200  ,

      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(widget.order.dateTime),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                    final random = Random();

                    // Generate a random width and height.
                    _width = random.nextInt(500).toDouble();
                    _height = random.nextInt(50).toDouble();

                    // Generate a random color.
                    _color = Color.fromRGBO(
                      random.nextInt(256),
                      random.nextInt(256),
                      random.nextInt(256),
                      1,
                    );

                    // Generate a random border radius.
                    _borderRadius =
                        BorderRadius.circular(random.nextInt(100).toDouble());
                  });
                },
              ),
            ),
              AnimatedContainer(
                //  width: _width,
                decoration: BoxDecoration(
                  color: _color,
                 // borderRadius: _borderRadius,
                ),
                duration: Duration(seconds: 2),
                // Provide an optional curve to make the animation feel smoother.
                curve: Curves.fastOutSlowIn,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded ? min(widget.order.products.length * 20.0 + 10, 100) : 0,
                child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity}x \$${prod.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            // FloatingActionButton(
            //    // When the user taps the button
            //    onPressed: () {
            //      // Use setState to rebuild the widget with new values.
            //      setState(() {
            //        // Create a random number generator.
            //        final random = Random();
            //
            //        // Generate a random width and height.
            //        _width = random.nextInt(50).toDouble();
            //        _height = random.nextInt(50).toDouble();
            //
            //        // Generate a random color.
            //        _color = Color.fromRGBO(
            //          random.nextInt(256),
            //          random.nextInt(256),
            //          random.nextInt(256),
            //          1,
            //        );
            //
            //        // Generate a random border radius.
            //        _borderRadius =
            //            BorderRadius.circular(random.nextInt(100).toDouble());
            //      });
            //    },
            //    child: Icon(Icons.play_arrow),
            //  ),
          ],
        ),
      ),
    );
  }
}
