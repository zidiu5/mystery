local library = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"))

-- Konfiguration der Ziel-IDs (8000, 8001, 8002)
local targetIds = {["8000"] = true, ["8001"] = true, ["8002"] = true}

local function deleteAllAtOnce()
    local save = library.Save.Get()
    local uidsToDelete = {}

    print("--- MASS-DELETE (ALL-IN-ONE) GESTARTET ---")

    -- 1. Alle UIDs sammeln
    if save and save.Pets then
        for _, data in pairs(save.Pets) do
            if type(data) == "table" and targetIds[tostring(data.id)] then
                -- Nur hinzufügen, wenn nicht gelockt und UID vorhanden
                if not data.l and data.uid then
                    table.insert(uidsToDelete, data.uid)
                end
            end
        end
    end

    -- 2. Alles in einem einzigen Request senden
    if #uidsToDelete > 0 then
        print("Sende Löschbefehl für " .. #uidsToDelete .. " Pets gleichzeitig...")
        
        local success, err = pcall(function()
            -- Wir schicken die gesamte Tabelle direkt
            game:GetService("ReplicatedStorage"):WaitForChild("Delete Several Pets"):InvokeServer(uidsToDelete)
        end)

        if success then
            print("Erfolg! Der Server hat alle " .. #uidsToDelete .. " Pets verarbeitet.")
        else
            warn("Fehler: Der Server hat das große Paket abgelehnt: " .. tostring(err))
        end
    else
        print("Keine passenden Pets gefunden.")
    end
end

-- Ausführung
deleteAllAtOnce()
