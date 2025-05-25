import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class QRGenerator {
  /// Generate a QR code with gym and member data
  static Widget generateQRCode({
    required String gymId,
    String? memberId,
    required String gymName,
    String? memberName,
    required double size,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
    String? logoPath,
    Widget? logo,
  }) {
    // Create data for QR code - we'll use JSON for structured data
    final Map<String, dynamic> qrData = {
      'gym_id': gymId,
      'gym_name': gymName,
      'type': memberId != null ? 'member' : 'gym',
    };

    // Add member data if available
    if (memberId != null) {
      qrData['member_id'] = memberId;
      if (memberName != null) {
        qrData['member_name'] = memberName;
      }
    }

    // Convert data to JSON string
    final String jsonData = jsonEncode(qrData);

    return QrImageView(
      data: jsonData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      errorStateBuilder: (cxt, err) {
        return Container(
          width: size,
          height: size,
          color: backgroundColor,
          child: Center(
            child: Text(
              'Error generating QR code',
              style: TextStyle(color: foregroundColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      embeddedImage: logoPath != null ? AssetImage(logoPath) : null,
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size(size * 0.2, size * 0.2),
      ),
      embeddedImageEmitsError: false,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
    );
  }

  /// Generate a branded QR code card with gym information
  static Widget generateGymQRCard({
    required String gymId,
    required String gymName,
    String? gymAddress,
    String? gymLogo,
    double width = 300,
  }) {
    final double qrSize = width * 0.7;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with gym info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Logo if available
                if (gymLogo != null && gymLogo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      gymLogo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                if (gymLogo != null && gymLogo.isNotEmpty)
                  const SizedBox(width: 12),

                // Gym name and address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gymName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (gymAddress != null && gymAddress.isNotEmpty)
                        Text(
                          gymAddress,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // QR Code
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: generateQRCode(
                gymId: gymId,
                gymName: gymName,
                size: qrSize,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Scan to join',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan this code with your GYMNEX app to register at $gymName',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Generate a member QR code card for check-ins
  static Widget generateMemberQRCard({
    required String gymId,
    required String memberId,
    required String gymName,
    required String memberName,
    String? membershipType,
    String? memberPhoto,
    double width = 300,
  }) {
    final double qrSize = width * 0.6;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with member info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Member photo
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage:
                      memberPhoto != null && memberPhoto.isNotEmpty
                          ? NetworkImage(memberPhoto)
                          : null,
                  child:
                      memberPhoto == null || memberPhoto.isEmpty
                          ? Text(
                            memberName.isNotEmpty
                                ? memberName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 16),

                // Member name and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gymName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (membershipType != null && membershipType.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            membershipType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // QR Code
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: generateQRCode(
                gymId: gymId,
                memberId: memberId,
                gymName: gymName,
                memberName: memberName,
                size: qrSize,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Scan for Check-in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Member ID: $memberId',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Share QR code
  static Future<void> shareQRCode(GlobalKey qrKey, String fileName) async {
    try {
      // Capture QR code as image
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final buffer = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${fileName}_qr.png');
      await file.writeAsBytes(buffer);

      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'GYMNEX QR Code');
    } catch (e) {
      print('Error sharing QR code: $e');
    }
  }
}
