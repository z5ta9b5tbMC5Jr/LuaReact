# Instalação - LuaReact

**Desenvolvido por: Bypass-dev**

Guia completo para instalar e executar o sistema de programação reativa LuaReact.

## Pré-requisitos

### 1. Love2D (LÖVE)

O LuaReact requer o Love2D para funcionar.

#### Windows

1. **Baixar Love2D:**
   - Acesse: https://love2d.org/
   - Baixe a versão mais recente (recomendado: 11.4 ou superior)
   - Escolha a versão 64-bit para melhor performance

2. **Instalar:**
   - Execute o instalador baixado
   - Instale no diretório padrão: `C:\Program Files\LOVE`

3. **Configurar PATH (Opcional mas recomendado):**
   - Abra "Variáveis de Ambiente" no Windows
   - Adicione `C:\Program Files\LOVE` ao PATH
   - Isso permite usar o comando `love` no terminal

#### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install love
```

#### macOS

```bash
# Usando Homebrew
brew install love

# Ou baixe diretamente de https://love2d.org/
```

## Instalação do LuaReact

### Método 1: Clone do Repositório

```bash
git clone <url-do-repositorio> luareact
cd luareact
```

### Método 2: Download Manual

1. Baixe todos os arquivos do projeto
2. Extraia para uma pasta (ex: `luareact`)
3. Navegue até a pasta

## Estrutura do Projeto

Após a instalação, você deve ter a seguinte estrutura:

```
luareact/
├── luareact/              # Biblioteca principal
│   ├── init.lua          # Ponto de entrada
│   ├── observable.lua    # Sistema de observables
│   ├── reactive_widget.lua # Widget base
│   ├── dependency_tracker.lua # Rastreamento de dependências
│   └── widgets/          # Widgets específicos
│       ├── button.lua
│       ├── text.lua
│       └── input.lua
├── examples/             # Exemplos de uso
│   ├── basic_example.lua
│   └── advanced_example.lua
├── main.lua             # Arquivo principal
├── conf.lua             # Configuração Love2D
├── run.bat              # Script de execução (Windows)
├── README.md            # Documentação principal
├── API.md               # Documentação da API
└── INSTALL.md           # Este arquivo
```

## Executando o Projeto

### Windows

#### Opção 1: Script Automático
```cmd
# Execute o arquivo batch
run.bat
```

#### Opção 2: Comando Direto (se PATH configurado)
```cmd
love .
```

#### Opção 3: Caminho Completo
```cmd
"C:\Program Files\LOVE\love.exe" .
```

### Linux/macOS

```bash
love .
```

## Verificando a Instalação

Se tudo estiver correto, você deve ver:

1. **Janela do Love2D** abrindo com título "LuaReact - Sistema de Programação Reativa"
2. **Interface do exemplo básico** com:
   - Contador reativo
   - Botões interativos
   - Campo de entrada de texto
   - Texto que atualiza automaticamente

## Exemplos Disponíveis

### Exemplo Básico
- Demonstra observables simples
- Widgets básicos (Button, Text, Input)
- Reatividade fundamental

### Exemplo Avançado (Todo List)
- Computed observables
- Lista dinâmica
- Filtros reativos
- Operações CRUD

### Alternando Entre Exemplos

No arquivo `main.lua`, você pode alterar qual exemplo carregar:

```lua
-- Para exemplo básico
local example = require('examples.basic_example')

-- Para exemplo avançado
-- local example = require('examples.advanced_example')
```

## Solução de Problemas

### Erro: "love não é reconhecido"

**Causa:** Love2D não está instalado ou não está no PATH.

**Solução:**
1. Verifique se Love2D está instalado
2. Use o caminho completo: `"C:\Program Files\LOVE\love.exe" .`
3. Ou configure o PATH do sistema

### Erro: "module 'luareact' not found"

**Causa:** Estrutura de arquivos incorreta.

**Solução:**
1. Verifique se a pasta `luareact/` existe
2. Verifique se `luareact/init.lua` existe
3. Execute a partir da pasta raiz do projeto

### Erro: "attempt to index nil value"

**Causa:** Dependência faltando ou erro de sintaxe.

**Solução:**
1. Verifique se todos os arquivos estão presentes
2. Verifique a sintaxe Lua
3. Consulte os logs de erro

### Performance Baixa

**Causas possíveis:**
- Muitos observables ativos
- Loops infinitos em computed
- Renderização excessiva

**Soluções:**
1. Use `dispose()` em observables não utilizados
2. Evite dependências circulares
3. Otimize funções computed

## Desenvolvimento

### Criando Novos Widgets

1. Crie um arquivo em `luareact/widgets/`
2. Herde de `ReactiveWidget`
3. Implemente `_doRender()` e outros métodos necessários
4. Registre no `luareact/init.lua`

### Exemplo de Widget Personalizado

```lua
local ReactiveWidget = require('luareact.reactive_widget')

local MyWidget = ReactiveWidget:extend()

function MyWidget:new(props)
    local instance = MyWidget.super.new(self, props)
    -- Inicialização específica
    return instance
end

function MyWidget:_doRender()
    -- Lógica de renderização
end

return MyWidget
```

## Recursos Adicionais

- **Documentação da API:** Consulte `API.md`
- **Exemplos:** Pasta `examples/`
- **Love2D Wiki:** https://love2d.org/wiki/
- **Lua Reference:** https://www.lua.org/manual/5.1/

## Suporte

Para problemas ou dúvidas:

1. Verifique este guia de instalação
2. Consulte a documentação da API
3. Analise os exemplos fornecidos
4. Verifique os logs de erro do Love2D

---

**Desenvolvido por: Bypass-dev**

Bom desenvolvimento com LuaReact! 🚀