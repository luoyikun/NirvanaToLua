GuildInfoView = GuildInfoView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate

function GuildInfoView:__init(instance)
	if instance == nil then
		return
	end

	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.HandleOpenNotice, self))
	self.node_list["ButtonOperate"].button:AddClickListener(BindTool.Bind(self.OnOpenOperation, self))

	self.node_list["BtnZhuDi"].button:AddClickListener(BindTool.Bind(self.EnterStation, self))
	self.node_list["BtnChat"].button:AddClickListener(BindTool.Bind(self.OnClickChat, self))
	self.node_list["BtnWafare"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnChangeName"].button:AddClickListener(BindTool.Bind(self.OnClickRename, self))
	self.node_list["BtnInclude"].button:AddClickListener(BindTool.Bind(self.OnClickInvite, self))
	self.node_list["ButtonDoation"].button:AddClickListener(BindTool.Bind(self.OnClickDonate, self))
	self.node_list["BtnAddMember"].button:AddClickListener(BindTool.Bind(self.OnClickPlus, self))
	self.node_list["ButtonRedPocket"].button:AddClickListener(BindTool.Bind(self.OpenHongBaoView, self))
	self.node_list["AutoKickToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickAutoKickOut, self))
	self.node_list["ButtonGuildHead"].button:AddClickListener(BindTool.Bind(self.OnClickChangePortrait, self))
	self.node_list["Touxiang"].button:AddClickListener(BindTool.Bind(self.OnClickChangePortrait, self))
	self.node_list["GuildWage"].button:AddClickListener(BindTool.Bind(self.OnClickGuildGongZi, self))
	-- self.node_list["ButtonSignin"].button:AddClickListener(BindTool.Bind(self.OnClickSignin, self))
	self.node_list["GuildShop"].button:AddClickListener(BindTool.Bind(self.OnClickGuildShop, self))
	self.node_list["GuildWare"].button:AddClickListener(BindTool.Bind(self.OnClickGuildWarehouse, self))

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG or vo.guild_post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.node_list["AutoKickToggle"].toggle.isOn = GuildDataConst.GUILDVO.is_auto_clear == 1
	end

	self.head_change = GlobalEventSystem:Bind(ObjectEventType.HEAD_CHANGE,
		BindTool.Bind(self.OnHeadChange, self))
	self.guild_head_change = GlobalEventSystem:Bind(ObjectEventType.GUILD_HEAD_CHANGE,
		BindTool.Bind(self.ChangeTempHead, self))
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
end

function GuildInfoView:__delete()
	if(self.cell_list ~= nil) then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
	if nil ~= self.head_change then
		GlobalEventSystem:UnBind(self.head_change)
		self.head_change = nil
	end
	if nil ~= self.guild_head_change then
		GlobalEventSystem:UnBind(self.guild_head_change)
		self.guild_head_change = nil
	end
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function GuildInfoView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "guild_name" then
		GuildDataConst.GUILDVO.guild_name = value
		self:Flush()
	end
end

function GuildInfoView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

function GuildInfoView:OnFlush()
	self.node_list["GuildOwnerName"].text.text = GuildDataConst.GUILDVO.tuanzhang_name
	self.node_list["GuildOwnerName2"].text.text = GuildDataConst.GUILDVO.tuanzhang_name
	self.node_list["GuildName"].text.text = GuildDataConst.GUILDVO.guild_name
	self.node_list["GuildRank"].text.text = GuildDataConst.GUILDVO.rank
	self.node_list["GuildLevel"].text.text = GuildDataConst.GUILDVO.guild_level
	self.node_list["MemberCount"].text.text = GuildDataConst.GUILDVO.cur_member_count .. " / " .. GuildDataConst.GUILDVO.max_member_count

	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG then
		self.node_list["AutoKickToggle"]:SetActive(true)
	else
		self.node_list["AutoKickToggle"]:SetActive(false)
	end
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.node_list["BtnChangeName"]:SetActive(true)
		self.node_list["BtnAddMember"]:SetActive(true)
		self.node_list["ButtonHelp"]:SetActive(true)
	else
		self.node_list["BtnChangeName"]:SetActive(false)
		self.node_list["BtnAddMember"]:SetActive(false)
		self.node_list["ButtonHelp"]:SetActive(false)
	end

	local is_open_guild_wage = OpenFunData.Instance:CheckIsHide("guild_gongzi")
	self.node_list["GuildWage"]:SetActive(is_open_guild_wage)
	local is_open_guild_warehouse = OpenFunData.Instance:CheckIsHide("guild_warehouse")
	self.node_list["GuildWare"]:SetActive(is_open_guild_warehouse)
	local is_open_guild_shop = OpenFunData.Instance:CheckIsHide("guild_contribute")
	self.node_list["GuildShop"]:SetActive(is_open_guild_shop)

	local is_show_wage_red_point = GuildData.Instance:IsCanShowGongZiRedPoint()
	self.node_list["ImgWageRedPoint"]:SetActive(is_show_wage_red_point)

	local guild_config = GuildData.Instance:GetGuildConfig()
	if guild_config then
		local level_config = guild_config.level_config
		if level_config then
			local max_level = #level_config
			local config = level_config[GuildDataConst.GUILDVO.guild_level or 0]
			if config then
				 -- 公会资金
				local exp = CommonDataManager.ConverMoney(GuildDataConst.GUILDVO.guild_exp)
				if max_level <= GuildDataConst.GUILDVO.guild_level then
					self.node_list["TextGuildExp"].text.text = exp .. " / " .. Language.Common.YiMan
				else
					self.node_list["TextGuildExp"].text.text = exp .. " / " .. config.max_exp
				end
				
			end
		end
	end

	local guild_notice = GuildDataConst.GUILDVO.guild_notice
	if(guild_notice == "") then
		guild_notice = Language.Guild.EmptyNotice
	end

	self.node_list["TextGuildPublish"].text.text = guild_notice
	if GuildDataConst.GUILD_APPLYFOR_LIST.count > 0 and (post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG) then

		self.node_list["RedPointOperate"]:SetActive(true)
	else
		self.node_list["RedPointOperate"]:SetActive(false)
	end

	self.node_list["ImgHasGet"]:SetActive(false)
	local fuli_count = GuildData.Instance:GetGuildFuLiCount() or 0
	if fuli_count < 1 and not GuildData.Instance:IsGuildCD() then

		self.node_list["RedPointZhuDi"]:SetActive(true)
	else
		self.node_list["RedPointZhuDi"]:SetActive(false)
		self.node_list["ImgHasGet"]:SetActive(true)
	end

	self.node_list["RedPointPocket"]:SetActive(GuildData.Instance:GetRedPacketRemindNum() == 1)

	self.node_list["BtnInclude"]:SetActive(true)
	post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG then
		self.node_list["BtnInclude"]:SetActive(false)
	end

	local card_id = GuildData.Instance:GetGuildJianSheId()

	self.node_list["RedPointDonate"]:SetActive(false)
	if card_id then
		local card_count = ItemData.Instance:GetItemNumInBagById(card_id)
		if card_count > 0 then

			self.node_list["RedPointDonate"]:SetActive(true)
		end
	end

	-- 签到小红点
	local remind_num = GuildData.Instance:GetSigninRemind()
	self.node_list["RedPointSignIn"]:SetActive(remind_num >= 1)

	local guild_head_remind_num = GuildData.Instance:GetGuildHeadRemind()
	self.node_list["RedPointHead"]:SetActive(guild_head_remind_num >= 1)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG or vo.guild_post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self.node_list["AutoKickToggle"].toggle.isOn = GuildDataConst.GUILDVO.is_auto_clear == 1
	end
	-- self:FlushNotice()
	self:OnHeadChange()
end

function GuildInfoView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["PlayerPanel"], Vector3(-603.2, 600, 0), TWEEN_TIME)
	UITween.MoveShowPanel(self.node_list["RightContent"], GuildData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GuildData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)

end

function GuildInfoView:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Guild) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["PortraitImage"]:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0)
	self.node_list["PortraitRaw"]:SetActive(AvatarManager.Instance:isDefaultImg(vo.guild_id, true) ~= 0)
	if AvatarManager.Instance:isDefaultImg(vo.guild_id, true) == 0 then
		local bundle, asset = ResPath.GetGuildBadgeIcon()
		self.node_list["PortraitImage"].image:LoadSprite(bundle, asset)
		self.node_list["Portrait"].image:LoadSprite(bundle, asset)
		return
	end
	local callback = function (path)
		self.avatar_path_big = path or AvatarManager.GetFilePath(vo.guild_id, true, true)
		if self.node_list then
			self.node_list["PortraitRaw"].raw_image:LoadURLSprite(self.avatar_path_big, function() end)
		end
	end

	AvatarManager.Instance:GetAvatar(vo.guild_id, true, callback, vo.guild_id)
