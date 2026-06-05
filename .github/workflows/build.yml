name: Build Android APK

# Quando o build roda:
# - a cada push na branch principal
# - manualmente, pelo botão "Run workflow" na aba Actions
on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  build-apk:
    runs-on: ubuntu-latest

    steps:
      # 1. Baixa o código do repositório
      - name: Checkout do código
        uses: actions/checkout@v4

      # 2. Instala o Java (necessário para o build Android)
      - name: Configurar Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      # 3. Instala o Flutter SDK (já vem pronto no runner do GitHub)
      - name: Configurar Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      # 4. Baixa as dependências do projeto
      - name: Instalar dependências
        run: flutter pub get

      # 5. Gera o código (Freezed, json_serializable, Riverpod)
      - name: Gerar código (build_runner)
        run: dart run build_runner build --delete-conflicting-outputs

      # 6. Compila o APK de release.
      #    As credenciais do Supabase vêm dos "secrets" do repositório,
      #    então não ficam expostas no código.
      - name: Compilar APK
        run: |
          flutter build apk --release \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}

      # 7. Disponibiliza o APK para download na aba Actions ("Artifacts")
      - name: Publicar APK
        uses: actions/upload-artifact@v4
        with:
          name: labpartner-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          if-no-files-found: error
