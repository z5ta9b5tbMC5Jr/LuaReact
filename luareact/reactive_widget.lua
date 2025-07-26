--[[
    LuaReact - ReactiveWidget
    Desenvolvido por: Bypass-dev
    
    Classe base para todos os widgets reativos
--]]

local ReactiveWidget = {}
ReactiveWidget.__index = ReactiveWidget

local Observable = require('luareact.observable')
local DependencyTracker = require('luareact.dependency_tracker')

function ReactiveWidget:new(props)
    props = props or {}
    
    local instance = {
        -- Propriedades básicas
        _props = {},
        _reactiveProps = {},
        _watchers = {},
        _isDisposed = false,
        _needsRender = true,
        _lastRenderTime = 0,
        
        -- Estado interno
        _isHovered = false,
        _isPressed = false,
        _isFocused = false,
        _isVisible = true,
        _isEnabled = true,
        
        -- Callbacks
        _onClick = nil,
        _onHover = nil,
        _onFocus = nil,
        _onBlur = nil,
        
        -- Cache de renderização
        _renderCache = {},
        _cacheValid = false
    }
    
    setmetatable(instance, self)
    
    -- Configurar propriedades padrão
    instance:_setDefaultProps()
    
    -- Aplicar propriedades fornecidas
    for key, value in pairs(props) do
        instance:setProp(key, value)
    end
    
    return instance
end

function ReactiveWidget:_setDefaultProps()
    self._props.x = 0
    self._props.y = 0
    self._props.width = 100
    self._props.height = 30
    self._props.visible = true
    self._props.enabled = true
end

function ReactiveWidget:setProp(key, value)
    if self._isDisposed then
        return
    end
    
    -- Remover watcher anterior se existir
    if self._watchers[key] then
        self._watchers[key]()
        self._watchers[key] = nil
    end
    
    -- Verificar se o valor é um observable
    if Observable.isObservableValue(value) then
        self._reactiveProps[key] = value
        
        -- Configurar watcher para o observable
        self._watchers[key] = value:watch(function(newValue)
            self._props[key] = newValue
            self:_onPropChanged(key, newValue)
            self:_scheduleRender()
        end)
        
        -- Definir valor inicial
        self._props[key] = value:get()
    else
        self._props[key] = value
        self._reactiveProps[key] = nil
    end
    
    -- Callbacks especiais
    if key == "onClick" then
        self._onClick = value
    elseif key == "onHover" then
        self._onHover = value
    elseif key == "onFocus" then
        self._onFocus = value
    elseif key == "onBlur" then
        self._onBlur = value
    end
    
    self:_onPropChanged(key, self._props[key])
    self:_scheduleRender()
end

function ReactiveWidget:getProp(key)
    if self._reactiveProps[key] then
        return self._reactiveProps[key]:get()
    end
    return self._props[key]
end

function ReactiveWidget:_onPropChanged(key, value)
    -- Invalidar cache
    self._cacheValid = false
    
    -- Atualizar estado interno baseado em propriedades
    if key == "visible" then
        self._isVisible = value
    elseif key == "enabled" then
        self._isEnabled = value
    end
    
    -- Método para ser sobrescrito por subclasses
end

function ReactiveWidget:_scheduleRender()
    if not self._needsRender then
        self._needsRender = true
        
        -- Agendar renderização no próximo frame
        if love and love.timer then
            local currentTime = love.timer.getTime()
            if currentTime - self._lastRenderTime > 0.016 then -- ~60 FPS
                self._lastRenderTime = currentTime
            end
        end
    end
end

function ReactiveWidget:render()
    if not self._isVisible or self._isDisposed then
        return
    end
    
    -- Verificar se precisa renderizar
    if not self._needsRender and self._cacheValid then
        return
    end
    
    -- Salvar estado gráfico
    love.graphics.push()
    
    -- Aplicar transformações
    love.graphics.translate(self._props.x or 0, self._props.y or 0)
    
    -- Renderizar o widget
    self:_doRender()
    
    -- Restaurar estado gráfico
    love.graphics.pop()
    
    self._needsRender = false
    self._cacheValid = true
end

function ReactiveWidget:_doRender()
    -- Método para ser implementado por subclasses
    love.graphics.setColor(1, 0, 1, 1) -- Magenta para debug
    love.graphics.rectangle("fill", 0, 0, self._props.width or 100, self._props.height or 30)
end

function ReactiveWidget:update(dt)
    if self._isDisposed then
        return
    end
    
    -- Atualizar animações, timers, etc.
    -- Método para ser sobrescrito por subclasses
end

function ReactiveWidget:mousepressed(x, y, button)
    if not self:_isPointInside(x, y) or not self._isEnabled then
        return false
    end
    
    if button == 1 then -- Botão esquerdo
        self._isPressed = true
        self:_scheduleRender()
        return true
    end
    
    return false
end

function ReactiveWidget:mousereleased(x, y, button)
    if button == 1 and self._isPressed then
        self._isPressed = false
        
        if self:_isPointInside(x, y) and self._onClick then
            self._onClick(self)
        end
        
        self:_scheduleRender()
        return true
    end
    
    return false
end

function ReactiveWidget:mousemoved(x, y)
    local wasHovered = self._isHovered
    self._isHovered = self:_isPointInside(x, y) and self._isEnabled
    
    if self._isHovered ~= wasHovered then
        if self._isHovered and self._onHover then
            self._onHover(self, true)
        elseif not self._isHovered and self._onHover then
            self._onHover(self, false)
        end
        
        self:_scheduleRender()
    end
    
    return self._isHovered
end

function ReactiveWidget:_isPointInside(x, y)
    local wx, wy = self._props.x or 0, self._props.y or 0
    local ww, wh = self._props.width or 100, self._props.height or 30
    
    return x >= wx and x <= wx + ww and y >= wy and y <= wy + wh
end

function ReactiveWidget:focus()
    if not self._isFocused and self._isEnabled then
        self._isFocused = true
        if self._onFocus then
            self._onFocus(self)
        end
        self:_scheduleRender()
    end
end

function ReactiveWidget:blur()
    if self._isFocused then
        self._isFocused = false
        if self._onBlur then
            self._onBlur(self)
        end
        self:_scheduleRender()
    end
end

function ReactiveWidget:setVisible(visible)
    self:setProp("visible", visible)
end

function ReactiveWidget:isVisible()
    return self._isVisible
end

function ReactiveWidget:setEnabled(enabled)
    self:setProp("enabled", enabled)
end

function ReactiveWidget:isEnabled()
    return self._isEnabled
end

function ReactiveWidget:dispose()
    if self._isDisposed then
        return
    end
    
    self._isDisposed = true
    
    -- Remover todos os watchers
    for key, watcher in pairs(self._watchers) do
        if watcher then
            watcher()
        end
    end
    self._watchers = {}
    
    -- Limpar propriedades reativas
    self._reactiveProps = {}
    self._props = {}
    
    -- Limpar callbacks
    self._onClick = nil
    self._onHover = nil
    self._onFocus = nil
    self._onBlur = nil
    
    -- Limpar cache
    self._renderCache = {}
end

-- Método para criar subclasses
function ReactiveWidget:extend()
    local subclass = {}
    subclass.__index = subclass
    setmetatable(subclass, self)
    subclass.super = self
    return subclass
end

return ReactiveWidget