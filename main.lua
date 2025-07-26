--[[
    LuaReact - Main
    Desenvolvido por: Bypass-dev
    
    Integração com Love2D e ponto de entrada principal
--]]

local LuaReact = require('luareact')

-- Carregar exemplo (altere aqui para trocar de exemplo)
local example = require('examples.basic_example')
-- local example = require('examples.advanced_example')

function love.load()
    -- Configurar janela
    love.window.setTitle("LuaReact - Sistema de Programação Reativa")
    
    -- Carregar exemplo
    example.load()
    
    print("LuaReact carregado com sucesso!")
    print("Desenvolvido por: Bypass-dev")
end

function love.update(dt)
    -- Atualizar sistema LuaReact
    LuaReact.update(dt)
    
    -- Atualizar exemplo
    if example.update then
        example.update(dt)
    end
end

function love.draw()
    -- Desenhar exemplo
    if example.draw then
        example.draw()
    end
end

function love.mousepressed(x, y, button)
    if example.mousepressed then
        example.mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if example.mousereleased then
        example.mousereleased(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if example.mousemoved then
        example.mousemoved(x, y)
    end
end

function love.textinput(text)
    if example.textinput then
        example.textinput(text)
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- Teclas globais
    if key == "escape" then
        love.event.quit()
    elseif key == "r" and love.keyboard.isDown("lctrl", "rctrl") then
        -- Recarregar exemplo (Ctrl+R)
        if example.cleanup then
            example.cleanup()
        end
        
        -- Recarregar módulo
        package.loaded['examples.basic_example'] = nil
        package.loaded['examples.advanced_example'] = nil
        
        -- Recarregar exemplo atual
        example = require('examples.basic_example')
        example.load()
        
        print("Exemplo recarregado!")
        return
    end
    
    -- Passar para o exemplo
    if example.keypressed then
        example.keypressed(key)
    end
end

function love.quit()
    print("Encerrando LuaReact...")
    
    -- Limpar exemplo
    if example.cleanup then
        example.cleanup()
    end
    
    -- Limpar sistema LuaReact
    if LuaReact.cleanup then
        LuaReact.cleanup()
    end
    
    print("LuaReact encerrado com sucesso!")
    return false -- Permitir que o Love2D encerre normalmente
end

function love.errhand(msg)
    print("Erro no LuaReact: " .. tostring(msg))
    print(debug.traceback())
    
    -- Tentar limpar recursos
    if example and example.cleanup then
        pcall(example.cleanup)
    end
    
    -- Chamar o handler de erro padrão do Love2D
    return love.errhand(msg)
end