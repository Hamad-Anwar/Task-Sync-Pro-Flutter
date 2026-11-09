# Dashboard de conclusão de tasks

Data: 2026-08-25

## Objetivo

Uma tela de dashboard mostrando a porcentagem de tasks concluídas, com quebras por
categoria e por prioridade, e a contagem de tasks atrasadas.

## Contexto: o que falta no app hoje

Três lacunas descobertas na leitura do código, todas bloqueantes para o dashboard:

1. **Não existe conclusão de task.** Toda task nasce com `status: 'unComplete'`
   (`add_task_controller.dart:34`) e nenhum código jamais altera esse campo.
2. **`progress` é somente-leitura depois da criação.** O slider aparece só na tela de
   nova task; não há caminho de edição.
3. **O item "Edit" do menu da task é um no-op.** `popupMenuSelected`
   (`home_controller.dart:131`) só trata `value == 2` (Delete); o `value == 1` cai no vazio.

## Decisões

**Conclusão é derivada do progresso:** uma task está concluída quando `progress >= 100`.
O campo `status` passa a ser mantido em sincronia (`'complete'` / `'unComplete'`) para não
divergir dos dados já gravados, mas a fonte de verdade é o `progress`.

**Escopo da edição:** apenas o progresso fica editável. Edição completa de task (título,
data, categoria) está fora do escopo — não é o que o dashboard precisa.

## Gotchas do código que o código novo precisa respeitar

Estes pontos quebram o dashboard silenciosamente se ignorados:

- **A lista do controller inclui tasks deletadas.** O delete é soft: grava `show: 'no'`
  (`db_helper.dart` → `removeFromList`). O `getData()` **não** filtra, e o filtro
  `show == 'yes'` vive espalhado na UI (`home_page.dart:141`, `progress_task.dart:21`,
  `checkData`). O `TaskStats` precisa filtrar `show == 'yes'`, senão as contagens saem infladas.
- **`progress` pode conter a string literal `"null"`.** O sync do Firebase faz
  `.toString()` em valores possivelmente nulos (`home_controller.dart:49`), então
  `int.parse` explode. Usar parse defensivo (`int.tryParse ?? 0`).
- **`Utils.getDaysDiffirece` não trata data inválida.** Faz `dateFormat.parse` sem
  `try/catch` (`utils.dart:48`) e lança com data vazia ou malformada. O `TaskStats` usa o
  próprio parse protegido em vez de depender dele. Formato: `dd MMM yyyy`.
- **A barra de progresso do card está chumbada em 60%.** `progress_container.dart` usa
  `value: 0.6` com o valor real comentado ao lado. Corrigido neste trabalho, senão o card
  e o dashboard exibem números contraditórios.

## Componentes

### 1. `lib/model/task_stats.dart` — camada de cálculo

Função pura, sem dependência de Firebase, banco ou UI. É o que torna as regras testáveis.

```dart
class TaskStats {
  final int total, completed, inProgress, notStarted, overdue;
  final double completionPercent;        // 0..100; 0 quando total == 0
  final List<GroupStat> byCategory;      // ordenado por total desc
  final List<GroupStat> byPriority;      // 'High' antes de 'Low'

  factory TaskStats.from(List<TaskModel> tasks, {DateTime? now});

  static int parseProgress(String? raw);           // 0..100, defensivo
  static DateTime? parseDate(String? raw);         // null se inválida
}

class GroupStat {
  final String label;
  final int total, completed;
  final double percent;
}
```

Regras de classificação (aplicadas só a tasks com `show == 'yes'`):

| Estado | Regra |
|---|---|
| Concluída | `progress >= 100` |
| Em andamento | `0 < progress < 100` |
| Não iniciada | `progress == 0` |
| Atrasada | data anterior a hoje **e** `progress < 100` |

`parseProgress` faz clamp em 0..100 — o dado gravado não é confiável.

### 2. Edição de progresso

O item morto "Edit" do menu vira **"Atualizar progresso"**, abrindo um bottom sheet com
slider de 0 a 100 (mesmo visual do slider da tela de nova task).

Ao salvar: grava no SQLite (`DbHelper.update`) e no Firebase
(`FirebaseService.update`, que já existe e aceita chave/campo/valor), atualiza `status`
conforme a regra dos 100%, e recarrega a lista (`getTaskData`).

### 3. `lib/view/dashboard/` — a tela

Acessada pelo ícone de menu da home, que hoje é inerte (`home_page.dart`, `AppIcon.menu`).

Lê a `RxList list` que o `HomeController` já mantém, dentro de um `Obx`: reativa a
mudanças e sem criar uma segunda fonte de dados nem um fetch novo.

Seções, em ordem:
1. Anel de conclusão com a % geral + contadores (concluídas / em andamento / não iniciadas)
2. Barras por categoria
3. Card de atrasadas
4. Barras por prioridade

Visual seguindo o app: fundo preto, gradiente pink→purple, `CustomBackButton`.
Estado vazio (nenhuma task) tratado explicitamente — sem divisão por zero.

## Testes

`test/task_stats_test.dart`, cobrindo os cálculos e as bordas que os gotchas acima expõem:
lista vazia, tasks com `show == 'no'`, `progress` igual a `"null"` / vazio / fora da faixa,
data malformada, e a fronteira exata dos 100%.
