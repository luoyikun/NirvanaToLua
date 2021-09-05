
require("game/guild/guild_information_view")
require("game/guild/guild_member_view")
require("game/guild/guild_list_view")
require("game/guild/guild_activity_view")
require("game/guild/guild_box_view")
-- require("game/guild/guild_storge_view")
require("game/guild/guild_request_view")
require("game/guild/guild_altar_view")
require("game/guild/guild_war_view")

GuildView = GuildView or BaseClass(BaseView)

-- 功能开启判断
-- 1为迷宫
local GuildFunNum = 1

local FunName = 
{
	[1] = "guild_maze"
}
function GuildView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/guildview_prefab", "ModelDragLayer"},
		{"uis/views/guildview_prefab", "MembersContent", {TabIndex.guild_member}},
		{"uis/views/guildview_prefab", "GuildsList", {TabIndex.guild_list}},
		{"uis/views/guildview_prefab", "BoxContent", {TabIndex.guild_box}},
		{"uis/views/guildview_prefab", "AltarContent", {TabIndex.guild_altar}},		-- 仙盟剑阵
		{"uis/views/guildview_prefab", "GuildActivity", {TabIndex.guild_activity}},
		-- {"uis/views/guildview_prefab", "GuildsStorge", {TabIndex.guild_storge}},
		{"uis/views/guildview_prefab", "GuildRequest", {TabIndex.guild_request}},
		{"uis/views/guildview_prefab", "GuildWarContent", {TabIndex.guild_war}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/guildview_prefab", "InformationContent", {TabIndex.guild_info}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
	}
	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.red_points = nil
	self.close_window = false
	self.last_index = nil
end

function GuildView:__delete()

end

function GuildView:LoadCallBack()

	local tab_cfg = {
		-- {name =	Language.Guild.TabbarName[1], bundle = "uis/images_atlas", asset = "tab_icon_default", func = "guild", tab_index = TabIndex.guild_request},
		{name = Language.Guild.TabbarName[1], bundle = "uis/images_atlas", asset = "tab_icon_guildinfo", tab_index = TabIndex.guild_info, func = BindTool.Bind(self.TabIsShowOrHide, self), remind_id = RemindName.GuildInfo}, 
		{name = Language.Guild.TabbarName[11], bundle = "uis/images_atlas", asset = "tab_icon_guildwar", tab_index = TabIndex.guild_war, func = BindTool.Bind(self.TabIsShowOrHide, self), remind_id = RemindName.GuildWar}, 
		{name = Language.Guild.TabbarName[2], bundle = "uis/images_atlas", asset = "tab_icon_guildbox", tab_index = TabIndex.guild_box, func = BindTool.Bind(self.TabIsShowOrHideBox, self), remind_id = RemindName.GuildBox},
		{name = Language.Guild.TabbarName[3], bundle = "uis/images_atlas", asset = "tab_icon_guildyiji", tab_index = TabIndex.guild_altar, func = BindTool.Bind(self.TabIsShowOrHideAlter, self), remind_id = RemindName.GuildAltar}, 
		{name = Language.Guild.TabbarName[4], bundle = "uis/images_atlas", asset = "tab_icon_guildactivity", tab_index = TabIndex.guild_activity, func = BindTool.Bind(self.TabIsShowOrHideActivity, self), remind_id = RemindName.GuildActivity}, 
		-- {name = Language.Guild.TabbarName[5], bundle = "uis/images_atlas", asset = "tab_icon_guildback", tab_index = TabIndex.guild_storge, func = BindTool.Bind(self.TabIsShowOrHide, self)},
		{name = Language.Guild.TabbarName[7], bundle = "uis/images_atlas", asset = "tab_icon_guildmeber", tab_index = TabIndex.guild_member, func = BindTool.Bind(self.TabIsShowOrHide, self)},
		{name = Language.Guild.TabbarName[8], bundle = "uis/images_atlas", asset = "tab_icon_guildlist", tab_index = TabIndex.guild_list, func = BindTool.Bind(self.TabIsShowOrHide, self)},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TxtTitle"].text.text = Language.Guild.TitleName
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))

	-- 子面板
	self.view_list = {}
	
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Guild)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Guild, BindTool.Bind(self.GetUiCallBack, self))
	self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/inlaycontent_bg2", "InlayContent_BG2.jpg", function()
		self.node_list["UnderBg"]:SetActive(true)
	end)

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	GuildCtrl.Instance:GuildViewOpen()
	RemindManager.Instance:Fire(RemindName.NoGuild)
