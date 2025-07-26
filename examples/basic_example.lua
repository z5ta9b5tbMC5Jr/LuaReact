--[[
    LuaReact - Exemplo Básico
    Desenvolvido por: Bypass-dev
    
    Demonstração básica dos recursos do LuaReact
--]]

local LuaReact = require('luareact')

local BasicExample = {}

function BasicExample.load()
    -- Criar observables
    BasicExample.counter = LuaReact.Observable:new(0)
    BasicExample.message = LuaReact.Observable:new("Olá, LuaReact!")
    BasicExample.inputText = LuaReact.Observable:new("")
    
    -- Computed observable para a mensagem do contador
    BasicExample.counterMessage = LuaReact.Observable:computed(function()
        local count = BasicExample.counter:get()
        if count == 0 then
            return "Nenhum clique ainda"
        elseif count == 1 then
            return "1 clique"
        else
            return count .. " cliques"
        end
    end)
    
    -- Computed observable para a mensagem do input
    BasicExample.inputMessage = LuaReact.Observable:computed(function()
        local text = BasicExample.inputText:get()
        if text == "" then
            return "Digite algo..."
        else
            return "Você digitou: " .. text
        end
    end)
    
    -- Criar widgets
    BasicExample.widgets = {}
    
    -- Título
    table.insert(BasicExample.widgets, LuaReact.Text:new({
        text = "LuaReact - Exemplo Básico",
        x = 50,
        y = 30,
        fontSize = 24,
        color = {0.2, 0.2, 0.8, 1}
    }))
    
    -- Texto da mensagem
    table.insert(BasicExample.widgets, LuaReact.Text:new({
        text = BasicExample.message,
        x = 50,
        y = 80,
        fontSize = 16,
        color = {0.3, 0.3, 0.3, 1}
    }))
    
    -- Contador
    table.insert(BasicExample.widgets, LuaReact.Text:new({
        text = BasicExample.counterMessage,
        x = 50,
        y = 120,
        fontSize = 18,
        color = {0.1, 0.6, 0.1, 1}
    }))
    
    -- Botão de incrementar
    table.insert(BasicExample.widgets, LuaReact.Button:new({
        text = "Incrementar",
        x = 50,
        y = 160,
        width = 120,
        height = 35,
        onClick = function(button)
            BasicExample.counter:set(BasicExample.counter:get() + 1)
        end
    }))
    
    -- Botão de decrementar
    table.insert(BasicExample.widgets, LuaReact.Button:new({
        text = "Decrementar",
        x = 180,
        y = 160,
        width = 120,
        height = 35,
        backgroundColor = {0.8, 0.3, 0.3, 1},
        hoverColor = {0.9, 0.4, 0.4, 1},
        pressedColor = {0.7, 0.2, 0.2, 1},
        onClick = function(button)
            BasicExample.counter:set(BasicExample.counter:get() - 1)
        end
    }))
    
    -- Botão de reset
    table.insert(BasicExample.widgets, LuaReact.Button:new({
        text = "Reset",
        x = 310,
        y = 160,
        width = 80,
        height = 35,
        backgroundColor = {0.6, 0.6, 0.6, 1},
        hoverColor = {0.7, 0.7, 0.7, 1},
        pressedColor = {0.5, 0.5, 0.5, 1},
        onClick = function(button)
            BasicExample.counter:set(0)
        end
    }))
    
    -- Campo de entrada
    table.insert(BasicExample.widgets, LuaReact.Input:new({
        value = BasicExample.inputText,
        x = 50,
        y = 220,
        width = 300,
        height = 30,
        placeholder = "Digite algo aqui...",
        onTextChanged = function(widget, newText)
            -- O observable já é atualizado automaticamente
        end
    }))
    
    -- Texto do input
    table.insert(BasicExample.widgets, LuaReact.Text:new({
        text = BasicExample.inputMessage,
        x = 50,
        y = 270,
        fontSize = 14,
        color = {0.4, 0.4, 0.4, 1}
    }))
    
    -- Botão para mudar mensagem
    table.insert(BasicExample.widgets, LuaReact.Button:new({
        text = "Mudar Mensagem",
        x = 50,
        y = 310,
        width = 150,
        height = 35,
        backgroundColor = {0.8, 0.6, 0.2, 1},
        hoverColor = {0.9, 0.7, 0.3, 1},
        pressedColor = {0.7, 0.5, 0.1, 1},
        onClick = function(button)
            local messages = {
                "Olá, LuaReact!",
                "Programação Reativa é incrível!",
                "Love2D + LuaReact = ❤️",
                "Widgets reativos funcionando!",
                "Desenvolvido por Bypass-dev"
            }
            local randomIndex = math.random(1, #messages)
            BasicExample.message:set(messages[randomIndex])
        end
    }))
    
    -- Configurar watchers para demonstração
    BasicExample.counter:watch(function(newValue)
        print("Contador mudou para: " .. newValue)
    end)
    
    BasicExample.inputText:watch(function(newValue)
        print("Input mudou para: '" .. newValue .. "'")
    end)
    
    print("Exemplo básico carregado!")
end

function BasicExample.update(dt)
    -- Atualizar widgets
    for _, widget in ipairs(BasicExample.widgets) do
        widget:update(dt)
    end
end

function BasicExample.draw()
    -- Desenhar fundo
    love.graphics.setColor(0.95, 0.95, 0.95, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Desenhar widgets
    for _, widget in ipairs(BasicExample.widgets) do
        widget:render()
    end
    
    -- Instruções
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Pressione 'R' para recarregar | 'Esc' para sair", 10, love.graphics.getHeight() - 25)
end

function BasicExample.mousepressed(x, y, button)
    for _, widget in ipairs(BasicExample.widgets) do
        if widget:mousepressed(x, y, button) then
            break
        end
    end
end

function BasicExample.mousereleased(x, y, button)
    for _, widget in ipairs(BasicExample.widgets) do
        if widget:mousereleased(x, y, button) then
            break
        end
    end
end

function BasicExample.mousemoved(x, y)
    for _, widget in ipairs(BasicExample.widgets) do
        widget:mousemoved(x, y)
    end
end

function BasicExample.textinput(text)
    for _, widget in ipairs(BasicExample.widgets) do
        if widget.textinput and widget:textinput(text) then
            break
        end
    end
end

function BasicExample.keypressed(key)
    for _, widget in ipairs(BasicExample.widgets) do
        if widget.keypressed and widget:keypressed(key) then
            break
        end
    end
end

function BasicExample.cleanup()
    -- Limpar observables
    if BasicExample.counter then
        BasicExample.counter:dispose()
    end
    if BasicExample.message then
        BasicExample.message:dispose()
    end
    if BasicExample.inputText then
        BasicExample.inputText:dispose()
    end
    if BasicExample.counterMessage then
        BasicExample.counterMessage:dispose()
    end
    if BasicExample.inputMessage then
        BasicExample.inputMessage:dispose()
    end
    
    -- Limpar widgets
    if BasicExample.widgets then
        for _, widget in ipairs(BasicExample.widgets) do
            widget:dispose()
        end
        BasicExample.widgets = {}
    end
    
    print("Exemplo básico limpo!")
end

return BasicExample