import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'data_function.dart';

class CustomInfoWindowWidget extends StatefulWidget {
  const CustomInfoWindowWidget(
      {super.key, required this.data, required this.controller});

  final dynamic data;
  final CustomInfoWindowController controller;

  @override
  State<CustomInfoWindowWidget> createState() => _CustomInfoWindowWidgetState();
}

class _CustomInfoWindowWidgetState extends State<CustomInfoWindowWidget> {

  String SetCaseStatus() {
    if(widget.data.departureTime[0] == '9')
      return 'Waiting';
    else
      return 'error';
  }

  @override
  void initState() {
    super.initState();
    print("ciw loaded");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1.5,
              blurRadius: 1.5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 5, top: 5),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      DataFunction.detailToString(widget.data.detail) ?? ''),
                  IconButton(
                    onPressed: () {
                      widget.controller.hideInfoWindow!();
                    },
                    icon: const Icon(Icons.close),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  )
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10),
              child: Text(
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  'Status: ' + SetCaseStatus()
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: Text('Clear'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        )
                    )
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(5)
                      )
                    )
                  )
                ],
              ),
            )
          ],
        ));
  }
}