end

function GuildView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == GuildData.Instance:GetGuildJianSheId() then
		RemindManager.Instance:Fire(RemindName.GuildDonation)
		self:Flush()
	end
end

function GuildView:OpenCallBack()
	self.open_trigger = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	self.data_listen = BindTool.Bind(self.OnFlushGold, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushTuanZhangModel, self))
	self.member_info = GlobalEventSystem:Bind(OtherEventType.GUILD_MEMBER_INFO_CHANGE, BindTool.Bind(self.FlushTuanZhangModel, self))
	self:FlushTuanZhangModel()

	local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid
	if tuanzhang_uid and tuanzhang_uid > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(tuanzhang_uid)
	end
	GuildCtrl.Instance:SendAllGuildInfoReq()

	if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
		GuildCtrl.Instance:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ)
		GuildCtrl.Instance:SendGuildWageInfoReq()
	end
	self:ShowOrHideTab()
	self:Flush()
end

function GuildView:TabIsShowOrHide()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	return guild_id > 0
end

function GuildView:TabIsShowOrHideBox()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local flag = OpenFunData.Instance:CheckIsHide("guild_box") and guild_id > 0
	return flag 
end

function GuildView:TabIsShowOrHideAlter()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local flag = OpenFunData.Instance:CheckIsHide("guild_altar") and guild_id > 0
	return flag 
end

function GuildView:TabIsShowOrHideActivity()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local flag = OpenFunData.Instance:CheckIsHide("guild_activity") and guild_id > 0
	return flag 
end


function GuildView:CloseCallBack()
	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end
	if self.member_info then
		GlobalEventSystem:UnBind(self.member_info)
		self.member_info = nil
	end

	if self.open_trigger then
		GlobalEventSystem:UnBind(self.open_trigger)
		self.open_trigger = nil
	end
	GlobalTimerQuest:CancelQuest(self.open_create_timer)
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	GuildCtrl.Instance:SetBoxTipClose()
end

function GuildView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Guild)
	end

	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	if self.skillcontent_view then
		self.skillcontent_view:DeleteMe()
		self.skillcontent_view = nil
	end

	if self.member_view then
		self.member_view:DeleteMe()
		self.member_view = nil
	end

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end

	if self.box_view then
		self.box_view:DeleteMe()
		self.box_view = nil
	end
	if self.altar_view then
		self.altar_view:DeleteMe()
		self.altar_view = nil
	end
	if self.storge_view then
		self.storge_view:DeleteMe()
		self.storge_view = nil
	end
	if self.request_view then
		self.request_view:DeleteMe()
		self.request_view = nil
	end
	if self.activity_view then
		self.activity_view:DeleteMe()
		self.activity_view = nil
	end
	if self.guildwar_view then
		self.guildwar_view:DeleteMe()
		self.guildwar_view = nil
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.open_create_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.open_create_timer)
		self.open_create_timer = nil
	end

	-- 清理变量和对象
	self.red_points = nil
	self.toggle_list = {}
	self.guild_auto_enter_btn = nil
end

function GuildView:ShowOrHideTab()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function GuildView:FlushTabbarByIndex(index)
	if self.tabbar then
		self.tabbar:ChangeToIndex(index)
		self.tabbar:FlushTabbar()
	end
end

