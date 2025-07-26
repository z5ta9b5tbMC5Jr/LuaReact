--[[
    LuaReact - Observable
    Desenvolvido por: Bypass-dev
    
    Sistema de observables reativos com rastreamento automático de dependências
--]]

local Observable = {}
Observable.__index = Observable

-- Importar o rastreador de dependências
local DependencyTracker = require('luareact.dependency_tracker')

function Observable:new(initialValue)
    local instance = {
        _value = initialValue,
        _watchers = {},
        _isComputed = false,
        _computeFn = nil,
        _dependencies = {},
        _isDisposed = false,
        _lastComputedValue = nil,
        _isComputing = false
    }
    setmetatable(instance, self)
    return instance
end

function Observable:computed(computeFn)
    local instance = self:new(nil)
    instance._isComputed = true
    instance._computeFn = computeFn
    instance._dependencies = {}
    
    -- Calcular valor inicial
    instance:_recompute()
    
    return instance
end

function Observable:get()
    if self._isDisposed then
        return nil
    end
    
    -- Registrar dependência se estivermos dentro de um computed
    DependencyTracker.track(self)
    
    if self._isComputed then
        -- Verificar se precisa recalcular
        if self._lastComputedValue == nil then
            self:_recompute()
        end
        return self._lastComputedValue
    end
    
    return self._value
end

function Observable:set(newValue)
    if self._isDisposed then
        return
    end
    
    if self._isComputed then
        error("Cannot set value on computed observable")
    end
    
    local oldValue = self._value
    if oldValue ~= newValue then
        self._value = newValue
        self:_notifyWatchers(newValue, oldValue)
        
        -- Notificar o rastreador de dependências
        DependencyTracker.trigger(self)
    end
end

function Observable:watch(callback)
    if self._isDisposed then
        return function() end
    end
    
    table.insert(self._watchers, callback)
    
    -- Retornar função para remover o watcher
    return function()
        for i, watcher in ipairs(self._watchers) do
            if watcher == callback then
                table.remove(self._watchers, i)
                break
            end
        end
    end
end

function Observable:_recompute()
    if self._isComputing then
        error("Circular dependency detected in computed observable")
    end
    
    self._isComputing = true
    
    -- Limpar dependências antigas
    for _, dep in ipairs(self._dependencies) do
        DependencyTracker.untrack(dep, self)
    end
    self._dependencies = {}
    
    -- Começar rastreamento de dependências
    DependencyTracker.startTracking(self)
    
    local success, result = pcall(self._computeFn)
    
    -- Parar rastreamento
    local newDeps = DependencyTracker.stopTracking()
    
    self._isComputing = false
    
    if success then
        local oldValue = self._lastComputedValue
        self._lastComputedValue = result
        self._dependencies = newDeps
        
        -- Notificar watchers se o valor mudou
        if oldValue ~= result then
            self:_notifyWatchers(result, oldValue)
            DependencyTracker.trigger(self)
        end
    else
        error("Error in computed observable: " .. tostring(result))
    end
end

function Observable:_notifyWatchers(newValue, oldValue)
    -- Usar corrotina para notificações assíncronas
    local co = coroutine.create(function()
        for _, callback in ipairs(self._watchers) do
            local success, err = pcall(callback, newValue, oldValue)
            if not success then
                print("Error in observable watcher: " .. tostring(err))
            end
            coroutine.yield()
        end
    end)
    
    -- Executar a corrotina
    local function runCoroutine()
        if coroutine.status(co) ~= "dead" then
            coroutine.resume(co)
            if coroutine.status(co) ~= "dead" then
                -- Continuar na próxima frame
                love.timer.sleep(0.001)
                runCoroutine()
            end
        end
    end
    
    runCoroutine()
end

function Observable:dispose()
    if self._isDisposed then
        return
    end
    
    self._isDisposed = true
    
    -- Limpar watchers
    self._watchers = {}
    
    -- Limpar dependências
    for _, dep in ipairs(self._dependencies) do
        DependencyTracker.untrack(dep, self)
    end
    self._dependencies = {}
    
    -- Remover do rastreador global
    DependencyTracker.cleanup(self)
    
    -- Limpar valores
    self._value = nil
    self._lastComputedValue = nil
    self._computeFn = nil
end

-- Método para verificar se é um observable
function Observable:isObservable()
    return true
end

-- Função utilitária para verificar se um valor é observable
function Observable.isObservableValue(value)
    return type(value) == "table" and value.isObservable and value:isObservable()
end

return Observable