--[[
    LuaReact - DependencyTracker
    Desenvolvido por: Bypass-dev
    
    Sistema global de rastreamento de dependências para observables
--]]

local DependencyTracker = {
    _currentTarget = nil,
    _trackingStack = {},
    _dependencies = {},
    _dependents = {},
    _isTracking = false
}

-- Iniciar rastreamento de dependências para um target (computed observable)
function DependencyTracker.startTracking(target)
    table.insert(DependencyTracker._trackingStack, DependencyTracker._currentTarget)
    DependencyTracker._currentTarget = target
    DependencyTracker._isTracking = true
end

-- Parar rastreamento e retornar dependências coletadas
function DependencyTracker.stopTracking()
    local target = DependencyTracker._currentTarget
    DependencyTracker._currentTarget = table.remove(DependencyTracker._trackingStack)
    
    if #DependencyTracker._trackingStack == 0 then
        DependencyTracker._isTracking = false
    end
    
    -- Retornar lista de dependências para o target
    return DependencyTracker._dependencies[target] or {}
end

-- Registrar uma dependência
function DependencyTracker.track(observable, target)
    target = target or DependencyTracker._currentTarget
    
    if not target or not DependencyTracker._isTracking then
        return
    end
    
    -- Inicializar estruturas se necessário
    if not DependencyTracker._dependencies[target] then
        DependencyTracker._dependencies[target] = {}
    end
    
    if not DependencyTracker._dependents[observable] then
        DependencyTracker._dependents[observable] = {}
    end
    
    -- Adicionar dependência (evitar duplicatas)
    local deps = DependencyTracker._dependencies[target]
    local found = false
    for _, dep in ipairs(deps) do
        if dep == observable then
            found = true
            break
        end
    end
    
    if not found then
        table.insert(deps, observable)
    end
    
    -- Adicionar dependente (evitar duplicatas)
    local dependents = DependencyTracker._dependents[observable]
    found = false
    for _, dep in ipairs(dependents) do
        if dep == target then
            found = true
            break
        end
    end
    
    if not found then
        table.insert(dependents, target)
    end
end

-- Remover uma dependência
function DependencyTracker.untrack(observable, target)
    -- Remover da lista de dependências do target
    if DependencyTracker._dependencies[target] then
        local deps = DependencyTracker._dependencies[target]
        for i = #deps, 1, -1 do
            if deps[i] == observable then
                table.remove(deps, i)
            end
        end
    end
    
    -- Remover da lista de dependentes do observable
    if DependencyTracker._dependents[observable] then
        local dependents = DependencyTracker._dependents[observable]
        for i = #dependents, 1, -1 do
            if dependents[i] == target then
                table.remove(dependents, i)
            end
        end
    end
end

-- Limpar todas as dependências de um target
function DependencyTracker.clearDependencies(target)
    if DependencyTracker._dependencies[target] then
        -- Remover target de todos os observables dependentes
        for _, observable in ipairs(DependencyTracker._dependencies[target]) do
            DependencyTracker.untrack(observable, target)
        end
        
        DependencyTracker._dependencies[target] = nil
    end
end

-- Disparar notificações para todos os dependentes de um observable
function DependencyTracker.trigger(observable)
    if not DependencyTracker._dependents[observable] then
        return
    end
    
    -- Criar cópia da lista para evitar modificações durante iteração
    local dependents = {}
    for _, dependent in ipairs(DependencyTracker._dependents[observable]) do
        table.insert(dependents, dependent)
    end
    
    -- Notificar todos os dependentes
    for _, dependent in ipairs(dependents) do
        if dependent and dependent._recompute then
            -- Usar corrotina para evitar stack overflow em dependências profundas
            local co = coroutine.create(function()
                local success, err = pcall(function()
                    dependent:_recompute()
                end)
                
                if not success then
                    print("Error in dependency update: " .. tostring(err))
                end
            end)
            
            coroutine.resume(co)
        end
    end
end

-- Limpeza global
function DependencyTracker.cleanup(target)
    if target then
        -- Limpar dependências específicas de um target
        DependencyTracker.clearDependencies(target)
        
        -- Remover target de todas as listas de dependentes
        for observable, dependents in pairs(DependencyTracker._dependents) do
            for i = #dependents, 1, -1 do
                if dependents[i] == target then
                    table.remove(dependents, i)
                end
            end
        end
    else
        -- Limpeza completa
        DependencyTracker._dependencies = {}
        DependencyTracker._dependents = {}
        DependencyTracker._currentTarget = nil
        DependencyTracker._trackingStack = {}
        DependencyTracker._isTracking = false
    end
end

-- Função para debug - mostrar estado atual
function DependencyTracker.debug()
    print("=== Dependency Tracker Debug ===")
    print("Current target:", DependencyTracker._currentTarget)
    print("Is tracking:", DependencyTracker._isTracking)
    print("Tracking stack size:", #DependencyTracker._trackingStack)
    
    print("\nDependencies:")
    for target, deps in pairs(DependencyTracker._dependencies) do
        print("  Target:", target, "-> Dependencies:", #deps)
    end
    
    print("\nDependents:")
    for observable, dependents in pairs(DependencyTracker._dependents) do
        print("  Observable:", observable, "-> Dependents:", #dependents)
    end
    print("================================")
end

-- Verificar se há dependências circulares
function DependencyTracker.checkCircularDependencies()
    local visited = {}
    local recursionStack = {}
    
    local function dfs(target)
        if recursionStack[target] then
            return true -- Dependência circular encontrada
        end
        
        if visited[target] then
            return false
        end
        
        visited[target] = true
        recursionStack[target] = true
        
        if DependencyTracker._dependencies[target] then
            for _, dep in ipairs(DependencyTracker._dependencies[target]) do
                if DependencyTracker._dependents[dep] then
                    for _, dependent in ipairs(DependencyTracker._dependents[dep]) do
                        if dfs(dependent) then
                            return true
                        end
                    end
                end
            end
        end
        
        recursionStack[target] = false
        return false
    end
    
    for target, _ in pairs(DependencyTracker._dependencies) do
        if dfs(target) then
            return true
        end
    end
    
    return false
end

return DependencyTracker