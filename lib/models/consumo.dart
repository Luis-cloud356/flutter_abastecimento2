class Abastecimento {
  String data;
  String combustivel;
  double litros;
  double valorPago;
  double quilometragem;

  Abastecimento({
    required this.data,
    required this.combustivel,
    required this.litros,
    required this.valorPago,
    required this.quilometragem,
  });

  double get precoMedioPorLitro {
    if (litros == 0) return 0;
    return valorPago / litros;
  }

  double consumoMedioComAnterior(double? quilometragemAnterior) {
    if (quilometragemAnterior == null || litros == 0) return 0;
    final distanciaRodada = quilometragem - quilometragemAnterior;
    if (distanciaRodada <= 0) return 0;
    return distanciaRodada / litros;
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'combustivel': combustivel,
      'litros': litros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
    };
  }

  factory Abastecimento.fromJson(Map<String, dynamic> json) {
    return Abastecimento(
      data: json['data']?.toString() ?? '',
      combustivel: json['combustivel']?.toString() ?? '',
      litros: double.tryParse(json['litros'].toString()) ?? 0,
      valorPago: double.tryParse(json['valorPago'].toString()) ?? 0,
      quilometragem: double.tryParse(json['quilometragem'].toString()) ?? 0,
    );
  }
}
