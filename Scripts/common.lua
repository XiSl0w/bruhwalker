local Class = function(...)
    local cls = {}
    cls.__index = cls
    function cls:New(...)
        local instance = setmetatable({}, cls)
        cls.__init(instance, ...)
        return instance
    end
    cls.__call = function(_, ...) return cls:New(...) end
    return setmetatable(cls, {__call = cls.__call})
end

local Common = Class()
local myHero = game.local_player
local version = 1
local base_url = "https://raw.githubusercontent.com/XiSl0w/bruhwalker/main/"
local common_dir = "\\brrrrAIO\\Common\\"
local script_name = "common"

-----------------
-- Point class --

local function IsPoint(p)
    return p and p.x and type(p.x) == "number"
            and p.y and type(p.y) == "number"
            and p.type and p.type == "Point"
end
-----------------------------------------------------------------------------------------------

local function IsUnit(p)
    return p ~= nil and type(p) ~= "number" and (p.path
        and p.path.server_pos ~= nil or p.origin ~= nil)
end
-----------------------------------------------------------------------------------------------

local function Round(v)
    return floor(v + 0.5) -- always positive number
end
-----------------------------------------------------------------------------------------------

local Point = Class()

function Point:__init(x, y)
    self.type = "Point"
    if x and IsUnit(x) then
        local p = x.path ~= nil and
            x.path.server_pos or x.origin
        self.x, self.y = p.x, p.z or p.y
    elseif x and y then
        self.x, self.y = x, y
    elseif x and not y then
        self.x, self.y = x.x, x.z or x.y
    else
        self.x, self.y = 0, 0
    end
end
-----------------------------------------------------------------------------------------------

function Point:__tostring()
    return string.format("%d %d", self.x, self.y)
end
----------------------------------------------------------------------------------------

function Point:__eq(p)
    return math.abs(self.x - p.x) < 1
        and math.abs(self.y - p.y) < 1
end
-----------------------------------------------------------------------------------------------

function Point:__add(p)
    return Point:New(self.x + p.x, self.y + p.y)
end
-----------------------------------------------------------------------------------------------

function Point:__sub(p)
    return Point:New(self.x - p.x, self.y - p.y)
end
-----------------------------------------------------------------------------------------------

function Point.__mul(a, b)
    if type(a) == "number" and IsPoint(b) then
        return Point:New(b.x * a, b.y * a)
    elseif type(b) == "number" and IsPoint(a) then
        return Point:New(a.x * b, a.y * b)
    end
    error("Multiplication error!")
end
-----------------------------------------------------------------------------------------------

function Point.__div(a, b)
    if type(a) == "number" and IsPoint(b) then
        return Point:New(a / b.x, a / b.y)
    elseif type(b) == "number" and IsPoint(a) then
        return Point:New(a.x / b, a.y / b)
    end
    error("Division error!")
end
-----------------------------------------------------------------------------------------------

function Point:__tostring()
    return string.format("(%f, %f)", self.x, self.y)
end
-----------------------------------------------------------------------------------------------

function Point:AngleBetween(p1, p2)
    local angle = math.deg(
        math.atan(p2.y - self.y, p2.x - self.x) -
        math.atan(p1.y - self.y, p1.x - self.x))
    if angle < 0 then angle = angle + 360 end
    return angle > 180 and 360 - angle or angle
end
-----------------------------------------------------------------------------------------------

function Point:Append(p, dist)
    if dist == 0 then return p:Clone() end
    return p + (p - self):Normalize() * dist
end
-----------------------------------------------------------------------------------------------

function Point:Clone()
    return Point:New(self.x, self.y)
end
-----------------------------------------------------------------------------------------------

function Point:ClosestOnSegment(s1, s2)
    local ap, ab = self - s1, s2 - s1
    local t = ap:DotProduct(ab) / ab:LengthSquared()
    return t < 0 and s1 or t > 1 and s2 or (s1 + ab * t)
end
-----------------------------------------------------------------------------------------------

function Point:CrossProduct(p)
    return self.x * p.y - self.y * p.x
end
-----------------------------------------------------------------------------------------------

function Point:DistanceSquared(p)
    local dx, dy = p.x - self.x, p.y - self.y
    return dx * dx + dy * dy
end
-----------------------------------------------------------------------------------------------

function Point:Distance(p)
    return math.sqrt(self:DistanceSquared(p))
end
-----------------------------------------------------------------------------------------------

function Point:DotProduct(p)
    return self.x * p.x + self.y * p.y
end
-----------------------------------------------------------------------------------------------

function Point:Extend(p, dist)
    if dist == 0 then return self:Clone() end
    return self + (p - self):Normalize() * dist
end
-----------------------------------------------------------------------------------------------

function Point:InPolygon(poly)
    local size, result = #poly, false
    for i = 1, size do
        local a, b = poly[i], poly[i % size + 1]
        if a.y <= self.y and b.y >= self.y or
            b.y <= self.y and a.y >= self.y then
            local ap, ab = self - a, b - a 
            if a.x + ap.y / ab.y * ab.x <= self.x then
                result = not result
            end
        end
    end
    return result
end
-----------------------------------------------------------------------------------------------

function Point:Intersection(a2, b1, b2)
    local a, b = a2 - self, b2 - b1
    local axb = a:CrossProduct(b)
    if axb == 0 then return nil end
    local bsa = b1 - self
    local t1 = bsa:CrossProduct(b) / axb
    local t2 = bsa:CrossProduct(a) / axb
    return t1 >= 0 and t1 <= 1 and t2 >= 0
        and t2 <= 1 and self + a * t1 or nil
end
-----------------------------------------------------------------------------------------------

function Point:IsZero()
    return self.x == 0 and self.y == 0
end
-----------------------------------------------------------------------------------------------

function Point:LengthSquared(p)
    local p = p and p:Clone() or self
    return p.x * p.x + p.y * p.y
end
-----------------------------------------------------------------------------------------------

function Point:Length(p)
    return math.sqrt(self:LengthSquared(p))
end
-----------------------------------------------------------------------------------------------

function Point:Negate()
    return Point:New(-self.x, -self.y)
end
-----------------------------------------------------------------------------------------------

function Point:Normalize()
    local len = self:Length()
    if len == 0 then return Point:New() end
    return Point:New(self.x / len, self.y / len)
end
-----------------------------------------------------------------------------------------------

function Point:Perpendicular()
    return Point:New(-self.y, self.x)
end
-----------------------------------------------------------------------------------------------

function Point:Perpendicular2()
    return Point:New(self.y, -self.x)
end
-----------------------------------------------------------------------------------------------

function Point:Rotate(phi, p)
    local c = math.cos(phi)
    local s = math.sin(phi)
    local p = p or Point:New()
    local d = self - p
    local x = c * d.x - s * d.y + p.x
    local y = s * d.x + c * d.y + p.y
    return Point:New(x, y)