end

function GuildInfoView:ChangeTempHead(path)
	if nil == path then
		return
	end
	self.node_list["PortraitImage"]:SetActive(false)
	self.node_list["PortraitRaw"]:SetActive(true)
	self.node_list["PortraitRaw"].raw_image:LoadURLSprite(path, function()
	end)
end

-- 进入驻地
function GuildInfoView:EnterStation()
	local guild_id = GuildData.Instance.guild_id
	if guild_id and guild_id > 0 then
		GuildCtrl.Instance:SendGuildBackToStationReq(guild_id)
	end
end

function GuildInfoView:OnClickChat()
	ViewManager.Instance:Close(ViewName.Guild)
	ViewManager.Instance:Open(ViewName.ChatGuild)
end

function GuildInfoView:OnOpenOperation()
	GuildCtrl.Instance:OpenOpearteView()
end

function GuildInfoView:OnClickReward()
	local fuli_count = GuildData.Instance:GetGuildFuLiCount() or 0
	if fuli_count < 1 and not GuildData.Instance:IsGuildCD() then
		AudioService.Instance:PlayRewardAudio()
	end
	GuildCtrl.Instance:SendGuildFetchRewardReq(GUILD_COMMON_REQ_TYPE.GUILD_COMMON_REQ_TYPE_FETCH_REWARD)
