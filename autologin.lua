script_name('Autologin')
script_author('akionka')
script_version('1.8.3')
script_version_number(16)

local sampev   = require 'lib.samp.events'
local vkeys    = require 'vkeys'
local sha1     = require 'sha1'
local basexx   = require 'basexx'
local band     = bit.band
local imgui    = require 'imgui'
local inicfg   = require 'inicfg'
local dlstatus = require 'moonloader'.download_status
local encoding = require 'encoding'

local updatesavaliable   = false
local collebrating_state = 0

encoding.default = 'cp1251'
u8 = encoding.UTF8
local textdraws    = {}
local account_info = nil
local attemps      = {false, false, false}

-- Хех)
local servers = {
  {
    is_builtin = true, title = 'Advance RP', list = {
      {
        name = 'Red', ip = '5.254.104.131', port = 7777, uID = 1
      },
      {
        name = 'Green',
        ip = '5.254.104.132',
        port = 7777,
        uID = 2
      },
      {
        name = 'Yellow',
        ip = '5.254.104.133',
        port = 7777,
        uID = 3
      },
      {
        name = 'Orange',
        ip = '5.254.104.134',
        port = 7777,
        uID = 4
      },
      {
        name = 'Blue',
        ip = '5.254.104.135',
        port = 7777,
        uID = 5
      },
      {
        name = 'White',
        ip = '5.254.104.136',
        port = 7777,
        uID = 6
      },
      {
        name = 'Silver',
        ip = '5.254.104.137',
        port = 7777,
        uID = 7
      },
      {
        name = 'Purple',
        ip = '5.254.104.138',
        port = 7777,
        uID = 8
      },
      {
        name = 'Chocolate',
        ip = '5.254.104.139',
        port = 7777,
        uID = 9
      }
    }
  },
  {
    is_builtin = true,
    title = 'Arizona RP',
    list = {
      {
        name = 'Phoenix', ip = '185.169.134.3', port = 7777, uID = 10
      },
      {
        name = 'Tucson',
        ip = '185.169.134.4',
        port = 7777,
        uID = 11
      },
      {
        name = 'Scottdale',
        ip = '185.169.134.43',
        port = 7777,
        uID = 12
      },
      {
        name = 'Chandler',
        ip = '185.169.134.44',
        port = 7777,
        uID = 13
      },
      {
        name = 'Brainburg',
        ip = '185.169.134.45',
        port = 7777,
        uID = 14
      },
      {
        name = 'Saint Rose',
        ip = '185.169.134.5',
        port = 7777,
        uID = 15
      },
      {
        name = 'Mesa',
        ip = '185.169.134.59',
        port = 7777,
        uID = 16
      },
      {
        name = 'Red-Rock',
        ip = '185.169.134.61',
        port = 7777,
        uID = 17
      },
      {
        name = 'Yuma',
        ip = '185.169.134.107',
        port = 7777,
        uID = 18
      }
    }
  },
  {
    is_builtin = true,
    title = 'Evovle RP',
    list = {
      {
        name = 'First', ip = '185.169.134.67', port = 7777, uID = 19
      },
      {
        name = 'Second',
        ip = '185.169.134.68',
        port = 7777,
        uID = 20
      },
      {
        name = 'Third',
        ip = '185.169.134.91',
        port = 7777,
        uID = 21
      }
    }
  },
  -- {
  --   is_builtin = true,
  --   title = 'Diamond RP',
  --   list = {
  --     {
  --       name = 'Emerald', ip = '194.61.44.61', port = 7777, uID = 22
  --     },
  --     {
  --       name = 'Radiant',
  --       ip = '5.254.123.3',
  --       port = 7777,
  --       uID = 23
  --     },
  --     {
  --       name = 'Trilliant',
  --       ip = '5.254.123.4',
  --       port = 7777,
  --       uID = 24
  --     },
  --     {
  --       name = 'Crystal',
  --       ip = '5.254.123.4',
  --       port = 7777,
  --       uID = 25
  --     },
  --     {
  --       name = 'Sapphire',
  --       ip = '5.254.123.6',
  --       port = 7777,
  --       uID = 26
  --     },
  --     {
  --       name = 'Onyx',
  --       ip = '5.254.105.202',
  --       port = 7777,
  --       uID = 27
  --     },
  --     {
  --       name = 'Amber',
  --       ip = '194.61.44.67',
  --       port = 7777,
  --       uID = 28
  --     },
  --     {
  --       name = 'Quartz',
  --       ip = '5.254.105.204',
  --       port = 7777,
  --       uID = 29
  --     }
  --   }
  -- },
  -- {
  --   is_builtin = true,
  --   title = 'SAMP RP',
  --   list = {
  --     {
  --       name = 'Second', ip = '185.169.134.20', port = 7777, uID = 30
  --     },
  --     {
  --       name = 'Revolution',
  --       ip = '185.169.134.11',
  --       port = 7777,
  --       uID = 31
  --     },
  --     {
  --       name = 'Reborn',
  --       ip = '185.169.134.34',
  --       port = 7777,
  --       uID = 32
  --     },
  --     {
  --       name = 'Legacy',
  --       ip = '185.169.134.22',
  --       port = 7777,
  --       uID = 33
  --     }
  --   }
  -- },
  {
    is_builtin = true,
    title = 'Trinity GTA',
    list = {
      {
        name = 'RPG', ip = '185.169.134.83', port = 7777, uID = 34
      },
      {
        name = 'RP1',
        ip = '185.169.134.84',
        port = 7777,
        uID = 35
      },
      {
        name = 'RP2',
        ip = '185.169.134.85',
        port = 7777,
        uID = 36
      }
    }
  }
}

local last_uID = 36
local accounts = {
  {
    nickname           = 'Nick_Name',
    password           = 'HackMe123',
    additionalpassword = '1337',
    gauth_secret       = 'MTIzNDU2Nzg5MTIz',
    suID               = 1,
  }
}