function GuildView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	self.tabbar:FlushTabbar()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	self.node_list["SideTab"]:SetActive(guild_id > 0)
	self.node_list["UnderBg"]:SetActive(false)

	if self.last_index and self.last_index ~= index and index ~= 0 then
		self:HideIndex(self.last_index)
	end

	self.last_index = index
	if index_nodes then
		if index == TabIndex.guild_info then
			self.info_view = GuildInfoView.New(index_nodes["InformationContent"])
			self.view_list[TabIndex.guild_info] = self.info_view
		elseif index == TabIndex.guild_member then
			self.member_view = GuildMemberView.New(index_nodes["MembersContent"])
			self.view_list[TabIndex.guild_member] = self.member_view
		elseif index == TabIndex.guild_list then
			self.list_view = GuildListView.New(index_nodes["GuildsList"])
			self.view_list[TabIndex.guild_list] = self.list_view
		elseif index == TabIndex.guild_box then
			self.box_view = GuildBoxView.New(index_nodes["BoxContent"])
			self.view_list[TabIndex.guild_box] = self.box_view
		elseif index == TabIndex.guild_altar then
			self.altar_view = GuildAltarView.New(index_nodes["AltarContent"])
			self.view_list[TabIndex.guild_altar] = self.altar_view
		elseif index == TabIndex.guild_activity then
			self.activity_view = GuildActivityView.New(index_nodes["GuildActivity"])
			self.view_list[TabIndex.guild_activity] = self.activity_view
		-- elseif index == TabIndex.guild_storge then
		-- 	self.storge_view = GuildStorgeView.New(index_nodes["GuildsStorge"])
		-- 	self.view_list[TabIndex.guild_storge] = self.storge_view
		elseif index == TabIndex.guild_request then
			self.request_view = GuildRequestView.New(index_nodes["GuildRequest"])
			self.view_list[TabIndex.guild_request] = self.request_view
		elseif index == TabIndex.guild_war then
			self.guildwar_view = GuildWarView.New(index_nodes["GuildWarContent"])
			self.view_list[TabIndex.guild_war] = self.guildwar_view
		end
	end

	if index ~= TabIndex.guild_box then
		if self.box_view then
			self.box_view:CloseTips()
		end
	end

	if index == TabIndex.guild_info then
		local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid
		if tuanzhang_uid and tuanzhang_uid > 0 then
			CheckCtrl.Instance:SendQueryRoleInfoReq(tuanzhang_uid)
		end
		self:HandleOpenInformation()

		local callback = function ()
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -300, 0)}, nil)
			self.node_list["BaseFullPanel_1"]:SetActive(false)
		end
		UIScene:ChangeScene(self, callback)
	else
		self.node_list["BaseFullPanel_1"]:SetActive(true)
		UIScene:ChangeScene(nil)
	end

	local bundle, asset = "uis/rawimages/inlaycontent_bg2", "InlayContent_BG2.jpg"

	if index == TabIndex.guild_member then
		self:HandleOpenMember()
		self.node_list["TaiZi"]:SetActive(false)
	elseif index == TabIndex.guild_box then
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["TaiZi"]:SetActive(false)
		self:HandleOpenBox()
	elseif index == TabIndex.guild_altar then
		self:HandleOpenAltar()
		self.node_list["TaiZi"]:SetActive(false)
		self.node_list["UnderBg"]:SetActive(true)
	elseif index == TabIndex.guild_activity then
		self:HandleOpenActivity()
		self.node_list["TaiZi"]:SetActive(false)
	elseif index == TabIndex.guild_list then
		self:HandleOpenList()
		self.node_list["TaiZi"]:SetActive(false)
	-- elseif index == TabIndex.guild_storge then
	-- 	self:HandleOpenStorge()
	elseif index == TabIndex.guild_request then
		self.node_list["UnderBg"]:SetActive(true)
		self:FlushRequest()
		self.node_list["TaiZi"]:SetActive(false)
		self.request_view:OpenCallBack()
	elseif index == TabIndex.guild_war then
		self:HandleOpenWar()
		-- bundle, asset = ResPath.GetRawImage("guildwar_bg2", true)
		self.node_list["TaiZi"]:SetActive(false)
	end

	-- self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, function()
	-- 	self.node_list["UnderBg"]:SetActive(true)
	-- end)

end

