import 'package:flutter/material.dart';

class ButtonContainer extends StatefulWidget {
  const ButtonContainer({super.key});

  @override
  State<ButtonContainer> createState() => _ButtonContainerState();
}

class _ButtonContainerState extends State<ButtonContainer> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: 90,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Departure'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        minimumSize: Size(double.infinity, 70)
                    )

                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: OutlinedButton(
                    onPressed: () {},
                    child: Text('Case Close'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        minimumSize: Size(double.infinity, 70)
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
