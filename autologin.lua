script_name('Autologin')
script_author('akionka')
script_version('1.7.1')
script_version_number(10)

local sampev   = require 'lib.samp.events'
local vkeys    = require 'vkeys'
local sha1     = require 'sha1'
local basexx   = require 'basexx'
local band     = bit.band
local imgui    = require 'imgui'
local inicfg   = require 'inicfg'
local dlstatus = require 'moonloader'.download_status
local encoding = require 'encoding'

local updatesavaliable = false

encoding.default = 'cp1251'
u8 = encoding.UTF8

local textdraws    = {}
local account_info = nil
local attemps      = {false, false, false}

local ini = inicfg.load({
  settings = {
    startmsg = true
  }
}, 'autologin')

local accounts = {
  {
    user_name         = 'Nick_Name',
    user_password     = 'HackMe123',
    user_textdrawpass = '1337',
    gauth_secret      = 'MTIzNDU2Nzg5MTIz',
    server_ip         = '185.169.134.83',
  }
}
local accounts_buffs = {}
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
  return ('%06d'):format(hash)
end

function sampev.onShowTextDraw(id, textdraw)
  if account_info ~= nil then
    if id >= 2049 and id <= 2058 then table.insert(textdraws, textdraw.text) end
    if #textdraws == 10 then
      for i = 1, #textdraws do
        local num = tostring(account_info['user_textdrawpass']):sub(i,i)
        for z, _ in ipairs(textdraws) do
          if textdraws[z] == num then sampSendClickTextdraw(640 + z) end
        end
      end
      textdraws = {}
      sampSendClickTextdraw(656)
      attemps[3] = true
    end
  end
end

function sampev.onServerMessage(color, text)
  if account_info ~= nil and color == -1347440641 and text == u8:decode('{ffffff}С возвращением, вы успешно вошли в свой аккаунт.') then
    lua_thread.create(function()
      wait(500)
      sampSpawnPlayer()
    end)
  end
end

function sampev.onShowDialog(id)
  if id == 2 and account_info ~= nil and not attemps[1] then
    sampSendDialogResponse(id, 1, 0, account_info['user_password'])
    attemps[1] = true
    return false
  end
  if id == 530 and account_info ~= nil and not attemps[2] then
    sampSendDialogResponse(id, 1, 0, genCode(account_info['gauth_secret']))
    attemps[2] = true
    return false
  end
end

function sampev.onSendClientJoin()
  attemps = {false, false, false}
end

local main_window_state = imgui.ImBool(false)
local cat_window_state  = imgui.ImBool(false)
local startmsg          = imgui.ImBool(ini.settings.startmsg)
local selected          = 0
local server            = imgui.ImInt(1)

