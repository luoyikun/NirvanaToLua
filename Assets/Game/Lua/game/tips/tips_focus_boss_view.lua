TipsFocusBossView = TipsFocusBossView or BaseClass(BaseView)

function TipsFocusBossView:__init()
	self.ui_config = {{"uis/views/tips/focustips_prefab", "FocusTips"}}
	self.is_rune = false
	self.view_layer = UiLayer.Pop
	self.is_yi_ji = false
	self.is_Boss_type = false
end

function TipsFocusBossView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseClick, self))
	self.node_list["BtnGo"].button:AddClickListener(BindTool.Bind(self.GoClick, self))

end

function TipsFocusBossView:ReleaseCallBack()

end

function TipsFocusBossView:OpenCallBack()
end

function TipsFocusBossView:CloseClick()
	self:Close()
end

function TipsFocusBossView:GoClick()
	if self.ok_call_back then
		self.ok_call_back()
	end
	self:Close()
end

function TipsFocusBossView:CloseCallBack()
	self.is_rune = false
	self.is_Boss_type = false
	self.boss_id = nil
	self.ok_call_back = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsFocusBossView:SetData(boss_id, ok_call_back)
	self.boss_id = boss_id
	self.ok_call_back = ok_call_back
	self:Flush()
end

function TipsFocusBossView:SetRuneInfo(is_rune)
	self.is_rune = is_rune or false
end

function TipsFocusBossView:SetXingZuoYiJiInfo(is_yi_ji)
	self.is_yi_ji = is_yi_ji or false
end

function TipsFocusBossView:SetBossTypeBool(is_Boss_type)
	self.is_Boss_type = is_Boss_type
end

function TipsFocusBossView:SetIsMikuElite(is_miku_elite)
	self.is_miku_elite = is_miku_elite
end

function TipsFocusBossView:SetIsGuildYunBiao(is_guild_yunbiao)
	self.is_guild_yunbiao = is_guild_yunbiao
end

function TipsFocusBossView:SetIsGuildYanHui(is_guild_yanhui)
	self.is_guild_yanhui = is_guild_yanhui
end

function TipsFocusBossView:OnFlush()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.node_list["TxtTime"]:SetActive(not self.is_rune)
	-- self.node_list["Img"]:SetActive(self.is_rune or self.is_yi_ji)
	self.node_list["BossIcon"]:SetActive(not (self.is_rune or self.is_yi_ji))
	self.node_list["Title"]:SetActive(true)
	self.node_list["Toggle_bg"]:SetActive(false)
	local bundle, asset = nil, nil
	if self.boss_id then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto")
		if nil ~= monster_cfg and nil ~= monster_cfg.monster_list then
			monster_cfg = monster_cfg.monster_list[self.boss_id]
		end
		if monster_cfg then
			bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
			self.node_list["BossIcon"].image:LoadSprite(bundle, asset)
		end

		if self.is_Boss_type then
			local scene_type = BossData.Instance:GetSceneTypeByBossID(self.boss_id)
			self.node_list["ImgMonsterIcon"]:SetActive(true)
			if scene_type then
				local title_bundle, title_asset = ResPath.GetBossTypeTag(scene_type)
				self.node_list["Title"].image:LoadSprite(title_bundle, title_asset)
			end
			self.node_list["Txt_Desc"].text.text = string.format(Language.Boss.BossFocusDesc, monster_cfg.level, monster_cfg.name)
			self.node_list["TxtBtn"].text.text = string.format(Language.FocusTips.Time1, "15")
			self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.BossCountDown, self))
			return
		else
			self.node_list["ImgMonsterIcon"]:SetActive(true)
			self.node_list["Txt_Desc"].text.text = Language.Boss.CommonBossFlushDesc
		end

	elseif self.is_rune then
		bundle, asset = ResPath.GetGuajiTaIcon()
		self.node_list["Img"].image:LoadSprite(bundle, asset)
		self.node_list["Txt_Desc"].text.text = Language.Rune.OfflineTimeNoEnough
		self.node_list["TxtBtn"].text.text = Language.OpenServer.GoBuy
		return

	elseif self.is_yi_ji then
		bundle, asset = ResPath.GetXingZuoYiJiIcon()
		self.node_list["Img"].image:LoadSprite(bundle, asset)
		self.node_list["Txt_Desc"].text.text = Language.ShengXiao.OpenXingZuoYiJi
		self.node_list["TxtBtn"].text.text = Language.Common.GoImmediately
	elseif self.is_guild_yunbiao then
		self.node_list["Title"]:SetActive(false)
		bundle,asset =ResPath.GetMainIcon("Icon_Activity_27")
		self.node_list["BossIcon"].image:LoadSprite(bundle, asset)
		self.node_list["Txt_Desc"].text.text = Language.Guild.GuildNvShenStart
		self.node_list["TxtBtn"].text.text = Language.Common.GoImmediately
	elseif self.is_guild_yanhui then
		self.node_list["Title"]:SetActive(false)
		bundle,asset =ResPath.GetMainIcon("Icon_Activity_33")
		self.node_list["BossIcon"].image:LoadSprite(bundle, asset)
		self.node_list["Txt_Desc"].text.text = Language.Guild.GuildYanHuiStart
		self.node_list["TxtBtn"].text.text = Language.Common.GoImmediately		
	else
		self.node_list["ImgMonsterIcon"]:SetActive(true)
		bundle, asset = ResPath.GetMainIcon("Icon_System_Boss")
		self.node_list["BossIcon"].image:LoadSprite(bundle, asset)
		self.node_list["Txt_Desc"].text.text = Language.Boss.BossFlushDesc
	end

	self.node_list["TxtTime"].text.text = string.format(Language.FocusTips.Time2, "15")
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusBossView:CountDown(elapse_time, total_time)
	local str_tmp = math.ceil(total_time - elapse_time)
	self.node_list["TxtTime"].text.text = string.format(Language.FocusTips.Time2, str_tmp)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end

function TipsFocusBossView:BossCountDown(elapse_time, total_time)
	local str_tmp = math.ceil(total_time - elapse_time)
	self.node_list["TxtBtn"].text.text = string.format(Language.FocusTips.Time1, str_tmp)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end