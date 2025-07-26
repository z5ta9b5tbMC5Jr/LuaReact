--[[
    LuaReact - Input Widget
    Desenvolvido por: Bypass-dev
    
    Widget de entrada de texto reativo com suporte a cursor e seleção
--]]

local ReactiveWidget = require('luareact.reactive_widget')
local Observable = require('luareact.observable')

local Input = ReactiveWidget:extend()

function Input:new(props)
    local instance = Input.super.new(self, props)
    
    -- Estado interno do input
    instance._cursorPos = 0
    instance._selectionStart = 0
    instance._selectionEnd = 0
    instance._cursorBlinkTime = 0
    instance._cursorVisible = true
    instance._textLines = {""}
    instance._currentLine = 0
    instance._scrollX = 0
    instance._scrollY = 0
    
    -- Configurar propriedades específicas do input
    instance:_setInputDefaults()
    
    -- Aplicar propriedades fornecidas
    if props then
        for key, value in pairs(props) do
            instance:setProp(key, value)
        end
    end
    
    -- Atualizar linhas de texto inicial
    instance:_updateTextLines()
    
    return instance
end

function Input:_setInputDefaults()
    -- Propriedades de texto
    self._props.value = ""
    self._props.placeholder = ""
    self._props.fontSize = 14
    self._props.font = nil
    
    -- Cores
    self._props.textColor = {0, 0, 0, 1} -- Preto
    self._props.backgroundColor = {1, 1, 1, 1} -- Branco
    self._props.borderColor = {0.7, 0.7, 0.7, 1} -- Cinza claro
    self._props.focusedBorderColor = {0.2, 0.4, 0.8, 1} -- Azul
    self._props.placeholderColor = {0.6, 0.6, 0.6, 1} -- Cinza
    self._props.cursorColor = {0, 0, 0, 1} -- Preto
    self._props.selectionColor = {0.2, 0.4, 0.8, 0.3} -- Azul transparente
    
    -- Layout
    self._props.padding = 4
    self._props.borderWidth = 1
    
    -- Comportamento
    self._props.maxLength = nil
    self._props.multiline = false
    self._props.password = false
    self._props.readonly = false
    
    -- Callbacks
    self._props.onTextChanged = nil
    self._props.onEnterPressed = nil
    self._props.onValidate = nil
    
    -- Dimensões padrão
    self._props.width = 200
    self._props.height = 30
end

function Input:_onPropChanged(key, value)
    Input.super._onPropChanged(self, key, value)
    
    if key == "value" then
        self:_updateTextLines()
        
        -- Chamar callback de mudança de texto
        if self._props.onTextChanged then
            self._props.onTextChanged(self, value)
        end
    end
end