function GuildView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function GuildView:FlushTuanZhangModel(uid, info)
	if not uid or not info then
		uid, info = GuildData.Instance:GetTuanzhanginfo()
	end
	local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid
	if tuanzhang_uid == uid then
		local prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
		transform.rotation = Quaternion.Euler(8, -168, 0)
		UIScene:SetCameraTransform(transform)

		local shizhuang_part_list = info.shizhuang_part_list
		if shizhuang_part_list then
			-- local is_normal_fashion = shizhuang_part_list[2].use_special_img == 0
			-- local body = is_normal_fashion and shizhuang_part_list[2].use_id or shizhuang_part_list[2].use_special_img
			-- local wuqi = is_normal_fashion and shizhuang_part_list[1].use_id or shizhuang_part_list[1].use_special_img
			local info1 = TableCopy(info)
			info1.appearance = {}
			info1.appearance.mask_used_imageid = info.mask_info.used_imageid
			info1.appearance.toushi_used_imageid = info.head_info.used_imageid
			info1.appearance.yaoshi_used_imageid = info.waist_info.used_imageid
			info1.appearance.qilinbi_used_imageid = info.arm_info.used_imageid
			info1.appearance.shouhuan_used_imageid = info.upgrade_sys_info[UPGRADE_TYPE.SHOU_HUAN].used_imageid
			info1.appearance.tail_used_imageid = info.upgrade_sys_info[UPGRADE_TYPE.TAIL].used_imageid
			-- info1.shizhuang_part_list = {{image_id = wuqi}, {image_id = body}}
			-- info1.is_normal_fashion = is_normal_fashion

			local fashion_info = info1.shizhuang_part_list[2]
			local wuqi_info = info1.shizhuang_part_list[1]
			local is_used_special_img = fashion_info.use_special_img
			info1.is_normal_fashion = is_used_special_img == 0
			info1.is_normal_wuqi = wuqi_info.use_special_img == 0
			local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
			local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
			info1.appearance.fashion_wuqi = wuqi_id
			info1.appearance.fashion_body = fashion_id
			-- info1.shizhuang_part_list = {{image_id = wuqi_id}, {image_id = fashion_id}}
			UIScene:SetRoleModelResInfo(info1, false, false, false, false, false, false)
		end
	end
end

-- function GuildView:OnOpen()
-- 	GuildCtrl.Instance:InitGuildView()
-- end


-- -- 当没有加入公会时VIew面板的初始化
-- function GuildView:InitViewCase1()
-- 	if self:IsLoaded() then
			
-- 		end
-- 		self.def_index = TabIndex.guild_request
-- 		self:CloseAllWindow()
-- 		-- self:ChangeToIndex(TabIndex.guild_request)
-- 		-- self:Flush()
-- 	end
-- end

-- 当加入公会后VIew面板的初始化
-- function GuildView:InitViewCase2()
-- 	if self:IsLoaded() then
-- 		self.def_index = TabIndex.guild_info
-- 		self:SetWindowSwitch(true)
-- 		self:CloseAllWindow()
-- 		self:ChangeToIndex(TabIndex.guild_info)

-- 		for i = 1, GuildFunNum do
-- 			local open_fun_data = OpenFunData.Instance
-- 			local flag = open_fun_data:CheckIsHide(FunName[i])
			
-- 		end
-- 	end
-- end

--点击关闭按钮
function GuildView:HandleClose()
	self:CloseAllWindow()
	ViewManager.Instance:Close(ViewName.Guild)
end

--点击信息按钮
function GuildView:HandleOpenInformation()
	self.show_index = TabIndex.guild_info
	self:CloseAllWindow()
	if self.info_view then
		self.info_view:OpenCallBack()
	end
	GuildCtrl.Instance:SendGuildInfoReq()
end

--点击成员按钮
function GuildView:HandleOpenMember()
	self.show_index = TabIndex.guild_member
	self:CloseAllWindow()
	if self.member_view then
		self.member_view:OpenCallBack()
	end
	GuildCtrl.Instance:SendAllGuildMemberInfoReq()
end

--点击盟战按钮
function GuildView:HandleOpenWar()
	self.show_index = TabIndex.guild_war
	self:CloseAllWindow()
	if self.guildwar_view then
		self.guildwar_view:OpenCallBack()
	end
	RankCtrl.Instance:SendGetGuildRankListReq(GUILD_RANK_TYPE.GUILD_RANK_TYPE_GUILDBATTLE)
	GuildFightCtrl.Instance:SendGuildWarOperate(GUILD_WAR_TYPE.TYPE_INFO_REQ)
end

--点击宝箱按钮
function GuildView:HandleOpenBox()
	self.show_index = TabIndex.guild_box
	self:CloseAllWindow()
	if self.box_view then
		self.box_view:CloseColorList()
		self.box_view:ShowColorList()
		self.box_view:OpenCallBack()
	end
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
end

--点击技能按钮
function GuildView:HandleOpenAltar()
	self.show_index = TabIndex.guild_altar
	self:CloseAllWindow()
	if self.altar_view then
		self.altar_view:OpenCallBack()
		self.altar_view:Flush()
	end
end

function GuildView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击列表按钮
function GuildView:HandleOpenList()
	self.show_index = TabIndex.guild_list
	self:CloseAllWindow()
	if self.list_view then
		self.list_view:OpenCallBack()
	end
	-- GuildCtrl.Instance:SendAllGuildInfoReq()
	GuildCtrl.Instance:SendGuildExchangeReq()
