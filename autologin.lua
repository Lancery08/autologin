script_name('Autologin')
script_author('akionka')
script_version('1.6')
script_version_number(7)

local sampev = require "lib.samp.events"
local vkeys = require "vkeys"
local sha1 = require "sha1"
local basexx = require "basexx"
local band = bit.band
local inicfg = require "inicfg"
local dlstatus = require "moonloader".download_status
local encoding = require "encoding"
local isGoUpdate = false
encoding.default = 'cp1251'
u8 = encoding.UTF8

local textdraws = {}
local account_info = nil
local attemps = {false, false, false}

local ini = inicfg.load({
	account1 = {
		server_ip = "",
		user_name = "",
		user_password = "",
		user_textdrawpass = "",
		gauth_secret = "",
	}
},"autologin")

--cred: Nishikinov
function genCode(skey)
	skey = basexx.from_base32(skey)
	value = math.floor(os.time() / 30)
	value = string.char(
	0, 0, 0, 0,
	band(value, 0xFF000000) / 0x1000000,
	band(value, 0xFF0000) / 0x10000,
	band(value, 0xFF00) / 0x100,
	band(value, 0xFF))
	local hash = sha1.hmac_binary(skey, value)
	local offset = band(hash:sub(-1):byte(1, 1), 0xF)
	local function bytesToInt(a,b,c,d)
		return a*0x1000000 + b*0x10000 + c*0x100 + d
	end
	hash = bytesToInt(hash:byte(offset + 1, offset + 4))
	hash = band(hash, 0x7FFFFFFF) % 1000000
	return ("%06d"):format(hash)
end

function sampev.onShowTextDraw(id, textdraw)
	if account_info ~= nil then
		if id >= 2049 and id <= 2058 then table.insert(textdraws, textdraw.text) end
		if #textdraws == 10 then
			for i = 1, #textdraws do
				local num = tostring(account_info["user_textdrawpass"]):sub(i,i)
				for z, _ in ipairs(textdraws) do
					if textdraws[z] == num then sampSendClickTextdraw(637 + z) end
				end
			end
			textdraws = {}
			sampSendClickTextdraw(653)
			attemps[3] = true
		end
	end
end

function sampev.onServerMessage(color, text)
	if account_info ~= nil and color == -1347440641 and text == u8:decode("{ffffff}С возвращением, вы успешно вошли в свой аккаунт.") then
		lua_thread.create(function()
			wait(500)
			sampSpawnPlayer()
		end)
	end
end

function sampev.onShowDialog(id, stytle, title, btn1, btn2, text)
	if id == 2 and account_info ~= nil and not attemps[1] then
    sampSendDialogResponse(id, 1, 0, account_info["user_password"])
		attemps[1] = true
    return false
  end
	if id == 530 and account_info ~= nil and not attemps[2] then
    sampSendDialogResponse(id, 1, 0, genCode(account_info["gauth_secret"]))
		attemps[2] = true
    return false
  end
end

function sampev.onSendClientJoin(version, mod, nickname, challengeResponse, joinAuthKey, clientVer, unknown)
	attemps = {false, false, false}
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
	inicfg.save(ini, "autologin")
	sampAddChatMessage(u8:decode("[Autologin]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {2980b9}"..thisScript().version.."{FFFFFF}."), -1)
	update()
	while updateinprogess ~= false do wait(0) if isGoUpdate then isGoUpdate = false goupdate() end end
	for k, v in pairs(ini) do
		if v["server_ip"] == select(1, sampGetCurrentServerAddress()) and v["user_name"] == sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
			account_info = v
			break
		end
	end
end

function update()
	local fpath = os.getenv('TEMP') .. '\\autologin-version.json'
	downloadUrlToFile('https://raw.githubusercontent.com/Akionka/autologin/master/version.json', fpath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(fpath, 'r')
			if f then
				local info = decodeJson(f:read('*a'))
				if info and info.version then
					version = info.version
					version_num = info.version_num
					if version_num > thisScript().version_num then
						sampAddChatMessage(u8:decode("[Autologin]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..version.."{FFFFFF}. Начинаю закачку."), -1)
						isGoUpdate = true
					else
						sampAddChatMessage(u8:decode("[Autologin]: У вас установлена самая свежая версия скрипта."), -1)
						updateinprogess = false
					end
				end
			end
		end
	end)
end

function goupdate()
	downloadUrlToFile("https://raw.githubusercontent.com/Akionka/autologin/master/autologin.lua", thisScript().path, function(id3, status1, p13, p23)
		if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(u8:decode('[Autologin]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...'), -1)
			sampAddChatMessage(u8:decode('[Autologin]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение.'), -1)
			sampAddChatMessage(u8:decode('[Autologin]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
			updateinprogess = false
		end
	end)
end
