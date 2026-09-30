import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/reservation.dart';
import '../../services/reservation_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() =>
      _QrScannerScreenState();
}

class _QrScannerScreenState
    extends State<QrScannerScreen> {

  final MobileScannerController scannerController =
      MobileScannerController();

  bool isProcessing = false;

  Future<void> handleQrCode(String code) async {
    if (isProcessing) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    final reservation = await ReservationService.findByCode(code);

    if (!mounted) return;

    if (reservation == null) {
      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'رمز QR غير صحيح أو الحجز غير موجود',
          ),
        ),
      );

      return;
    }

    scannerController.stop();

    _showReservationDialog(reservation);
  }

  void _showReservationDialog(
    Reservation reservation,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isCompleted =
            reservation.status ==
                ReservationStatus.completed;

        return AlertDialog(
          title: Text(
            isCompleted
                ? 'الحجز مكتمل'
                : 'تم العثور على الحجز ✓',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'الوجبة: ${reservation.mealName}',
              ),

              const SizedBox(height: 8),

              Text(
                'الكمية: ${reservation.quantity}',
              ),

              const SizedBox(height: 8),

              Text(
                'الرمز: ${reservation.code}',
              ),

              const SizedBox(height: 15),

              if (isCompleted)
                const Text(
                  'تم استلام هذا الحجز مسبقاً.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                const Text(
                  'هل تريد تأكيد استلام الحجز؟',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),

          actions: [
            if (!isCompleted)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  setState(() {
                    isProcessing = false;
                  });

                  scannerController.start();
                },
                child: const Text(
                  'إلغاء',
                ),
              ),

            if (!isCompleted)
              ElevatedButton(
                onPressed: () async {
                  final success =
                      await ReservationService.completeReservation(
                    reservation,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم تأكيد الاستلام بنجاح ✓',
                        ),
                      ),
                    );
                  }

                  Navigator.pop(context);
                },
                child: const Text(
                  'تأكيد الاستلام',
                ),
              ),

            if (isCompleted)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'إغلاق',
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مسح رمز QR',
        ),

        actions: [
          IconButton(
            onPressed: () {
              scannerController.toggleTorch();
            },
            icon: const Icon(
              Icons.flash_on,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,

            onDetect: (capture) {
              for (final barcode
                  in capture.barcodes) {

                final code =
                    barcode.rawValue;

                if (code != null &&
                    code.isNotEmpty) {
                  handleQrCode(code);
                  break;
                }
              }
            },
          ),

          Center(
            child: Container(
              width: 260,
              height: 260,

              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                ),
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),
          ),

          const Positioned(
            bottom: 50,
            left: 20,
            right: 20,

            child: Text(
              'وجّه الكاميرا نحو رمز QR الخاص بالحجز',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}