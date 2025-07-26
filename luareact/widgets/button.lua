--[[
    LuaReact - Button Widget
    Desenvolvido por: Bypass-dev
    
    Widget de botão reativo com estados de hover e pressionado
--]]

local ReactiveWidget = require('luareact.reactive_widget')
local Observable = require('luareact.observable')

local Button = ReactiveWidget:extend()

function Button:new(props)
    local instance = Button.super.new(self, props)
    
    -- Configurar propriedades específicas do botão
    instance:_setButtonDefaults()
    
    -- Aplicar propriedades fornecidas
    if props then
        for key, value in pairs(props) do
            instance:setProp(key, value)
        end
    end
    
    return instance
end

function Button:_setButtonDefaults()
    -- Propriedades de texto
    self._props.text = "Button"
    self._props.fontSize = 14
    self._props.font = nil
    
    -- Cores
    self._props.textColor = {1, 1, 1, 1} -- Branco
    self._props.backgroundColor = {0.2, 0.4, 0.8, 1} -- Azul
    self._props.hoverColor = {0.3, 0.5, 0.9, 1} -- Azul mais claro
    self._props.pressedColor = {0.1, 0.3, 0.7, 1} -- Azul mais escuro
    self._props.disabledColor = {0.5, 0.5, 0.5, 1} -- Cinza
    
    -- Borda
    self._props.borderColor = {0.1, 0.2, 0.6, 1}
    self._props.borderWidth = 1
    
    -- Layout
    self._props.padding = 8
    self._props.cornerRadius = 4
    
    -- Dimensões automáticas baseadas no texto
    self:_calculateSize()
end

function Button:_onPropChanged(key, value)
    Button.super._onPropChanged(self, key, value)
    
    -- Recalcular tamanho se texto ou fonte mudaram
    if key == "text" or key == "fontSize" or key == "font" or key == "padding" then
        self:_calculateSize()
    end
end

function Button:_calculateSize()
    local text = self:getProp("text") or ""
    local fontSize = self:getProp("fontSize") or 14
    local padding = self:getProp("padding") or 8
    
    -- Configurar fonte
    local font = self:getProp("font")
    if font then
        love.graphics.setFont(font)
    else
        love.graphics.setFont(love.graphics.newFont(fontSize))
    end
    
    -- Calcular dimensões do texto
    local textWidth = love.graphics.getFont():getWidth(text)
    local textHeight = love.graphics.getFont():getHeight()
    
    -- Definir tamanho do botão (se não foi definido manualmente)
    if not self._props.width or self._autoWidth then
        self._props.width = textWidth + (padding * 2)
        self._autoWidth = true
    end
    
    if not self._props.height or self._autoHeight then
        self._props.height = textHeight + (padding * 2)
        self._autoHeight = true
    end
end

function Button:_doRender()
    local width = self._props.width or 100
    local height = self._props.height or 30
    local cornerRadius = self._props.cornerRadius or 0
    
    -- Determinar cor de fundo baseada no estado
    local bgColor
    if not self._isEnabled then
        bgColor = self._props.disabledColor
    elseif self._isPressed then
        bgColor = self._props.pressedColor
    elseif self._isHovered then
        bgColor = self._props.hoverColor
    else
        bgColor = self._props.backgroundColor
    end
    
    -- Desenhar fundo
    love.graphics.setColor(bgColor)
    if cornerRadius > 0 then
        -- Desenhar retângulo com cantos arredondados (aproximação)
        love.graphics.rectangle("fill", 0, 0, width, height, cornerRadius)
    else
        love.graphics.rectangle("fill", 0, 0, width, height)
    end
    
    -- Desenhar borda
    local borderWidth = self._props.borderWidth or 0
    if borderWidth > 0 then
        love.graphics.setColor(self._props.borderColor or {0, 0, 0, 1})
        love.graphics.setLineWidth(borderWidth)
        
        if cornerRadius > 0 then
            love.graphics.rectangle("line", 0, 0, width, height, cornerRadius)
        else
            love.graphics.rectangle("line", 0, 0, width, height)
        end
    end
    
    -- Desenhar texto
    local text = self:getProp("text") or ""
    if text ~= "" then
        local fontSize = self:getProp("fontSize") or 14
        local font = self:getProp("font")
        
        -- Configurar fonte
        if font then
            love.graphics.setFont(font)
        else
            love.graphics.setFont(love.graphics.newFont(fontSize))
        end
        
        -- Calcular posição do texto (centralizado)
        local textWidth = love.graphics.getFont():getWidth(text)
        local textHeight = love.graphics.getFont():getHeight()
        local textX = (width - textWidth) / 2
        local textY = (height - textHeight) / 2
        
        -- Desenhar texto
        love.graphics.setColor(self._props.textColor or {1, 1, 1, 1})
        love.graphics.print(text, textX, textY)
    end
end

-- Métodos específicos do botão
function Button:setText(text)
    self:setProp("text", text)
end

function Button:getText()
    return self:getProp("text")
end

function Button:setEnabled(enabled)
    Button.super.setEnabled(self, enabled)
    self:_scheduleRender()
end

function Button:setTextColor(color)
    self:setProp("textColor", color)
end

function Button:setBackgroundColor(color)
    self:setProp("backgroundColor", color)
end

function Button:setHoverColor(color)
    self:setProp("hoverColor", color)
end

function Button:setPressedColor(color)
    self:setProp("pressedColor", color)
end

-- Sobrescrever eventos de mouse para feedback visual
function Button:mousepressed(x, y, button)
    local result = Button.super.mousepressed(self, x, y, button)
    if result then
        self:_scheduleRender()
    end
    return result
end

function Button:mousereleased(x, y, button)
    local result = Button.super.mousereleased(self, x, y, button)
    if result or self._isPressed then
        self:_scheduleRender()
    end
    return result
end

function Button:mousemoved(x, y)
    local result = Button.super.mousemoved(self, x, y)
    return result
end

return Button