end

--点击活动按钮
function GuildView:HandleOpenActivity()
	self.show_index = TabIndex.guild_activity
	self:CloseAllWindow()
	if self.activity_view then
		self.activity_view:OpenCallBack()
	end
end

--点击仓库按钮
-- function GuildView:HandleOpenStorge()
-- 	self.show_index = TabIndex.guild_storge
-- 	self:CloseAllWindow()
-- 	if self.storge_view then
-- 		self.storge_view:OpenCallBack()
-- 	end
-- 	GuildCtrl.Instance:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_REQ_INFO)
-- end

function GuildView:OnClickWuZi()
	TipsCtrl.Instance:OpenItem({item_id = GuildData.Instance:GetGuildJianSheId() or 0, num = 1})
end

-- 设置弹窗状态
function GuildView:SetWindowSwitch(switch)
	self.close_window = switch or false
end

-- 刷新公会
function GuildView:OnFlush(param_t)
	if self.info_view and self.show_index == TabIndex.guild_info then
		local tuanzhang_uid = GuildDataConst.GUILDVO.tuanzhang_uid
		if tuanzhang_uid and tuanzhang_uid > 0 then
			CheckCtrl.Instance:SendQueryRoleInfoReq(tuanzhang_uid)
		end
	end

	self:OnFlushGold("gold")
	self:OnFlushGold("bind_gold")

	self:FlushRedPoint()
	self:FlushCurrentView()
	if self.close_window then
		self.close_window = false
		self:CloseAllWindow()
	end
	for k,v in pairs(param_t) do
		if k == "CreateGuild" and nil == self.open_create_timer then
			self.open_create_timer = GlobalTimerQuest:AddDelayTimer(function ()
				self.request_view:CreateGuildByItem()
				self.open_create_timer = nil
			end, 0.5)
		elseif k == "guild_war" then
			if self.guildwar_view then
				self.guildwar_view:Flush()
			end
		elseif k == "guild_box" then
			if self.box_view then
				self.box_view:Flush()
			end
		end
	end
	self.tabbar:FlushTabbar()
end

-- 刷新列表
function GuildView:OnFlushListView()
	if not self.is_open then
		return
	end
	self.list_view:Flush()
end

-- 刷新成员
function GuildView:OnFlushMember()
	if not self.is_open then
		return
	end
	self.member_view:Flush()
end

-- 刷新信息
function GuildView:OnFlushInfo()
	if not self.is_open then
		return
	end
	self.info_view:Flush()
end

-- 关闭所有弹窗
function GuildView:CloseAllWindow()
	if self.is_open then
		if self.info_view then
			self.info_view:CloseAllWindow()
		end
		if self.skillcontent_view then
			self.skillcontent_view:CloseAllWindow()
		end
		if self.request_view then
			self.request_view:CloseAllWindow()
		end
	end
end

function GuildView:CloseInfoViewWindow()
	if self.is_open then
		if self.info_view then
			self.info_view:CloseAllWindow()
		end
	end
end

-- 刷新钻石
function GuildView:OnFlushGold(attr_name)
	if not self.is_open then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	elseif attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

-- 刷新当前界面
function GuildView:FlushCurrentView()
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		self.show_index = TabIndex.guild_request
	end
	local now_view = self.view_list[self.show_index]
	if now_view then
		now_view:Flush()
	end
	-- self:ShowIndex(self.show_index)
end

function GuildView:FlushRedPoint()
	local red_point_list = GuildData.Instance:GetReminder()
	for k,v in pairs(red_point_list) do
		self:SetRedPoint(k, v)
	end

end

function GuildView:SetOpenBoxTips(state)
	if self.box_view then
		self.box_view:SetHaveTips(state)
	end
end

function GuildView:SetRedPoint(index, switch)
	if not switch then
		switch = false
	end
	-- if self.red_points[index] then
	-- 	self.red_points[index]:SetActive(switch)
	-- end
end

function GuildView:FlushRequest()
	if self.request_view then
		self.request_view:FlushGuildDetails()
	end
end

function GuildView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.GuildAutoEnter then
		if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
			return NextGuideStepFlag
		else
			if self.request_view then
				return self.request_view:GetAutoBtn()
			end
 		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end

function GuildView:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.Guild then
		self:Flush()
	end
end