function Input:_updateTextLines()
    local value = self:getProp("value") or ""
    local multiline = self:getProp("multiline") or false
    
    if multiline then
        self._textLines = {}
        for line in value:gmatch("([^\n]*)\n?") do
            table.insert(self._textLines, line)
        end
        if #self._textLines == 0 then
            self._textLines = {""}
        end
    else
        -- Remover quebras de linha em modo single-line
        value = value:gsub("\n", "")
        self._textLines = {value}
        self._currentLine = 0
    end
    
    -- Ajustar posição do cursor
    self._cursorPos = math.min(self._cursorPos, #value)
end

function Input:update(dt)
    Input.super.update(self, dt)
    
    -- Atualizar piscar do cursor
    self._cursorBlinkTime = self._cursorBlinkTime + dt
    if self._cursorBlinkTime >= 0.5 then
        self._cursorVisible = not self._cursorVisible
        self._cursorBlinkTime = 0
        self:_scheduleRender()
    end
end

function Input:_doRender()
    local width = self._props.width or 200
    local height = self._props.height or 30
    local padding = self._props.padding or 4
    local borderWidth = self._props.borderWidth or 1
    
    -- Desenhar fundo
    love.graphics.setColor(self._props.backgroundColor or {1, 1, 1, 1})
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    -- Desenhar borda
    if borderWidth > 0 then
        local borderColor = self._isFocused and 
            (self._props.focusedBorderColor or {0.2, 0.4, 0.8, 1}) or 
            (self._props.borderColor or {0.7, 0.7, 0.7, 1})
        
        love.graphics.setColor(borderColor)
        love.graphics.setLineWidth(borderWidth)
        love.graphics.rectangle("line", 0, 0, width, height)
    end
    
    -- Configurar fonte
    local fontSize = self:getProp("fontSize") or 14
    local font = self:getProp("font")
    if font then
        love.graphics.setFont(font)
    else
        love.graphics.setFont(love.graphics.newFont(fontSize))
    end
    
    local currentFont = love.graphics.getFont()
    local fontHeight = currentFont:getHeight()
    
    -- Área de texto (dentro do padding)
    local textX = padding
    local textY = padding
    local textWidth = width - (padding * 2)
    local textHeight = height - (padding * 2)
    
    -- Configurar clipping para área de texto
    love.graphics.setScissor(textX, textY, textWidth, textHeight)
    
    local value = self:getProp("value") or ""
    local displayText = value
    
    -- Modo senha
    if self:getProp("password") then
        displayText = string.rep("*", #value)
    end
    
    -- Desenhar texto ou placeholder
    if displayText == "" and not self._isFocused then
        -- Desenhar placeholder
        local placeholder = self:getProp("placeholder") or ""
        if placeholder ~= "" then
            love.graphics.setColor(self._props.placeholderColor or {0.6, 0.6, 0.6, 1})
            love.graphics.print(placeholder, textX, textY)
        end
    else
        -- Desenhar texto
        love.graphics.setColor(self._props.textColor or {0, 0, 0, 1})
        
        if self:getProp("multiline") then
            -- Renderizar múltiplas linhas
            for i, line in ipairs(self._textLines) do
                local y = textY + (i - 1) * fontHeight
                love.graphics.print(line, textX - self._scrollX, y - self._scrollY)
            end
        else
            -- Renderizar linha única
            love.graphics.print(displayText, textX - self._scrollX, textY)
        end
    end
    
    -- Desenhar cursor se focado
    if self._isFocused and self._cursorVisible and not self:getProp("readonly") then
        local cursorX = textX - self._scrollX
        local cursorY = textY
        
        -- Calcular posição do cursor
        if self._cursorPos > 0 then
            local textBeforeCursor = displayText:sub(1, self._cursorPos)
            cursorX = cursorX + currentFont:getWidth(textBeforeCursor)
        end
        
        love.graphics.setColor(self._props.cursorColor or {0, 0, 0, 1})
        love.graphics.setLineWidth(1)
        love.graphics.line(cursorX, cursorY, cursorX, cursorY + fontHeight)
    end
    
    -- Remover clipping
    love.graphics.setScissor()
end

function Input:textinput(text)
    if not self._isFocused or self:getProp("readonly") then
        return false
    end
    
    local value = self:getProp("value") or ""
    local maxLength = self:getProp("maxLength")
    
    -- Verificar limite de caracteres
    if maxLength and #value >= maxLength then
        return true
    end
    
    -- Inserir texto na posição do cursor
    local newValue = value:sub(1, self._cursorPos) .. text .. value:sub(self._cursorPos + 1)
    
    -- Validar se necessário
    if self._props.onValidate then
        if not self._props.onValidate(newValue) then
            return true
        end
    end
    
    self:setProp("value", newValue)
    self._cursorPos = self._cursorPos + #text
    
    -- Resetar piscar do cursor
    self._cursorBlinkTime = 0
    self._cursorVisible = true
    
    self:_scheduleRender()
    return true
end

function Input:keypressed(key)
    if not self._isFocused then
        return false
    end
    
    local value = self:getProp("value") or ""
    local readonly = self:getProp("readonly") or false
    
    if key == "backspace" and not readonly then
        if self._cursorPos > 0 then
            local newValue = value:sub(1, self._cursorPos - 1) .. value:sub(self._cursorPos + 1)
            self:setProp("value", newValue)
            self._cursorPos = self._cursorPos - 1
        end
    elseif key == "delete" and not readonly then
        if self._cursorPos < #value then
            local newValue = value:sub(1, self._cursorPos) .. value:sub(self._cursorPos + 2)
            self:setProp("value", newValue)
        end
    elseif key == "left" then
        self._cursorPos = math.max(0, self._cursorPos - 1)
    elseif key == "right" then
        self._cursorPos = math.min(#value, self._cursorPos + 1)
    elseif key == "home" then
        self._cursorPos = 0
    elseif key == "end" then
        self._cursorPos = #value
    elseif key == "return" or key == "kpenter" then
        if self:getProp("multiline") and not readonly then
            local newValue = value:sub(1, self._cursorPos) .. "\n" .. value:sub(self._cursorPos + 1)
            self:setProp("value", newValue)
            self._cursorPos = self._cursorPos + 1
        elseif self._props.onEnterPressed then
            self._props.onEnterPressed(self)
        end
    else
        return false
    end
    
    -- Resetar piscar do cursor
    self._cursorBlinkTime = 0
    self._cursorVisible = true
    
    self:_scheduleRender()
    return true
end

function Input:mousepressed(x, y, button)
    local result = Input.super.mousepressed(self, x, y, button)
    
    if result and button == 1 then
        -- Calcular posição do cursor baseada no clique
        local padding = self._props.padding or 4
        local textX = x - self._props.x - padding + self._scrollX
        
        -- Configurar fonte
        local fontSize = self:getProp("fontSize") or 14
        local font = self:getProp("font")
        if font then
            love.graphics.setFont(font)
        else
            love.graphics.setFont(love.graphics.newFont(fontSize))
        end
        
        local value = self:getProp("value") or ""
        local displayText = self:getProp("password") and string.rep("*", #value) or value
        
        -- Encontrar posição do cursor mais próxima
        local bestPos = 0
        local bestDistance = math.huge
        
        for i = 0, #displayText do
            local textWidth = love.graphics.getFont():getWidth(displayText:sub(1, i))
            local distance = math.abs(textX - textWidth)
            
            if distance < bestDistance then
                bestDistance = distance
                bestPos = i
            end
        end
        
        self._cursorPos = bestPos
        self._cursorBlinkTime = 0
        self._cursorVisible = true
        
        self:focus()
        self:_scheduleRender()
    end
    
    return result
end

-- Métodos específicos do input
function Input:getValue()
    return self:getProp("value")
end

function Input:setValue(value)
    self:setProp("value", value or "")
end

function Input:clear()
    self:setValue("")
    self._cursorPos = 0
end

function Input:selectAll()
    local value = self:getProp("value") or ""
    self._selectionStart = 0
    self._selectionEnd = #value
    self._cursorPos = #value
end

function Input:setPlaceholder(placeholder)
    self:setProp("placeholder", placeholder)
end

function Input:getPlaceholder()
    return self:getProp("placeholder")
end

function Input:setReadonly(readonly)
    self:setProp("readonly", readonly)
end

function Input:isReadonly()
    return self:getProp("readonly") or false
end

function Input:setMultiline(multiline)
    self:setProp("multiline", multiline)
end

function Input:isMultiline()
    return self:getProp("multiline") or false
end

return Input