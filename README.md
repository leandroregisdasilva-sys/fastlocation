# FastLocation

Aplicativo mobile (Android e iOS) para consulta de endereços por CEP e de CEPs por endereço, desenvolvido em Flutter para os entregadores da empresa fictícia **FastDelivery**.

Projeto do **Desafio 02** da Unidade Curricular **Desenvolvimento de Sistemas Móveis** — Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas, UniSENAI (2026/2). Professor: Julio Cezar Rutke.

**Grupo 53**

| Integrante | RA |
|---|---|
| Daniel Paulo Linhares | 2579194 |
| Leandro Régis da Silva | 2579144 |

## Funcionalidades

- Consulta de endereço por CEP na API pública [ViaCEP](https://viacep.com.br).
- Busca de CEP por endereço completo ou parcial (UF, cidade e parte do logradouro).
- Armazenamento local das consultas (Hive): um CEP já consultado é respondido pelo armazenamento local, sem nova chamada à API.
- Gerenciamento de estado reativo com MobX (`Observer`, ações e reações).
- Tela de carregamento durante a consulta externa.
- Componente de busca vazia quando nada é encontrado.
- Último endereço consultado em destaque na tela inicial.
- Histórico de endereços consultados em página própria, carregado automaticamente.
- Rota da localização atual do dispositivo até o último endereço consultado, aberta no aplicativo de mapas instalado.
- Página de abertura animada com redirecionamento automático para a home.

## Como executar

### Requisitos

| Ferramenta | Versão | Observação |
|---|---|---|
| Flutter | **3.24.5** (stable) | Versão usada no projeto e na integração contínua. As bibliotecas exigidas pelo desafio (dio 4, hive 2, mobx_codegen e hive_generator 2) só geram código com o analisador dessa geração do Flutter. |
| JDK | **17** | Exigido pelo Gradle 8.3 do projeto Android. |
| Android Studio | qualquer recente | Para o emulador Android (ou use um celular com depuração USB). |
| Xcode | compatível com Flutter 3.24 | Apenas para rodar no iOS (somente em macOS). |

Instalação rápida do Flutter 3.24.5 e do JDK 17 no macOS:

```bash
git clone --depth 1 --branch 3.24.5 https://github.com/flutter/flutter.git ~/flutter-3.24.5
export PATH="$HOME/flutter-3.24.5/bin:$PATH"
brew install --cask temurin@17
flutter config --jdk-dir "$(/usr/libexec/java_home -v 17)"
flutter doctor
```

### Passos

```bash
git clone <URL_DO_REPOSITORIO>
cd fastlocation
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Os arquivos gerados do MobX e do Hive (`*.g.dart`) já estão versionados; o comando `build_runner` apenas os gera novamente.

### Testes e análise

```bash
flutter analyze
flutter test
```

O repositório também tem integração contínua (GitHub Actions, `.github/workflows/ci.yml`): a cada envio são executados `flutter analyze`, `flutter test` e o build do APK de depuração, que fica disponível para download na aba **Actions**.

### Ajustes de plataforma

- **Android:** o `map_launcher` 2.x, versão exigida pelo desafio, não declara `namespace`, obrigatório no Android Gradle Plugin 8. O `android/build.gradle` atribui o namespace automaticamente a bibliotecas que não o declaram. O `AndroidManifest.xml` principal declara a permissão de internet, necessária para a consulta na versão de release.
- **iOS:** o `Info.plist` declara `LSApplicationQueriesSchemes` com os esquemas dos aplicativos de mapas, conforme a documentação do `map_launcher`, para que o app detecte os mapas instalados.

### Como usar

1. Aguarde a tela de abertura; o aplicativo segue sozinho para a home.
2. Toque em **Nova consulta** e escolha **Por CEP** ou **Por endereço**.
3. Na busca por endereço, quando houver mais de um resultado, toque no endereço correto para selecioná-lo.
4. Toque em **Traçar rota** para abrir o aplicativo de mapas com o trajeto até o último endereço consultado.
5. Toque em **Histórico** para ver todos os endereços já consultados.

## Bibliotecas

| Biblioteca | Uso no projeto |
|---|---|
| `dio` | Comunicação HTTP com a API ViaCEP (`lib/src/http`) |
| `mobx`, `flutter_mobx` | Gerenciamento de estado dos controllers e reatividade das páginas |
| `hive`, `hive_flutter` | Armazenamento local do histórico de consultas |
| `path`, `path_provider`, `path_provider_android`, `path_provider_ios` | Localização da pasta de dados do aplicativo para o armazenamento local |
| `geocoding` | Conversão do endereço consultado em coordenadas |
| `map_launcher` | Abertura da rota no aplicativo de mapas do dispositivo |
| `mobx_codegen`, `hive_generator`, `build_runner` | Geração de código (desenvolvimento) |

## Estrutura do projeto

```
lib/
├── main.dart
└── src/
    ├── app_widget.dart
    ├── http/
    │   └── http_config.dart
    ├── routes/
    │   └── app_routes.dart
    ├── shared/
    │   ├── colors/        app_colors.dart
    │   ├── components/    address_tile.dart, app_button.dart,
    │   │                  app_empty_state.dart, app_loading.dart
    │   ├── exceptions/    app_exception.dart
    │   ├── metrics/       app_metrics.dart
    │   └── storage/       storage_config.dart, storage_keys.dart
    └── modules/
        ├── initial/
        │   └── page/          initial_page.dart
        ├── home/
        │   ├── components/    address_list.dart, empty_search.dart,
        │   │                  last_address_card.dart, search_form.dart
        │   ├── controller/    home_controller.dart
        │   ├── model/         address_model.dart
        │   ├── page/          home_page.dart
        │   ├── repositories/  home_repository.dart, home_local_repository.dart
        │   └── service/       home_service.dart, route_service.dart
        └── history/
            ├── controller/    history_controller.dart
            └── page/          history_page.dart
```

O fluxo de uma consulta segue as camadas: `page` → `controller` (MobX) → `service` (regras de negócio) → `repositories` (API e armazenamento local).

## Correspondência com os passos do desafio

| Passo do enunciado | Onde está |
|---|---|
| 01 – Criando o projeto | Projeto Flutter somente com as plataformas `android/` e `ios/`; exemplo padrão removido; `main()` refatorado em `lib/main.dart` |
| 02 – Instalando as libs | `pubspec.yaml`, com as dependências e versões indicadas |
| 03 – Estruturas compartilhadas | `lib/src/shared` (colors, components, metrics, storage), `lib/src/routes`, `lib/src/http` |
| 04 – Página de abertura | `lib/src/modules/initial/page/initial_page.dart` (animação e redirecionamento automático) |
| 05 – Módulo Home | `lib/src/modules/home` (components, controller, model, page, repositories, service) |
| 06 – Módulo History | `lib/src/modules/history` (controller, page) |

## Regras de negócio

- O CEP deve ter 8 dígitos; a máscara é removida antes da consulta.
- Na busca por endereço, a UF é obrigatória e cidade e logradouro precisam de pelo menos 3 letras (exigência da ViaCEP).
- Cada CEP aparece uma única vez no histórico; ao ser consultado de novo, volta para o topo.
- Falhas de rede, tempo esgotado e dados inválidos são convertidos em mensagens claras, exibidas por uma reação do MobX.
