# Reembolso API 🌐

Projeto **Reembolso API** para o desafio técnico da empresa [Caiena](https://www.caiena.net/). Todo projeto Reembolso API foi desenvolvido na framework **Ruby on Rails**, seguindo um padrão **APIRestul**.

Este projeto é utilizado como back-end da aplicação [Reembolso APP](https://github.com/tzanarde/reembolso_app), desenvolvida em Vue.js.

**Versão:** 1.0.0
**Formato de Resposta:** application/json
**Link para Execução:** localhost:3000

---

### Indíce
- [Instalação](#instalação)
- [Autenticação](#autenticação)
- [Endpoints](#endpoints)
    - [Users](#users)
    - [Expenses](#expenses)
    - [Tags](#tags)
- [Testes](#testes)

---

### Instalação

O projeto pode ser instalado a partir do Docker Compose. Para instalar execute:

```sh
docker compose build
docker compose up -d
docker compose exec web rails db:create db:migrate
```
É importante definir o valor da variável `RAILS_ENV` para definir em qual ambiente será feita a migration.

Com isso a API já poderá ser acessada pela sua URL padrão:

```sh
localhost:3000
```

---

### Autenticação

A autenticação foi desenvolvida utilizando a gem [Devise](https://rubygems.org/gems/devise/versions/4.2.0?locale=pt-BR). É utilizado **JWT (JSON Web Token)** para autenticação.

Ao realizar o login, a requisição irá retornar um token. Todos os endpoints, com excessão daqueles relacionados a criação de usuário e login, precisam de token na key `Authorization` em seu header, com o `Bearer Token`, no formato mostrado no exemplo a seguir.

Exemplo de retorno de requisição de login:
```json
{
    "user": {
        "id": 1,
        "email": "user@email.com",
        "created_at": "2025-02-20T14:30:09.428Z",
        "updated_at": "2025-02-20T14:30:09.428Z",
        "name": "User Name",
        "role": "Employee",
        "manager_user_id": 1,
        "active": true,
        "jti": "2bcf87e5-ce3e-4cce-97ae-f63967da6f25"
    },
    "token": "SEU_TOKEN",
    "message": "Login realizado com sucesso!"
}
```

Exemplo de requisição autenticada:
```sh
curl --location 'localhost:3000/expenses/2' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data ''
```
---

### Endpoints

#### Users
| ENDPOINT | MÉTODO | URL | DESCRIÇÃO |
|:--------|:----|:----|:--------------|
| SIGN_UP | POST | /users | Cria um usuário |
| SIGN_IN | POST | /users/sign_in | Loga um usuário |
| SIGN_OUT | DELETE | /users/sign_out | Desloga um usuário |

##### SIGN_UP

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint SIGN_UP da entidade Users:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| email | Email do usuário, utilizado com login |
| password | Senha do usuário, criptografada e gerenciado pelo Devise |
| name | Nome do usuário |
| role | Tipo de usuário (Employee = Funcionário Comum - Manager = Gestor) |
| manager_user_id | ID do usuário gestor (Manager), caso seja um funcionário comum (Employee) |
| active | Indicador de usuário ativo no sistema |

###### Exemplo de Requisição

Exemplo de requisição do endpoint SIGN_UP da entidade Expenses:

```sh
curl --location 'localhost:3000/users' \
--header 'Content-Type: application/json' \
--data-raw '{"user":
    {
    "email": "nome@email.com",
    "password": "password",
    "name": "Nome",
    "role": "Manager",
    "active": true
    }
}'
```

##### SIGN_IN

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint SIGN_IN da entidade Users:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| email | Email do usuário |
| password | Senha do usuário |

###### Exemplo de Requisição

Exemplo de requisição do endpoint SIGN_UP da entidade Expenses:

```sh
curl --location 'localhost:3000/users/sign_in' \
--header 'Content-Type: application/json' \
--data-raw '{"user":
    {
    "email": "user@email.com",
    "password": "password"
    }
}'
```

##### SIGN_OUT

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint SIGN_OUT da entidade Users:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| email | Email do usuário |
| password | Senha do usuário |

###### Exemplo de Requisição

Exemplo de requisição do endpoint SIGN_UP da entidade Expenses:

```sh
curl --location --request DELETE 'localhost:3000/users/sign_out' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data-raw '{"user":
    {
    "email": "user@email.com",
    "password": "password"
    }
}'
```

#### Expenses
| ENDPOINT | MÉTODO | URL | DESCRIÇÃO |
|:--------|:----|:----|:--------------|
| INDEX | GET| /expenses | Retorna todas as despesas |
| SHOW | GET | /expenses:id | Retorna uma despesa específica |
| CREATE | POST | /expenses | Adiciona uma despesa |
| UPDATE | PATCH | /expenses/:id | Atualiza uma despesa |
| DELETE | DELETE | /expenses/:id | Remove uma despesa |

##### INDEX

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint INDEX da entidade Expenses:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| type | Permite filtrar por despesas pendentes ou por histórico de despesas |
| text_filter | Permite filtrar pela descrição da despesa |
| date | Permite filtrar pela data exata |
| start_date | Permite filtrar por uma data inicial (Usado em conjunto com o parâmetro final_date) |
| final_date | Permite filtrar por uma data final (Usado em conjunto com o parâmetro start_date) |
| employee_id | Permite filtrar pelo funcionário a qual a despesa pertence |
| min_amount | Permite filtrar por um valor mínimo (Usado em conjunto com o parâmetro max_amount) |
| max_amount | Permite filtrar por um valor máximo (Usado em conjunto com o parâmetro min_amount) |

###### Exemplo de Requisição

Exemplo de requisição do endpoint INDEX da entidade Expenses:

```sh
curl --location 'localhost:3000/expenses?type=P&text_filter=Nova&date=2024-12-06&start_date=2024-12-05&final_date=2024-12-08&employee_id=12&min_amount=90&max_amount=110' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data ''
```

##### SHOW

###### Exemplo de Requisição

Exemplo de requisição do endpoint SHOW da entidade Expenses:

```sh
curl --location 'localhost:3000/expenses/2' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data ''
```

##### CREATE

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint CREATE da entidade Expenses:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| description | Descrição da despesa |
| date | Data da despesa |
| amount | Valor da despesa |
| location | Local da despesa |
| status | Status da despesa (P = Pendente/Pending - A = Aprovado/Approved  - N = Negado/Declined) |
| user_id | Usuário do qual a despesa pertence |
| receipt_nf | Arquivo de recibo de nota fiscal |
| receipt_card | Arquivo de recibo de cartão |

###### Exemplo de Requisição

Exemplo de requisição do endpoint CREATE da entidade Expenses:

```sh
curl --location 'localhost:3000/expenses' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--form 'description="Descrição da despesas de Teste"' \
--form 'date="2024-12-06"' \
--form 'amount="100.00"' \
--form 'location="Local de Teste"' \
--form 'status="P"' \
--form 'user_id="12"' \
--form 'receipt_nf=@"/receipt_example.png"' \
--form 'receipt_card=@"/receipt_example_2.png"'
```

##### UPDATE

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint UPDATE da entidade Expenses:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| description | Descrição da despesa |
| date | Data da despesa |
| amount | Valor da despesa |
| location | Local da despesa |
| status | Status da despesa (P = Pendente/Pending - A = Aprovado/Approved  - N = Negado/Declined) |
| user_id | Usuário do qual a despesa pertence |
| receipt_nf | Arquivo de recibo de nota fiscal |
| receipt_card | Arquivo de recibo de cartão |

###### Exemplo de Requisição

Exemplo de requisição do endpoint UPDATE da entidade Expenses:

```sh
curl --location --request PATCH 'localhost:3000/expenses/1' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--form 'description="Descrição da despesas de Teste"' \
--form 'date="2024-12-06"' \
--form 'amount="100.00"' \
--form 'location="Local de Teste"' \
--form 'status="P"' \
--form 'user_id="12"' \
--form 'receipt_nf=@"/receipt_example.png"' \
--form 'receipt_card=@"/receipt_example_2.png"'
```

##### DELETE

###### Exemplo de Requisição

Exemplo de requisição do endpoint DELETE da entidade Expenses:

```sh
curl --location --request DELETE 'localhost:3000/expenses/1' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data ''
```

#### Tags
| ENDPOINT | MÉTODO | URL | DESCRIÇÃO |
|:--------|:----|:----|:--------------|
| INDEX | GET| /tags | Retorna todas as tags |
| SHOW | GET | /tags:id | Retorna uma tag específica |
| CREATE | POST | /tags | Adiciona uma tag |
| UPDATE | PATCH | /tags/:id | Atualiza uma tag |
| DELETE | DELETE | /tags/:id | Remove uma tags |

##### INDEX

###### Exemplo de Requisição

Exemplo de requisição do endpoint INDEX da entidade Tags:

```sh
curl --location 'localhost:3000/tags' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data ''
```

##### SHOW

###### Exemplo de Requisição

Exemplo de requisição do endpoint SHOW da entidade Tags:

```sh
curl --location 'localhost:3000/tags/1' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data ''
```

##### CREATE

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint CREATE da entidade Tags:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| description | Descrição da tag |

###### Exemplo de Requisição

Exemplo de requisição do endpoint CREATE da entidade Tags:

```sh
curl --location 'localhost:3000/tags' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data '{
    "description": "Descrição 2"
}'
```

##### UPDATE

###### Parâmetros Permitidos

Lista de parâmetros permitidos pelo endpoint UPDATE da entidade Tags:

| PARÂMETRO |  DESCRIÇÃO |
|:--------|:--------------|
| description | Descrição da tag |

###### Exemplo de Requisição

Exemplo de requisição do endpoint UPDATE da entidade Tags:

```sh
curl --location --request PATCH 'localhost:3000/tags/1' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data '{
    "description": "Descrição Nova"
}'
```

##### DELETE

###### Exemplo de Requisição

Exemplo de requisição do endpoint DELETE da entidade Tags:

```sh
curl --location --request DELETE 'localhost:3000/tags/1' \
--header 'Content-Type: application/json' \
--header 'ACCEPT: application/json' \
--header 'Authorization: Bearer SEU_TOKEN' \
--data ''
```

---

### Testes

Para rodar os testes, utilizar o comando abaixo:

```sh
docker compose exec rails db:create db:migrate
```
