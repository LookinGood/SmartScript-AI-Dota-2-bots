---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("bot_name_generic", package.seeall)

-- Глобальные таблицы
_used_bot_names = _used_bot_names or {} -- Для сохранения имён между играми
_generated_names_table = {}             -- Таблица для текущего набора имён

-- Компоненты имён
_name_components = {
    prefixes = { "Pro228", "Meme", "Cursed", "Easy", "Nice", "Legendary" },
    suffixes = { "GPT-4", "Acc Buyer", "FireFrog", "Admin", "Lord", "Kek", "Account", "DevoDeAL", "Murdage", "Vilverin", "Barracuda", "Sezam", "Gwinblade",  },
    separators = { "", "-", "_", ".", " " }
}

function GetBotName()
    local required_names = 10 -- Количество имён для генерации
    local max_attempts = 200  -- Макс. попыток на 1 имя

    -- Генерация новых имён только если таблица пуста
    if #_generated_names_table == 0
    then
        for i = 1, required_names do
            local attempts = 0
            local new_name

            -- Генерация уникального имени
            repeat
                attempts = attempts + 1
                local prefix = _name_components.prefixes[RandomInt(1, #_name_components.prefixes)]
                local suffix = _name_components.suffixes[RandomInt(1, #_name_components.suffixes)]
                local separator = _name_components.separators[RandomInt(1, #_name_components.separators)]
                new_name = prefix .. separator .. suffix

                -- Если закончились попытки - фолбэк
                if attempts > max_attempts
                then
                    new_name = "Bot_" .. tostring(RandomInt(10000, 99999))
                    break;
                end
            until not _used_bot_names[new_name]

            -- Добавляем в таблицы
            table.insert(_generated_names_table, new_name)
            _used_bot_names[new_name] = true
        end
    end

    return _generated_names_table;
end


--[[ local function GetBotNameOld()
    if (GetTeam() == TEAM_RADIANT) then
        name =
        { "DevoDeAL",
            "Murdage",
            "Vilverin-Talekon",
            "Barracuda",
            "O tempora, o mores!",
        }
    elseif (GetTeam() == TEAM_DIRE) then
        name =
        {
            "Cursed account",
            "GPT-4",
            "Road_to_228_MMR",
            "<<Acc Buyer>>",
            "iadmireyou",
        }
    end
    return name;
end ]]

---------------------------------------------------------------------------------------------------
for k, v in pairs(bot_name_generic) do _G._savedEnv[k] = v end
