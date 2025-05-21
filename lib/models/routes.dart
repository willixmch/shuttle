class Routes {
  final String routeId;
  final String routeNameZh;
  final String routeNameEn;
  final String estateId;
  final String infoZh;
  final String infoEn;
  final String residentFare;
  final String visitorFare;

  const Routes({
    required this.routeId,
    required this.routeNameZh,
    required this.routeNameEn,
    required this.estateId,
    required this.infoZh,
    required this.infoEn,
    required this.residentFare,
    required this.visitorFare,
  });

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'routeNameZh': routeNameZh,
      'routeNameEn': routeNameEn,
      'estateId': estateId,
      'infoZh': infoZh,
      'infoEn': infoEn,
      'residentFare': residentFare,
      'visitorFare': visitorFare,
    };
  }

  factory Routes.fromMap(Map<String, dynamic> map) {
    final routeId = map['routeId'];
    final routeNameZh = map['routeNameZh'];
    final routeNameEn = map['routeNameEn'];
    final estateId = map['estateId'];
    final infoZh = map['infoZh'];
    final infoEn = map['infoEn'] ?? '';
    final residentFare = map['residentFare'];
    final visitorFare = map['visitorFare'];
    if (routeId == null ||
        routeNameZh == null ||
        routeNameEn == null ||
        estateId == null ||
        infoZh == null ||
        infoEn == null ||
        residentFare == null ||
        visitorFare == null) {
      throw Exception('Invalid route data: one or more fields are null in map: $map');
    }
    return Routes(
      routeId: routeId as String,
      routeNameZh: routeNameZh as String,
      routeNameEn: routeNameEn as String,
      estateId: estateId as String,
      infoZh: infoZh as String,
      infoEn: infoEn as String,
      residentFare: residentFare as String,
      visitorFare: visitorFare as String,
    );
  }

  @override
  String toString() {
    return 'Routes{routeId: $routeId, routeNameZh: $routeNameZh, routeNameEn: $routeNameEn, estateId: $estateId, infoZh: $infoZh, infoEn: $infoEn, residentFare: $residentFare, visitorFare: $visitorFare}';
  }
}