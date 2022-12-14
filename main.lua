-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf("no")

-- Variable d'essai Coding
timerTitre = 0
showTitre = false

local scene = "titre"
require("titre")
require("level2")
-- Algo impact elements
function distance(x1, y1, x2, y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

-- Création MAP / drawn ligne 207
local MAP_LARGEUR = 20
local MAP_HAUTEUR = 15
local TILE_LARGEUR = 40
local TILE_HAUTEUR = 40
TILE_T = 40

MAP = {}
MAP =  {
              { 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 },
              { 1,1,3,3,0,0,0,3,3,0,0,0,1,1,1,1,1,1,1,0 },
              { 1,0,0,0,2,2,0,0,0,0,2,0,0,0,0,1,0,0,0,2 },
              { 1,2,0,0,3,3,3,3,3,0,0,0,0,0,0,1,0,0,2,0 },
              { 1,0,0,0,3,3,3,3,0,3,3,3,3,0,0,0,0,0,0,0 },
              { 1,0,0,0,0,3,3,3,2,3,3,0,0,0,0,1,0,0,3,3 },
              { 1,2,0,2,0,3,3,3,3,3,3,2,0,0,0,1,0,0,0,3 },
              { 1,2,2,0,0,3,3,3,0,0,3,0,0,0,0,1,1,0,0,0 },
              { 1,2,0,2,0,0,3,0,0,2,3,3,0,0,0,0,1,0,2,3 },
              { 1,0,0,0,2,0,0,0,3,0,0,0,3,0,0,0,1,0,0,3 },
              { 1,0,0,3,3,3,3,0,0,0,0,0,3,0,0,0,0,0,0,0 },
              { 1,0,0,0,0,3,3,3,0,0,0,0,3,0,0,0,1,0,0,0 },
              { 1,2,0,2,2,0,0,0,0,0,2,3,0,0,2,0,1,0,0,0 },
              { 1,1,1,3,3,3,3,3,0,0,3,3,1,1,1,1,1,1,1,3 },
              { 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 },
            }

MAP.Sprite_MAP = {}

-- Cadre de Visée 
local focus = {}
focus.X = love.mouse.getX()
focus.Y = love.mouse.getY()
focus.taille = 0.2

-- Algo de l'angle focus
function math.angle(x1,y1, x2,y2) 
    return math.atan2(y2-y1, x2-x1) 
end

-- Start Spawn
screenLargeur = love.graphics:getWidth()
screenHauteur = love.graphics:getHeight()

local spawnPlayer = {}
spawnPlayer.taille = 40
spawnPlayer.X = (10 * 40) - spawnPlayer.taille
spawnPlayer.Y = (14 * 40) - spawnPlayer.taille
spawnPlayer.angle = - math.pi / 2

-- Player Value / update ligne 117 / Draw ligne 173
local tank = {}
tank.X = spawnPlayer.X + (spawnPlayer.taille / 2)
tank.Y = spawnPlayer.Y + (spawnPlayer.taille / 2)
tank.angle = spawnPlayer.angle
tank.focus = 0
tank.Speed = 2
tank.tourelleX = 0
tank.tourelleY = 8
tank.ligne = 1
tank.colonne = 1
tank.map = 0
tank.armure = 1

-- mode Debug / keypress ligne 262 / draw ligne 226
debug = false
debug_Grille = false
debug_Tile = false
debug_Bloc = false
debug_Camouflage = false

-- Raccourcie clavier (Non utilisé)
leftMouse = "Off"
rightMouse = "Off"

-- Liste projectiles / Draw ligne 188 / Update ligne 143
    local projectiles = {}
-- Fonction Tir
function Shoot(pX, pY, pAngle, pVitesse, pImg, pOri)    
    local projectile = {}
          projectile.X = pX
          projectile.Y = pY
          projectile.angle = pAngle
          projectile.vitesse = pVitesse
          projectile.img = pImg
          projectile.origine = pOri
          projectile.ligne = 1
          projectile.colonne = 1
          projectile.map = 0
          projectile.aSupprimer = false
    table.insert(projectiles, projectile)
end

-- liste Ennemis / Gestion ligne 156
    local ennemis = {}
-- Fonction Spawn Ennemi / Call ligne 100 / Draw ligne 153
function SpanwEnnemi(pX, pY, pAngle, pTaille, pVitesse, pImg, pAI, pDist, pShoot, pMX)
    local ennemi = {}
          ennemi.X = pX
          ennemi.Y = pY
          ennemi.angle = pAngle
          ennemi.taille = pTaille
          ennemi.vitesse = pVitesse
          ennemi.vitesseR = pVitesse
          ennemi.img = pImg
          ennemi.AI = pAI
          ennemi.distance = pDist
          ennemi.shoot = pShoot
          ennemi.moveX = pMX
          ennemi.reboot = pDist
          ennemi.timerTir = 4
          ennemi.cadenceTir = 4
          ennemi.timer = 1
    table.insert(ennemis, ennemi)
end

-- liste bloc / *pour gérer les colision avec la map, les projectile étant dans une fonction, on ne peut pas se position sur la variable MAP*
    local obstacles = {}
-- fonction Obstacle / Call ligne 163 / draw ligne 434
function SpanwObstacle(pObsX, pObsY, pObsTL, pObsTH, pObsImg)
    local obstacle = {}
          obstacle.X = pObsX
          obstacle.Y = pObsY
          obstacle.TL = pObsTL
          obstacle.TH = pObsTH
          obstacle.img = pObsImg
    table.insert(obstacles, obstacle)
end

-- Détecte la colision
function Collision(pID)
    tank.map = MAP[tank.ligne][tank.colonne]
end

function Start()
    ennemis = {}
    projectiles = {}
    goal = {}
    tank.X = spawnPlayer.X + (spawnPlayer.taille / 2)
    tank.Y = spawnPlayer.Y + (spawnPlayer.taille / 2)
    tank.angle = spawnPlayer.angle
    tank.armure = 1
end


function love.load()
-- Fichier Image
    imgPlayer = love.graphics.newImage("img/Player/tank_Vert1.png")
    imgFocus = love.graphics.newImage("img/Player/tourelle1.png")
    imgProj_1 = love.graphics.newImage("img/Projectile/Tir_1.png")
    imgProj_2 = love.graphics.newImage("img/Projectile/Tir_2.png")
    imgEnnemi_1 = love.graphics.newImage("img/Ennemi/tank_Bleu1.png")
    imgTarget = love.graphics.newImage("img/UI/target_1.png")
    imgCross = love.graphics.newImage("img/UI/cross.png")
    imgCircle = love.graphics.newImage("img/UI/circle.png")
    imgPE = love.graphics.newImage("img/UI/PE.png")
    imgPI = love.graphics.newImage("img/UI/PI.png")
    imgDecompte = love.graphics.newImage("img/UI/decompte.png")
    imgFire = love.graphics.newImage("img/UI/fire.png")
    imgFond = love.graphics.newImage("img/UI/fondTank.jpeg")
    imgTitre = love.graphics.newImage("img/UI/titre.jpg")
    imgDemoT = love.graphics.newImage("img/UI/titre_demoT.png")
    imgGamecodeurT = love.graphics.newImage("img/UI/titre_gamecodeurT.png")
    imgGametankT = love.graphics.newImage("img/UI/titre_tankgameT.png")

-- Relancer le jeu
    Start()

    -- Terrain par tuile
    MAP.Sprite_MAP[0] = nil
    MAP.Sprite_MAP[1] = nil
    MAP.Sprite_MAP[2] = nil
    MAP.Sprite_MAP[3] = nil
    MAP.Sprite_MAP[4] = love.graphics.newImage("img/Terrain/road_3.png")
    MAP.Sprite_MAP[5] = love.graphics.newImage("img/Terrain/road_4.png")

    -- Fichier de la Carte
    imgMap = love.graphics.newImage("img/Map/02_Mirror_Islands.png")

    -- Evènement de terrain
    if distance(tank.X, tank.Y, 180, 540) < 20 then
        print("COLISION")
    end

-- Obstacle pour les projectiles / create ligne 122 / draw ligne 434 / paramètre ligne 288 dans un fichier a part 
    spanwObs = require("spawnObstacle")

-- Apparation des Ennemi
    -- Orientation spawn
    northWest = 7.5
    north = - math.pi 
    northEast = - math.pi / 2
    east = 0
    southEast = math.pi / 2
    south = math.pi / 2
    southWest = 4.5
    west =  - 3.15
    -- fonction + legende des paramètres ligne 67 / Draw ligne 153 dans un fichier a part 
    spanwEnn = require("spawnEnnemi")

-- Destination Trajet / Draw ligne 203 / Load ligne 180 / Update ligne 180
          goal = {}
          goal.X = 40
          goal.Y = 40
          goal.nbX = 18
          goal.nbY = 10
          goal.taille = 40
          goal.hit = false
end

function love.update(dt)
    if scene == "titre" then
        timerTitre = timerTitre + dt
        if math.ceil(timerTitre) ~= Second then
            showTitre = not showTitre
            Second = math.ceil(timerTitre)
        end
        updateMenu(dt)
        print(showTitre)
        print("Timer : " .. tostring(timerTitre)) 
    else

        -- Raccourcie Souris
        mouseR = love.mouse.isDown(2)
        mouseL = love.mouse.isDown(1)

        -- Raccourcie Clavier
        pressZ = love.keyboard.isDown("z")
        pressD = love.keyboard.isDown("d")
        pressS = love.keyboard.isDown("s")
        pressQ = love.keyboard.isDown("q")
        pressSpace = love.keyboard.isDown("space")
        
        -- Prérequis collision / enregistrer les anciennes valeurs
        old_X, old_Y = tank.X, tank.Y 

        -- Déplacer Tank Player
        -- Tourner a gauche
        if pressQ and pressZ or pressD and pressS then
            tank.angle = tank.angle - 0.05
        end
        -- Tourner a droite
        if pressD and pressZ or pressQ and pressS then
            tank.angle = tank.angle + 0.05
        end
        -- Avancer
        if pressZ then
            local ratio_X = math.cos(tank.angle)
            local ratio_Y = math.sin(tank.angle)
            tank.X = tank.X + (tank.Speed * ratio_X)
            tank.Y = tank.Y + (tank.Speed * ratio_Y)
        end
        -- Reculer
        if pressS then
            local ratio_X = math.cos(tank.angle)
            local ratio_Y = math.sin(tank.angle)
            tank.X = tank.X - (tank.Speed * ratio_X)
            tank.Y = tank.Y - (tank.Speed * ratio_Y)
        end

        -- Calcul la position du tank en ligne/colonne
        tank.colonne = math.floor((tank.X - 20) / TILE_LARGEUR) + 1
        tank.ligne = math.floor((tank.Y + 20) / TILE_HAUTEUR) + 1
        Collision()
        if tank.map == 1 or tank.map == 3 then
        -- print("MUR")
            tank.X = old_X
            tank.Y = old_Y
        else
        -- print("RAS")
        end

        -- Gestion Tir de Visée
        focus.X, focus.Y = love.mouse.getPosition()
        tank.focus = math.angle(tank.X, tank.Y, focus.X, focus.Y)

        -- Gestion des projectile / Draw ligne 188
        for k, projectile in ipairs(projectiles) do
            projectile.X = projectile.X + (dt * projectile.vitesse) * math.cos(projectile.angle)
            projectile.Y = projectile.Y + (dt * projectile.vitesse) * math.sin(projectile.angle)
            -- suppression du projectile lorsqu'il quitte l'écran
            if projectile.X > screenLargeur or projectile.X < 0 then
                projectile.aSupprimer = true
            end
            if projectile.Y > screenHauteur or projectile.Y < 0 then
                projectile.aSupprimer = true
            end
            if projectile.aSupprimer == false then
                local col = math.floor(projectile.X / TILE_LARGEUR) + 1
                local line = math.floor(projectile.Y / TILE_HAUTEUR) + 1
                if MAP[line][col] == 3 then
                    projectile.aSupprimer = true
                end
            end
        end
        if mouseR then
            if charge == false then
                timer = timer - dt
            end
        else
            timer = 4
            charge = false
        end
        if timer <= 0.9 and charge == false then
            charge = true
            Shoot(tank.X, tank.Y, tank.focus, 1000, imgProj_2, "player") 
            timer = 4
        end

        -- Gestion des Ennemis / create list at ligne 71 
        -- Parcours de la liste des ennemis
        for n = #ennemis, 1, -1 do
            local ennemiG = ennemis[n]
            local ennemiT = 30
        -- DÉPLACEMENT ENNEMI
            -- ETAT NORMAL
            if ennemiG.AI == "move" then
                local ratio_X = ennemiG.vitesse * math.cos(ennemiG.angle)
                local ratio_Y = ennemiG.vitesse * math.sin(ennemiG.angle)
                ennemiG.X = ennemiG.X + ratio_X * dt
                ennemiG.Y = ennemiG.Y + ratio_Y * dt
                ennemiG.distance = ennemiG.distance - dt
                -- DECLENCHEUR AI
                if distance(ennemiG.X, ennemiG.Y, tank.X, tank.Y) < 100 then
                    ennemiG.AI = "close"
                elseif ennemiG.distance <= 0.999 then
                    ennemiG.AI = "back"
                end
            -- AI repère le player
            elseif ennemiG.AI == "close" then
                -- angle entre l'ennemi et le player
                local anglePoursuite = math.angle(ennemiG.X, ennemiG.Y, tank.X, tank.Y)
                ennemiG.angle = anglePoursuite
                local ratio_X = ennemiG.vitesse * math.cos(anglePoursuite)
                local ratio_Y = ennemiG.vitesse * math.sin(anglePoursuite)
                ennemiG.vitesse = 0
                ennemiG.X = ennemiG.X + ratio_X * dt
                ennemiG.Y = ennemiG.Y + ratio_Y * dt
                if distance(ennemiG.X, ennemiG.Y, tank.X, tank.Y) > 150 then
                    ennemiG.vitesse = ennemiG.vitesseR
                    ennemiG.AI = "back"
                elseif distance(ennemiG.X, ennemiG.Y, tank.X, tank.Y) < 100 then
                    ennemiG.timer = ennemiG.timer - dt
                    print(ennemiG.timer)
                    if ennemiG.timer <= 0 then
                        ennemiG.AI = "attack"
                        ennemiG.timer = 2
                    end
                end
            -- AI MODE ATTAQUE
            elseif ennemiG.AI == "attack" then 
                local anglePoursuite = math.angle(ennemiG.X, ennemiG.Y, tank.X, tank.Y)
                ennemiG.angle = anglePoursuite
                local ratio_X = ennemiG.vitesse * math.cos(anglePoursuite)
                local ratio_Y = ennemiG.vitesse * math.sin(anglePoursuite)
                ennemiG.timerTir = ennemiG.timerTir - dt
                -- print(math.floor(ennemiG.timerTir))
                if ennemiG.timerTir <= 0.5 then
                    Shoot(ennemiG.X, ennemiG.Y, ennemiG.angle, 1000, imgProj_2, "ennemi")
                    ennemiG.timerTir = ennemiG.cadenceTir
                elseif distance(ennemiG.X, ennemiG.Y, tank.X, tank.Y) > 150 then
                    ennemiG.vitesse = ennemiG.vitesseR
                    ennemiG.AI = "back"
                end
            -- AI RETOUR EN ETAT NORMAL
            elseif ennemiG.AI == "back" then 
                if ennemiG.angle ~= west or ennemiG.angle ~= east then
                    ennemiG.angle = - ennemiG.angle
                end
                if ennemiG.angle == east then
                    ennemiG.angle = west
                elseif ennemiG.angle == - west then
                    ennemiG.angle = east
                end
                ennemiG.AI = "move"
                ennemiG.distance = ennemiG.reboot
            end

            -- Parcours de la liste des projectiles
            for k = #projectiles, 1, -1 do
                local projectileG = projectiles[k]
                -- Suppression du projectile et de l'ennemi après leur impact
                if distance(projectileG.X, projectileG.Y, ennemiG.X, ennemiG.Y) < ennemiT and projectileG.origine == "player" then
                    table.remove(ennemis, n)
                    projectileG.aSupprimer = true
                end
                -- Suppression du projectile et de l'ennemi après leur impact 2
                if distance(projectileG.X, projectileG.Y, tank.X, tank.Y) < 40 and projectileG.origine == "ennemi" then
                    tank.armure = tank.armure - 1
                    projectileG.aSupprimer = true
                end
            end
        end

        -- Gestion des Obstacles projectiles / create list at ligne 121 / call ligne 164
        -- Parcours de la liste des Obstacle
        for nbO = #obstacles, 1, -1 do
            local obstacleG = obstacles[nbO]
            local obstacleL = 10
            -- Parcours de la liste des projectiles
            for nbk = #projectiles, 1, -1 do
                local projectileG = projectiles[nbk]
                -- Suppression le projectile sur l'obstacle
                if distance(projectileG.X, projectileG.Y, obstacleG.X, obstacleG.Y) < obstacleL then
                    projectileG.aSupprimer = true
                end
            end
        end

        -- Supprimer un projectiles
        for n = #projectiles, 1, -1 do
            local projectile = projectiles[n]
            if projectile.aSupprimer then
                table.remove(projectiles, n)
            end
        end

        -- Condition de victoire par destination / load 1igne 116 / Draw ligne 202 
        if distance(tank.X, tank.Y, (goal.X * goal.nbX), (goal.Y * goal.nbY)) < 20 then
            goal.hit = true
            scene = "level2"
        -- Condition de victoire par destruction 
        elseif #ennemis <= 0 then
            goal.hit = true
            scene = "level2"
        end

        -- Condition de défaire
        if tank.armure <= 0 then
            scene = "titre"
            Start()
            SpanwEnnemi(100, 180, south, 0.225, 20, imgEnnemi_1, "move", 5)
            SpanwEnnemi(460, 100, east, 0.225, 20, imgEnnemi_1, "move", 5)
            SpanwEnnemi(540, 255, south, 0.225, 50, imgEnnemi_1, "move", 5)
            SpanwEnnemi(780, 140, south, 0.225, 20, imgEnnemi_1, "move", 3)
            SpanwEnnemi(700, 420, west, 0.225, 20, imgEnnemi_1, "move", 3)
        end
    end
end

function love.draw()
    if scene == "titre" then
        drawMenu()
        elseif scene == "level2" then
        drawLevel2()
        elseif scene == "game" then

        -- Afficher Carte
            love.graphics.draw(imgMap,0 ,0)

            -- Afficher un éléments par Tuile    
        c,l = nil  
        for l=1,MAP_HAUTEUR do
            for c=1,MAP_LARGEUR do
            local id = MAP[l][c]
            local spriteM = MAP.Sprite_MAP[id]
            if spriteM ~= nil then
                love.graphics.draw(spriteM, (c-1)*TILE_LARGEUR, (l-1)*TILE_HAUTEUR)
            end
            end
        end
        -- Afficher tank dissimuler
        if tank.map == 2 then
            -- print("CACHER !!")
            love.graphics.draw(imgFocus, tank.X + tank.tourelleX, tank.Y + tank.tourelleY, tank.focus, 0.2, 0.2)
        else
            -- Afficher le tank player -> paramètre ligne 30 / update 117
            love.graphics.draw(imgPlayer, tank.X, tank.Y, tank.angle, 0.2, 0.2, imgPlayer:getWidth() / 2, imgPlayer:getHeight() / 2)
            
            -- Afficher Tourelle -> paramètre ligne 30
                love.graphics.draw(imgFocus, tank.X + tank.tourelleX, tank.Y + tank.tourelleY, tank.focus, 0.2, 0.2, imgFocus:getWidth() / 4, imgFocus:getHeight() / 2)
        end


        -- Afficher les ennemis -> paramètre ligne 67 / call ligne 100
        for j, ennemi in ipairs(ennemis) do
            love.graphics.draw(ennemi.img, ennemi.X, ennemi.Y, ennemi.angle, ennemi.taille, ennemi.taille, ennemi.img:getWidth() / 2, ennemi.img:getHeight() / 2)
            if ennemi.AI == "close" then
                love.graphics.draw(imgPE, ennemi.X - 27, ennemi.Y - 54, 0, 0.8, 0.8)
            elseif ennemi.AI == "attack" then
                if ennemi.AI == "attack" then
                    if ennemi.timerTir <= 0.999 then
                        love.graphics.draw(imgFire, ennemi.X - 35, ennemi.Y - 54, 0, 0.6, 0.6)
                        love.graphics.setColor(1, 0, 0)
                        love.graphics.print("FEU", ennemi.X - 20, ennemi.Y - 49, 0, 1.5, 1.5)
                        love.graphics.setColor(1, 1, 1)
                    else
                        love.graphics.draw(imgDecompte, ennemi.X - 27, ennemi.Y - 54, 0, 0.8, 0.8)
                        love.graphics.setColor(1, 0, 0)
                        love.graphics.print(math.floor(ennemi.timerTir), ennemi.X - 16, ennemi.Y - 53, 0, 1.5, 1.5)
                        love.graphics.setColor(1, 1, 1)
                    end
                end
            elseif ennemi.AI == "surveillance" then
                love.graphics.draw(imgPI, ennemi.X - 27, ennemi.Y - 54, 0, 0.8, 0.8)
            end
        end

        -- Afficher la Visée -> paramètre ligne 12
        -- love.graphics.rectangle("line", focus.X - (focus.taille / 2), focus.Y - (focus.taille / 2), focus.taille, focus.taille) ANCIENNE VISÉE
        love.graphics.draw(imgTarget, focus.X - (focus.taille / 2), focus.Y - (focus.taille / 2), 0, focus.taille, focus.taille, imgTarget:getWidth() / 2, imgTarget:getHeight() / 2)

        -- Afficher projectile -> paramètre ligne 54 / update ligne 143
        for k, projectile in ipairs(projectiles) do
            love.graphics.draw(projectile.img, projectile.X, projectile.Y, projectile.angle, 1, 1, imgProj_1:getWidth() / 2, imgProj_1:getHeight() / 2)
        end    
        -- spriteMte Tir Chargé * goal.hit == false est ajouté pour évité la supersition du spriteMte GOOD !!*
        if mouseR and goal.hit == false then
            if mouseR and timer == 4 then
                love.graphics.print("BOUM !!", tank.X - 35, tank.Y - 50, 0, 1.5, 1.5)
            else
                love.graphics.print(math.floor(timer), tank.X - 8, tank.Y - 55, 0, 2, 2)
            end
        end

        -- spanw start
        love.graphics.print( "START", spawnPlayer.X - 10, spawnPlayer.Y - 25 , 0, 1.5, 1.5)
        love.graphics.rectangle("line", spawnPlayer.X, spawnPlayer.Y, spawnPlayer.taille, spawnPlayer.taille)

        -- Destination Trajet / load 1igne 116 / Update ligne 180
        love.graphics.print( "FINISH", (goal.X * goal.nbX) - 10,(goal.Y * goal.nbY) - 25 , 0, 1.5, 1.5)
        love.graphics.rectangle( "line", (goal.X * goal.nbX), (goal.Y * goal.nbY), goal.taille, goal.taille)
        if goal.hit == true then
            love.graphics.print("GOOD !!", tank.X - 35, tank.Y - 50, 0, 1.5, 1.5)
        end

        -- Afficher le debug / create variable ligne 49 / keypress ligne 262 
        if debug == true then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print("Click Gauche : " .. tostring(leftMouse) .. " Click Droit : " .. tostring(rightMouse))
            love.graphics.print("Valeur X : " .. tostring(tank.X), 0, (15 * 1))
            love.graphics.print("Valeur Y : " .. tostring(tank.Y), 0, (15 * 2))
            love.graphics.print("Valeur Angle : " .. tostring(tank.focus), 0, (15 * 3))
            love.graphics.print("Nb de projectiles : " .. tostring(#projectiles), 0, (15 * 4))
            love.graphics.print("X.Tank : " .. tostring(focus.X - (focus.taille / 2)), 0, (15 * 5))
            love.graphics.print("Y.Tank : " .. tostring(focus.Y - (focus.taille / 2)), 0, (15 * 6))
            love.graphics.print("Timer Shoot Spécial : " .. tostring(timer), 0, (15 * 7))
            love.graphics.print("Nb ennemi : " .. tostring(#ennemis), 0, (15 * 8))
            love.graphics.print("Valeur Grille X : " .. tostring(tank.colonne), 0, (15 * 9))
            love.graphics.print("Valeur Grille Y : " .. tostring(tank.ligne), 0, (15 * 10))

            -- Affichage à droite
            love.graphics.print("Largeur écran : " .. tostring(screenLargeur), screenLargeur - 123, (15 * 0))
            love.graphics.print("Hauteur écran : " .. tostring(screenHauteur), screenLargeur - 125, (15 * 1))
            love.graphics.print("Nb de tuile_X : " .. tostring(MAP_LARGEUR), screenLargeur - 110, (15 * 2))
            love.graphics.print("Nb de tuile_Y : " .. tostring(MAP_HAUTEUR), screenLargeur - 110, (15 * 3))
            love.graphics.print("Taille d'une tuile : " .. tostring(TILE_LARGEUR) .. " px", screenLargeur - 148, (15 * 4))

            -- Affichage position de la souris sur la grille
            local mX = love.mouse.getX()
            local mY = love.mouse.getY()
            local cM = math.floor(mX / TILE_LARGEUR) + 1
            local lM = math.floor(mY / TILE_HAUTEUR) + 1
            if lM > 0 and cM> 0 and lM <= MAP_HAUTEUR and cM<= MAP_LARGEUR then
                local idM = MAP[lM][cM]
                love.graphics.print("Ligne souris: " .. tostring(lM), 0, (15 * 11))
                love.graphics.print("Colonne souris: " .. tostring(cM), 0, (15 * 12))
                love.graphics.print("Case ID souris: "..tostring(idM), 0, (15 * 13))
            end

            -- Affichage position de Player sur la grille
            local tX = tank.X
            local tY = tank.Y
            local cT = math.floor(tX / TILE_LARGEUR) + 1
            local lT = math.floor(tY / TILE_HAUTEUR) + 1
            if lT > 0 and cT> 0 and lT <= MAP_HAUTEUR and cT<= MAP_LARGEUR then
                local idT = MAP[lT][cT]
                love.graphics.print("Ligne Tank: " .. tostring(lT), 0, (15 * 14))
                love.graphics.print("Colonne Tank: " .. tostring(cT), 0, (15 * 15))
                love.graphics.print("Case ID Tank: "..tostring(idT), 0, (15 * 16))
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
        
        -- Afficher la grille pour debug
        if debug_Grille == true then
            love.graphics.print("DEBUG GRILLE : ACTIVÉ", (screenLargeur / 2) - 120, 50, 0, 1.5, 1.5)
            for nbLigne_V = 1, MAP_LARGEUR do
                love.graphics.print(nbLigne_V - 1, (nbLigne_V * 40) - 40, 0, 0, 1, 1)
                love.graphics.line((nbLigne_V * TILE_LARGEUR), 0, (nbLigne_V * TILE_LARGEUR), 600)
            end
            for nbLigne_H = 1, MAP_HAUTEUR do
                love.graphics.print(nbLigne_H - 1, 0, (nbLigne_H * 40) - 40, 0, 1, 1)
                love.graphics.line( 0, (nbLigne_H * TILE_HAUTEUR), 800, (nbLigne_H * TILE_HAUTEUR))
            end
        end

        -- Afficher les collision contre le tank via la grille MAP
        if debug_Tile == true then 
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.print("DEBUG COLLISION : ACTIVÉ", (screenLargeur / 2) - 120, 80, 0, 1.5, 1.5)
            cD,lD = nil  
            for lD=1,MAP_HAUTEUR do
            for cD=1,MAP_LARGEUR do
                local idD = MAP[lD][cD]
                local spriteMD = idD
                if spriteMD == 1 or spriteMD == 3 then
                love.graphics.rectangle("fill", (cD-1)*TILE_LARGEUR, (lD-1)*TILE_HAUTEUR, 40, 40)
                end
            end
            end
            love.graphics.setColor(1, 1, 1, 1)
        end    
        -- Afficher les obstacles pour debug / Call ligne 163 // create ligne 122 /
        if debug_Bloc == true then
            love.graphics.print("DEBUG BLOC PROJECTILE : ACTIVÉ", (screenLargeur / 2) - 150, 90, 0, 1.5, 1.5)
            for i, obstacle in ipairs(obstacles) do
                --love.graphics.rectangle("fill", obstacle.X, obstacle.Y, obstacle.TL, obstacle.TH)
                love.graphics.draw(imgCross, obstacle.X, obstacle.Y, 0, 1, 1)
                -- love.graphics.draw(imgCross, obstacle.X, obstacle.Y, 0, obstacle.TL, obstacle.TH)

            end
        end
        -- Afficher les obstacles pour debug / Call ligne 163 // create ligne 122 /
        if debug_Camouflage == true then
            love.graphics.print("DEBUG BLOC HIDDEN : ACTIVÉ", (screenLargeur / 2) - 150, 90, 0, 1.5, 1.5)
            cD,lD = nil  
            for lD=1,MAP_HAUTEUR do
            for cD=1,MAP_LARGEUR do
                local idD = MAP[lD][cD]
                local spriteMD = idD
                if spriteMD == 2 then
                -- love.graphics.rectangle("fill", (cD-1)*TILE_LARGEUR, (lD-1)*TILE_HAUTEUR, 40, 40)
                love.graphics.draw(imgCircle, (cD-1)*TILE_LARGEUR, (lD-1)*TILE_HAUTEUR, 0, 1, 1)
                end
            end
            end
        end
        -- Afficher le timer déplacements des tanks
        if debug_ennemiDist == true then
            for i, ennemi in ipairs(ennemis) do
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print(math.floor(ennemi.distance), ennemi.X - 5, ennemi.Y - 45, 0, 1.5, 1.5)
            love.graphics.print(ennemi.AI, ennemi.X - 25, ennemi.Y + 15, 0, 1.5, 1.5)
            love.graphics.setColor(1, 1, 1, 1)
            end
        end

    end
end

function love.mousepressed(b)  

    -- Test Clique gauche (Remettre dans la MousePressed avec David)
    if love.mouse.isDown(1) then
        leftMouse = "Up"
        Shoot(tank.X, tank.Y, tank.focus, 700, imgProj_1, "player") 
    else
        leftMouse = "Off"
    end

    -- Test Clique droit (Remettre dans la MousePressed avec David)
    if love.mouse.isDown(2) then
        rightMouse = "Up"
    else
        rightMouse = "Off"
    end
end

function love.keypressed(key)  
    -- print(key)
    if key == "space" and scene == "titre" then
        scene = "game"
    elseif key == "escape" and scene ~= "titre" then
        scene = "titre"
    end
    -- Activer le Debug / create variable ligne 49 / draw ligne 226
    if love.keyboard.isDown("f1") then
        debug = not debug
    end  
    -- Méthode 2
    if love.keyboard.isDown("f2") then
        if debug_Grille == true then 
            debug_Grille = false
        else 
            debug_Grille = true
        end
    end

    if love.keyboard.isDown("f3") then
        debug_Tile = not debug_Tile
    end

    if love.keyboard.isDown("f4") then
        debug_Bloc = not debug_Bloc
    end

    if love.keyboard.isDown("f5") then
        debug_Camouflage = not debug_Camouflage
    end

    if love.keyboard.isDown("f6") then
        debug_ennemiDist = not debug_ennemiDist
    end


end
