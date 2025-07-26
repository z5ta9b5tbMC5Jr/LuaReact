--[[
    LuaReact - Text Widget
    Desenvolvido por: Bypass-dev
    
    Widget de texto reativo com suporte a alinhamento e quebra de linha
--]]

local ReactiveWidget = require('luareact.reactive_widget')
local Observable = require('luareact.observable')

local Text = ReactiveWidget:extend()

function Text:new(props)
    local instance = Text.super.new(self, props)
    
    -- Configurar propriedades específicas do texto
    instance:_setTextDefaults()
    
    -- Cache para dimensões do texto
    instance._textDimensions = {width = 0, height = 0}
    instance._wrappedText = {}
    instance._textDirty = true
    
    -- Aplicar propriedades fornecidas
    if props then
        for key, value in pairs(props) do
            instance:setProp(key, value)
        end
    end
    
    return instance
end

function Text:_setTextDefaults()
    -- Propriedades de texto
    self._props.text = "Text"
    self._props.fontSize = 14
    self._props.font = nil
    self._props.color = {0, 0, 0, 1} -- Preto
    
    -- Alinhamento
    self._props.align = "left" -- left, center, right
    self._props.valign = "top" -- top, middle, bottom
    
    -- Quebra de linha
    self._props.wrap = false
    self._props.lineHeight = 1.2
    self._props.maxWidth = nil
    
    -- Efeitos
    self._props.shadow = false
    self._props.shadowColor = {0, 0, 0, 0.5}
    self._props.shadowOffset = {1, 1}
    
    -- Calcular dimensões iniciais
    self:_calculateTextDimensions()
end

function Text:_onPropChanged(key, value)
    Text.super._onPropChanged(self, key, value)
    
    -- Marcar texto como sujo se propriedades relevantes mudaram
    if key == "text" or key == "fontSize" or key == "font" or 
       key == "wrap" or key == "maxWidth" or key == "lineHeight" then
        self._textDirty = true
        self:_calculateTextDimensions()
    end
end

function Text:_calculateTextDimensions()
    local text = self:getProp("text") or ""
    local fontSize = self:getProp("fontSize") or 14
    local wrap = self:getProp("wrap") or false
    local maxWidth = self:getProp("maxWidth")
    local lineHeight = self:getProp("lineHeight") or 1.2
    
    -- Configurar fonte
    local font = self:getProp("font")
    if font then
        love.graphics.setFont(font)
    else
        love.graphics.setFont(love.graphics.newFont(fontSize))
    end
    
    local currentFont = love.graphics.getFont()
    
    if wrap and maxWidth then
        -- Quebrar texto em linhas
        self._wrappedText = self:_wrapText(text, maxWidth)
        
        -- Calcular dimensões com quebra
        local totalHeight = 0
        local maxLineWidth = 0
        
        for _, line in ipairs(self._wrappedText) do
            local lineWidth = currentFont:getWidth(line)
            maxLineWidth = math.max(maxLineWidth, lineWidth)
            totalHeight = totalHeight + currentFont:getHeight() * lineHeight
        end
        
        self._textDimensions.width = maxLineWidth
        self._textDimensions.height = totalHeight
    else
        -- Texto em linha única
        self._wrappedText = {text}
        self._textDimensions.width = currentFont:getWidth(text)
        self._textDimensions.height = currentFont:getHeight()
    end
    
    -- Atualizar dimensões do widget se não foram definidas manualmente
    if not self._props.width or self._autoWidth then
        self._props.width = self._textDimensions.width
        self._autoWidth = true
    end
    
    if not self._props.height or self._autoHeight then
        self._props.height = self._textDimensions.height
        self._autoHeight = true
    end
    
    self._textDirty = false
end

function Text:_wrapText(text, maxWidth)
    local font = love.graphics.getFont()
    local words = {}
    local lines = {}
    
    -- Dividir texto em palavras
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end
    
    local currentLine = ""
    
    for _, word in ipairs(words) do
        local testLine = currentLine == "" and word or currentLine .. " " .. word
        local lineWidth = font:getWidth(testLine)
        
        if lineWidth <= maxWidth then
            currentLine = testLine
        else
            if currentLine ~= "" then
                table.insert(lines, currentLine)
                currentLine = word
            else
                -- Palavra muito longa, forçar quebra
                table.insert(lines, word)
            end
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

function Text:_doRender()
    if self._textDirty then
        self:_calculateTextDimensions()
    end
    
    local text = self:getProp("text") or ""
    if text == "" then
        return
    end
    
    local fontSize = self:getProp("fontSize") or 14
    local color = self:getProp("color") or {0, 0, 0, 1}
    local align = self:getProp("align") or "left"
    local valign = self:getProp("valign") or "top"
    local lineHeight = self:getProp("lineHeight") or 1.2
    local shadow = self:getProp("shadow") or false
    local shadowColor = self:getProp("shadowColor") or {0, 0, 0, 0.5}
    local shadowOffset = self:getProp("shadowOffset") or {1, 1}
    
    -- Configurar fonte
    local font = self:getProp("font")
    if font then
        love.graphics.setFont(font)
    else
        love.graphics.setFont(love.graphics.newFont(fontSize))
    end
    
    local currentFont = love.graphics.getFont()
    local fontHeight = currentFont:getHeight()
    
    -- Calcular posição inicial baseada no alinhamento vertical
    local startY = 0
    if valign == "middle" then
        startY = (self._props.height - self._textDimensions.height) / 2
    elseif valign == "bottom" then
        startY = self._props.height - self._textDimensions.height
    end
    
    -- Renderizar cada linha
    for i, line in ipairs(self._wrappedText) do
        local lineWidth = currentFont:getWidth(line)
        local y = startY + (i - 1) * fontHeight * lineHeight
        
        -- Calcular posição X baseada no alinhamento horizontal
        local x = 0
        if align == "center" then
            x = (self._props.width - lineWidth) / 2
        elseif align == "right" then
            x = self._props.width - lineWidth
        end
        
        -- Desenhar sombra se habilitada
        if shadow then
            love.graphics.setColor(shadowColor)
            love.graphics.print(line, x + shadowOffset[1], y + shadowOffset[2])
        end
        
        -- Desenhar texto principal
        love.graphics.setColor(color)
        love.graphics.print(line, x, y)
    end
end

-- Métodos específicos do texto
function Text:setText(text)
    self:setProp("text", text)
end

function Text:getText()
    return self:getProp("text")
end

function Text:setColor(color)
    self:setProp("color", color)
end

function Text:getColor()
    return self:getProp("color")
end

function Text:setFontSize(fontSize)
    self:setProp("fontSize", fontSize)
end

function Text:getFontSize()
    return self:getProp("fontSize")
end

function Text:setAlign(align)
    self:setProp("align", align)
end

function Text:getAlign()
    return self:getProp("align")
end

function Text:setWrap(wrap)
    self:setProp("wrap", wrap)
end

function Text:getWrap()
    return self:getProp("wrap")
end

function Text:setMaxWidth(maxWidth)
    self:setProp("maxWidth", maxWidth)
end

function Text:getMaxWidth()
    return self:getProp("maxWidth")
end

function Text:getTextDimensions()
    if self._textDirty then
        self:_calculateTextDimensions()
    end
    return self._textDimensions.width, self._textDimensions.height
end

return Text