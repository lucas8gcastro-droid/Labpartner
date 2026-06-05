# LabPartner

Plataforma B2B de cotações de química fina para representantes universitários.
Conecta estudantes representantes, professores/laboratórios e uma empresa
fornecedora — com foco em **geração de cotações**, **comissões** e
**relacionamento comercial acadêmico** (não é um marketplace aberto).

> `LabPartner` é um nome provisório. Todo o branding está centralizado em
> `lib/core/config/branding.dart` — para renomear, edite apenas esse arquivo.

---

## Stack

- **Flutter** + **Material 3** (UI responsiva, tema único centralizado)
- **Supabase** — PostgreSQL, Auth e Row Level Security
- **Riverpod** (com geração de código) — estado e injeção de dependências
- **GoRouter** — navegação e proteção de rotas por sessão
- **Freezed** + **json_serializable** — modelos imutáveis e serialização

---

## Arquitetura de pastas

O projeto é organizado **por feature**. Cada feature segue as camadas
`data` (acesso a dados) → `domain` (modelos) → `application` (providers/estado)
→ `presentation` (telas e widgets).

```text
lib/
├── main.dart                     # bootstrap (Supabase, locale, ProviderScope)
├── app.dart                      # MaterialApp.router + tema
│
├── core/                         # base transversal (sem regra de negócio)
│   ├── config/                   # branding e credenciais (Supabase)
│   ├── theme/                    # cores, tipografia, espaçamento, tema
│   ├── router/                   # rotas, GoRouter e redirect de auth
│   ├── utils/                    # validadores, formatadores, mensagens de erro
│   └── widgets/                  # componentes reutilizáveis (botões, inputs…)
│
├── shared/
│   └── models/                   # enums do domínio (espelham os enums do banco)
│
└── features/
    ├── auth/                     # login, cadastro, recuperação, logout
    │   ├── data/                 # AuthRepository (Supabase Auth)
    │   ├── domain/               # AppUser
    │   ├── application/          # providers de autenticação
    │   └── presentation/         # telas e AuthScaffold
    ├── dashboard/                # dashboard do representante
    │   ├── data/                 # DashboardRepository (consultas)
    │   ├── domain/               # DashboardSummary
    │   ├── application/          # provider do resumo
    │   └── presentation/         # tela + StatCard
    ├── catalog/                  # (próxima etapa) catálogo de produtos
    ├── quotes/                   # (próxima etapa) fluxo de cotação
    ├── commissions/              # (próxima etapa) comissões
    └── admin/                    # (próxima etapa) painel administrativo

supabase/
└── migrations/
    └── 0001_initial_schema.sql   # esquema completo + RLS + seed
```

---

## Pré-requisitos

- Flutter SDK **>= 3.24** (Dart **>= 3.5**)
- Uma conta/projeto no [Supabase](https://supabase.com)

---

## Passo a passo

### 1. Instalar dependências

```bash
flutter pub get
```

### 2. Gerar o código (Freezed, json_serializable, Riverpod)

Os modelos (`*.freezed.dart`, `*.g.dart`) e os providers anotados são gerados
por build_runner. **Este passo é obrigatório antes de compilar** — sem ele o
projeto não compila.

```bash
dart run build_runner build --delete-conflicting-outputs
```

Durante o desenvolvimento, deixe rodando em modo watch:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 3. Configurar o Supabase

1. Crie um projeto no Supabase.
2. No painel **SQL Editor**, cole e execute o conteúdo de
   `supabase/migrations/0001_initial_schema.sql`. Isso cria as tabelas
   (`users`, `products`, `quotes`, `quote_items`, `commissions`), os enums,
   as triggers (numeração de cotação, criação de perfil no cadastro, geração
   automática de comissão ao aprovar), as políticas de **RLS** e alguns
   produtos de exemplo.
3. Em **Project Settings → API**, copie a **Project URL** e a **anon public key**.

> Por padrão o Supabase exige **confirmação de e-mail** no cadastro. Para testar
> rápido, você pode desabilitar em **Authentication → Providers → Email**
> (ou confirmar pelo link enviado). O app já trata os dois casos.

### 4. Rodar o app

As credenciais **não ficam no código** — são injetadas em tempo de compilação
via `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sua_anon_key
```

Para evitar digitar sempre, crie um `env.json` (não versione) e use:

```bash
flutter run --dart-define-from-file=env.json
```

```json
{
  "SUPABASE_URL": "https://SEU-PROJETO.supabase.co",
  "SUPABASE_ANON_KEY": "sua_anon_key"
}
```

---

## Como a autenticação e a navegação se conectam

- O `AuthRepository` isola toda a conversa com o Supabase Auth.
- Os **controllers não navegam**: eles apenas mudam o estado da sessão.
- O **`GoRouter`** (em `core/router/app_router.dart`) tem um `redirect` que lê
  a sessão atual e um `refreshListenable` ligado à stream de autenticação.
  Quando o usuário entra ou sai, o router reavalia e leva ao destino certo
  (dashboard ao logar, login ao deslogar). Isso evita lógica de navegação
  espalhada pelas telas.
- No cadastro, os campos do usuário vão como _metadata_ e uma trigger no banco
  (`handle_new_user`) cria a linha correspondente em `public.users`.

---

## O que já está pronto

- ✅ Arquitetura escalável por feature
- ✅ Banco de dados completo (SQL + RLS + triggers + seed)
- ✅ Autenticação (login, cadastro, recuperação de senha, logout)
- ✅ Navegação com proteção de rotas por sessão
- ✅ Dashboard do representante (comissões, volume de cotações, status)
- ✅ Tema global, modelos de todas as entidades e componentes reutilizáveis

## Próximas etapas

- [ ] Catálogo de produtos (busca + cards) — UI sobre a tabela `products`
- [ ] Fluxo de **nova cotação** (carrinho → cria `quotes` + `quote_items`)
- [ ] Painel **administrativo** (aprovar/recusar, mudar status, métricas)
- [ ] Tela de **comissões** do representante
- [ ] Roteamento por papel (admin x representante) no redirect do GoRouter