local temp_buffers = {}

local trinity_data = {
  submit = 659,
  -- baseLetter = 1,
  baseClickable = 643
}

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

function sampev.onSendClickTextDraw( id )
  if id == 0xFFFF then return end
  -- print(id)
  if collebrating_state == 1 then
    sampAddChatMessage(u8:decode('[Autologin]: Пожалуйста, нажмите на кнопку Submit (неправильный выбор приведет к ошибкам при входе).'), -1)
    trinity_data.baseClickable = id - 1
    collebrating_state = 2
    saveAllData()
    return
  elseif collebrating_state == 2 then
    trinity_data.submit = id
    collebrating_state = 0
    saveAllData()
    return
  end
end

function sampev.onShowTextDraw(id, textdraw)
  -- print(id, textdraw.text)
  if account_info == nil then
    return
  end

  if account_info['suID'] >= 1 and account_info['suID'] <= 9 then
    -- Advance, не требуется

  elseif account_info['suID'] >= 10 and account_info['suID'] <= 18 then
    -- Arizona, не требуется

  elseif account_info['suID'] >= 19 and account_info['suID'] <= 26 then
    -- TODO: Diamond

  elseif account_info['suID'] >= 27 and account_info['suID'] <= 29 then
    -- Evolve
  elseif account_info['suID'] >= 30 and account_info['suID'] <= 33 then
    -- TODO: SAMP-RP

  -- Trinity
  elseif account_info['suID'] >= 34 and account_info['suID'] <= 36 then
    if id >= 2049 and id <= 2058 then
      table.insert(textdraws, textdraw.text)
    end
    if #textdraws == 10 then
      for i = 1, #textdraws do
        local num = ('%04d'):format(account_info['additionalpassword']):sub(i,i)
        for z, _ in ipairs(textdraws) do
          if textdraws[z] == num then sampSendClickTextdraw(trinity_data.baseClickable + z) end
        end
      end
      textdraws = {}
      sampSendClickTextdraw(trinity_data.submit)
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

function sampev.onShowDialog(id, style, title, button1, button2, text)
  -- print(id, title)


  -- Интеграция с Аризоной
  if id == 8921 and title == u8:decode('{BFBBBA}3-тий шаг') then
    local code = text:match(u8:decode('{F55F5F}(.+){FFFFFF}'))
    temp_buffers.gauth.v = code
    sampAddChatMessage(u8:decode('[Autologin]: Обнаружен GAuth токен. Воспользуйтесь {9932cc}/generator{FFFFFF}, чтобы получить код и/или скопировать токен.'), -1)
  end

  if account_info == nil then
    return
  end

  -- Адванс
  if account_info['suID'] >= 1 and account_info['suID'] <= 9 then
    if id == 1 and not attemps[1] then
      sampSendDialogResponse(id, 1, 0, u8:decode(account_info['password']))
      attemps[1] = true
      return false
    end

    if id == 88 and not attemps[3] then
      if #account_info['gauth_secret'] == 0 then return end
      local result, output = pcall(genCode, account_info['gauth_secret'])
      if result then
        sampSendDialogResponse(id, 1, 0, output)
        return false
      else
        print(u8:decode('GAuth код невалидный, либо не указан.'))
      end
      attemps[3] = true
    end
  end

  -- Аризона
  if account_info['suID'] >= 10 and account_info['suID'] <= 18 then
    if id == 2 and not attemps[1] then
      sampSendDialogResponse(id, 1, 0, u8:decode(account_info['password']))
      attemps[1] = true
      return false
    end

    if id == 8929 and not attemps[2] and #account_info['gauth_secret'] ~= 0 then
      if #account_info['gauth_secret'] == 0 then return end
      local result, output = pcall(genCode, account_info['gauth_secret'])
      if result then
        sampSendDialogResponse(id, 1, 0, output)
        return false
      else
        print(u8:decode('GAuth код невалидный, либо не указан.'))
      end
      attemps[3] = true
      return false
    end
  end

  -- Даймонд, который с багом.
  if account_info['suID'] >= 19 and account_info['suID'] <= 26 then
    -- if id == 2 and not attemps[1] then
    --   lua_thread.create(function()
    --     wait(5000) -- Та я отвечаю сервер говнище
    --     sampSendDialogResponse(id, 1, 0, account_info['password'])
    --     attemps[1] = true
    --     return false

    --   end)
    -- end
  end

  -- Евольва
  if account_info['suID'] >= 27 and account_info['suID'] <= 29 then
    if id == 1 and not attemps[1] then
      sampSendDialogResponse(id, 1, 0, u8:decode(account_info['password']))
      attemps[1] = true
      return false
    end
  end

  -- Самп рп
  if account_info['suID'] >= 30 and account_info['suID'] <= 33 then
    -- TODO: SAMP-RP
  end

  -- Trinity
  if account_info['suID'] >= 34 and account_info['suID'] <= 36 then
    if id == 2 and not attemps[1] then
      sampSendDialogResponse(id, 1, 0, u8:decode(account_info['password']))
      attemps[1] = true
      return false
    end

    if id == 530 and not attemps[2] and #account_info['gauth_secret'] ~= 0 then
      if #account_info['gauth_secret'] == 0 then return end
      local result, output = pcall(genCode, account_info['gauth_secret'])
      if result then
        sampSendDialogResponse(id, 1, 0, output)
        return false
      else
        print(u8:decode('GAuth код невалидный, либо не указан.'))
      end
      attemps[3] = true
      return false
    end
  end

end

function sampev.onSendClientJoin()
  attemps = {false, false, false}
end

local main_window_state      = imgui.ImBool(false)
local generator_window_state = imgui.ImBool(false)
local selected_tab           = 1
local selected_account       = 1
local selected_server        = 1
local selected_server_group  = 1
local server                 = imgui.ImInt(1)

