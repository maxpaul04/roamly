import 'dart:math';

class MockCityRatingService {
  static const List<double> ratingCategories = [
    0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0
  ];

  final Random _random = Random();

  // generates mocked rating distributions
  Map<double, int> generateRatingDistribution() {
    final rawWeights = _generatePeakWeights();

    final totalWeight = rawWeights.reduce((a, b) => a + b);
    final normalizedWeights = rawWeights.map((w) => w / totalWeight * 100).toList();

    final rounded  = normalizedWeights.map((w) => w.floor()).toList();
    final remainder = 100 - rounded.reduce((a, b) => a + b);

    final shuffledIndices = List.generate(ratingCategories.length, (i) => i)..shuffle(_random);
    for (int i = 0; i < remainder; i++) {
      rounded[shuffledIndices[i]] += 1;
    }

    final distribution = {
      for (int i = 0; i < ratingCategories.length; i++)
        ratingCategories[i]: rounded[i]
    };

    return distribution;
  }

  //generates 10 weights for each rating with slight noise to simulate a realistic distribution
  List<double> _generatePeakWeights() {
    final peakIndex = _random.nextInt(ratingCategories.length);
    final weights = List<double>.filled(ratingCategories.length, 0.0);
    weights[peakIndex] = 0.5 + _random.nextDouble() * 0.5;

    //walk left from the peak
    double previousWeight = weights[peakIndex];
    for (int i = peakIndex - 1; i >= 0; i--) {
      previousWeight = _nextWeight(previousWeight);
      weights[i] = previousWeight;
    }

    //walk right from the peak
    previousWeight = weights[peakIndex];
    for (int i = peakIndex + 1; i < ratingCategories.length; i++) {
      previousWeight = _nextWeight(previousWeight);
      weights[i] = previousWeight;
    }
    return weights;
  }

  //random steps for weight generation; 80% chance to decrease, 20% chance to increase
  double _nextWeight(double previousWeight) {
    final goesDown = _random.nextDouble() < 0.8;
    if (goesDown) {
      //shrink to 50-90%
      return previousWeight * (0.5 + _random.nextDouble() * 0.4);
    }
    else {
      //grow 5-30%
      return previousWeight * (1.05 + _random.nextDouble() * 0.25);
    }
  }

  double averageRating (Map<double, int> distribution) {
    double weightedResult = 0.0;
    distribution.forEach((rating, percentage) {
      weightedResult += rating * percentage;
    });
    return weightedResult / 100;
  }
}
