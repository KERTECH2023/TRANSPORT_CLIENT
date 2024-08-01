
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class DriverCancelMessageDialog extends StatefulWidget {
  const DriverCancelMessageDialog({super.key});

  @override
  State<DriverCancelMessageDialog> createState() => _DriverCancelMessageDialogState();
}
class _DriverCancelMessageDialogState extends State<DriverCancelMessageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
      ),
      backgroundColor: Colors.black,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6)
        ),

        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text(
               AppLocalizations.of(context)!.tripMessage,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black
                ),
              ),

              const SizedBox(height: 30),

               Text(
                AppLocalizations.of(context)!.driverhascancelledyourtrip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),

              const SizedBox(height: 20),

               Text(
                 AppLocalizations.of(context)!.rideStatusCancelled,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black
                ),
              ),
              const SizedBox(height: 40),

              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.black,
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/main_screen');
                    
                  },

                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0 , 177 , 118, 1)
                  ),

                  child:  Text(
                    AppLocalizations.of(context)!.submit,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              )

            ],
          ),
        ),

      ),
    );
  }
}
