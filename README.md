# LuaReact - Sistema de Programação Reativa para Love2D

**Desenvolvido por: Bypass-dev**

Uma biblioteca de UI reativa inspirada no Vue.js para Love2D/LÖVE, oferecendo bindings de dados automáticos e atualizações reativas da interface.

## Características

- 🔄 **Programação Reativa**: Observables que atualizam automaticamente a UI
- 📊 **Data Binding**: Vinculação bidirecional de dados
- ⚡ **Performance**: Uso eficiente de corrotinas e metatables
- 🎮 **Love2D Ready**: Integração nativa com Love2D/LÖVE
- 🧩 **Componentes**: Sistema modular de widgets reativos

## Exemplo de Uso

```lua
local LuaReact = require('luareact')

-- Criar um observable
local counter = LuaReact.Observable(0)

-- Criar um widget reativo
local button = LuaReact.ReactiveWidget:new({
    text = LuaReact.Observable("Clique-me"),
    x = 100,
    y = 100,
    width = 200,
    height = 50,
    onClick = function()
        counter:set(counter:get() + 1)
        print("Clicked! Counter: " .. counter:get())
    end
})

-- Binding reativo
counter:watch(function(newValue)
    button.text:set("Clicks: " .. newValue)
end)
```

## Instalação

1. Clone este repositório
2. Copie os arquivos para seu projeto Love2D
3. Require a biblioteca: `local LuaReact = require('luareact')`

## Estrutura do Projeto

```
luareact/
├── init.lua              # Ponto de entrada principal
├── observable.lua        # Sistema de observables
├── reactive_widget.lua   # Widgets reativos base
├── dependency_tracker.lua # Rastreamento de dependências
├── widgets/              # Widgets específicos
│   ├── button.lua
│   ├── text.lua
│   └── input.lua
└── examples/             # Exemplos de uso
```

## Licença

MIT License - Desenvolvido por Bypass-dev