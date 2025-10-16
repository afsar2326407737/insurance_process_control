import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

class ReportDialog extends StatelessWidget {
  final String employeeId;
  final String createdAt;
  final List<String> mediaPaths;
  final Uint8List signature;

  const ReportDialog({
    super.key,
    required this.employeeId,
    required this.createdAt,
    required this.mediaPaths,
    required this.signature,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  'Completion Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Employee Info
              Text('Employee ID: $employeeId',
                  style: const TextStyle(fontSize: 16)),
              Text('Created At: $createdAt',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              // Proof Media
              const Text(
                'Proof Media:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              mediaPaths.isNotEmpty
                  ? SizedBox(
                height: 120,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: mediaPaths.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(mediaPaths[index]),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              )
                  : const Text('No media available'),
              const SizedBox(height: 16),

              // Signature
              const Text(
                'Signature:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              signature.isNotEmpty
                  ? Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.memory(
                    signature,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              )
                  : const Text('No signature available'),

              const SizedBox(height: 16),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
