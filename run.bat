@echo off
echo LuaReact - Sistema de Programacao Reativa
echo Desenvolvido por: Bypass-dev
echo.

REM Verificar se Love2D esta instalado
love --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Love2D nao encontrado!
    echo.
    echo Por favor, instale o Love2D:
    echo 1. Acesse: https://love2d.org/
    echo 2. Baixe a versao mais recente
    echo 3. Instale e adicione ao PATH do sistema
    echo.
    echo Ou execute diretamente:
    echo "C:\Program Files\LOVE\love.exe" .
    echo.
    pause
    exit /b 1
)

echo Executando LuaReact...
echo.
love .

if %errorlevel% neq 0 (
    echo.
    echo Erro ao executar o projeto!
    pause
)
