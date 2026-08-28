import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/consumo.dart';
import '../root/file.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Abastecimento> abastecimentos = [];

  String data = '';
  String combustivel = '';
  String litros = '';
  String valorPago = '';
  String quilometragem = '';

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  String _hojeFormatado() {
    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    return '$dia/$mes/${agora.year}';
  }

  double _toDouble(String valor) {
    return double.tryParse(valor.replaceAll(',', '.')) ?? 0;
  }

  Future<void> carregarDados() async {
    final conteudo = await GerenciarArquivo.abrir();
    if (conteudo.isEmpty) {
      if (!mounted) return;
      setState(() {
        abastecimentos = [];
      });
      return;
    }

    final dados = jsonDecode(conteudo) as List<dynamic>;
    if (!mounted) return;
    setState(() {
      abastecimentos = dados
          .map((item) => Abastecimento.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> salvarDados() async {
    final conteudo = jsonEncode(abastecimentos.map((a) => a.toJson()).toList());
    await GerenciarArquivo.salvar(conteudo);
  }

  void limparCampos() {
    data = '';
    combustivel = '';
    litros = '';
    valorPago = '';
    quilometragem = '';
  }

  double _precoMedioPorLitroAtual() {
    if (abastecimentos.isEmpty) return 0;
    return abastecimentos.last.precoMedioPorLitro;
  }

  double _consumoMedioAtual() {
    if (abastecimentos.length < 2) return 0;
    final atual = abastecimentos.last;
    final anterior = abastecimentos[abastecimentos.length - 2];
    return atual.consumoMedioComAnterior(anterior.quilometragem);
  }

  double _valorMaximo() {
    if (abastecimentos.isEmpty) return 1;
    final maximo = abastecimentos
        .map((a) => a.valorPago)
        .reduce((a, b) => a > b ? a : b);
    return maximo == 0 ? 1 : maximo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abastecimentos'),
        actions: [
          GestureDetector(
            onTap: () {
              limparCampos();
              cadastrar();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: const Icon(Icons.add, size: 40, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preco medio/L',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'R\$ ${_precoMedioPorLitroAtual().toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consumo medio',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_consumoMedioAtual().toStringAsFixed(2)} km/L',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: abastecimentos.isEmpty
                ? const Center(child: Text('Nenhum abastecimento registrado'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemBuilder: (context, i) => Card(
                      child: ListTile(
                        title: Text(
                          '${abastecimentos[i].data} - ${abastecimentos[i].combustivel}',
                        ),
                        subtitle: Text(
                          "${abastecimentos[i].litros.toStringAsFixed(2)} L  •  R\$ ${abastecimentos[i].valorPago.toStringAsFixed(2)}  •  Km ${abastecimentos[i].quilometragem.toStringAsFixed(0)}  •  R\$/L ${abastecimentos[i].precoMedioPorLitro.toStringAsFixed(2)}  •  Km/L ${i == 0 ? '---' : abastecimentos[i].consumoMedioComAnterior(abastecimentos[i - 1].quilometragem).toStringAsFixed(2)}",
                        ),
                        trailing: GestureDetector(
                          onTap: () => excluir(i),
                          child: const Icon(Icons.delete),
                        ),
                        onTap: () => alterar(i),
                      ),
                    ),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemCount: abastecimentos.length,
                  ),
          ),
          graficoComparativo(),
        ],
      ),
    );
  }

  Widget graficoComparativo() {
    if (abastecimentos.isEmpty) return const SizedBox.shrink();

    final maiorValor = _valorMaximo();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relatorio de abastecimentos',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          ...abastecimentos.asMap().entries.map((entry) {
            final indice = entry.key;
            final abastecimento = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text('${indice + 1}'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: abastecimento.valorPago / maiorValor,
                        minHeight: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('R\$ ${abastecimento.valorPago.toStringAsFixed(2)}'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void cadastrar() {
    data = _hojeFormatado();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo abastecimento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: data),
              decoration: const InputDecoration(hintText: 'Data'),
              onChanged: (value) => data = value,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Combustivel'),
              onChanged: (value) => combustivel = value,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Litros'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => litros = value,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Valor pago'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => valorPago = value,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Quilometragem'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => quilometragem = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                abastecimentos.add(
                  Abastecimento(
                    data: data.isEmpty ? _hojeFormatado() : data,
                    combustivel: combustivel,
                    litros: _toDouble(litros),
                    valorPago: _toDouble(valorPago),
                    quilometragem: _toDouble(quilometragem),
                  ),
                );
              });
              await salvarDados();
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }

  void alterar(int indice) {
    data = abastecimentos[indice].data;
    combustivel = abastecimentos[indice].combustivel;
    litros = abastecimentos[indice].litros.toString();
    valorPago = abastecimentos[indice].valorPago.toString();
    quilometragem = abastecimentos[indice].quilometragem.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar abastecimento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: data),
              decoration: const InputDecoration(hintText: 'Data'),
              onChanged: (value) => data = value,
            ),
            TextField(
              controller: TextEditingController(text: combustivel),
              decoration: const InputDecoration(hintText: 'Combustivel'),
              onChanged: (value) => combustivel = value,
            ),
            TextField(
              controller: TextEditingController(text: litros),
              decoration: const InputDecoration(hintText: 'Litros'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => litros = value,
            ),
            TextField(
              controller: TextEditingController(text: valorPago),
              decoration: const InputDecoration(hintText: 'Valor pago'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => valorPago = value,
            ),
            TextField(
              controller: TextEditingController(text: quilometragem),
              decoration: const InputDecoration(hintText: 'Quilometragem'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) => quilometragem = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                abastecimentos[indice] = Abastecimento(
                  data: data,
                  combustivel: combustivel,
                  litros: _toDouble(litros),
                  valorPago: _toDouble(valorPago),
                  quilometragem: _toDouble(quilometragem),
                );
              });
              await salvarDados();
            },
            child: const Text('Salvar alteracao'),
          ),
        ],
      ),
    );
  }

  void excluir(int indice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir abastecimento'),
        content: const Text('Confirma a exclusao deste registro?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                abastecimentos.removeAt(indice);
              });
              await salvarDados();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
