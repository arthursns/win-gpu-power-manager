# ScheduleGPU: Gerenciador Automático de GPU e Energia

Este script PowerShell gerencia automaticamente o estado da Placa de Vídeo Dedicada (GPU) e as configurações de economia de energia do Windows, baseando-se na fonte de alimentação atual (Bateria ou Tomada).

## Funcionalidades

O script verifica se o computador está conectado à tomada:

1.  **Modo Bateria (Desconectado)**:
    *   Desabilita a GPU dedicada (ex: RTX 4070) para maximizar a duração da bateria.
    *   (Opcional) Ativa o modo de economia de energia imediatamente, definindo o limite para 100%.

2.  **Modo Tomada (Conectado)**:
    *   Habilita a GPU dedicada para garantir performance máxima.
    *   (Opcional) Restaura o limite de economia de energia para 20%.

## Pré-requisitos

*   **Privilégios de Administrador**: O script executa comandos como `powercfg` e `Disable-PnpDevice`, que exigem elevação de privilégios.
*   PowerShell 5.1 ou superior.

## Configuração

Antes de utilizar, abra o arquivo `ScheduleGPU.ps1` e ajuste as variáveis de acordo com sua preferência:

```powershell
# O nome da sua placa de vídeo dedicada. Use '*' como curinga.
$gpuName = "*RTX 4070*"

# Mude para $false se você NÃO quiser que o script gerencie a Economia de Energia.
$managePowerSaver = $true
```

## Como Usar

### Opção 1: Agendador de Tarefas (Importação Rápida)
Um arquivo `ScheduleGPU.xml` está incluído para facilitar a configuração.

1.  Abra o **Agendador de Tarefas** (Task Scheduler).
2.  Clique em **Importar Tarefa...** no painel de ações à direita.
3.  Selecione o arquivo `ScheduleGPU.xml` deste repositório.
4.  Na janela que abrir, vá para a aba **Ações**, selecione a ação "Iniciar um programa" e clique em **Editar**.
5.  No campo "Adicionar argumentos", altere o caminho `"C:\Caminho\Para\ScheduleGPU.ps1"` para o local real onde você salvou o script.
6.  Clique em **OK** para salvar a tarefa.

### Opção 2: Agendador de Tarefas (Manual)
Caso prefira configurar manualmente:

1.  Crie uma nova tarefa que dispare ao conectar/desconectar da energia ou ao fazer logon.
2.  Na ação, inicie o `powershell.exe` com o argumento `-File "c:\Caminho\Para\ScheduleGPU.ps1"`.
3.  **Importante**: Marque a opção "Executar com privilégios mais altos" (Run with highest privileges).