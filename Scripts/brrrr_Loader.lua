local loader = {}
local loader_version = 1.2
local base_url = "https://raw.githubusercontent.com/XiSl0w/bruhwalker/main/"
local my_dir = "\\brrrrAIO"
local common_dir = my_dir .. "\\Common"
local imgs_dir = my_dir .. "\\Images"
local scripts_dir = my_dir .. "\\Scripts"
local player = game.local_player

local supported = {
    ["Draven"] = 1.2,
    ["Sion"] = 1.1
}

local my_images = {
    --[["Caitlyn",
    "Caitlyn_Q",
    "Caitlyn_W",
    "Caitlyn_E",
    "Caitlyn_R",
    "Galeforce",
    "Draven",
    "Draven_Q",
    "Draven_W",
    "Draven_E",
    "Draven_R",
    "Draven_Axe"--]]
}

function loader:Update(this, version)
    local _version = http:get(base_url .. "Versions/".. this .. ".version")
    console:log("[Loader] " .. this .. " Version: " .. (_version or "unknown"))
    if _version and tonumber(_version) > version then
        http:download_file(base_url .. "Scripts/" .. this .. ".lua", this .. ".lua")
        console:log(string.format("[brrrr] Successfully updated %s to v%s. Please reload!", this, tostring(_version)))
        return true
    end
    return false
end

function loader:__dir()
    if not file_manager:directory_exists(my_dir) then
        file_manager:create_directory(my_dir)
    end
    if not file_manager:directory_exists(common_dir) then
        file_manager:create_directory(common_dir)
    end
    if not file_manager:directory_exists(imgs_dir) then
        file_manager:create_directory(imgs_dir)
    end
    if not file_manager:directory_exists(scripts_dir) then
        file_manager:create_directory(scripts_dir)
    end
end

function loader:download_scripts(this)
    for script, _ in pairs(this) do
        if not file_manager:file_exists(scripts_dir .. "\\brrrr_" .. script .. ".lua") then
            http:download_file(base_url .. "Scripts/brrrr_" .. script .. ".lua", scripts_dir .. "\\brrrr_" .. script .. ".lua")
            console:log(string.format("[brrrr] Successfully downloaded script(%s)!", script))
        end
    end
end

function loader:download_common()
    if not file_manager:file_exists(common_dir .. "\\common.lua") then
        http:download_file(base_url .. "Scripts/common.lua", common_dir .. "\\common.lua")
        console:log("[brrrr] Successfully downloaded common library!")
    end
end

function loader:download_images()
    for i=1, #my_images do
        local my_image = my_images[i]
        if not file_manager:file_exists(imgs_dir .. "\\" .. my_image .. ".png") then
            http:download_file(base_url .. "Images/" .. my_image .. ".png", imgs_dir .. "\\" .. my_image .. ".png")
            console:log(string.format("[brrrr] Successfully downloaded image(%s)!", my_image))
        end
    end
end

function loader:__load()
    self:download_scripts(supported)
    self:download_common()
    self:download_images()
    local script_ver = supported[player.champ_name]
    if script_ver then
        if self:Update("brrrr_" .. player.champ_name, script_ver) then
            self:Update("brrrr_Loader", loader_version)
            return
        end
        require("brrrrAIO.Scripts.brrrr_" .. player.champ_name)
        return
    end
    console:log(string.format("[brrrr] %s is not supported yet!", player.champ_name))
end

function loader:__init()
    self:__dir()
    self:__load()
end

return loader:__init()
