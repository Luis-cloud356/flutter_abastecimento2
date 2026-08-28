# flutter_abastecimento2

App de historico de abastecimentos mantendo a mesma estrutura do projeto anterior.

## Screenshots

### Splash

![Screenshot da Splash](./flutter_abastecimento_veiculos/assets/splash.png)

### Home

![Screenshot da Home](./flutter_abastecimento_veiculos/assets/home.png)


```text
lib/
  main.dart
  ui/
    splash.dart
    home.dart
    style/
      colors.dart
      theme.dart
  models/
    consumo.dart
  root/
    file.dart
```

## Como rodar

```bash
flutter pub get
flutter run
```

## O que cada tela faz

- `Splash` - icone do app, switch de tema escuro e botao `Entrar`.
- `Home` - lista de abastecimentos com data, combustivel, litros, valor pago e quilometragem, botao `+` para cadastrar, lixeira para excluir e toque no item para editar. Abaixo da lista, um grafico comparativo.

## Regras

- Preco medio por litro = `valor_pago / litros`.
- Consumo medio = `(quilometragem atual - quilometragem anterior) / litros atuais`.
- Os registros sao salvos localmente com `SharedPreferences`, funcionando no celular e no web.
