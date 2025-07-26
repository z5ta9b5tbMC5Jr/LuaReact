--[[
    LuaReact - Sistema de Programação Reativa para Love2D
    Desenvolvido por: Bypass-dev
    
    Ponto de entrada principal da biblioteca
--]]

local LuaReact = {}

-- Importar módulos principais
local Observable = require('luareact.observable')
local ReactiveWidget = require('luareact.reactive_widget')
local DependencyTracker = require('luareact.dependency_tracker')

-- Widgets específicos
local Button = require('luareact.widgets.button')
local Text = require('luareact.widgets.text')
local Input = require('luareact.widgets.input')

-- Exportar API pública
LuaReact.Observable = Observable
LuaReact.ReactiveWidget = ReactiveWidget
LuaReact.DependencyTracker = DependencyTracker

-- Widgets
LuaReact.Button = Button
LuaReact.Text = Text
LuaReact.Input = Input

-- Funções utilitárias
function LuaReact.createObservable(initialValue)
    return Observable:new(initialValue)
end

function LuaReact.computed(computeFn)
    return Observable:computed(computeFn)
end

-- Sistema de renderização global
LuaReact._renderQueue = {}
LuaReact._isRendering = false

function LuaReact.scheduleRender(widget)
    if not LuaReact._isRendering then
        table.insert(LuaReact._renderQueue, widget)
    end
end

function LuaReact.flushRenderQueue()
    LuaReact._isRendering = true
    
    for _, widget in ipairs(LuaReact._renderQueue) do
        if widget and widget.render then
            widget:render()
        end
    end
    
    LuaReact._renderQueue = {}
    LuaReact._isRendering = false
end

-- Hook para Love2D
function LuaReact.update(dt)
    LuaReact.flushRenderQueue()
end

return LuaReact