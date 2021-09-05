GuildTotemView = GuildTotemView or BaseClass(BaseRender)

function GuildTotemView:__init(instance)
	if instance == nil then
		return
	end

	self.node_list["ButtonLevelUp"].button:AddClickListener(BindTool.Bind(self.OnClickLevelUp, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OpenWindow, self))
	self.last_totem_level = GuildDataConst.GUILDVO.guild_totem_level
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Capability"])

	self.amount = 0
	self.qizhi_model = nil
	self.res_id = -1
end

function GuildTotemView:__delete()
	if self.qizhi_model then
		self.qizhi_model:DeleteMe()
		self.qizhi_model = nil
	end
	self.fight_text = nil
end

function GuildTotemView:Flush()
	local totem_level = GuildDataConst.GUILDVO.guild_totem_level
	local totem_exp = GuildDataConst.GUILDVO.guild_totem_exp
	local totem_config = GuildData.Instance:GetTotemConfig()
	if totem_config then
		local exp = totem_config.max_exp
		if exp ~= 0 then
			self.amount = totem_exp / exp
			if self.amount > 1 then
				self.amount = 1
			end
		else
			self.amount = 1
		end
		if self.amount >= 1 then
			local info = GuildData.Instance:GetGuildMemberInfo()
			if info then
				if info.post == GuildDataConst.GUILD_POST.TUANGZHANG or info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then

					self.node_list["RedPoint"]:SetActive(true)
				end
			end
		else
			self.node_list["RedPoint"]:SetActive(false)
		end

		self.node_list["ExpBarText"].text.text = totem_exp .. "/" .. exp
		self.node_list["ExpBar"].slider.value = self.amount
		self.node_list["LevelText"].text.text = totem_level
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self:CalculateFp()
		end
		self.node_list["GongJi"].text.text = totem_config.gongji
		self.node_list["FangYu"].text.text = totem_config.fangyu
		self.node_list["ShengMing"].text.text = totem_config.maxhp
		self.node_list["LeaderGongJi"].text.text = totem_config.leader_gongji

		self.node_list["CurExp"].text.text = totem_config.bless_exp
		self.node_list["CurHp"].text.text = CommonDataManager.ConverMoney(totem_config.totem_hp)
	end
	totem_config = GuildData.Instance:GetTotemConfig(totem_level + 1)
	if totem_config then

		UI:SetButtonEnabled(self.node_list["ButtonLevelUp"], true)
		self.node_list["Arrow1"]:SetActive(true)
		self.node_list["Arrow2"]:SetActive(true)
		self.node_list["TextMaxLevel"]:SetActive(false)
		self.node_list["TextMaxLevel2"]:SetActive(false)
		self.node_list["NextExp"].text.text = totem_config.bless_exp
		self.node_list["NextHp"].text.text = CommonDataManager.ConverMoney(totem_config.totem_hp)
		self.node_list["BtnText"].text.text = Language.Common.Up
	else
		self.node_list["RedPoint"]:SetActive(false)
		GuildCtrl.Instance.view:SetRedPoint(Guild_PANEL.totem, false)
		UI:SetButtonEnabled(self.node_list["ButtonLevelUp"], false)
		self.node_list["NextExp"].text.text = ""
		self.node_list["NextHp"].text.text = ""
		self.node_list["Arrow1"]:SetActive(false)
		self.node_list["Arrow2"]:SetActive(false)
		self.node_list["TextMaxLevel"]:SetActive(true)
		self.node_list["TextMaxLevel2"]:SetActive(true)
		self.node_list["BtnText"].text.text = Language.Common.YiManJi
	end

	if(totem_level > self.last_totem_level) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.TotemUpSucc)
		self.last_totem_level = totem_level
	end
	self:SetQizhiModel(totem_level)
end

function GuildTotemView:OnClickLevelUp()
	local post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
		return
	end
	if self.amount < 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotTotemEXP)
		return
	end
	GuildCtrl.Instance:SendGuildTotemUplevelReq()
end

function GuildTotemView:CalculateFp()
	local temp_fight_power = 0
	local totem_config = GuildData.Instance:GetTotemConfig()
	if totem_config then
		local value = {maxhp = totem_config.maxhp, gongji = totem_config.gongji, fangyu = totem_config.fangyu}
		temp_fight_power = CommonDataManager.GetCapability(value)
	end

	local info = GuildData.Instance:GetGuildMemberInfo()
	if info then
		if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
			local value = {gongji = totem_config.leader_gongji}
			temp_fight_power = temp_fight_power + CommonDataManager.GetCapability(value)
		end
	end
	return temp_fight_power
end

function GuildTotemView:OpenWindow()
	TipsCtrl.Instance:ShowHelpTipView(150)
end

function GuildTotemView:CloseAllWindow()

end

function GuildTotemView:InitQizhiModel()
	if not self.qizhi_model then
		self.qizhi_model = RoleModel.New()
		self.qizhi_model:SetDisplay(self.node_list["QiZhiDisplay"].ui3d_display)
	end
end

function GuildTotemView:SetQizhiModel(level)
	local res_id = GuildData.Instance:GetQiZhiResId(level)
	if self.res_id ~= res_id then
		self.res_id = res_id
		local asset_bundle, name = ResPath.GetQiZhiModel(res_id)
		if not self.qizhi_model then
			self:InitQizhiModel()
		end
		if self.qizhi_model then
			if asset_bundle and name then
				self.qizhi_model:SetMainAsset(asset_bundle, name)
			end
		end
	end
end