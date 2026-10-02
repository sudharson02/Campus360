import '../models/lost_found_model.dart';

class AIMatchingService {
  /// Evaluates all Lost vs Found items and computes AI match confidence scores
  static List<LostFoundMatchResult> findMatches(
    List<LostFoundItem> lostItems,
    List<LostFoundItem> foundItems,
  ) {
    final List<LostFoundMatchResult> matches = [];

    for (final lost in lostItems.where((i) => i.type == 'lost' && i.status == 'Open')) {
      for (final found in foundItems.where((i) => i.type == 'found' && i.status == 'Open')) {
        final double score = _calculateMatchScore(lost, found);
        if (score >= 0.45) { // Threshold for potential match
          matches.add(LostFoundMatchResult(
            lostItem: lost,
            foundItem: found,
            confidenceScore: score,
            matchReason: _generateReason(lost, found, score),
          ));
        }
      }
    }

    // Sort by confidence score descending
    matches.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return matches;
  }

  static double _calculateMatchScore(LostFoundItem lost, LostFoundItem found) {
    double score = 0.0;

    // 1. Category match (Weight 0.35)
    if (lost.category.toLowerCase() == found.category.toLowerCase()) {
      score += 0.35;
    }

    // 2. Title & Description Keyword Overlap (Weight 0.40)
    final lostTokens = _tokenize('${lost.title} ${lost.description}');
    final foundTokens = _tokenize('${found.title} ${found.description}');

    if (lostTokens.isNotEmpty && foundTokens.isNotEmpty) {
      int overlap = 0;
      for (final token in lostTokens) {
        if (foundTokens.contains(token)) {
          overlap++;
        }
      }
      final double tokenSimilarity = overlap / (lostTokens.length + 0.1);
      score += (tokenSimilarity * 0.40).clamp(0.0, 0.40);
    }

    // 3. Location Keyword Match (Weight 0.15)
    final lostLoc = _tokenize(lost.location);
    final foundLoc = _tokenize(found.location);
    if (lostLoc.any((token) => foundLoc.contains(token))) {
      score += 0.15;
    }

    // 4. Date Proximity (Weight 0.10)
    if (lost.date == found.date) {
      score += 0.10;
    }

    return score.clamp(0.0, 0.98); // Cap at 98% for realistic AI confidence
  }

  static Set<String> _tokenize(String text) {
    final clean = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    final words = clean.split(RegExp(r'\s+'));
    const stopWords = {'the', 'a', 'an', 'in', 'on', 'at', 'near', 'and', 'or', 'of', 'for', 'with', 'is', 'was'};
    return words.where((w) => w.length > 2 && !stopWords.contains(w)).toSet();
  }

  static String _generateReason(LostFoundItem lost, LostFoundItem found, double score) {
    final List<String> reasons = [];
    if (lost.category.toLowerCase() == found.category.toLowerCase()) {
      reasons.add('Same Category (${lost.category})');
    }
    final lostLoc = _tokenize(lost.location);
    final foundLoc = _tokenize(found.location);
    if (lostLoc.any((t) => foundLoc.contains(t))) {
      reasons.add('Matching Location (${lost.location})');
    }
    if (lost.date == found.date) {
      reasons.add('Same Date Reported (${lost.date})');
    }
    if (reasons.isEmpty) {
      reasons.add('High description keyword overlap');
    }
    return reasons.join(' • ');
  }
}
