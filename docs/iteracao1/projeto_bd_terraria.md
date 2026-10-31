# Projeto de Banco de Dados — Terraria

**Grupo:**

- Iruziky Araujo de Medeiros
- Heitor Gabriel de Carvalho Borges
- Davi Alves do Nascimento

## 1. Descrição do minimundo

O sistema representa parte do universo do jogo **Terraria**, com foco em jogadores, inventários, itens, inimigos, biomas, comportamentos de inteligência artificial, drops e receitas de fabricação.

Cada jogador possui atributos como vida, mana, classe e velocidade, além de um ou mais inventários. Os inventários possuem tipos diferentes, como principal, Piggy Bank, cofre, munição e equipamento. Cada item armazenado ocupa um slot e possui uma quantidade.

Cada inimigo pertence a um bioma, utiliza um padrão de IA e pode fornecer vários itens ao ser derrotado. Para cada drop são registradas a chance e as quantidades mínima e máxima. Um item também pode ser produzido por diferentes receitas, e cada receita exige um ou mais ingredientes.

O banco permite consultar, por exemplo, os itens de um jogador, os inimigos de um bioma, quais inimigos fornecem determinado item e os ingredientes necessários para fabricar um objeto.

## 2. Diagrama UML

O diagrama apresenta as entidades, seus atributos, chaves primárias (`PK`), chaves estrangeiras (`FK`), relacionamentos e cardinalidades.

- [Visualizar diagrama UML](terraria_db_schema_expanded.html)
- [Abrir SVG](terraria_db_schema_expanded.svg)

### Entidades

- **Principais:** `Jogador`, `Item`, `Inimigo` e `Bioma`.
- **De apoio:** `Inventario`, `AI` e `Receita`.
- **Associativas:** `ItemInventario`, `Drop` e `IngredienteReceita`.

### Relacionamentos e cardinalidades

| Relacionamento | Cardinalidade | Significado |
|---|---|---|
| Jogador — Inventario | `1 : 1..*` | Um jogador possui um ou mais inventários. |
| Inventario — ItemInventario | `1 : 0..*` | Um inventário pode possuir vários slots ocupados. |
| Item — ItemInventario | `1 : 0..*` | Um item pode aparecer em vários inventários. |
| Bioma — Inimigo | `1 : 0..*` | Um bioma pode conter vários inimigos. |
| AI — Inimigo | `1 : 0..*` | Um padrão de IA pode ser usado por vários inimigos. |
| Inimigo — Drop | `1 : 0..*` | Um inimigo pode possuir vários drops. |
| Item — Drop | `1 : 0..*` | Um item pode ser fornecido por vários inimigos. |
| Item — Receita | `1 : 0..*` | Um item pode possuir várias receitas alternativas. |
| Receita — IngredienteReceita | `1 : 1..*` | Uma receita exige pelo menos um ingrediente. |
| Item — IngredienteReceita | `1 : 0..*` | Um item pode participar de várias receitas. |

## 3. Justificativa da modelagem

- **Inventário genérico:** inventário principal, Piggy Bank, cofre e equipamentos possuem estruturas semelhantes. Por isso, são representados por `Inventario` e diferenciados pelo atributo `tipo`, evitando tabelas repetidas.

- **ItemInventario:** quantidade, slot e estado de equipado dependem da presença do item em um inventário, e não do item isoladamente. Essa entidade também resolve a relação muitos-para-muitos entre inventários e itens.

- **Drop:** um inimigo pode fornecer vários itens e um item pode vir de vários inimigos. A entidade associativa armazena os dados próprios dessa relação: chance e intervalo de quantidade.

- **Receita e IngredienteReceita:** uma receita utiliza vários itens, e um item pode participar de várias receitas. A separação permite registrar quantidades e receitas alternativas sem listas ou colunas repetidas.

- **AI separada:** diferentes inimigos podem compartilhar o mesmo comportamento. Armazenar a IA separadamente reduz repetição.

- **Bloco como Item:** blocos são armazenados e utilizados em receitas como os demais itens. Portanto, `Block` é um valor de `Item.tipo`, sem necessidade de uma entidade própria nesta etapa.

- **Chaves compostas:** as entidades associativas usam combinações como `(idInventario, slot)`, `(idCreature, idItem)` e `(idReceita, idIngrediente)` para impedir ocorrências duplicadas.

- **Atributos:** os valores pesquisados diretamente foram mantidos simples e atômicos. Informações com vários valores, como drops e ingredientes, foram transformadas em entidades próprias. `statusGerais` usa JSON apenas para dados variáveis e secundários.

## Referências

- [Terraria Wiki — Recipes](https://terraria.wiki.gg/wiki/Recipes)
- [Terraria Wiki — Items](https://terraria.wiki.gg/wiki/Item_IDs)
- [Terraria Wiki — Enemies](https://terraria.wiki.gg/wiki/Enemies)
