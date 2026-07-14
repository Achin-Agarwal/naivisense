class DomainScores {
  final double attention;
  final double behavioral;
  final double socialCommunication;
  final double receptiveLanguage;
  final double expressiveLanguage;
  final double speechProduction;
  final double imitation;
  final double visualPerception;
  final double fineMotor;
  final double grossMotor;
  final double sensory;
  final double adl;
  final double academics;
  final double cognitive;
  final double emotionalRegulation;

  const DomainScores({
    this.attention = 0,
    this.behavioral = 0,
    this.socialCommunication = 0,
    this.receptiveLanguage = 0,
    this.expressiveLanguage = 0,
    this.speechProduction = 0,
    this.imitation = 0,
    this.visualPerception = 0,
    this.fineMotor = 0,
    this.grossMotor = 0,
    this.sensory = 0,
    this.adl = 0,
    this.academics = 0,
    this.cognitive = 0,
    this.emotionalRegulation = 0,
  });

  factory DomainScores.fromJson(Map<String, dynamic> j) => DomainScores(
    attention: (j['attention'] as num?)?.toDouble() ?? 0,
    behavioral: (j['behavioral'] as num?)?.toDouble() ?? 0,
    socialCommunication: (j['social_communication'] as num?)?.toDouble() ?? 0,
    receptiveLanguage: (j['receptive_language'] as num?)?.toDouble() ?? 0,
    expressiveLanguage: (j['expressive_language'] as num?)?.toDouble() ?? 0,
    speechProduction: (j['speech_production'] as num?)?.toDouble() ?? 0,
    imitation: (j['imitation'] as num?)?.toDouble() ?? 0,
    visualPerception: (j['visual_perception'] as num?)?.toDouble() ?? 0,
    fineMotor: (j['fine_motor'] as num?)?.toDouble() ?? 0,
    grossMotor: (j['gross_motor'] as num?)?.toDouble() ?? 0,
    sensory: (j['sensory'] as num?)?.toDouble() ?? 0,
    adl: (j['adl'] as num?)?.toDouble() ?? 0,
    academics: (j['academics'] as num?)?.toDouble() ?? 0,
    cognitive: (j['cognitive'] as num?)?.toDouble() ?? 0,
    emotionalRegulation: (j['emotional_regulation'] as num?)?.toDouble() ?? 0,
  );

  Map<String, double> toKeyedMap() => {
    'attention': attention,
    'behavioral': behavioral,
    'social_communication': socialCommunication,
    'receptive_language': receptiveLanguage,
    'expressive_language': expressiveLanguage,
    'speech_production': speechProduction,
    'imitation': imitation,
    'visual_perception': visualPerception,
    'fine_motor': fineMotor,
    'gross_motor': grossMotor,
    'sensory': sensory,
    'adl': adl,
    'academics': academics,
    'cognitive': cognitive,
    'emotional_regulation': emotionalRegulation,
  };
}

class AssessmentModel {
  final String id;
  final String childId;
  final String type; // initial | monthly | quarterly
  final DateTime date;
  final String assessedBy;
  final bool isComplete;
  final double overallScorePct;
  final String riskLevel; // green | amber | red
  final double developmentalQuotient;
  final DomainScores domainScores;
  final String generalNotes;

  /// Original assessment data (never changes)
  final Map<String, dynamic>? domainData;

  /// Latest assessment data (updated after every reassessment)
  final Map<String, dynamic>? latest;

  const AssessmentModel({
    required this.id,
    required this.childId,
    required this.type,
    required this.date,
    required this.assessedBy,
    required this.isComplete,
    required this.overallScorePct,
    required this.riskLevel,
    required this.developmentalQuotient,
    required this.domainScores,
    required this.generalNotes,
    this.domainData,
    this.latest,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> j) {
    return AssessmentModel(
      id: (j['_id'] ?? j['id']) as String? ?? '',
      childId: j['child_id'] as String? ?? '',
      type: j['type'] as String? ?? 'initial',
      date: j['date'] != null
          ? DateTime.tryParse(j['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      assessedBy: j['assessed_by'] as String? ?? '',
      isComplete: j['is_complete'] as bool? ?? false,
      overallScorePct: (j['overall_score_pct'] as num?)?.toDouble() ?? 0,
      riskLevel: j['risk_level'] as String? ?? 'amber',
      developmentalQuotient:
          (j['developmental_quotient'] as num?)?.toDouble() ?? 0,
      domainScores: j['domain_scores'] != null
          ? DomainScores.fromJson(j['domain_scores'] as Map<String, dynamic>)
          : const DomainScores(),
      generalNotes: j['general_notes'] as String? ?? '',
      domainData: j['domain_data'] != null
          ? Map<String, dynamic>.from(j['domain_data'] as Map<String, dynamic>)
          : null,
      latest: j['latest'] != null
          ? Map<String, dynamic>.from(j['latest'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get hasLatest => latest != null && latest!.isNotEmpty;

  /// Returns the data that should be used to prefill the wizard.
  /// Prefers latest, falls back to the original assessment.
  Map<String, dynamic>? get prefillData {
    if (hasLatest) return latest;
    return domainData;
  }
}
