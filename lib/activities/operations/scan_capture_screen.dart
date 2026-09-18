import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/custom_toast.dart';
import '../../models/station.dart';
import '../../services/scan_api_service.dart';
import '../../utils/employee_names.dart';
import '../../utils/error_messages.dart';
import '../../utils/theme_tokens.dart';
import 'scan_review_screen.dart';
import 'scan_widgets.dart';

/// Works through one worker's book, one page at a time.
///
/// The worker is chosen once for the whole book because the pages carry only a signature, not a
/// printed name - identity comes from the book, not the page. Keeping it fixed here is what makes
/// scanning a fortnight of pages fast: photograph, check, save, repeat.
class ScanCaptureScreen extends StatefulWidget {
  final int employeeId;
  final String employeeName;
  final List<Station> stations;

  const ScanCaptureScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.stations,
  });

  @override
  State<ScanCaptureScreen> createState() => _ScanCaptureScreenState();
}

class _ScanCaptureScreenState extends State<ScanCaptureScreen> {
  final _apiService = ScanApiService();
  final _picker = ImagePicker();

  bool _isReading = false;
  int _pagesSaved = 0;
  int _entriesSaved = 0;

  Future<void> _capture(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      // Enough resolution to read cramped handwriting, small enough to upload quickly over a
      // phone connection. A modern camera's full-size image is several times larger than this
      // with no gain in legibility once the page fills the frame.
      imageQuality: 88,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (picked == null) return;

    setState(() => _isReading = true);
    try {
      final page = await _apiService.readPage(
        imagePath: picked.path,
        employeeId: widget.employeeId,
      );
      if (!mounted) return;
      setState(() => _isReading = false);

      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ScanReviewScreen(page: page, stations: widget.stations),
        ),
      );
      if (saved == true && mounted) {
        setState(() {
          _pagesSaved++;
          _entriesSaved += page.entryCount;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isReading = false);
      CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(EmployeeNames.display(context, widget.employeeName),
                style: ThemeTokens.headingMedium.copyWith(fontSize: 16),
                overflow: TextOverflow.ellipsis),
            Text('Scan production book', style: ThemeTokens.caption),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 640 : double.infinity),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              if (_pagesSaved > 0)
                ScanProgressBanner(pagesSaved: _pagesSaved, entriesSaved: _entriesSaved),
              const SizedBox(height: 8.0),
              const ScanGuidanceCard(),
              const SizedBox(height: 24.0),
              if (_isReading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: ThemeTokens.primary),
                      SizedBox(height: 16.0),
                      Text('Reading the page…'),
                    ],
                  ),
                )
              else ...[
                ScanActionButton(
                  icon: Icons.photo_camera_rounded,
                  label: 'Photograph a page',
                  primary: true,
                  onTap: () => _capture(ImageSource.camera),
                ),
                const SizedBox(height: 12.0),
                ScanActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from gallery',
                  primary: false,
                  onTap: () => _capture(ImageSource.gallery),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
