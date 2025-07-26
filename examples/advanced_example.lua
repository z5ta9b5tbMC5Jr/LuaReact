--[[
    LuaReact - Exemplo Avançado
    Desenvolvido por: Bypass-dev
    
    Demonstração avançada com computed observables e componentes complexos
    Implementa uma aplicação de lista de tarefas (Todo List)
--]]

local LuaReact = require('luareact')

local AdvancedExample = {}

function AdvancedExample.load()
    -- Estado da aplicação
    AdvancedExample.todos = LuaReact.Observable:new({})
    AdvancedExample.newTodoText = LuaReact.Observable:new("")
    AdvancedExample.filter = LuaReact.Observable:new("all") -- all, active, completed
    AdvancedExample.nextId = 1
    
    -- Computed observables
    AdvancedExample.filteredTodos = LuaReact.Observable:computed(function()
        local todos = AdvancedExample.todos:get()
        local filter = AdvancedExample.filter:get()
        
        if filter == "all" then
            return todos
        elseif filter == "active" then
            local filtered = {}
            for _, todo in ipairs(todos) do
                if not todo.completed then
                    table.insert(filtered, todo)
                end
            end
            return filtered
        elseif filter == "completed" then
            local filtered = {}
            for _, todo in ipairs(todos) do
                if todo.completed then
                    table.insert(filtered, todo)
                end
            end
            return filtered
        end
        return todos
    end)
    
    AdvancedExample.todoCount = LuaReact.Observable:computed(function()
        local todos = AdvancedExample.todos:get()
        local active = 0
        local completed = 0
        
        for _, todo in ipairs(todos) do
            if todo.completed then
                completed = completed + 1
            else
                active = active + 1
            end
        end
        
        return {total = #todos, active = active, completed = completed}
    end)
    
    AdvancedExample.statusText = LuaReact.Observable:computed(function()
        local count = AdvancedExample.todoCount:get()
        if count.total == 0 then
            return "Nenhuma tarefa"
        else
            return string.format("%d total, %d ativas, %d concluídas", 
                count.total, count.active, count.completed)
        end
    end)
    
    -- Widgets da interface
    AdvancedExample.widgets = {}
    AdvancedExample.todoWidgets = {}
    
    -- Título
    table.insert(AdvancedExample.widgets, LuaReact.Text:new({
        text = "LuaReact - Lista de Tarefas",
        x = 50,
        y = 30,
        fontSize = 24,
        color = {0.2, 0.2, 0.8, 1}
    }))
    
    -- Campo de nova tarefa
    AdvancedExample.newTodoInput = LuaReact.Input:new({
        value = AdvancedExample.newTodoText,
        x = 50,
        y = 80,
        width = 400,
        height = 30,
        placeholder = "Digite uma nova tarefa...",
        onEnterPressed = function(widget)
            AdvancedExample.addTodo()
        end
    })
    table.insert(AdvancedExample.widgets, AdvancedExample.newTodoInput)
    
    -- Botão de adicionar
    table.insert(AdvancedExample.widgets, LuaReact.Button:new({
        text = "Adicionar",
        x = 460,
        y = 80,
        width = 80,
        height = 30,
        onClick = function(button)
            AdvancedExample.addTodo()
        end
    }))
    
    -- Filtros
    table.insert(AdvancedExample.widgets, LuaReact.Text:new({
        text = "Filtros:",
        x = 50,
        y = 130,
        fontSize = 14,
        color = {0.3, 0.3, 0.3, 1}
    }))
    
    -- Botões de filtro
    local filterButtons = {
        {text = "Todas", filter = "all", x = 110},
        {text = "Ativas", filter = "active", x = 170},
        {text = "Concluídas", filter = "completed", x = 230}
    }
    
    for _, filterBtn in ipairs(filterButtons) do
        table.insert(AdvancedExample.widgets, LuaReact.Button:new({
            text = filterBtn.text,
            x = filterBtn.x,
            y = 125,
            width = 70,
            height = 25,
            fontSize = 12,
            backgroundColor = LuaReact.Observable:computed(function()
                return AdvancedExample.filter:get() == filterBtn.filter and 
                    {0.2, 0.4, 0.8, 1} or {0.7, 0.7, 0.7, 1}
            end),
            onClick = function(button)
                AdvancedExample.filter:set(filterBtn.filter)
            end
        }))
    end
    
    -- Status
    table.insert(AdvancedExample.widgets, LuaReact.Text:new({
        text = AdvancedExample.statusText,
        x = 50,
        y = 170,
        fontSize = 14,
        color = {0.4, 0.4, 0.4, 1}
    }))
    
    -- Botão de limpar concluídas
    table.insert(AdvancedExample.widgets, LuaReact.Button:new({
        text = "Limpar Concluídas",
        x = 400,
        y = 165,
        width = 140,
        height = 25,
        fontSize = 12,
        backgroundColor = {0.8, 0.3, 0.3, 1},
        hoverColor = {0.9, 0.4, 0.4, 1},
        onClick = function(button)
            AdvancedExample.clearCompleted()
        end
    }))
    
    -- Configurar watchers para atualizar a lista de tarefas
    AdvancedExample.filteredTodos:watch(function(newTodos)
        AdvancedExample.updateTodoWidgets()
    end)
    
    -- Adicionar algumas tarefas de exemplo
    AdvancedExample.addTodoItem("Aprender LuaReact", false)
    AdvancedExample.addTodoItem("Criar uma aplicação reativa", true)
    AdvancedExample.addTodoItem("Testar todos os widgets", false)
    
    print("Exemplo avançado carregado!")
end

function AdvancedExample.addTodo()
    local text = AdvancedExample.newTodoText:get():trim()
    if text ~= "" then
        AdvancedExample.addTodoItem(text, false)
        AdvancedExample.newTodoText:set("")
    end
end

function AdvancedExample.addTodoItem(text, completed)
    local todos = AdvancedExample.todos:get()
    local newTodos = {}
    
    -- Copiar todos existentes
    for _, todo in ipairs(todos) do
        table.insert(newTodos, todo)
    end
    
    -- Adicionar novo todo
    table.insert(newTodos, {
        id = AdvancedExample.nextId,
        text = text,
        completed = completed or false
    })
    
    AdvancedExample.nextId = AdvancedExample.nextId + 1
    AdvancedExample.todos:set(newTodos)
end

function AdvancedExample.toggleTodo(id)
    local todos = AdvancedExample.todos:get()
    local newTodos = {}
    
    for _, todo in ipairs(todos) do
        if todo.id == id then
            table.insert(newTodos, {
                id = todo.id,
                text = todo.text,
                completed = not todo.completed
            })
        else
            table.insert(newTodos, todo)
        end
    end
    
    AdvancedExample.todos:set(newTodos)
end

function AdvancedExample.removeTodo(id)
    local todos = AdvancedExample.todos:get()
    local newTodos = {}
    
    for _, todo in ipairs(todos) do
        if todo.id ~= id then
            table.insert(newTodos, todo)
        end
    end
    
    AdvancedExample.todos:set(newTodos)
end

function AdvancedExample.clearCompleted()
    local todos = AdvancedExample.todos:get()
    local newTodos = {}
    
    for _, todo in ipairs(todos) do
        if not todo.completed then
            table.insert(newTodos, todo)
        end
    end
    
    AdvancedExample.todos:set(newTodos)
end

function AdvancedExample.updateTodoWidgets()
    -- Limpar widgets existentes
    for _, widget in ipairs(AdvancedExample.todoWidgets) do
        widget:dispose()
    end
    AdvancedExample.todoWidgets = {}
    
    local filteredTodos = AdvancedExample.filteredTodos:get()
    local startY = 210
    
    for i, todo in ipairs(filteredTodos) do
        local y = startY + (i - 1) * 35
        
        -- Checkbox (botão de toggle)
        local checkbox = LuaReact.Button:new({
            text = todo.completed and "✓" or "○",
            x = 50,
            y = y,
            width = 25,
            height = 25,
            fontSize = 12,
            backgroundColor = todo.completed and {0.2, 0.8, 0.2, 1} or {0.9, 0.9, 0.9, 1},
            textColor = todo.completed and {1, 1, 1, 1} or {0.3, 0.3, 0.3, 1},
            onClick = function(button)
                AdvancedExample.toggleTodo(todo.id)
            end
        })
        table.insert(AdvancedExample.todoWidgets, checkbox)
        
        -- Texto da tarefa
        local textWidget = LuaReact.Text:new({
            text = todo.text,
            x = 85,
            y = y + 5,
            fontSize = 14,
            color = todo.completed and {0.6, 0.6, 0.6, 1} or {0.2, 0.2, 0.2, 1}
        })
        table.insert(AdvancedExample.todoWidgets, textWidget)
        
        -- Botão de remover
        local removeBtn = LuaReact.Button:new({
            text = "✕",
            x = 500,
            y = y,
            width = 25,
            height = 25,
            fontSize = 12,
            backgroundColor = {0.8, 0.3, 0.3, 1},
            hoverColor = {0.9, 0.4, 0.4, 1},
            textColor = {1, 1, 1, 1},
            onClick = function(button)
                AdvancedExample.removeTodo(todo.id)
            end
        })
        table.insert(AdvancedExample.todoWidgets, removeBtn)
    end
end

-- Função utilitária para trim
string.trim = function(s)
    return s:match("^%s*(.-)%s*$")
end

function AdvancedExample.update(dt)
    -- Atualizar widgets principais
    for _, widget in ipairs(AdvancedExample.widgets) do
        widget:update(dt)
    end
    
    -- Atualizar widgets de tarefas
    for _, widget in ipairs(AdvancedExample.todoWidgets) do
        widget:update(dt)
    end
end

function AdvancedExample.draw()
    -- Desenhar fundo
    love.graphics.setColor(0.95, 0.95, 0.95, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Desenhar widgets principais
    for _, widget in ipairs(AdvancedExample.widgets) do
        widget:render()
    end
    
    -- Desenhar widgets de tarefas
    for _, widget in ipairs(AdvancedExample.todoWidgets) do
        widget:render()
    end
    
    -- Instruções
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Pressione 'R' para recarregar | 'Esc' para sair", 10, love.graphics.getHeight() - 25)
end

function AdvancedExample.mousepressed(x, y, button)
    -- Verificar widgets principais
    for _, widget in ipairs(AdvancedExample.widgets) do
        if widget:mousepressed(x, y, button) then
            return
        end
    end
    
    -- Verificar widgets de tarefas
    for _, widget in ipairs(AdvancedExample.todoWidgets) do
        if widget:mousepressed(x, y, button) then
            return
        end
    end
end

function AdvancedExample.mousereleased(x, y, button)
    -- Verificar widgets principais
    for _, widget in ipairs(AdvancedExample.widgets) do
        if widget:mousereleased(x, y, button) then
            return
        end
    end
    
    -- Verificar widgets de tarefas
    for _, widget in ipairs(AdvancedExample.todoWidgets) do
        if widget:mousereleased(x, y, button) then
            return
        end
    end
end

function AdvancedExample.mousemoved(x, y)
    -- Atualizar widgets principais
    for _, widget in ipairs(AdvancedExample.widgets) do
        widget:mousemoved(x, y)
    end
    
    -- Atualizar widgets de tarefas
    for _, widget in ipairs(AdvancedExample.todoWidgets) do
        widget:mousemoved(x, y)
    end
end

function AdvancedExample.textinput(text)
    -- Verificar widgets principais
    for _, widget in ipairs(AdvancedExample.widgets) do
        if widget.textinput and widget:textinput(text) then
            return
        end
    end
end

function AdvancedExample.keypressed(key)
    -- Verificar widgets principais
    for _, widget in ipairs(AdvancedExample.widgets) do
        if widget.keypressed and widget:keypressed(key) then
            return
        end
    end
end

function AdvancedExample.cleanup()
    -- Limpar observables
    if AdvancedExample.todos then
        AdvancedExample.todos:dispose()
    end
    if AdvancedExample.newTodoText then
        AdvancedExample.newTodoText:dispose()
    end
    if AdvancedExample.filter then
        AdvancedExample.filter:dispose()
    end
    if AdvancedExample.filteredTodos then
        AdvancedExample.filteredTodos:dispose()
    end
    if AdvancedExample.todoCount then
        AdvancedExample.todoCount:dispose()
    end
    if AdvancedExample.statusText then
        AdvancedExample.statusText:dispose()
    end
    
    -- Limpar widgets principais
    if AdvancedExample.widgets then
        for _, widget in ipairs(AdvancedExample.widgets) do
            widget:dispose()
        end
        AdvancedExample.widgets = {}
    end
    
    -- Limpar widgets de tarefas
    if AdvancedExample.todoWidgets then
        for _, widget in ipairs(AdvancedExample.todoWidgets) do
            widget:dispose()
        end
        AdvancedExample.todoWidgets = {}
    end
    
    print("Exemplo avançado limpo!")
end

return AdvancedExample