end
-----------------------------------------------------------------------------------------------

function Point:To3D(y)
    local y = y or myHero.origin.y
    return vec3.new(self.x, y, self.y)
end

--------------------------------


local function ParseFunc(func)
    if func == nil then return function(x) return x end end
    if type(func) == "function" then return func end
    local index = string.find(func, "=>")
    local arg = string.sub(func, 1, index - 1)
    local func = string.sub(func, index + 2, #func)
    return load(string.format("return function"
        .. " %s return %s end", arg, func))()
end

local function Linq(tab)
    return setmetatable(tab or {}, {__index = table})
end

function table.All(source, func)
    local func = ParseFunc(func)
    for index, value in ipairs(source) do
        if not func(value, index) then
            return false
        end
    end
    return true
end

function table.Any(source, func)
    local func = ParseFunc(func)
    for index, value in ipairs(source) do
        if func(value, index) then
            return true
        end
    end
    return false
end

function table.Concat(first, second)
    local result, index = Linq(), 0
    for _, value in ipairs(first) do
        index = index + 1
        result[index] = value
    end
    for _, value in ipairs(second) do
        index = index + 1
        result[index] = value
    end
    return result
end

function table.Distinct(source)
    local result = Linq()
    local hash, index = {}, 0
    for _, value in ipairs(source) do
        if hash[value] == nil then
            index = index + 1
            result[index] = value
            hash[value] = true
        end
    end
    return result
end

function table.First(source, func)
    local func = ParseFunc(func)
    for index, value in ipairs(source) do
        if func(value, index) then
            return value
        end
    end
    return nil
end

function table.ForEach(source, func)
    for index, value in pairs(source) do
        func(value, index)
    end
end

function table.Last(source, func)
    local func = ParseFunc(func)
    for index = #source, 1, -1 do
        local value = source[index]
        if func(value, index) then
            return value
        end
    end
    return nil
end

function table.Select(source, func)
    local result = Linq()
    local func = ParseFunc(func)
    for index, value in ipairs(source) do
        result[index] = func(value, index)
    end
    return result
end

function table.Where(source, func)
    local result, iteration = Linq(), 0
    local func = ParseFunc(func)
    for index, value in ipairs(source) do
        if func(value, index) then
            iteration = iteration + 1
            result[iteration] = value
        end
    end
    return result
end

function Common:__init()
    self.heroPassives = {
        ["Aatrox"] = function(args) local source = args.source
            if not source:has_buff("aatroxpassiveready") then return end
            args.rawPhysical = args.rawPhysical + (4.59 + 0.41
                * source.level) * 0.01 * args.unit.max_health
        end,
        ["Akali"] = function(args) local source = args.source
            if not source:has_buff("akalishadowstate") then return end
            local mod = ({35, 38, 41, 44, 47, 50, 53, 62, 71, 80,
                89, 98, 107, 122, 137, 152, 167, 182})[source.level]
            args.rawMagical = args.rawMagical + mod + 0.55 *
                source.ability_power + 0.6 * source.bonus_attack_damage
        end,
        ["Akshan"] = function(args) local source = args.source
            local buff = args.unit:get_buff("AkshanPassiveDebuff")
            if not buff or buff.count ~= 2 then return end
            local mod = ({20, 25, 30, 35, 40, 45, 50, 55, 65, 75,
                85, 95, 105, 115, 130, 145, 160, 175})[source.level]
            args.rawMagical = args.rawMagical + mod
        end,
        ["Ashe"] = function(args) local source = args.source
            local totalDmg = source.total_attack_damage
            local slowed = args.unit:has_buff("ashepassiveslow")
            local mod = 0.0075 + (source:has_item(3031) and 0.0035 or 0)
            local percent = slowed and 0.1 + source.crit_chance * mod or 0
            args.rawPhysical = args.rawPhysical + percent * totalDmg
            if not source:has_buff("AsheQAttack") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical * (1 + 0.05 * lvl)
        end,
        ["Bard"] = function(args) local source = args.source
            if not source:has_buff("bardpspiritammocount") then return end
            local chimes = source:get_buff("bardpdisplaychimecount")
            if not chimes or chimes.count <= 0 then return end
            args.rawMagical = args.rawMagical + (12 * math.floor(
                chimes.count / 5)) + 30 + 0.3 * source.ability_power
        end,
        ["Blitzcrank"] = function(args) local source = args.source
            if not source:has_buff("PowerFist") then return end
            args.rawPhysical = args.rawPhysical + source.total_attack_damage
        end,
        ["Braum"] = function(args) local source = args.source
            local buff = args.unit:get_buff("BraumMark")
            if not buff or buff.count ~= 3 then return end
            args.rawMagical = args.rawMagical + 16 + 10 * source.level
        end,
        ["Caitlyn"] = function(args) local source = args.source
            if not source:has_buff("caitlynpassivedriver") then return end
            local mod = 1.09375 + (source:has_item(3031) and 0.21875 or 0)
            args.rawPhysical = args.rawPhysical + (1 + (mod * 0.01 *
                source.crit_chance)) * source.total_attack_damage
        end,
        ["Camille"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            if source:has_buff("CamilleQ") then
                args.rawPhysical = args.rawPhysical + (0.15 +
                    0.05 * lvl) * source.total_attack_damage
            elseif source:has_buff("CamilleQ2") then
                args.trueDamage = args.trueDamage + math.min(
                    0.36 + 0.04 * source.level, 1) * (0.3 +
                    0.1 * lvl) * source.total_attack_damage
            end
        end,
        ["Chogath"] = function(args) local source = args.source
            if not source:has_buff("VorpalSpikes") then return end
            local lvl = spellbook:get_spell_slot(SLOT_E).level
            args.rawMagical = args.rawMagical + 10 + 12 * lvl + 0.3 *
                source.ability_power + 0.03 * args.unit.max_health
        end,
        ["Darius"] = function(args) local source = args.source
            if not source:has_buff("DariusNoxianTacticsONH") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawPhysical = args.rawPhysical + (0.35 +
                0.05 * lvl) * source.total_attack_damage
        end,
        ["Diana"] = function(args) local source = args.source
            local buff = source:get_buff("dianapassivemarker")
            if not buff or buff.count ~= 2 then return end
            local mod = ({20, 25, 30, 35, 40, 55, 65, 75, 85,
                95, 120, 135, 150, 165, 180, 210, 230, 250})[source.level]
            args.rawMagical = args.rawMagical + mod + 0.4 * source.ability_power
        end,
        ["Draven"] = function(args) local source = args.source
            if not source:has_buff("DravenSpinningAttack") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 35 + 5 * lvl +
                (0.6 + 0.1 * lvl) * source.bonus_attack_damage
        end,
        ["DrMundo"] = function(args) local source = args.source
            if not source:has_buff("DrMundoE") then return end
            --[[ local lvl = spellbook:get_spell_slot(SLOT_E).level
            local bonusHealth = source.max_health - (494 + source.level * 89)
            args.rawPhysical = args.rawPhysical + (0.14 * bonusHealth - 10
                + 20 * lvl) * (1 + 1.5 * math.min((source.max_health
                - source.health) / source.max_health, 0.4)) --]]
        end,
        ["Ekko"] = function(args) local source = args.source
            local buff = args.unit:get_buff("ekkostacks")
            if buff ~= nil and buff.count == 2 then
                local mod = ({30, 40, 50, 60, 70, 80, 85, 90, 95, 100,
                    105, 110, 115, 120, 125, 130, 135, 140})[source.level]
                args.rawMagical = args.rawMagical + mod + 0.8 * source.ability_power
            end
            if source:has_buff("ekkoeattackbuff") then
                local lvl = spellbook:get_spell_slot(SLOT_E).level
                args.rawMagical = args.rawMagical + 25 +
                    25 * lvl + 0.4 * source.ability_power
            end
        end,
        ["Fizz"] = function(args) local source = args.source
            if not source:has_buff("FizzW") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawMagical = args.rawMagical + 30 +
                20 * lvl + 0.5 * source.ability_power
        end,
        ["Galio"] = function(args) local source = args.source
            if not source:has_buff("galiopassivebuff") then return end
            --[[ local bonusResist = source.mr - (30.75 + 1.25 * source.level)
            args.rawMagical, args.rawPhysical = args.rawMagical + 4.12 +
                10.88 * source.level + source.total_attack_damage +
                0.5 * source.ability_power + 0.6 * bonusResist, 0 --]]
        end,
        ["Garen"] = function(args) local source = args.source
            if not source:has_buff("GarenQ") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 30 *
                lvl + 0.5 * source.total_attack_damage
        end,
        ["Gnar"] = function(args) local source = args.source
            local buff = args.unit:get_buff("gnarwproc")
            if not buff or buff.count ~= 2 then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawMagical = args.rawMagical - 10 + 10 * lvl + (0.04 +
                0.02 * lvl) * args.unit.max_health + source.ability_power
        end,
        ["Gragas"] = function(args) local source = args.source
            if not source:has_buff("gragaswattackbuff") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawMagical = args.rawMagical - 10 + 30 * lvl + 0.07
                * args.unit.max_health + 0.7 * source.ability_power
        end,
        ["Gwen"] = function(args) local source = args.source
            args.rawMagical = args.rawMagical + (0.01 + 0.008 *
                0.01 * source.ability_power) * args.unit.max_health
            if args.unit.health / args.unit.max_health <= 0.4
                and args.unit.champ_name:find("Minion") then
                local mod = 6.71 + 1.29 * source.level
                args.rawPhysical = args.rawPhysical + mod
            elseif not args.unit.champ_name:find("Minion") then
                args.rawMagical = math.max(args.rawMagical,
                    10 + 0.25 * source.ability_power)
            end
        end,
        ["Illaoi"] = function(args) local source = args.source
            if not source:has_buff("IllaoiW") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            local damage = math.min(300, math.max(10 + 10 * lvl,
                args.unit.max_health * (0.025 + 0.005 * lvl
                + 0.0002 * source.total_attack_damage)))
            args.rawPhysical = args.rawPhysical + damage
        end,
        ["Irelia"] = function(args) local source = args.source
            local buff = source:get_buff("ireliapassivestacks")
            if not buff or buff.count ~= 4 then return end
            args.rawMagical = args.rawMagical + 7 + 3 *
                source.level + 0.3 * source.bonus_attack_damage
        end,
        ["JarvanIV"] = function(args) local source = args.source
            if not args.unit:has_buff("jarvanivmartialcadencecheck") then return end
            local damage = math.min(400, math.max(20, 0.1 * args.unit.health))
            args.rawPhysical = args.rawPhysical + damage
        end,
        ["Jax"] = function(args) local source = args.source
            if source:has_buff("JaxEmpowerTwo") then
                local lvl = spellbook:get_spell_slot(SLOT_W).level
                args.rawMagical = args.rawMagical + 5 +
                    35 * lvl + 0.6 * source.ability_power
            end
            if source:has_buff("JaxRelentlessAssault") then
                local lvl = spellbook:get_spell_slot(SLOT_R).level
                args.rawMagical = args.rawMagical + 60 +
                    40 * lvl + 0.7 * source.ability_power
            end
        end,
        ["Jayce"] = function(args) local source = args.source
            if source:has_buff("JaycePassiveMeleeAttack") then
                local mod = ({25, 25, 25, 25, 25, 65,
                    65, 65, 65, 65, 105, 105, 105, 105,
                    105, 145, 145, 145})[source.level]
                args.rawMagical = args.rawMagical + mod
                    + 0.25 * source.bonus_attack_damage
            end -- JayceHyperCharge buff count not working?
        end,
        ["Jhin"] = function(args) local source = args.source
            if not source:has_buff("jhinpassiveattackbuff") then return end
            local missingHealth, mod = args.unit.max_health - args.unit.health,
                source.level < 6 and 0.15 or source.level < 11 and 0.2 or 0.25
            args.rawPhysical = args.rawPhysical + mod * missingHealth
        end,
        ["Jinx"] = function(args) local source = args.source
            if not source:has_buff("JinxQ") then return end
            args.rawPhysical = args.rawPhysical
                + source.total_attack_damage * 0.1
        end,
        ["Kaisa"] = function(args) local source = args.source
            local buff = args.unit:get_buff("kaisapassivemarker")
            local count = buff ~= nil and buff.count or 0
            local damage = ({1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3,
                4, 4, 4, 4, 5, 5, 5})[source.level] * count +
                (0.075 - 0.025 * count) * source.ability_power
            if count == 4 then damage = damage +
                (0.15 + (0.025 * source.ability_power / 100)) *
                (args.unit.max_health - args.unit.health) end
            args.rawMagical = args.rawMagical + damage
        end,
        ["Kassadin"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            if source:has_buff("NetherBlade") then
                args.rawMagical = args.rawMagical + 45 +
                    25 * lvl + 0.8 * source.ability_power
            elseif lvl > 0 then
                args.rawMagical = args.rawMagical +
                    20 + 0.1 * source.ability_power
            end
        end,
        ["Kayle"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_E).level
            if lvl > 0 then args.rawMagical = args.rawMagical
                + 10 + 5 * lvl + 0.2 * source.ability_power
                + 0.1 * source.bonus_attack_damage end
            if source:has_buff("JudicatorRighteousFury") then
                args.rawMagical = args.rawMagical + (7 + lvl +
                    source.ability_power * 0.01 * 2) * 0.01 *
                    (args.unit.max_health - args.unit.health)
            end
        end,
        ["Kennen"] = function(args) local source = args.source
            if not source:has_buff("kennendoublestrikelive") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawMagical = args.rawMagical + 10 + 10 * lvl + (0.5 + 0.1 *
                lvl) * source.bonus_attack_damage + 0.25 * source.ability_power
        end,
        ["KogMaw"] = function(args) local source = args.source
            if not source:has_buff("KogMawBioArcaneBarrage") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawMagical = args.rawMagical + (0.02 + 0.01 * lvl +
                0.0001 * source.ability_power) * args.unit.max_health
        end,
        ["Leona"] = function(args) local source = args.source
            if not source:has_buff("LeonaSolarFlare") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawMagical = args.rawMagical - 15 +
                25 * lvl + 0.3 * source.ability_power
        end,
        ["Lux"] = function(args) local source = args.source
            if not args.unit:has_buff("LuxIlluminatingFraulein") then return end
            args.rawMagical = args.rawMagical + 10 + 10 *
                source.level + 0.2 * source.ability_power
        end,
        ["Malphite"] = function(args) local source = args.source
            if not source:has_buff("MalphiteCleave") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawPhysical = args.rawPhysical + 15 + 15 * lvl
                + 0.2 * source.ability_power + 0.1 * source.armor
        end,
        ["MasterYi"] = function(args) local source = args.source
            if not source:has_buff("wujustylesuperchargedvisual") then return end
            local lvl = spellbook:get_spell_slot(SLOT_E).level
            args.trueDamage = args.trueDamage + 20 + 10 *
                lvl + 0.35 * source.bonus_attack_damage
        end,
        -- MissFortune - can't detect buff ??
        ["Mordekaiser"] = function(args) local source = args.source
            args.rawMagical = args.rawMagical + 0.4 * source.ability_power
        end,
        ["Nami"] = function(args) local source = args.source
            if not source:has_buff("NamiE") then return end
            local lvl = spellbook:get_spell_slot(SLOT_E).level
            args.rawMagical = args.rawMagical + 10 +
                15 * lvl + 0.2 * source.ability_power
        end,
        ["Nasus"] = function(args) local source = args.source
            if not source:has_buff("NasusQ") then return end
            local buff = source:get_buff("NasusQStacks")
            local stacks = buff ~= nil and buff.count or 0
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 10 + 20 * lvl + stacks
        end,
        ["Nautilus"] = function(args) local source = args.source
            if args.unit:has_buff("nautiluspassivecheck") then return end
            args.rawPhysical = args.rawPhysical + 2 + 6 * source.level
        end,
        ["Nidalee"] = function(args) local source = args.source
            if not source:has_buff("Takedown") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawMagical = args.rawMagical + (-20 + 25 *
                lvl + 0.75 * source.total_attack_damage + 0.4 *
                source.ability_power) * ((args.unit.max_health -
                args.unit.health) / args.unit.max_health + 1)
            if args.unit:has_buff("NidaleePassiveHunted") then
                args.rawMagical = args.rawMagical * 1.4 end
            args.rawPhysical = 0
        end,
        ["Neeko"] = function(args) local source = args.source
            if not source:has_buff("neekowpassiveready") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawMagical = args.rawMagical + 30 +
                20 * lvl + 0.6 * source.ability_power
        end,
        ["Nocturne"] = function(args) local source = args.source
            if not source:has_buff("nocturneumbrablades") then return end
            args.rawPhysical = args.rawPhysical + 0.2 * source.total_attack_damage
        end,
        ["Orianna"] = function(args) local source = args.source
            args.rawMagical = args.rawMagical + 2 + math.ceil(
                source.level / 3) * 8 + 0.15 * source.ability_power
            local buff = source:get_buff("orianapowerdaggerdisplay")
            if not buff or buff.count == 0 then return end
            args.rawMagical = raw.rawMagical * (1 + 0.2 * buff.count)
        end,
        ["Poppy"] = function(args) local source = args.source
            if not source:has_buff("poppypassivebuff") then return end
            args.rawMagical = args.rawMagical + 10.59 + 9.41 * source.level
        end,
        ["Quinn"] = function(args) local source = args.source
            if not args.unit:has_buff("QuinnW") then return end
            args.rawPhysical = args.rawPhysical + 5 + 5 * source.level +
                (0.14 + 0.02 * source.level) * source.total_attack_damage
        end,
        ["RekSai"] = function(args) local source = args.source
            if not source:has_buff("RekSaiQ") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 15 + 6 *
                lvl + 0.5 * source.bonus_attack_damage
        end,
        ["Rell"] = function(args) local source = args.source
            args.rawMagical = args.rawMagical + 7.53 + 0.47 * source.level
            if not source:has_buff("RellWEmpoweredAttack") then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawMagical = args.rawMagical - 5 +
                15 * lvl + 0.4 * source.ability_power
        end,
        ["Rengar"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            if source:has_buff("RengarQ") then
                args.rawPhysical = args.rawPhysical + 30 * lvl +
                    (-0.05 + 0.05 * lvl) * source.total_attack_damage
            elseif source:has_buff("RengarQEmp") then
                local mod = ({30, 45, 60, 75, 90, 105,
                    120, 135, 145, 155, 165, 175, 185,
                    195, 205, 215, 225, 235})[source.level]
                args.rawPhysical = args.rawPhysical +
                    mod + 0.4 * source.total_attack_damage
            end
        end,
        ["Riven"] = function(args) local source = args.source
            if not source:has_buff("RivenPassiveAABoost") then return end
            args.rawPhysical = args.rawPhysical + (source.level >= 6 and 0.36 + 0.06 *
                math.floor((source.level - 6) / 3) or 0.3) * source.total_attack_damage
        end,
        ["Rumble"] = function(args) local source = args.source
            if not source:has_buff("RumbleOverheat") then return end
            args.rawMagical = args.rawMagical + 2.94 + 2.06 * source.level
                + 0.25 * source.ability_power + 0.06 * args.unit.max_health
        end,
        ["Sett"] = function(args) local source = args.source
            if not source:has_buff("SettQ") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical +
                10 * lvl + (0.01 + (0.005 + 0.005 * lvl) * 0.01 *
                source.total_attack_damage) * args.unit.max_health
        end,
        ["Shaco"] = function(args) local source = args.source
            local turned = not self:IsFacing(args.unit, source)
            if turned then args.rawPhysical = args.rawPhysical + 19.12 +
                0.88 * source.level + 0.15 * source.bonus_attack_damage end
            if not source:has_buff("Deceive") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 15 +
                10 * lvl + 0.25 * source.bonus_attack_damage
            local mod = 0.3 + (source:has_item(3031) and 0.35 or 0)
            if turned then args.rawPhysical = args.rawPhysical
                + mod * source.total_attack_damage end
        end,
        -- Seraphine
        ["Shen"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            if source:has_buff("shenqbuffweak") then
                args.rawMagical = args.rawMagical + 4 + 6 * math.ceil(
                    source.level / 3) + (0.015 + 0.005 * lvl + 0.015 *
                    source.ability_power / 100) * args.unit.max_health
            elseif source:has_buff("shenqbuffstrong") then
                args.rawMagical = args.rawMagical + 4 + 6 * math.ceil(
                    source.level / 3) + (0.045 + 0.005 * lvl + 0.02 *
                    source.ability_power / 100) * args.unit.max_health
            end
        end,
        ["Shyvana"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_E).level
            if source:has_buff("ShyvanaDoubleAttack") then
                args.rawPhysical = args.rawPhysical + (0.05 + 0.15 * lvl) *
                    source.total_attack_damage + 0.25 * source.ability_power
            end
            if args.unit:has_buff("ShyvanaFireballMissile") then
                local damage = 0.0375 * args.unit.max_health
                if args.unit.is_minion == true and
                    not args.unit.champ_name:find("Minion")
                    and damage > 150 then damage = 150 end
                args.rawMagical = args.rawMagical + damage
            end
        end,
        ["Skarner"] = function(args) local source = args.source
            if not source:has_buff("skarnerpassivebuff") then return end
            local lvl = spellbook:get_spell_slot(SLOT_E).level
            args.rawPhysical = args.rawPhysical + 10 + 20 * lvl
        end,
        ["Sona"] = function(args) local source = args.source
            if source:has_buff("SonaQProcAttacker") then
                local lvl = spellbook:get_spell_slot(SLOT_Q).level
                args.rawMagical = args.rawMagical + 5 +
                    5 * lvl + 0.2 * source.ability_power
            end -- SonaPassiveReady
        end,
        ["Sylas"] = function(args) local source = args.source
            if not source:has_buff("SylasPassiveAttack") then return end
            args.rawMagical, args.rawPhysical = source.ability_power
                * 0.25 + source.total_attack_damage * 1.3, 0
        end,
        ["TahmKench"] = function(args) local source = args.source
            args.rawMagical = args.rawMagical + 4.94 + 3.06 * source.level
                + 0.025 * (source.max_health - (475 + 95 * source.level))
        end,
        ["Taric"] = function(args) local source = args.source
            if not source:has_buff("taricgemcraftbuff") then return end
            args.rawMagical = args.rawMagical + 21 + 4 *
                source.level + 0.15 * source.bonus_armor
        end,
        ["Teemo"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_E).level
            if lvl == 0 then return end
            local damage = 3 + 11 * lvl + 0.3 * source.ability_power
            local mod = not args.unit.champ_name:find("Minion")
                and args.unit.is_minion == true and 1.5 or 1
            args.rawMagical = args.rawMagical + mod * damage
        end,
        ["Trundle"] = function(args) local source = args.source
            if not source:has_buff("TrundleTrollSmash") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 20 * lvl +
                (0.05 + 0.1 * lvl) * source.total_attack_damage
        end,
        ["TwistedFate"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            if source:has_buff("BlueCardPreAttack") then
                args.rawMagical = args.rawMagical + 20 + 20 * lvl +
                    source.total_attack_damage + 0.9 * source.ability_power
            elseif source:has_buff("RedCardPreAttack") then
                args.rawMagical = args.rawMagical + 15 + 15 * lvl +
                    source.total_attack_damage + 0.6 * source.ability_power
            elseif source:has_buff("GoldCardPreAttack") then
                args.rawMagical = args.rawMagical + 7.5 + 7.5 * lvl +
                    source.total_attack_damage + 0.5 * source.ability_power
            end
            if args.rawMagical > 0 then args.rawPhysical = 0 end
            if source:has_buff("cardmasterstackparticle") then
                local lvl = spellbook:get_spell_slot(SLOT_E).level
                args.rawMagical = args.rawMagical + 40 +
                    25 * lvl + 0.5 * source.ability_power
            end
        end,
        ["Varus"] = function(args) local source = args.source
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            if lvl > 0 then args.rawMagical = args.rawMagical +
                6 + lvl + 0.25 * source.ability_power end
        end,
        ["Vayne"] = function(args) local source = args.source
            if source:has_buff("vaynetumblebonus") then
                local lvl = spellbook:get_spell_slot(SLOT_Q).level
                local bonus = source.bonus_attack_damage
                local mod = (1.55 + 0.05 * lvl) * bonus
                args.rawPhysical = args.rawPhysical + mod
            end
            local buff = args.unit:get_buff("VayneSilveredDebuff")
            if not buff or buff.count ~= 2 then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            local damage = math.max((0.015 + 0.025 * lvl)
                * args.unit.max_health, 35 + 15 * lvl)
            if not args.unit.champ_name:find("Minion")
                and args.unit.is_minion == true and
                damage > 200 then damage = 200 end
            args.trueDamage = args.trueDamage + damage
        end,
        -- Vex
        ["Vi"] = function(args) local source = args.source
            if source:has_buff("ViE") then
                local lvl = spellbook:get_spell_slot(SLOT_E).level
                --[[ args.rawPhysical = 20 * lvl - 10 + source.ability_power
                    * 0.9 + 1.1 * source.total_attack_damage --]]
            end
            local buff = args.unit:get_buff("viwproc")
            if not buff or buff.count ~= 2 then return end
            local lvl = spellbook:get_spell_slot(SLOT_W).level
            args.rawPhysical = args.rawPhysical + (0.04 + 0.015 * lvl + 0.01
                * source.bonus_attack_damage / 35) * args.unit.max_health
        end,
        ["Viego"] = function(args) local source = args.source
            --[[ local lvl = spellbook:get_spell_slot(SLOT_Q).level
            if lvl > 0 then args.rawPhysical = args.rawPhysical + math.max(
                5 + 5 * lvl, (0.01 + 0.01 * lvl) * args.unit.health) end --]]
        end,
        ["Viktor"] = function(args) local source = args.source
            if not source:has_buff("ViktorPowerTransferReturn") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawMagical, args.rawPhysical = args.rawMagical - 5 + 25 * lvl
                + source.total_attack_damage + 0.6 * source.ability_power, 0
        end,
        ["Volibear"] = function(args) local source = args.source
            if not source:has_buff("volibearpapplicator") then return end
            local mod = ({11, 12, 13, 15, 17, 19, 22, 25,
                28, 31, 34, 37, 40, 44, 48, 52, 56, 60})[source.level]
            args.rawMagical = args.rawMagical + mod + 0.4 * source.ability_power
        end,
        ["Warwick"] = function(args) local source = args.source
            args.rawMagical = args.rawMagical + 10 + 2 * source.level + 0.15
                * source.bonus_attack_damage + 0.1 * source.ability_power
        end,
        ["MonkeyKing"] = function(args) local source = args.source
            if not source:has_buff("MonkeyKingDoubleAttack") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical - 5 +
                25 * lvl + 0.45 * source.bonus_attack_damage
        end,
        ["XinZhao"] = function(args) local source = args.source
            if not source:has_buff("XinZhaoQ") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 7 +
                9 * lvl + 0.4 * source.bonus_attack_damage
        end,
        -- Yone
        ["Yorick"] = function(args) local source = args.source
            if not source:has_buff("yorickqbuff") then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = args.rawPhysical + 5 +
                25 * lvl + 0.4 * source.total_attack_damage
        end,
        -- Zed
        ["Zeri"] = function(args) local source = args.source
            if not spellbook:can_cast(SLOT_Q) then return end
            local lvl = spellbook:get_spell_slot(SLOT_Q).level
            args.rawPhysical = 5 + 5 * lvl + 1.1 * myHero.total_attack_damage
        end,
        ["Ziggs"] = function(args) local source = args.source
            if not source:has_buff("ZiggsShortFuse") then return end
            local mod = ({20, 24, 28, 32, 36, 40, 48, 56, 64,
                72, 80, 88, 100, 112, 124, 136, 148, 160})[source.level]
            args.rawMagical = args.rawMagical + mod + 0.5 * source.ability_power
        end,
        ["Zoe"] = function(args) local source = args.source
            if not source:has_buff("zoepassivesheenbuff") then return end
            local mod = ({16, 20, 24, 28, 32, 36, 42, 48, 54,
                60, 66, 74, 82, 90, 100, 110, 120, 130})[source.level]
            args.rawMagical = args.rawMagical + mod + 0.2 * source.ability_power
        end
    }
    self.itemPassives = {
        [3504] = function(args) local source = args.source -- Ardent Censer
            if not source:has_buff("3504Buff") then return end
            args.rawMagical = args.rawMagical + 4.12 + 0.88 * args.unit.level
        end,
        [3153] = function(args) local source = args.source -- Blade of the Ruined King
            local damage = math.min(math.max((source.is_melee
                and 0.1 or 0.06) * args.unit.health, 15), 60)
            args.rawPhysical = args.rawPhysical + damage
        end,
        [6632] = function(args) local source = args.source -- Divine Sunderer
            if not source:has_buff("6632buff") then return end
            local attackDmg = source.total_attack_damage
            local mod = source.is_melee and 0.12 or 0.09
            local damage = math.min(attackDmg
                * 1.5, mod * args.unit.max_health)
            if not args.unit.champ_name:find("Minion")
                and args.unit.is_minion and damage > 2.5 *
                attackDmg then damage = 2.5 * attackDmg end
            args.rawPhysical = args.rawPhysical + damage
        end,
        [1056] = function(args) -- Doran's Ring
            args.rawPhysical = args.rawPhysical + 5
        end,
        [1054] = function(args) -- Doran's Shield
            args.rawPhysical = args.rawPhysical + 5
        end,
        [3508] = function(args) local source = args.source -- Essence Reaver
            if not source:has_buff("3508buff") then return end
            args.rawPhysical = args.rawPhysical + 0.4 *
                source.bonus_attack_damage + source.base_attack_damage
        end,
        [3124] = function(args) local source = args.source -- Guinsoo's Rageblade
            args.rawPhysical = args.rawPhysical +
                math.min(200, source.crit_chance * 200)
        end,
        [2015] = function(args) local source = args.source -- Kircheis Shard
            local buff = source:get_buff("itemstatikshankcharge")
            local damage = buff and buff.stacks2 == 100 and 80 or 0
            args.rawMagical = args.rawMagical + damage
        end,
        [6672] = function(args) local source = args.source -- Kraken Slayer
            local buff = source:get_buff("6672buff")
            if not buff or buff.count ~= 2 then return end
            args.trueDamage = args.trueDamage + 60 +
                0.45 * source.bonus_attack_damage
        end,
        [3100] = function(args) local source = args.source -- Lich Bane
            if not source:has_buff("lichbane") then return end
            args.rawMagical = args.rawMagical + 1.5 *
                source.base_attack_damage + 0.4 * source.ability_power
        end,
        [3036] = function(args) local source = args.source -- Lord Dominik's Regards
            local diff = math.min(2000, math.max(0,
                args.unit.max_health - source.max_health))
            args.rawPhysical = args.rawPhysical + (1 + diff /
                100 * 0.75) * source.bonus_attack_damage
        end,
        [3042] = function(args) -- Muramana
            args.rawPhysical = args.rawPhysical 
                + args.source.max_mana * 0.025
        end,
        [3115] = function(args) -- Nashor's Tooth
            args.rawMagical = args.rawMagical + 15
                + 0.2 * args.source.ability_power
        end,
        [6670] = function(args) -- Noonquiver
            args.rawPhysical = args.rawPhysical + 20
        end,
        [6677] = function(args) local source = args.source -- Rageknife
            args.rawPhysical = args.rawPhysical +
                math.min(175, 175 * source.crit_chance)
        end,
        [3094] = function(args) local source = args.source -- Rapid Firecannon
            local buff = source:get_buff("itemstatikshankcharge")
            local damage = buff and buff.stacks2 == 100 and 120 or 0
            args.rawMagical = args.rawMagical + damage
        end,
        [1043] = function(args) -- Recurve Bow
            args.rawPhysical = args.rawPhysical + 15
        end,
        [3057] = function(args) local source = args.source -- Sheen
            if not source:has_buff("sheen") then return end
            args.rawPhysical = args.rawPhysical + source.base_attack_damage
        end,
        [3095] = function(args) local source = args.source -- Stormrazor
            local buff = source:get_buff("itemstatikshankcharge")
            local damage = buff and buff.stacks2 == 100 and 120 or 0
            args.rawMagical = args.rawMagical + damage
        end,
        [3070] = function(args) -- Tear of the Goddess
            args.rawPhysical = args.rawPhysical + 5
        end,
        [3748] = function(args) local source = args.source -- Titanic Hydra
            local damage = source.is_melee and (5 + source.max_health
                * 0.015) or (3.75 + source.max_health * 0.01125)
            args.rawPhysical = args.rawPhysical + damage
        end,
        [3078] = function(args) local source = args.source -- Trinity Force
            if not source:has_buff("3078trinityforce") then return end
            args.rawPhysical = args.rawPhysical + 2 * source.base_attack_damage
        end,
        [6664] = function(args) local source = args.source -- Turbo Chemtank
            local buff = source:get_buff("item6664counter")
            if not buff or buff.stacks2 ~= 100 then return end
            args.rawMagical = args.rawMagical + 35.29 + 4.71 * source.level
                + 0.01 * source.max_health + 0.03 * source.move_speed
        end,
        [3091] = function(args) local source = args.source -- Wit's End
            local damage = ({15, 15, 15, 15, 15, 15, 15, 15, 25, 35,
                45, 55, 65, 75, 76.25, 77.5, 78.75, 80})[source.level]
            args.rawMagical = args.rawMagical + damage
        end
    }
end

function Common:CalcAutoAttackDamage(source, unit)
    local name = source.champ_name
    local physical = source.total_attack_damage
    if name == "Corki" and physical > 0 then return
        self:CalcMixedDamage(source, unit, physical) end
    local args = {rawMagical = 0, rawPhysical = physical,
        trueDamage = 0, source = myHero, unit = unit}
    local ids = Linq(myHero.items):Where("(i) => i ~= nil")
        :Select("(i) => i.item_id"):Distinct():ForEach(function(i)
        if self.itemPassives[i] then self.itemPassives[i](args) end end)
    if self.heroPassives[name] then self.heroPassives[name](args) end
    local magical = self:CalcMagicalDamage(source, unit, args.rawMagical)
    physical = self:CalcPhysicalDamage(source, unit, args.rawPhysical)
    return magical + physical + args.trueDamage
end

function Common:CalcEffectiveDamage(source, unit, amount)
    return source.ability_power > source.total_attack_damage
    and self:CalcMagicalDamage(source, unit, amount)
    or self:CalcPhysicalDamage(source, unit, amount)
end

function Common:CalcPhysicalDamage(source, unit, amount)
    amount = amount or source.total_attack_damage
    if amount <= 0 then return amount end
    if source.champ_name == "Kalista" then
        amount = amount * 0.9
    elseif source.champ_name == "Graves" then
        local percent = 0.68235 + source.level * 0.01765
        amount = amount * percent
    end
    local armor = unit.armor
    if armor < 0 then
        local reduction = 2 - 100 / (100 - armor)
        return math.floor(amount * reduction)
    end
    local bonusArmor = unit.bonus_armor
    local armorPen = source.percent_armor_penetration
    local bonusPen = source.percent_bonus_armor_penetration
    local lethality = source.lethality * (0.6 + 0.4 * source.level / 18)
    local res = armor * armorPen - (bonusArmor * (1 - bonusPen)) - lethality
    return math.floor(amount * (res < 0 and 1 or 100 / (100 + res)))
end

function Common:CalcMagicalDamage(source, unit, amount)
    amount = amount or source.ability_power
    if amount <= 0 then return amount end
    local magicRes = unit.mr
    if magicRes < 0 then
        local reduction = 2 - 100 / (100 - magicRes)
        return math.floor(amount * reduction)
    end
    local magicPen = source.percent_magic_penetration
    local flatPen = source.flat_magic_penetration
    local res = magicRes * magicPen - flatPen
    local reduction = res < 0 and 1 or 100 / (100 + res)
    return math.floor(amount * reduction)
end

function Common:CalcMixedDamage(source, unit, amount)
    return self:CalcMagicalDamage(source, unit, amount * 0.8)
        + self:CalcPhysicalDamage(source, unit, amount * 0.2)
end

function Common:AngleBetween(p1, p2, p3)
    local angle = math.deg(
        math.atan(p3.z - p1.z, p3.x - p1.x) -
        math.atan(p2.z - p1.z, p2.x - p1.x))
    if angle < 0 then angle = angle + 360 end
    return angle > 180 and 360 - angle or angle
end

function Common:CircleToPolygon(center, radius, steps, offset)
    local result = {}
    for i = 0, steps - 1 do
        local phi = 2 * math.pi / steps * (i + 0.5)
        local cx = center.x + radius * math.cos(phi + offset)
        local cy = center.z + radius * math.sin(phi + offset)
        table.insert(result, vec3.new(cx, center.y, cy))
    end
    return result
end

function Common:DrawPolygon(polygon, color, width)
    local size, c, w = #polygon, color, width
    if size < 3 then return end
    for i = 1, size do
        local p1, p2 = polygon[i], polygon[i % size + 1]
        local a = game:world_to_screen_2(p1.x, p1.y, p1.z)
        local b = game:world_to_screen_2(p2.x, p2.y, p2.z)
        renderer:draw_line(a.x, a.y, b.x, b.y, w, c.r, c.g, c.b, c.a)
    end
end

function Common:Distance(p1, p2)
    return math.sqrt(self:DistanceSqr(p1, p2))
end

function Common:DistanceSqr(p1, p2)
    local dx, dy = p2.x - p1.x, p2.z - p1.z
    return dx * dx + dy * dy
end

function Common:IsFacing(source, unit)
    local dir = source.direction
    local p1, p2 = source.origin, unit.origin
    local p3 = {x = p1.x + dir.x * 2, z = p1.z + dir.z * 2}
    return self:AngleBetween(p1, p2, p3) < 80
end

function Common:GetAutoAttackRange(unit)
    unit = unit or myHero
    return unit.attack_range + unit.bounding_radius
end

function Common:IsInAutoAttackRange(unit)
    local range = self:GetAutoAttackRange()
    local hitbox = unit.bounding_radius
    if (unit:has_buff("caitlynwsight")
        or unit:has_buff("CaitlynEMissile"))
        then range = range + 425
    end
    local p1 = myHero.path.server_pos
    local p2 = unit.path ~= nil and
        unit.path.server_pos or unit.origin
    local dist = self:DistanceSqr(p1, p2)
    return dist <= (range + hitbox) ^ 2
end

function Common:Validate(obj)
    return obj
    and obj.is_valid
    and obj.is_alive
    and obj.is_targetable
    and not obj.is_immortal
end

function Common:ValidateHero(object, enemy, ally)
    return  object
    and object.is_valid
    and object.is_alive
    and object.is_targetable
    and not object.is_immortal
    and object.is_hero
    and (
            not enemy and not ally
            or enemy and object.is_enemy
            or ally and not object.is_enemy
        )
end

function Common:substruct_vec(vec1, vec2)
    return vec3.new(vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z)
end

function Common:add_vec(vec1, vec2)
    return vec3.new(vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z)
end

function Common:multiply_vec(vec, num)
    return vec3.new(vec.x * num, vec.y * num, vec.z * num)
end

function Common:extend_vec(from, towards, by)
    local substructed = self:substruct_vec(towards, from)
    local normalized = substructed:normalized()
    local multiplied = self:multiply_vec(normalized, by)
    return self:add_vec(towards, multiplied)
end

function Common:LowMana(val)
    return myHero.mana / myHero.max_mana * 100. <= val
end

function Common:HealthCheck(tar, val)
    return tar.health / tar.max_health * 100. > val
end

function Common:ValidateMinion(object, jungle)
    if jungle then
        return object
        and object.is_valid
        and object.is_alive
        and object.is_targetable
        and object.is_jungle_minion
    else
        return object
        and object.is_valid
        and object.is_alive
        and object.is_targetable
        and object.is_minion
    end
end

function Common:Encrypt(filename)
    return file_manager:encrypt_file(filename..".lua")
end

function Common:Draw_Circle(pos, radius, r, g, b, a)
    return renderer:draw_circle(pos.x, pos.y, pos.z, radius, r, g, b, a)
end

function Common:spell(slot)
    return spellbook:get_spell_slot(slot)
end

function Common:spell_ready(slot, tick)
	return spellbook:can_cast(slot) and game.game_time >= (tick or game.game_time - 1)
end

function Common:spell_data(slot)
    return spellbook:get_spell_slot(slot).spell_data
end

function Common:spell_level(slot)
    return spellbook:get_spell_slot(slot).level
end

function Common:spell_name(slot)
    return spellbook:get_spell_slot(slot).spell_data.spell_name
end

function Common:spell_mana(slot)
    return spellbook:get_spell_slot(slot).spell_data.mana_cost
end

function Common:has_buff(source, buff)
    return source:get_buff(buff)
end

function Common:get_buff(source, buff)
    return source:get_buff(buff)
end

--[[function Common:SpellShielded(hero)
    for i=1, #spellshield_buff_list do
        if self:has_buff(hero, spellshield_buff_list[i]) then
            return true
        end
    end
    return false
end--]]

function Common:has_spellshield(hero)
    return hero:has_buff_type(spellshield) or hero:has_buff("malzaharpassiveshield")
end

function Common:IsImmobile(target)
    return target:has_buff_type(5)
    or target:has_buff_type(11)
    or target:has_buff_type(29)
    or target:has_buff_type(24)
    or target:has_buff_type(10)
end

function Common:GetAllyHeroes(range)
    local pos = myHero.path.server_pos
    return Linq(game.players):Where(function(u)
        return self:ValidateHero(u, false, true) and
            u.object_id ~= myHero.object_id and range >=
            self:Distance(pos, u.path.server_pos)
    end)
end

function Common:GetAllyMinions(range)
    local pos = myHero.path.server_pos
    return Linq(game.minions):Where(function(GetEnemyHeroesu)
        return self:ValidateMinion(u, false) and not u.is_enemy and
        self:Distance(pos, u.origin) <= range
    end)
end

function Common:GetClosestAllyTurret()
    local turrets = Linq(game.turrets):Where(function(t)
        return self:Validate(t) and not t.is_enemy end)
    if #turrets == 0 then return nil end
    local pos = myHero.path.server_pos
    table.sort(turrets, function(a, b) return
        self:DistanceSqr(pos, a.origin) <
        self:DistanceSqr(pos, b.origin) end)
    return turrets[1]
end

function Common:UnderEnemyTower(pos)
    for i=1, #game.turrets do
        local turret = game.turrets[i]
        if turret.is_enemy
        and self:Distance(pos, turret.origin) <= 950 then
            return true
        end
    end
    return false
end

function Common:GetEnemyHeroes(range, pos)
    pos = pos or myHero.path.server_pos
    return Linq(game.players):Where(function(u)
        return self:Validate(u) and u.is_enemy
            and (range and self:Distance(
            pos, u.path.server_pos) <= range
            or self:IsInAutoAttackRange(u))
    end)
end

function Common:GetEnemyMinions()
    return Linq(game.minions):Where(function(u)
        return self:Validate(u) and u.is_enemy
    end)
end

function Common:GetEnemyMonsters()
    return Linq(game.jungle_minions):Where(function(u)
        return self:Validate(u) and u.is_enemy
    end)
end

function Common:GetEnemyPets()
    return Linq(game.pets):Where(function(u)
        return self:Validate(u) and u.is_enemy
    end)
end

function Common:GetEnemyStructures()
    return Linq(game.nexus):Concat(
        game.inhibs):First(function(t)
        return self:Validate(t) and t.is_enemy
    end)
end

function Common:GetEnemyTurrets()
    return Linq(game.turrets):First(function(t)
        return self:Validate(t) and t.is_enemy
    end)
end

function Common:GetEnemyWard()
    return Linq(game.wards):First(function(w)
        return self:Validate(w) and w.is_enemy
    end)
end

function Common:GetAttackableUnits()
    return Linq(game.players):Concat(game.minions):Concat(game.jungle_minions):Concat(game.turrets):Concat(game.inhibs):Concat(game.wards):Concat(game.pets):Concat(game.jungle_plants):Where(function(w)
        return self:Validate(w) and w.object_id ~= myHero.object_id
    end)
end


function Common:AutoUpdate(this, version)
    this = "brrrr_" .. this
    local _version = tonumber(http:get("https://raw.githubusercontent.com/XiSl0w/bruhwalker/main/Versions/" .. this .. ".version"))
    if _version and _version > version then
        http:download_file("https://raw.githubusercontent.com/XiSl0w/bruhwalker/main/Scripts/" .. this .. ".lua", this .. ".lua")
        console:log(string.format("[brrrr] Successfully updated %s to v%s. Please reload!", this, tostring(_version)))
    end
end

function Common:ScriptNotReady()
    return myHero.is_dead or game.is_chat_opened or not myHero.is_on_screen or menu.is_opened
end

function Common:get_charge_buff() 
    if myHero then
        if myHero.champ_name == "Varus" then
            return myHero:get_buff("VarusQ")
        elseif myHero.champ_name == "Xerath" then
            return myHero:get_buff("XerathArcanopulseChargeUp")
        elseif myHero.champ_name == "Pyke" then
            return myHero:get_buff("PykeQ")
        elseif myHero.champ_name == "Pantheon" then
            return myHero:get_buff("PantheonQ")
        elseif myHero.champ_name == "Sion" then
            return myHero:get_buff("SionQ")
        elseif myHero.champ_name == "Viego" then
            return myHero:get_buff("ViegoW")
        elseif myHero.champ_name == "Zac" then
            return myHero:get_buff("ZacE")
        end
    end
end

function Common:IsCharging()
    local buff = self:get_charge_buff()
    return buff and buff.is_valid

end



function Common:GetChargePercentage(spell_charge_duration)
   local buff = self:get_charge_buff()

    if buff and buff.is_valid then
        local substract = 0

        if buff.name == "SionQ" then substract = 0.25 
        elseif buff.name == "PykeQ" then substract = 0.4 end

        return math.max(0, math.min(1, (game.game_time - buff.start_time + 0.25 - substract) /  spell_charge_duration))
    
    end
    return 0
end

function Common:GetChargeRange(max_range, min_range, duration)
    if self:IsCharging() then
        return min_range + math.min(max_range - min_range, (max_range - min_range) * self:GetChargePercentage(duration))
    end
    return max_range
end

local _version = tonumber(http:get(base_url .. "Versions/" .. script_name .. ".version"))
if _version then
    if _version > version then
        http:download_file(base_url .. "Scripts/" .. script_name .. ".lua", common_dir .. script_name .. ".lua")
        console:log(string.format("[brrrr] Successfully updated %s to v%s. Please reload!", script_name, tostring(_version)))
    else
        console:log(string.format("[brrrr] %s is on the latest version %s!", script_name, tostring(_version)))
    end
else
    console:log(string.format("[brrrr] Failed to update %s!", script_name))
end

return Common:New()