end

-- 关闭所有弹窗
function GuildInfoView:CloseAllWindow()
	-- self.node_list["NoticeWindow"]:SetActive(false)
	-- self.node_list["OperationWindow"]:SetActive(false)
end

-- 关闭所有弹窗
function GuildInfoView:OnClose()
	self:CloseAllWindow()
	self:Flush()
end

function GuildInfoView:OnClickGuildFight()
	ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_activity)
end

function GuildInfoView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(152)
end

function GuildInfoView:OnClickRename()
	local post = GuildData.Instance:GetGuildPost()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local describe = Language.Role.RenameGuildTxt
	local yes_func = function(new_name) GuildCtrl.Instance:SendResetNameReq(guild_id, new_name) end
	
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		local number = ItemData.Instance:GetItemNumInBagById(COMMON_CONSTS.GUILD_CHANGE_NAME)
		if number < 1 then
			local func = function(item_id, num, is_bind, is_tip_use) 
				ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0)
				TipsCtrl.Instance:ShowRename(yes_func, nil, COMMON_CONSTS.GUILD_CHANGE_NAME, nil, describe)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, COMMON_CONSTS.GUILD_CHANGE_NAME, nil, 1)
		else
			TipsCtrl.Instance:ShowRename(yes_func, nil, COMMON_CONSTS.GUILD_CHANGE_NAME, nil, describe)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
	end
end

