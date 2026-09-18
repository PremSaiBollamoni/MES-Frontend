import 'package:flutter/widgets.dart';

/// Telugu display names for station operations.
///
/// Operation names come from the database in English and are shared with the backend,
/// reports and HRMS, so they are not translated at source - renaming them there would
/// ripple through every system that references them. Instead this maps the stored
/// English value to a Telugu display string at render time.
///
/// These are transliterations rather than literal translations ("Collar Attaching" ->
/// "కాలర్ అటాచింగ్"), because that is how the terms are actually spoken on the floor.
/// Reviewed and confirmed by a Telugu-speaking supervisor.
///
/// Anything not in this map falls through to the original English, so a station added
/// later still displays correctly - just untranslated until its name is added here.
class OperationNames {
  const OperationNames._();

  static const Map<String, String> _te = {
    // Collar
    'Collar Attaching': 'కాలర్ అటాచింగ్',
    'Collar Band Attach': 'కాలర్ బ్యాండ్ అటాచ్',
    'Collar Bone Preparing and Attaching': 'కాలర్ బోన్ ప్రిపేరింగ్ అండ్ అటాచింగ్',
    'Collar Finishing': 'కాలర్ ఫినిషింగ్',
    'Collar Middle': 'కాలర్ మిడిల్',
    'Collar Run': 'కాలర్ రన్',
    'Collar Top': 'కాలర్ టాప్',
    'Neck Band Hemming': 'నెక్ బ్యాండ్ హెమ్మింగ్',

    // Cuff
    'Cuff Attaching': 'కఫ్ అటాచింగ్',
    'Cuff Hemming': 'కఫ్ హెమ్మింగ్',
    'Cuff Ironing': 'కఫ్ ఐరనింగ్',
    'Cuff Run': 'కఫ్ రన్',
    'Cuff Top Stitch': 'కఫ్ టాప్ స్టిచ్',
    'Cuff Turning and Collar Marking': 'కఫ్ టర్నింగ్ అండ్ కాలర్ మార్కింగ్',

    // Sleeve
    'Sleeve Attach': 'స్లీవ్ అటాచ్',
    'Sleeve Big Placket': 'స్లీవ్ బిగ్ ప్లాకెట్',
    'Sleeve Big Placket Iron': 'స్లీవ్ బిగ్ ప్లాకెట్ ఐరన్',
    'Sleeve Small Placket': 'స్లీవ్ స్మాల్ ప్లాకెట్',
    'Sleeve Small Placket Locking': 'స్లీవ్ స్మాల్ ప్లాకెట్ లాకింగ్',
    'Sleeve Top': 'స్లీవ్ టాప్',

    // Front / back / body
    'Back Main Label Adding and Attaching': 'బ్యాక్ మెయిన్ లేబుల్ యాడింగ్ అండ్ అటాచింగ్',
    'Back Top Stitch': 'బ్యాక్ టాప్ స్టిచ్',
    'Back Yoke Adding': 'బ్యాక్ యోక్ యాడింగ్',
    'Front and Back Attaching': 'ఫ్రంట్ అండ్ బ్యాక్ అటాచింగ్',
    'Front Kansai Left Placket': 'ఫ్రంట్ కన్సాయ్ లెఫ్ట్ ప్లాకెట్',
    'Front Kansai Right Placket': 'ఫ్రంట్ కన్సాయ్ రైట్ ప్లాకెట్',
    'Shoulder Top': 'షోల్డర్ టాప్',
    'Side Seam & Side Loading': 'సైడ్ సీమ్ & సైడ్ లోడింగ్',
    'Bottom Hemming': 'బాటమ్ హెమ్మింగ్',

    // Pocket
    'Pocket Attaching': 'పాకెట్ అటాచింగ్',
    'Pocket Hemming': 'పాకెట్ హెమ్మింగ్',
    'Pocket Ironing': 'పాకెట్ ఐరనింగ్',

    // Button
    'Button Attach': 'బటన్ అటాచ్',
    'Button Hole Marking and Button Hole': 'బటన్ హోల్ మార్కింగ్ అండ్ బటన్ హోల్',

    // Finishing / other
    'Edge Cutting': 'ఎడ్జ్ కటింగ్',
    'Fusing': 'ఫ్యూజింగ్',
    'Polybag insertiom': 'పాలీబ్యాగ్ ఇన్సర్షన్',
    'QUALITY CHECKING': 'క్వాలిటీ చెకింగ్',
    'Wash Care Label Adding': 'వాష్ కేర్ లేబుల్ యాడింగ్',
  };

  /// Telugu name for [operationName] when the app is in Telugu, otherwise the original.
  /// Unknown values pass through unchanged rather than showing a blank or a key.
  static String display(BuildContext context, String? operationName) {
    if (operationName == null || operationName.isEmpty) return '';
    final isTelugu = Localizations.localeOf(context).languageCode == 'te';
    if (!isTelugu) return operationName;
    return _te[operationName] ?? _te[operationName.trim()] ?? operationName;
  }
}