function imgui.OnDrawFrame()
  if main_window_state.v then
    local resX, resY = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(resX * 0.4, resY * 0.3))
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.Once, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(thisScript().name..' v'..thisScript().version, main_window_state, imgui.WindowFlags.AlwaysAutoResize)

    ---------------------------------------------------------------------------
    ------------------------- Левое меню с выбором вкладок [DONE]
    ---------------------------------------------------------------------------

      imgui.BeginChild('Меню', imgui.ImVec2(resX * 0.07, 0), true)
        if imgui.Selectable('Аккаунты', selected_tab == 1) then selected_tab   = 1 end
        if imgui.Selectable('Сервера', selected_tab == 2) then selected_tab    = 2 end
        if imgui.Selectable('Информация', selected_tab == 3) then selected_tab = 3 end
      imgui.EndChild()

      imgui.SameLine()

      ---------------------------------------------------------------------------
      ------------------------- Первая вкладка. С аккаунтами. [WIP]
      ---------------------------------------------------------------------------

        if selected_tab == 1 then
          imgui.BeginGroup()

          ---------------------------------------------------------------------------
          ------------------------- Выбор аккаунта [WIP]
          ---------------------------------------------------------------------------

            imgui.BeginChild('Список аккаунтов', imgui.ImVec2(resX * 0.07, -imgui.GetItemsLineHeightWithSpacing()), true)
              -- Генерация списка аккаунтов
              for i, v in ipairs(accounts) do
                if imgui.Selectable(v['nickname']..'##'..i..'accounts', selected_account == i, imgui.SelectableFlags.AllowDoubleClick) then
                  selected_account = i

                  ---------------------------------------------------------------------------
                  ------------------------- Реализация двойного щелчка для измения аккаунта [DONE]
                  ---------------------------------------------------------------------------

                  if imgui.IsMouseDoubleClicked(0) then
                    temp_buffers.nickname           = imgui.ImBuffer(25)
                    temp_buffers.password           = imgui.ImBuffer(100)
                    temp_buffers.additionalpassword = imgui.ImInt(accounts[selected_account]['additionalpassword'])
                    temp_buffers.gauth_secret       = imgui.ImBuffer(100)
                    temp_buffers.suID               = accounts[selected_account]['suID']
                    temp_buffers.nickname.v         = accounts[selected_account]['nickname']
                    temp_buffers.password.v         = accounts[selected_account]['password']
                    temp_buffers.gauth_secret.v     = accounts[selected_account]['gauth_secret']
                    imgui.OpenPopup('Изменить##аккаунт'..selected_account)
                  end
                end
              end
              -- Изменение данных аккаунта
              if imgui.BeginPopupModal('Изменить##аккаунт'..selected_account, nil, imgui.WindowFlags.AlwaysAutoResize) then
                imgui.PushItemWidth(180)
                imgui.InputText('Ник##аккаунт'..selected_account, temp_buffers.nickname)
                imgui.InputText('Пароль##аккаунт'..selected_account, temp_buffers.password)
                imgui.InputInt('Доп. пароль##аккаунт'..selected_account, temp_buffers.additionalpassword)
                imgui.InputText('GAuth secret##аккаунт'..selected_account, temp_buffers.gauth_secret, imgui.InputTextFlags.CharsNoBlank)
                if imgui.Button(getProjectNameByuID(temp_buffers.suID)..' '..getServerNameByuID(temp_buffers.suID)..'##аккаунт'..selected_account, imgui.ImVec2(180, 0)) then
                  imgui.OpenPopup('Выбор сервера##аккаунт'..selected_account)
                end

                -- Выбор сервера

                imgui.SetNextWindowSize(imgui.ImVec2(resX * 0.2, resY * 0.2))
                if imgui.BeginPopupModal('Выбор сервера##аккаунт'..selected_account, nil, imgui.WindowFlags.AlwaysAutoResize) then
                  imgui.BeginGroup()
                    imgui.BeginChild('Выбор раздела##аккаунт'..selected_account, imgui.ImVec2(resX * 0.07, -imgui.GetItemsLineHeightWithSpacing()), true)
                      for i, v in ipairs(servers) do
                        if imgui.Selectable(v['title']..'##'..i..'раздел', selected_server_group == i) then
                          selected_server_group = i
                          if #servers[selected_server_group]['list'] ~= 0 then
                            selected_server = 1
                          else
                            selected_server = 0
                          end
                        end
                      end
                    imgui.EndChild()

                    imgui.SameLine()

                    imgui.BeginChild('Выбора сервера##аккаунт'..selected_account, imgui.ImVec2(resX * 0.07, -imgui.GetItemsLineHeightWithSpacing()), true)
                      for i, v in ipairs(servers[selected_server_group]['list']) do
                        if imgui.Selectable(v['name']..'##'..i..'сервер', selected_server == i) then
                          selected_server = i
                        end
                      end
                    imgui.EndChild()
                  imgui.Separator()
                  imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
                  if imgui.Button('OK##выбор сервера'..selected_account, imgui.ImVec2(120, 0)) then
                    temp_buffers.suID = servers[selected_server_group]['list'][selected_server]['uID']
                    imgui.CloseCurrentPopup()
                  end
                  imgui.SameLine()
                  if imgui.Button('Отмена##выбор сервера'..selected_account, imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
                  imgui.EndGroup()
                  imgui.EndPopup()
                end
                -- Выбор сервера END
                imgui.SameLine()
                imgui.Text('Сервер')
                imgui.PopItemWidth()
                imgui.Separator()
                imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
                if imgui.Button('OK##аккаунт'..selected_account, imgui.ImVec2(120, 0)) and doesServerExists(temp_buffers.suID) and #temp_buffers.nickname.v ~= 0 and #temp_buffers.password.v ~= 0 then
                  accounts[selected_account]['nickname']           = temp_buffers.nickname.v
                  accounts[selected_account]['password']           = temp_buffers.password.v
                  accounts[selected_account]['additionalpassword'] = temp_buffers.additionalpassword.v
                  accounts[selected_account]['gauth_secret']       = temp_buffers.gauth_secret.v
                  accounts[selected_account]['suID']               = temp_buffers.suID
                  saveAllData()
                  imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button('Отмена##аккаунт'..selected_account, imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
                imgui.EndPopup()
              end
            imgui.EndChild()

            ---------------------------------------------------------------------------
            ------------------------- Добавление нового аккаунта [DONE]
            ---------------------------------------------------------------------------

            if imgui.Button('Добавить##аккаунт') then
              temp_buffers.nickname           = imgui.ImBuffer(25)
              temp_buffers.password           = imgui.ImBuffer(100)
              temp_buffers.additionalpassword = imgui.ImInt(1337)
              temp_buffers.gauth_secret       = imgui.ImBuffer(100)
              temp_buffers.suID               = 1
              temp_buffers.nickname.v         = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
              temp_buffers.password.v         = 'HackMe123'
              imgui.OpenPopup('Добавить##аккаунт')
            end

            if imgui.BeginPopupModal('Добавить##аккаунт', nil, imgui.WindowFlags.AlwaysAutoResize) then
              imgui.PushItemWidth(180)
              imgui.InputText('Ник##аккаунт'..selected_account, temp_buffers.nickname)
              imgui.InputText('Пароль##аккаунт'..selected_account, temp_buffers.password)
              imgui.InputInt('Доп. пароль##аккаунт'..selected_account, temp_buffers.additionalpassword)
              imgui.InputText('GAuth secret##аккаунт'..selected_account, temp_buffers.gauth_secret, imgui.InputTextFlags.CharsNoBlank)
              if imgui.Button(getProjectNameByuID(temp_buffers.suID)..' '..getServerNameByuID(temp_buffers.suID)..'##аккаунт'..selected_account, imgui.ImVec2(180, 0)) then
                imgui.OpenPopup('Выбор сервера##аккаунт'..selected_account)
              end

              imgui.SetNextWindowSize(imgui.ImVec2(resX * 0.2, resY * 0.2))
              if imgui.BeginPopupModal('Выбор сервера##аккаунт'..selected_account, nil, imgui.WindowFlags.AlwaysAutoResize) then
                imgui.BeginGroup()
                  imgui.BeginChild('Выбор раздела##аккаунт'..selected_account, imgui.ImVec2(resX * 0.07, -imgui.GetItemsLineHeightWithSpacing()), true)
                    for i, v in ipairs(servers) do
                      if imgui.Selectable(v['title']..'##'..i..'раздел', selected_server_group == i) then
                        selected_server_group = i
                        if #servers[selected_server_group]['list'] ~= 0 then
                          selected_server = 1
                        else
                          selected_server = 0
                        end
                      end
                    end
                  imgui.EndChild()

                  imgui.SameLine()

                  imgui.BeginChild('Выбора сервера##аккаунт'..selected_account, imgui.ImVec2(resX * 0.07, -imgui.GetItemsLineHeightWithSpacing()), true)
                    for i, v in ipairs(servers[selected_server_group]['list']) do
                      if imgui.Selectable(v['name']..'##'..i..'сервер', selected_server == i) then
                        selected_server = i
                      end
                    end
                  imgui.EndChild()
                imgui.Separator()
                imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
                if imgui.Button('OK##выбор сервера'..selected_account, imgui.ImVec2(120, 0)) then
                  temp_buffers.suID = servers[selected_server_group]['list'][selected_server]['uID']
                  imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button('Отмена##выбор сервера'..selected_account, imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
                imgui.EndGroup()
                imgui.EndPopup()
              end

              imgui.PopItemWidth()
              imgui.Separator()
              imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
              if imgui.Button('OK##аккаунт', imgui.ImVec2(120, 0)) and #temp_buffers.nickname.v ~= 0 and #temp_buffers.password.v ~= 0 then
                table.insert(accounts, {
                  nickname           = temp_buffers.nickname.v,
                  password           = temp_buffers.password.v,
                  additionalpassword = temp_buffers.additionalpassword.v,
                  gauth_secret       = temp_buffers.gauth_secret.v,
                  suID               = temp_buffers.suID,
                })
                imgui.CloseCurrentPopup()
                selected_account = #accounts
                saveAllData()
              end
              imgui.SameLine()
              if imgui.Button('Отмена##аккаунт', imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
              imgui.EndPopup()
            end

            imgui.SameLine()

            ---------------------------------------------------------------------------
            ------------------------- Удаление аккаунта [DONE]
            ---------------------------------------------------------------------------

            if selected_account ~= 0 and #accounts ~= 0 then
              if imgui.Button('Удалить##аккаунт') then
                if not temp_buffers.dontAskAboutDeletingAccount.v then
                  imgui.OpenPopup('Удалить?##аккаунт')
                else
                  deleteAccount()
                end
              end
            end

            if imgui.BeginPopupModal('Удалить?##аккаунт', nil, imgui.WindowFlags.AlwaysAutoResize) then
              imgui.Text('Аккаунт '..accounts[selected_account]['nickname']..' будет полностью удален.\nДанное действие необратимо!\n\n')
              imgui.Checkbox('Больше меня не спрашивать', temp_buffers.dontAskAboutDeletingAccount)
              imgui.Separator()
              imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
              if imgui.Button('OK##аккаунт', imgui.ImVec2(120, 0)) then
                deleteAccount()
              end
              imgui.SameLine()
              if imgui.Button('Отмена##аккаунт', imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
              imgui.EndPopup()
            end

          imgui.EndGroup()

          imgui.SameLine()

          imgui.BeginGroup()

            imgui.BeginChild('Информация об аккаунте##'..selected_account, imgui.ImVec2(0, 0), true)

              if selected_account ~= 0 and #accounts ~= 0 then
                imgui.Text('Никнейм: '..accounts[selected_account]['nickname'])
                imgui.Text('Сервер: ')
                imgui.SameLine()
                local ip, port = getServerAddresByuID(accounts[selected_account]['suID'])
                imgui.Text(getProjectNameByuID(accounts[selected_account]['suID'])..' '..getServerNameByuID(accounts[selected_account]['suID'])..'\n'..ip..':'..port)
              end

            imgui.EndChild()

          imgui.EndGroup()

        ---------------------------------------------------------------------------
        ------------------------- Вторая вкладка. С серверами. [DONE]
        ---------------------------------------------------------------------------

        elseif selected_tab == 2 then

          imgui.BeginGroup()

          ---------------------------------------------------------------------------
          ------------------------- Выбор раздела из списка [DONE]
          ---------------------------------------------------------------------------

          imgui.BeginChild('Список разделов', imgui.ImVec2(resX * 0.07, -imgui.GetItemsLineHeightWithSpacing()), true)

            for i, v in ipairs(servers) do
              if imgui.Selectable(v['title']..'##'..i..'раздел', selected_server_group == i, imgui.SelectableFlags.AllowDoubleClick) then
                selected_server_group = i
                if #servers[selected_server_group]['list'] ~= 0 then
                  selected_server = 1
                else
                  selected_server = 0
                end

                ---------------------------------------------------------------------------
                ------------------------- Реализация двойного щелчка для измения раздела [DONE]
                ---------------------------------------------------------------------------

                if imgui.IsMouseDoubleClicked(0) and not servers[selected_server_group]['is_builtin'] then
                  temp_buffers.title = imgui.ImBuffer(20)
                  temp_buffers.title.v = servers[selected_server_group]['title']
                  imgui.OpenPopup('Изменить##раздел'..selected_server_group)
                end
              end
            end

            if imgui.BeginPopupModal('Изменить##раздел'..selected_server_group, nil, imgui.WindowFlags.AlwaysAutoResize) then
              imgui.PushItemWidth(180)
              imgui.InputText('Название##раздел', temp_buffers.title)
              imgui.PopItemWidth()
              imgui.Separator()
              imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
              if imgui.Button('OK##раздел', imgui.ImVec2(120, 0)) and #temp_buffers.title.v ~= 0 then
                servers[selected_server_group]['title'] = temp_buffers.title.v
                imgui.CloseCurrentPopup()
                saveAllData()
              end
              imgui.SameLine()
              if imgui.Button('Отмена##раздел', imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
              imgui.EndPopup()
            end
          imgui.EndChild()

          ---------------------------------------------------------------------------
          ------------------------- Добавление нового раздела [DONE]
          ---------------------------------------------------------------------------

          if imgui.Button('Добавить##раздел') then
            temp_buffers.title = imgui.ImBuffer(20)
            imgui.OpenPopup('Добавить##раздел')
          end

          if imgui.BeginPopupModal('Добавить##раздел', nil, imgui.WindowFlags.AlwaysAutoResize) then
            imgui.PushItemWidth(180)
            imgui.InputText('Название##раздел', temp_buffers.title)
            imgui.PopItemWidth()
            imgui.Separator()
            imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
            if imgui.Button('OK##раздел', imgui.ImVec2(120, 0)) and #temp_buffers.title.v ~= 0 then
              table.insert(servers, {title=temp_buffers.title.v,is_builtin=false,list={}})
              imgui.CloseCurrentPopup()
              selected_server_group = #servers
              selected_server = 0
              saveAllData()
            end
            imgui.SameLine()
            if imgui.Button('Отмена##раздел', imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
            imgui.EndPopup()
          end

          imgui.SameLine()

          ---------------------------------------------------------------------------
          ------------------------- Удаление раздела [DONE]
          ---------------------------------------------------------------------------
          if not servers[selected_server_group]['is_builtin'] and #servers ~= 0 then
            if imgui.Button('Удалить##раздел') then
              if not temp_buffers.dontAskAboutDeletingProject.v then
                imgui.OpenPopup('Удалить?##раздел')
              else
                deleteProject()
              end
            end
          end

          if imgui.BeginPopupModal('Удалить?##раздел', nil, imgui.WindowFlags.AlwaysAutoResize) then
            imgui.Text('Раздел '..servers[selected_server_group]['title']..' и все его сервера будут полностью удалены.\nВсе привязанные к нему аккаунты потеряют привязку\nДанное действие необратимо!\n\n')
            imgui.Checkbox('Больше меня не спрашивать', temp_buffers.dontAskAboutDeletingProject)
            imgui.Separator()
            imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
            if imgui.Button('OK##раздел', imgui.ImVec2(120, 0)) then
              deleteProject()
            end
            imgui.SameLine()
            if imgui.Button('Отмена##раздел', imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
            imgui.EndPopup()
          end

          imgui.EndGroup()

          imgui.SameLine()

          ---------------------------------------------------------------------------
          ------------------------- Меню с выбором сервера из раздела [DONE]
          ---------------------------------------------------------------------------

          imgui.BeginGroup()
          imgui.BeginChild('Список серверов', imgui.ImVec2(resX * 0.07, -imgui.GetItemsLineHeightWithSpacing()), true)
            for i, v in ipairs(servers[selected_server_group]['list']) do
              if imgui.Selectable(v['name']..'##'..i..'name', selected_server == i, imgui.SelectableFlags.AllowDoubleClick, imgui.ImVec2(resX * 0.07, 0)) then

                ---------------------------------------------------------------------------
                ------------------------- Реализация двойного щелчка для измения сервера [DONE]
                ---------------------------------------------------------------------------

                if imgui.IsMouseDoubleClicked(0) and not servers[selected_server_group]['is_builtin'] then
                  temp_buffers.title   = imgui.ImBuffer(20)
                  temp_buffers.ip      = imgui.ImBuffer(16)
                  temp_buffers.port    = imgui.ImInt(servers[selected_server_group]['list'][i]['port'])
                  temp_buffers.title.v = servers[selected_server_group]['list'][i]['name']
                  temp_buffers.ip.v    = servers[selected_server_group]['list'][i]['ip']
                  imgui.OpenPopup('Изменить##сервер'..selected_server)
                end
                selected_server = i
              end
            end
            if imgui.BeginPopupModal('Изменить##сервер'..selected_server, nil, imgui.WindowFlags.AlwaysAutoResize) then
              imgui.PushItemWidth(180)
              imgui.InputText('Название##сервер'..selected_server, temp_buffers.title)
              imgui.InputText('IP##сервер'..selected_server, temp_buffers.ip, imgui.InputTextFlags.CharsDecimal)
              imgui.InputInt('Порт##сервер'..selected_server, temp_buffers.port)
              imgui.PopItemWidth()
              imgui.Separator()
              imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
              if imgui.Button('OK##сервер'..selected_server, imgui.ImVec2(120, 0)) and #temp_buffers.title.v ~= 0 then
                servers[selected_server_group]['list'][selected_server]['title'] = temp_buffers.title.v
                servers[selected_server_group]['list'][selected_server]['ip'] = temp_buffers.ip.v
                servers[selected_server_group]['list'][selected_server]['port'] = temp_buffers.port.v
                imgui.CloseCurrentPopup()
                selected_server_group = #servers
                selected_server = #servers[selected_server_group]['list']
                saveAllData()
              end
              imgui.SameLine()
              if imgui.Button('Отмена##сервер'..selected_server, imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
              imgui.EndPopup()
            end

          imgui.EndChild()

          ---------------------------------------------------------------------------
          ------------------------- Добавление нового сервера в раздел [DONE]
          ---------------------------------------------------------------------------

          if not servers[selected_server_group]['is_builtin'] then
            if imgui.Button('Добавить##сервер'..selected_server) then
              local name           = sampGetCurrentServerName()
              local ip, port       = sampGetCurrentServerAddress()
              temp_buffers.title   = imgui.ImBuffer(100)
              temp_buffers.ip      = imgui.ImBuffer(16)
              temp_buffers.port    = imgui.ImInt(port)
              temp_buffers.title.v = name
              temp_buffers.ip.v    = ip
              imgui.OpenPopup('Добавить##сервер'..selected_server)
            end
          end

          if imgui.BeginPopupModal('Добавить##сервер'..selected_server, nil, imgui.WindowFlags.AlwaysAutoResize) then
            imgui.PushItemWidth(180)
            imgui.InputText('Название##сервер'..selected_server, temp_buffers.title)
            imgui.InputText('IP##сервер'..selected_server, temp_buffers.ip, imgui.InputTextFlags.CharsDecimal)
            imgui.InputInt('Порт##сервер'..selected_server, temp_buffers.port)
            imgui.PopItemWidth()
            imgui.Separator()
            imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
            if imgui.Button('OK##сервер'..selected_server, imgui.ImVec2(120, 0)) and #temp_buffers.title.v ~= 0 then
              table.insert(servers[selected_server_group]['list'], {name=temp_buffers.title.v,ip=temp_buffers.ip.v,port=temp_buffers.port.v,uID=last_uID+1})
              last_uID = last_uID + 1
              imgui.CloseCurrentPopup()
              selected_server_group = #servers
              selected_server = #servers[selected_server_group]['list']
              saveAllData()
            end
            imgui.SameLine()
            if imgui.Button('Отмена##сервер'..selected_server, imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
            imgui.EndPopup()
          end

          imgui.SameLine()

          ---------------------------------------------------------------------------
          ------------------------- Удаление сервера в разделе [DONE]
          ---------------------------------------------------------------------------

          if not servers[selected_server_group]['is_builtin'] and #servers[selected_server_group]['list'] ~= 0  and selected_server ~= 0 then
            if imgui.Button('Удалить##сервер'..selected_server) then
              if not temp_buffers.dontAskAboutDeletingServer.v then
                imgui.OpenPopup('Удалить?##сервер'..selected_server)
              else
                deleteServer()
              end
            end
          end

          if imgui.BeginPopupModal('Удалить?##сервер'..selected_server, nil, imgui.WindowFlags.AlwaysAutoResize) then
            imgui.Text('Сервер '..servers[selected_server_group]['list'][selected_server]['name']..' будет полностью удален.\nВсе привязанные к нему аккаунты потеряют привязку\nДанное действие необратимо!\n\n')
            imgui.Checkbox('Больше меня не спрашивать', temp_buffers.dontAskAboutDeletingServer)
            imgui.Separator()
            imgui.SetCursorPosX((imgui.GetWindowWidth() - 240 + imgui.GetStyle().ItemSpacing.x) / 2)
            if imgui.Button('OK##сервер'..selected_server, imgui.ImVec2(120, 0)) then
              deleteServer()
            end
            imgui.SameLine()
            if imgui.Button('Отмена##сервер'..selected_server, imgui.ImVec2(120, 0)) then imgui.CloseCurrentPopup() end
            imgui.EndPopup()
          end

          imgui.EndGroup()

          imgui.SameLine()

          ---------------------------------------------------------------------------
          ------------------------- Вывод информации о сервере в правом меню [DONE]
          ---------------------------------------------------------------------------

          imgui.BeginChild('Server info##сервер'..selected_server, imgui.ImVec2(0, 0), true)
            if selected_server ~= 0 then
              imgui.Text('uID: '..servers[selected_server_group]['list'][selected_server]['uID'])
              imgui.Text('IP: '..servers[selected_server_group]['list'][selected_server]['ip'])
              imgui.Text('Port: '..servers[selected_server_group]['list'][selected_server]['port'])
              imgui.Text('Builtin: '..tostring(servers[selected_server_group]['is_builtin']))
              imgui.Text('Accounts: '..getAccountsOnServer(servers[selected_server_group]['list'][selected_server]['uID']))
            end
          imgui.EndChild()

        ---------------------------------------------------------------------------
        ------------------------- Третья вкладка. С информацией. [DONE]
        ---------------------------------------------------------------------------

        else
          imgui.BeginChild('Infomation', imgui.ImVec2(resX * 0.27, 0), true)
            imgui.Text('Название: '..thisScript().name..'\nАвтор: Akionka\nВерсия: '..thisScript().version_num..'('..thisScript().version..')\nКоманды: /autologin, /generator')
            if updatesavaliable then
              if imgui.Button('Скачать обновление', imgui.ImVec2(150, 0)) then
                update('https://raw.githubusercontent.com/Akionka/autologin/master/autologin.lua')
                main_window_state.v = false
              end
            else
              if imgui.Button('Проверить обновление', imgui.ImVec2(150, 0)) then
                checkupdates('https://raw.githubusercontent.com/Akionka/autologin/master/version.json')
              end
            end
            if imgui.Button('Bug report [VK]', imgui.ImVec2(150, 0)) then os.execute('explorer "https://vk.com/akionka"') end
            imgui.SameLine()
            if imgui.Button('Bug report [Telegram]', imgui.ImVec2(150, 0)) then os.execute('explorer "https://teleg.run/akionka"') end
            if
            imgui.Checkbox('Больше меня не спрашивать об удалении аккаунта', temp_buffers.dontAskAboutDeletingAccount) or
            imgui.Checkbox('Больше меня не спрашивать об удалении раздела (проекта)', temp_buffers.dontAskAboutDeletingProject) or
            imgui.Checkbox('Больше меня не спрашивать об удалении сервера', temp_buffers.dontAskAboutDeletingServer) then
              saveAllData()
            end
            local file = getWorkingDirectory()..'\\config\\accounts.json'
            if doesFileExist(file) then
              imgui.Separator()
              if imgui.Button('Импортировать данные старого формата') then
                local f = io.open(file, 'r')
                local json = decodeJson(f:read('*a'))
                for i,v in ipairs(json) do
                  table.insert(accounts, {
                    nickname           = v['user_name'],
                    password           = v['user_password'],
                    additionalpassword = v['user_textdrawpass'],
                    gauth_secret       = v['gauth_secret'],
                    suID               = v['server_ip'] == '185.169.134.83' and 34 or v['server_ip'] == '185.169.134.84' and 35 or v['server_ip'] == '185.169.134.85' and 36 or 1,
                  })
                end
                f:close()
                os.remove(file)
                saveAllData()
              end
            end
          imgui.EndChild()
        end
    imgui.End()
  end

  if generator_window_state.v then
    local function getTOTPLiveTime()
      return 30 - math.floor((os.time() / 30 - math.floor(os.time() / 30)) * 30 + 0.5)
    end
    local resX, resY = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(resX * 0.2, resY * 0.2))
    imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.Once, imgui.ImVec2(0.5, 0.5))
    imgui.Begin('Генератор TOTP кода (GAuth)', generator_window_state, imgui.WindowFlags.AlwaysAutoResize)
      imgui.InputText('GAuth код', temp_buffers.gauth, imgui.InputTextFlags.CharsNoBlank)
      local result, output = pcall(genCode, temp_buffers.gauth.v)
      if result then
        imgui.Text('Код будет актуален в течение '..getTOTPLiveTime()..' секунд. (Максимум - 30)')
        imgui.Text(output)
        if imgui.Button('Скопировать в буфер обмена') then
          imgui.SetClipboardText(output)
        end
      else
        imgui.Text('GAuth код невалидный')
      end
    imgui.End()


  end
end

function apply_custom_style()imgui.SwitchContext()local a=imgui.GetStyle()local b=a.Colors;local c=imgui.Col;local d=imgui.ImVec4;a.WindowRounding=0.0;a.WindowTitleAlign=imgui.ImVec2(0.5,0.5)a.ChildWindowRounding=0.0;a.FrameRounding=0.0;a.ItemSpacing=imgui.ImVec2(5.0,5.0)a.ScrollbarSize=13.0;a.ScrollbarRounding=0;a.GrabMinSize=8.0;a.GrabRounding=0.0;b[c.TitleBg]=d(0.60,0.20,0.80,1.00)b[c.TitleBgActive]=d(0.60,0.20,0.80,1.00)b[c.TitleBgCollapsed]=d(0.60,0.20,0.80,1.00)b[c.CheckMark]=d(0.60,0.20,0.80,1.00)b[c.Button]=d(0.60,0.20,0.80,0.31)b[c.ButtonHovered]=d(0.60,0.20,0.80,0.80)b[c.ButtonActive]=d(0.60,0.20,0.80,1.00)b[c.WindowBg]=d(0.13,0.13,0.13,1.00)b[c.Header]=d(0.60,0.20,0.80,0.31)b[c.HeaderHovered]=d(0.60,0.20,0.80,0.80)b[c.HeaderActive]=d(0.60,0.20,0.80,1.00)b[c.FrameBg]=d(0.60,0.20,0.80,0.31)b[c.FrameBgHovered]=d(0.60,0.20,0.80,0.80)b[c.FrameBgActive]=d(0.60,0.20,0.80,1.00)b[c.ScrollbarBg]=d(0.60,0.20,0.80,0.31)b[c.ScrollbarGrab]=d(0.60,0.20,0.80,0.31)b[c.ScrollbarGrabHovered]=d(0.60,0.20,0.80,0.80)b[c.ScrollbarGrabActive]=d(0.60,0.20,0.80,1.00)b[c.Text]=d(1.00,1.00,1.00,1.00)b[c.Border]=d(0.60,0.20,0.80,0.00)b[c.BorderShadow]=d(0.00,0.00,0.00,0.00)b[c.CloseButton]=d(0.60,0.20,0.80,0.31)b[c.CloseButtonHovered]=d(0.60,0.20,0.80,0.80)b[c.CloseButtonActive]=d(0.60,0.20,0.80,1.00)end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end

  if not doesDirectoryExist(getWorkingDirectory()..'\\config') then
    createDirectory(getWorkingDirectory()..'\\config')
  end

  checkupdates('https://raw.githubusercontent.com/Akionka/autologin/master/version.json')
  apply_custom_style()
  sampAddChatMessage(u8:decode('[Autologin]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {9932cc}'..thisScript().version..'{FFFFFF}.'), -1)

  loadAllData()

  sampRegisterChatCommand('autologin', function()
    main_window_state.v = not main_window_state.v
  end)

  sampRegisterChatCommand('trinity_collebrate', function()
    collebrating_state = 1
    sampAddChatMessage(u8:decode('[Autologin]: Пожалуйста, нажмите на самую левую ячейку (неправильный выбор приведет к ошибкам при входе).'), -1)
   end)

  temp_buffers.gauth   = imgui.ImBuffer(100)
  temp_buffers.gauth.v = 'random'

  sampRegisterChatCommand('generator', function()
    generator_window_state.v = not generator_window_state.v

  end)

  while true do
    wait(0)
    imgui.Process = main_window_state.v or generator_window_state.v
  end
end

function getAccountsOnServer(uID)
  local amount = 0
  for k, v in pairs(accounts) do
    if v['suID'] == uID then
      amount = amount + 1
    end
  end
  return amount
end

function getServerAddresByuID(suID)
  for i1, v1 in ipairs(servers) do
    for i2, v2 in ipairs(v1['list']) do
      if v2['uID'] == suID then
        return v2['ip'], v2['port']
      end
    end
  end
  return 'Error'
end

function getServerNameByuID(uID)
  local result, name = doesServerExists(uID)
  return name
end

function getProjectNameByuID(uID)
  local result, _, title = doesServerExists(uID)
  return title
end

function doesServerExists(suID)
  for i1, v1 in ipairs(servers) do
    for i2, v2 in ipairs(v1['list']) do
      if v2['uID'] == suID then
        return true, v2['name'], v1['title']
      end
    end
  end
  return false
end

function deleteAccount()
  table.remove(accounts, selected_account)
  imgui.CloseCurrentPopup()
  selected_account = selected_account-1
  saveAllData()
end

function deleteProject()
  table.remove(servers, selected_server_group)
  imgui.CloseCurrentPopup()
  selected_server_group = selected_server_group - 1
  selected_server = 0
  saveAllData()
end

function deleteServer()
  table.remove(servers[selected_server_group]['list'], selected_server)
  imgui.CloseCurrentPopup()
  selected_server = selected_server - 1
  saveAllData()
end

function saveAllData()
  local file = getWorkingDirectory()..'\\config\\autologin.json'
  local f = io.open(file, 'w+')
  if f then
    f:write(encodeJson({
      servers                     = servers,
      accounts                    = accounts,
      last_uID                    = last_uID,
      dontAskAboutDeletingAccount = temp_buffers.dontAskAboutDeletingAccount.v,
      dontAskAboutDeletingServer  = temp_buffers.dontAskAboutDeletingServer.v,
      dontAskAboutDeletingProject = temp_buffers.dontAskAboutDeletingProject.v,
      trinity_data                = trinity_data
  })):close()
  else
    sampAddChatMessage('[Autologin]: Упс, ошибка сохранения.', -1)
  end
end

function loadAllData()
  local file = getWorkingDirectory()..'\\config\\autologin.json'

  -- Если файл не сущестует, то заполняем его шаблоном
  if not doesFileExist(file) then
    local f = io.open(file, 'w+')
    if f then
      f:write(encodeJson({
        servers   = servers,
        accounts                    = accounts,
        last_uID                    = last_uID,
        dontAskAboutDeletingAccount = false,
        dontAskAboutDeletingServer  = false,
        dontAskAboutDeletingProject = false,
        trinity_data                = trinity_data
      }))
      f:close()
      temp_buffers.dontAskAboutDeletingAccount = imgui.ImBool(false)
      temp_buffers.dontAskAboutDeletingServer  = imgui.ImBool(false)
      temp_buffers.dontAskAboutDeletingProject = imgui.ImBool(false)
    end
    return
  end
  -- А если сущестует, то просто выгружаем все данные
  local f = io.open(file, 'r')
  if f then
    local json = decodeJson(f:read('*a'))
    servers                                  = json['servers']
    accounts                                 = json['accounts']
    last_uID                                 = json['last_uID']
    temp_buffers.dontAskAboutDeletingAccount = imgui.ImBool(json['dontAskAboutDeletingAccount'])
    temp_buffers.dontAskAboutDeletingServer  = imgui.ImBool(json['dontAskAboutDeletingServer'])
    temp_buffers.dontAskAboutDeletingProject = imgui.ImBool(json['dontAskAboutDeletingProject'])
    trinity_data                             = json['trinity_data'] or trinity_data
    f:close()
    local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    local ip1, port1 = sampGetCurrentServerAddress()
    for i, v in ipairs(accounts) do
      local ip2, port2 = getServerAddresByuID(accounts[i]['suID'])
      if v['nickname'] == nick and ip1 == ip2 and port1 == port2 then
        account_info = v
      end
    end
  end
end

function checkupdates(json)
  local fpath = os.tmpname()
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
            sampAddChatMessage(u8:decode('[Autologin]: Найдено объявление. Текущая версия: {9932cc}'..thisScript().version..'{FFFFFF}, новая версия: {9932cc}'..info.version..'{FFFFFF}.'), -1)
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
      sampAddChatMessage(u8:decode('[Autologin]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {9932cc}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
      thisScript():reload()
    end
  end)
end