-- 增加公会人数上限
function GuildInfoView:OnClickPlus()
	local post = GuildData.Instance:GetGuildPost()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		if GuildDataConst.GUILDVO.max_member_count >= GuildData.Instance:GetMaxGuildMemberCount() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxMemberCount)
			return
		end
		local extend_member_item_id = GuildData.Instance:GetGuildExtendId() or 0
		local need_num = GuildData.Instance:GetGuildExtendCountByNum() or 0
		local has_num = ItemData.Instance:GetItemNumInBagById(extend_member_item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(extend_member_item_id) or {}
		local item_name = item_cfg.name or ""
		local describe = string.format(Language.Guild.AddMemberCount, need_num, item_name)
		if has_num < need_num then
			local shop_cfg = ShopData.Instance:GetShopItemCfg(extend_member_item_id) or {}
			local price = shop_cfg.gold or 0
			local cost = price * (need_num - has_num) or 0
			describe = string.format(Language.Guild.AddMemberCount2, need_num, item_name, need_num - has_num, cost)
		end
		local yes_func = function() GuildCtrl.Instance:SendGuildExtendMemberReq(GUILD_EXTEND_OPERATE_TYPE.EXTEND_MEMBER, 1, 1) end
		TipsCtrl.Instance:ShowCommonAutoView("AddMember", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
	end
end

function GuildInfoView:OnClickInvite()
	local last_callin_time = GuildData.Instance:GetLastCallinTime()
	if last_callin_time + 10 <= Status.NowTime then
		local yes_func = function()
			GuildCtrl.Instance:SendGuildCallInReq()
		end
		if GuildData.Instance:GetCanCallinFree() then
			yes_func()
		else
			local describe = string.format(Language.Guild.ZhaoMuCost, GuildData.Instance:GetCallinPrice())
			TipsCtrl.Instance:ShowCommonAutoView("guild_callin", describe, yes_func)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InviteCD)
	end
end

function GuildInfoView:OnClickDonate()
	GuildCtrl.Instance:OpenDonateView()
end

function GuildInfoView:OpenHongBaoView()
	ViewManager.Instance:Open(ViewName.GuildRedPacket)
end

function GuildInfoView:OnClickAutoKickOut(switch)
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG then
		GuildCtrl.Instance:SendGuildSetAutoClearReq(switch and 1 or 0)
	end
end

function GuildInfoView:OnClickGuildGongZi()
	ViewManager.Instance:Open(ViewName.GuildWageView)
end

function GuildInfoView:OnClickGuildWarehouse()
	GuildCtrl.Instance:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_REQ_INFO)
	ViewManager.Instance:Open(ViewName.GuildWarehouseView)
end

function GuildInfoView:OnClickGuildShop()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_guildcontribute)
end

function GuildInfoView:OnClickChangePortrait()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG or vo.guild_post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		-- if vo.level < COMMON_CONSTS.GUILD_ICON_CHANGE_LV then 
		if not OpenFunData.Instance:CheckIsHide("guild") then 				-- 策划说换成仙盟开启
			local str = string.format(Language.Guild.NoChangePortraitLv, PlayerData.GetLevelString(COMMON_CONSTS.GUILD_ICON_CHANGE_LV))
			TipsCtrl.Instance:ShowSystemMsg(str)
		else
			GuildCtrl.Instance:ShowGuildPortraitView()
		end

		if ClickOnceRemindList[RemindName.GuildHead] == 1 then
			ClickOnceRemindList[RemindName.GuildHead] = 0
			RemindManager.Instance:Fire(RemindName.GuildHead)
		end
	else
		local str = Language.Guild.NoChangePortrait
		TipsCtrl.Instance:ShowSystemMsg(str)
	end
end

-- function GuildInfoView:OnClickSignin()
-- 	GuildCtrl.Instance:OpenSigninView()
-- end

--打开公告面板
function GuildInfoView:HandleOpenNotice()
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		GuildCtrl.Instance:OpenNoticeView()
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
	end
end
-------------------------------------------------------------------- 操作面板 -----------------------------------------------------------------------



