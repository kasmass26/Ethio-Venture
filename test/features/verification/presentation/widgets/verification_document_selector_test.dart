import 'dart:typed_data';

import 'package:ethioventure/features/verification/presentation/widgets/verification_document_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PlatformFile file({
    required String name,
    required String extension,
    int size = 100,
  }) {
    return PlatformFile(
      name: name,
      size: size,
      bytes: Uint8List.fromList(List<int>.filled(size, 1)),
    );
  }

  test('accepts JPG, PNG, and PDF files within the size limit', () {
    for (final extension in const ['jpg', 'png', 'pdf']) {
      expect(
        VerificationDocumentValidator.validate(
          file(name: 'proof.$extension', extension: extension),
        ),
        isNull,
      );
    }

    expect(
      VerificationDocumentValidator.validate(
        file(
          name: 'limit.pdf',
          extension: 'pdf',
          size: VerificationDocumentValidator.maxFileSizeBytes,
        ),
      ),
      isNull,
    );
  });

  test('rejects unsupported extensions, empty files, and oversized files', () {
    expect(
      VerificationDocumentValidator.validate(
        file(name: 'proof.docx', extension: 'docx'),
      ),
      'Choose a JPG, PNG, or PDF file.',
    );

    expect(
      VerificationDocumentValidator.validate(
        file(name: 'empty.pdf', extension: 'pdf', size: 0),
      ),
      'The selected file is empty.',
    );

    expect(
      VerificationDocumentValidator.validate(
        file(
          name: 'large.pdf',
          extension: 'pdf',
          size: VerificationDocumentValidator.maxFileSizeBytes + 1,
        ),
      ),
      'The selected file must be 10 MB or smaller.',
    );
  });
}
