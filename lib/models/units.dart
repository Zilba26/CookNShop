class Unit {
  final String unit;
  final String fullName;

  const Unit({required this.unit, required this.fullName});

  Unit.fromJson(Map<String, dynamic> json)
      : unit = json['unite'],
        fullName = json['fullName'];

  Map<String, dynamic> toJson() => {
    'unite': unit,
    'fullName': fullName,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Unit && unit == other.unit && fullName == other.fullName;
  }

  @override
  String toString() {
    return "$fullName ($unit)";
  }

  @override
  int get hashCode => unit.hashCode ^ fullName.hashCode;
}

const baseUnits = [
  Unit(unit: "", fullName: "Pas d'unité"),
  Unit(unit: "ml", fullName: "millilitre"),
  Unit(unit: "cl", fullName: "centilitre"),
  Unit(unit: "dl", fullName: "décilitre"),
  Unit(unit: "l", fullName: "litre"),
  Unit(unit: "g", fullName: "gramme"),
  Unit(unit: "kg", fullName: "kilogramme"),
  Unit(unit: "mg", fullName: "milligramme"),
];