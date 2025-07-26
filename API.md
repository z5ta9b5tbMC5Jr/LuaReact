# LuaReact - Documentação da API

**Desenvolvido por: Bypass-dev**

Esta documentação descreve a API completa da biblioteca LuaReact para programação reativa em Love2D.

## Índice

1. [Observable](#observable)
2. [ReactiveWidget](#reactivewidget)
3. [Widgets](#widgets)
   - [Button](#button)
   - [Text](#text)
   - [Input](#input)
4. [DependencyTracker](#dependencytracker)
5. [Exemplos](#exemplos)

## Observable

A classe `Observable` é o núcleo do sistema reativo. Permite criar valores que notificam automaticamente quando mudam.

### Construtor

```lua
local obs = Observable:new(initialValue)
```

### Métodos

#### `get()`
Retorna o valor atual do observable.

```lua
local value = obs:get()
```

#### `set(newValue)`
Define um novo valor e notifica todos os watchers.

```lua
obs:set("novo valor")
```

#### `watch(callback)`
Registra uma função para ser chamada quando o valor muda.

```lua
local watcher = obs:watch(function(newValue)
    print("Valor mudou para: " .. newValue)
end)
```

#### `computed(computeFn)`
Cria um observable computado que recalcula automaticamente.

```lua
local computed = Observable:computed(function()
    return obs1:get() + obs2:get()
end)
```

#### `dispose()`
Limpa todas as dependências e watchers.

```lua
obs:dispose()
```

## ReactiveWidget

Classe base para todos os widgets reativos.

### Construtor

```lua
local widget = ReactiveWidget:new({
    x = 100,
    y = 100,
    width = 200,
    height = 50,
    visible = true,
    onClick = function(widget) end
})
```

### Propriedades

- `x`, `y`: Posição do widget
- `width`, `height`: Dimensões do widget
- `visible`: Visibilidade do widget
- `onClick`: Callback para clique
- `onHover`: Callback para hover
- `onFocus`: Callback para foco
- `onBlur`: Callback para perda de foco

### Métodos

#### `getProp(key)`
Obtém o valor de uma propriedade (reativa ou estática).

#### `setProp(key, value)`
Define o valor de uma propriedade.

#### `render()`
Renderiza o widget na tela.

#### `update(dt)`
Atualiza o estado interno do widget.

#### `dispose()`
Limpa recursos e dependências.

## Widgets

### Button

Widget de botão interativo.

```lua
local button = LuaReact.Button:new({
    text = "Clique-me",
    x = 100,
    y = 100,
    width = 120,
    height = 40,
    fontSize = 14,
    textColor = {1, 1, 1, 1},
    backgroundColor = {0.2, 0.4, 0.8, 1},
    hoverColor = {0.3, 0.5, 0.9, 1},
    pressedColor = {0.1, 0.3, 0.7, 1},
    onClick = function(button)
        print("Botão clicado!")
    end
})
```

#### Propriedades Específicas

- `text`: Texto do botão (pode ser Observable)
- `fontSize`: Tamanho da fonte
- `textColor`: Cor do texto
- `backgroundColor`: Cor de fundo
- `hoverColor`: Cor quando hover
- `pressedColor`: Cor quando pressionado
- `borderColor`: Cor da borda
- `borderWidth`: Largura da borda
- `padding`: Espaçamento interno
- `cornerRadius`: Raio dos cantos

#### Métodos Específicos

- `setText(text)`: Define o texto
- `getText()`: Obtém o texto
- `setEnabled(enabled)`: Habilita/desabilita
- `isEnabled()`: Verifica se está habilitado

### Text

Widget para exibição de texto.

```lua
local text = LuaReact.Text:new({
    text = "Olá, mundo!",
    x = 50,
    y = 50,
    fontSize = 16,
    color = {0, 0, 0, 1},
    align = "left",
    wrap = false
})
```

#### Propriedades Específicas

- `text`: Texto a ser exibido (pode ser Observable)
- `fontSize`: Tamanho da fonte
- `color`: Cor do texto
- `align`: Alinhamento horizontal ("left", "center", "right")
- `valign`: Alinhamento vertical ("top", "middle", "bottom")
- `wrap`: Quebra de linha automática
- `lineHeight`: Altura da linha
- `maxWidth`: Largura máxima para quebra
- `shadow`: Habilitar sombra
- `shadowColor`: Cor da sombra
- `shadowOffset`: Deslocamento da sombra

#### Métodos Específicos

- `setText(text)`: Define o texto
- `getText()`: Obtém o texto
- `setColor(color)`: Define a cor
- `getTextDimensions()`: Retorna largura e altura do texto

### Input

Widget para entrada de texto.

```lua
local input = LuaReact.Input:new({
    value = "",
    x = 100,
    y = 100,
    width = 200,
    height = 30,
    placeholder = "Digite aqui...",
    onTextChanged = function(widget, newText)
        print("Texto: " .. newText)
    end
})
```

#### Propriedades Específicas

- `value`: Valor do input (pode ser Observable)
- `placeholder`: Texto de placeholder
- `fontSize`: Tamanho da fonte
- `textColor`: Cor do texto
- `backgroundColor`: Cor de fundo
- `borderColor`: Cor da borda
- `focusedBorderColor`: Cor da borda quando focado
- `placeholderColor`: Cor do placeholder
- `maxLength`: Comprimento máximo
- `multiline`: Permitir múltiplas linhas
- `password`: Modo senha
- `readonly`: Somente leitura

#### Callbacks Específicos

- `onTextChanged`: Chamado quando o texto muda
- `onEnterPressed`: Chamado quando Enter é pressionado
- `onValidate`: Função de validação

#### Métodos Específicos

- `getValue()`: Obtém o valor
- `setValue(value)`: Define o valor
- `clear()`: Limpa o conteúdo
- `selectAll()`: Seleciona todo o texto

## DependencyTracker

Sistema interno para rastreamento de dependências.

### Métodos Estáticos

- `track(observable, target)`: Registra dependência
- `untrack(observable, target)`: Remove dependência
- `clearDependencies(target)`: Limpa todas as dependências
- `trigger(observable)`: Dispara notificações
- `cleanup()`: Limpeza global

## Exemplos

### Exemplo Básico

```lua
local LuaReact = require('luareact')

-- Criar observable
local counter = LuaReact.Observable:new(0)

-- Criar botão reativo
local button = LuaReact.Button:new({
    text = LuaReact.Observable:computed(function()
        return "Cliques: " .. counter:get()
    end),
    onClick = function()
        counter:set(counter:get() + 1)
    end
})
```

### Computed Observable

```lua
local firstName = LuaReact.Observable:new("João")
local lastName = LuaReact.Observable:new("Silva")

local fullName = LuaReact.Observable:computed(function()
    return firstName:get() .. " " .. lastName:get()
end)

-- fullName atualiza automaticamente quando firstName ou lastName mudam
```

### Binding Bidirecional

```lua
local inputValue = LuaReact.Observable:new("")

local input = LuaReact.Input:new({
    value = inputValue
})

local display = LuaReact.Text:new({
    text = LuaReact.Observable:computed(function()
        return "Você digitou: " .. inputValue:get()
    end)
})
```

### Watchers

```lua
local data = LuaReact.Observable:new({})

-- Watcher para log
data:watch(function(newData)
    print("Dados atualizados:", #newData, "itens")
end)

-- Watcher para validação
data:watch(function(newData)
    if #newData > 100 then
        print("Aviso: Muitos itens!")
    end
end)
```

## Integração com Love2D

### main.lua

```lua
local LuaReact = require('luareact')
local widgets = {}

function love.load()
    -- Criar widgets
end

function love.update(dt)
    LuaReact.update(dt)
    for _, widget in ipairs(widgets) do
        widget:update(dt)
    end
end

function love.draw()
    for _, widget in ipairs(widgets) do
        widget:render()
    end
end

function love.mousepressed(x, y, button)
    for _, widget in ipairs(widgets) do
        if widget:mousepressed(x, y, button) then
            break
        end
    end
end

-- Outros eventos...
```

## Boas Práticas

1. **Sempre dispose observables**: Chame `dispose()` quando não precisar mais
2. **Use computed para cálculos**: Evite recalcular manualmente
3. **Minimize watchers**: Muitos watchers podem impactar performance
4. **Agrupe atualizações**: Use o sistema de renderização para otimizar
5. **Valide dados**: Use callbacks de validação nos inputs

## Performance

- Observables usam corrotinas para notificações assíncronas
- Sistema de renderização em batch para otimização
- Rastreamento automático de dependências
- Limpeza automática de referências órfãs

---

**Desenvolvido por: Bypass-dev**

Para mais exemplos, consulte a pasta `examples/`.