function imgui.OnDrawFrame()
  if main_window_state.v then
    imgui.Begin(thisScript().name..' v'..thisScript().version, main_window_state, imgui.WindowFlags.AlwaysAutoResize)
    if imgui.Button('Менеджер аккаунтов') then
      cat_window_state.v = not cat_window_state.v
    end
    if imgui.CollapsingHeader('Дополнительные настройки') then
      if imgui.Checkbox('Стартовое сообщение', startmsg) then
        ini.settings.startmsg = startmsg.v
        inicfg.save(ini, 'autologin')
      end
      imgui.Separator()
      if updatesavaliable then
        if imgui.Button('Скачать обновление') then
          update('https://raw.githubusercontent.com/Akionka/autologin/master/autologin.lua')
          main_window_state.v = false
        end
      else
        if imgui.Button('Проверить обновление') then
          checkupdates('https://raw.githubusercontent.com/Akionka/autologin/master/version.json')
        end
      end
      imgui.Separator()
      if imgui.Button('Bug report [VK]') then os.execute('explorer "https://vk.com/akionka"') end
      if imgui.Button('Bug report [Telegram]') then os.execute('explorer "https://teleg.run/akionka"') end
    end
    imgui.End()
  end
  if cat_window_state.v then
    local resX, resY = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(thisScript().name..' v'..thisScript().version..' | Менеджер каналов', cat_window_state, imgui.WindowFlags.AlwaysAutoResize)
    imgui.BeginGroup()
      imgui.BeginChild('Catalog', imgui.ImVec2(150, 240 - imgui.GetItemsLineHeightWithSpacing() - 1), true)
        for i, v in ipairs(accounts) do
          if imgui.Selectable(v['user_name']..'##'..i, selected == i) then selected = i end
        end
      imgui.EndChild()
      imgui.BeginChild('New', imgui.ImVec2(150, 0), false)
        if imgui.Button('Добавить ещё') then
          local fpath = getWorkingDirectory()..'\\config\\accounts.json'
          if doesFileExist(fpath) then
            local f = io.open(fpath, 'w+')
            if f then
              local temptable = {
                user_name         = imgui.ImBuffer(64),
                user_password     = imgui.ImBuffer(64),
                user_textdrawpass = imgui.ImBuffer(5),
                gauth_secret      = imgui.ImBuffer(17),
                server            = imgui.ImInt(1),
								gcode             = imgui.ImBuffer(7)
              }
              temptable['user_name'].v         = 'Nick_Name'
              temptable['user_password'].v     = 'HackMe123'
              temptable['user_textdrawpass'].v = '1337'
              temptable['gauth_secret'].v      = 'MTIzNDU2Nzg5MTIz'
              temptable['server'].v            = 0
							temptable['gcode'].v             = genCode('MTIzNDU2Nzg5MTIz')
              table.insert(accounts_buffs, temptable)
              table.insert(accounts, {
                user_name         = 'Nick_Name',
                user_password     = 'HackMe123',
                user_textdrawpass = '1337',
                gauth_secret      = 'MTIzNDU2Nzg5MTIz',
                server_ip         = '185.169.134.83',
              })
              selected = #accounts
              f:write(encodeJson(accounts)):close()
            else
              sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так :('), -1)
            end
          else
            sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так :('), -1)
          end
        end
      imgui.EndChild()
    imgui.EndGroup()
    imgui.SameLine()
    imgui.BeginChild('Settings', imgui.ImVec2(300, 240), true)
    if selected ~= 0 then
      imgui.InputText('Ник-нейм##'..selected, accounts_buffs[selected]['user_name'])
      imgui.InputText('Пароль##'..selected, accounts_buffs[selected]['user_password'])
      imgui.InputText('Доп. пароль##'..selected, accounts_buffs[selected]['user_textdrawpass'])
			imgui.InputText('Токен GAuth##'..selected, accounts_buffs[selected]['gauth_secret'])
			accounts_buffs[selected]['gcode'].v = genCode(accounts_buffs[selected]['gauth_secret'].v)
			imgui.InputText(tostring(30 - math.floor((os.time() / 30 - math.floor(os.time() / 30)) * 30 + 0.5))..'##code..'..selected, accounts_buffs[selected]['gcode'], 16384)
      if imgui.CollapsingHeader('Сервер') then
        if imgui.ListBox('', accounts_buffs[selected]['server'], {'Trinity RPG', 'Trinity RP 1', 'Trinity RP 2'}, imgui.ImInt(3)) then
          if accounts_buffs[selected]['server'].v == 0 then accounts[selected]['server_ip'] = '185.169.134.83' end
          if accounts_buffs[selected]['server'].v == 1 then accounts[selected]['server_ip'] = '185.169.134.84' end
          if accounts_buffs[selected]['server'].v == 2 then accounts[selected]['server_ip'] = '185.169.134.85' end
        end
      end
      if imgui.Button('Сохранить##'..selected) then
        local fpath = getWorkingDirectory()..'\\config\\accounts.json'
        if doesFileExist(fpath) then
          local f = io.open(fpath, 'w+')
          if f then
            accounts[selected]['user_name'] = accounts_buffs[selected]['user_name'].v
            accounts[selected]['user_password'] = accounts_buffs[selected]['user_password'].v
            accounts[selected]['user_textdrawpass'] = accounts_buffs[selected]['user_textdrawpass'].v
            accounts[selected]['gauth_secret'] = accounts_buffs[selected]['gauth_secret'].v
            f:write(encodeJson(accounts)):close()
          else
            sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так :('), -1)
          end
        else
          sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так :('), -1)
        end
      end
      imgui.SameLine()
      if imgui.Button('Удалить##'..selected) then
        local fpath = getWorkingDirectory()..'\\config\\accounts.json'
        if doesFileExist(fpath) then
          local f = io.open(fpath, 'w+')
          if f then
            local temp = selected
            if selected == #accounts then selected = selected - 1 end
            table.remove(accounts, temp)
            table.remove(accounts_buffs, temp)
            f:write(encodeJson(accounts)):close()
          else
            sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так :('), -1)
          end
        else
          sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так :('), -1)
        end
      end
    end
    imgui.EndChild()
    imgui.End()
  end
end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end

  checkupdates('https://raw.githubusercontent.com/Akionka/autologin/master/version.json')

  if ini.settings.startmsg then
    sampAddChatMessage(u8:decode('[Autologin]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {2980b9}'..thisScript().version..'{FFFFFF}.'), -1)
    sampAddChatMessage(u8:decode('[Autologin]: Автор - {2980b9}Akionka{FFFFFF}. Выключить данное сообщение можно в {2980b9}/autologin{FFFFFF}.'), -1)
  end

  local fpath = getWorkingDirectory()..'\\config\\accounts.json'
  if doesFileExist(fpath) then
    local f = io.open(fpath, 'r')
    if f then
      accounts = decodeJson(f:read('*a'))
      f:close()
      accounts_buffs = {}
      for i, v in ipairs(accounts) do
        local temptable = {
          user_name         = imgui.ImBuffer(64),
          user_password     = imgui.ImBuffer(64),
          user_textdrawpass = imgui.ImBuffer(5),
          gauth_secret      = imgui.ImBuffer(17),
          server            = imgui.ImInt(1),
					gcode 						= imgui.ImBuffer(7)
        }
        temptable['user_name'].v         = v['user_name']
        temptable['user_password'].v     = v['user_password']
        temptable['user_textdrawpass'].v = v['user_textdrawpass']
        temptable['gauth_secret'].v      = v['gauth_secret']
				temptable['gcode'].v 						 = genCode(v['gauth_secret'])
        if v['server_ip'] == '185.169.134.83' then temptable['server'].v = 0 end
        if v['server_ip'] == '185.169.134.84' then temptable['server'].v = 1 end
        if v['server_ip'] == '185.169.134.85' then temptable['server'].v = 2 end
        table.insert(accounts_buffs, temptable)
      end
    end
  else
    sampAddChatMessage(u8:decode('[Autologin]: Отсутствует файл со списком каналов по пути {2980b0}'..fpath..'{FFFFFF}.'), -1)
    sampAddChatMessage(u8:decode('[Autologin]: Скрипт автоматически создаст шаблонный файл.'), -1)
    local f = io.open(fpath, 'w+')
    if f then
      f:write(encodeJson({
        {
          user_name         = 'Nick_Name',
          user_password     = 'HackMe123',
          user_textdrawpass = '1337',
          gauth_secret      = 'MTIzNDU2Nzg5MTIz',
          server_ip         = '185.169.134.83',
        }
      })):close()
      local temptable = {
        user_name         = imgui.ImBuffer(64),
        user_password     = imgui.ImBuffer(64),
        user_textdrawpass = imgui.ImBuffer(5),
        gauth_secret      = imgui.ImBuffer(17),
        server            = imgui.ImInt(1),
				gcode 						= imgui.ImBuffer(7)
      }
      accounts_buffs = {}
      temptable['user_name'].v         = 'Nick_Name'
      temptable['user_password'].v     = 'HackMe123'
      temptable['user_textdrawpass'].v = '1337'
      temptable['gauth_secret'].v      = 'MTIzNDU2Nzg5MTIz'
      temptable['server'].v            = 0
			temptable['gcode'].v    				 = genCode('MTIzNDU2Nzg5MTIz')
      table.insert(accounts_buffs, temptable)
    else
      sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так :('), -1)
    end
  end

  for i, v in ipairs(accounts) do
    if v['server_ip'] == select(1, sampGetCurrentServerAddress()) and v['user_name'] == sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
      print(u8:decode('{FFFFFF}[Autologin]: {00FF00}Успешно{FFFFFF} загружен аккаунт {2980b9}'..v['user_name']..'{FFFFFF}.'))
      account_info = v
      if #v['gauth_secret'] ~= 16 then
        attemps[2] = true
      end
      break
    end
  end

  sampRegisterChatCommand('autologin', function()
    main_window_state.v = not main_window_state.v
  end)

  while true do
    wait(0)
    imgui.Process = main_window_state.v
  end
end

function checkupdates(json)
  local fpath = os.getenv('TEMP')..'\\'..thisScript().name..'-version.json'
  if doesFileExist(fpath) then os.remove(fpath) end
  downloadUrlToFile(json, fpath, function(_, status, _, _)
    if status == dlstatus.STATUSEX_ENDDOWNLOAD then
      if doesFileExist(fpath) then
        local f = io.open(fpath, 'r')
        if f then
          local info = decodeJson(f:read('*a'))
          local updateversion = info.version_num
          f:close()
          os.remove(fpath)
          if updateversion > thisScript().version_num then
            updatesavaliable = true
            sampAddChatMessage(u8:decode('[Autologin]: Найдено объявление. Текущая версия: {2980b9}'..thisScript().version..'{FFFFFF}, новая версия: {2980b9}'..info.version..'{FFFFFF}.'), -1)
            return true
          else
            updatesavaliable = false
            sampAddChatMessage(u8:decode('[Autologin]: У вас установлена самая свежая версия скрипта.'), -1)
          end
        else
          updatesavaliable = false
          sampAddChatMessage(u8:decode('[Autologin]: Что-то пошло не так, упс. Попробуйте позже.'), -1)
        end
      end
    end
  end)
end

function update(url)
  downloadUrlToFile(url, thisScript().path, function(_, status1, _, _)
    if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
      sampAddChatMessage(u8:decode('[Autologin]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...'), -1)
      sampAddChatMessage(u8:decode('[Autologin]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение.'), -1)
      sampAddChatMessage(u8:decode('[Autologin]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
      thisScript():reload()
    end
  end)
end
