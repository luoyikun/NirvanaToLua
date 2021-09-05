require("game/forge/forge_role_equip_list")
require("game/forge/forge_advance_view")
require("game/forge/forge_strengthen_view")
require("game/forge/forge_gem_view")
require("game/forge/forge_quality_view")
require("game/forge/forge_yongheng_view")
require("game/forge/forge_cast_view")
require("game/forge/forge_upstar_view")
require("game/forge/forge_jade_view")
require("game/forge/forge_jade_refine_view")
-- require("game/forge/forge_deity_intersify_view")
require("game/forge/forge_clear_view")
require("game/forge/forge_deity_suit_view")
require("game/forge/forge_extreme_suit_view")
require("game/forge/forge_jue_xing_view")
require("game/forge/forge_exchange_view")

local FORGE_TAB_INDEX =
{
	[TabIndex.forge_advance] = "advance_view",
	[TabIndex.forge_strengthen] = "strengthen_view",
 	[TabIndex.forge_gem] = "gem_view",
 	[TabIndex.forge_quality] = "quality_view",
 	[TabIndex.forge_cast] = "cast_view",

 	[TabIndex.forge_jade] = "jade_view",
 	[TabIndex.forge_jade_refine] = "jade_refine_view",
 	[TabIndex.forge_deity_intersify] = "deity_intersify_view",
 	[TabIndex.forge_jue_xing] = "jue_xing_view",

 	-- 不是装备列表回调(界面有自己的装备列表)
 	[1] = {
	 	[TabIndex.forge_yongheng] = "yongheng_view",
	 	[TabIndex.forge_up_star] = "up_star_view",
	 	
 	},
 	-- 没有装备列表回调
 	[2] = {
 		[TabIndex.forge_extreme_suit] = "extreme_suit_view",
 		[TabIndex.forge_deity_suit] = "deity_suit_view",
 		[TabIndex.forge_exchange] = "exchange_view",
 	}
}

local ITEM_CHANGE_FLUSH_INDEX = {
	[TabIndex.forge_strengthen] = "strengthen",
}

ForgeView = ForgeView or BaseClass(BaseView)

function ForgeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		
		{"uis/views/forgeview_prefab", "RoleEquipBar", {TabIndex.forge_advance, TabIndex.forge_strengthen, TabIndex.forge_gem, TabIndex.forge_quality, TabIndex.forge_cast, 
														TabIndex.forge_jade, TabIndex.forge_jade_refine, TabIndex.forge_deity_intersify, TabIndex.forge_jue_xing}},
		{"uis/views/forgeview_prefab", "ModelDragLayer"},
		{"uis/views/forgeview_prefab", "ForgeAdvanceContent", {TabIndex.forge_advance}},
		{"uis/views/forgeview_prefab", "StrengthContent", {TabIndex.forge_strengthen}},
		{"uis/views/forgeview_prefab", "GemContent", {TabIndex.forge_gem}},
		{"uis/views/forgeview_prefab", "ForgeQualityContent", {TabIndex.forge_quality}},
		{"uis/views/forgeview_prefab", "YongHengContent", {TabIndex.forge_yongheng}},
		{"uis/views/forgeview_prefab", "CastContent", {TabIndex.forge_cast}},
		{"uis/views/forgeview_prefab", "UpStarContent", {TabIndex.forge_up_star}},
		{"uis/views/forgeview_prefab", "JadeContent", {TabIndex.forge_jade}},
		{"uis/views/forgeview_prefab", "JadeRefineContent", {TabIndex.forge_jade_refine}},
		{"uis/views/forgeview_prefab", "ForgeClearContent", {TabIndex.forge_deity_intersify}},
		{"uis/views/forgeview_prefab", "DeitySuitContent", {TabIndex.forge_deity_suit}},
		{"uis/views/forgeview_prefab", "ExtremeSuitContent", {TabIndex.forge_extreme_suit}},
		{"uis/views/forgeview_prefab", "ForgeJueXingContent", {TabIndex.forge_jue_xing}},
		{"uis/views/forgeview_prefab", "ForgeComposeContent", {TabIndex.forge_exchange}},

		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true

	self.def_index = TabIndex.forge_strengthen
end

function ForgeView:__delete()
	self:StopCountDown()
end

function ForgeView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.role_equip_list then
		self.role_equip_list:DeleteMe()
		self.role_equip_list = nil
	end

	for k, v in pairs(FORGE_TAB_INDEX) do
		if self[v] then
			self[v]:DeleteMe()
			self[v] = nil
		end
	end

	for k, v in pairs(FORGE_TAB_INDEX[1]) do
		if self[v] then
			self[v]:DeleteMe()
			self[v] = nil
		end
	end

	for k, v in pairs(FORGE_TAB_INDEX[2]) do
		if self[v] then
			self[v]:DeleteMe()
			self[v] = nil
		end
	end

	self:StopCountDown()

	FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Forge)
	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
	EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_change_callback)
	ForgeData.Instance:UnNotifyZhuanzhiDataChangeCallBack(self.zhuanzhi_equip_change_callback)
end

function ForgeView:LoadCallBack(index)
	self.node_list["TxtTitle"].text.text = Language.Title.Forge
	
	local function group_one()
		return OpenFunData.Instance:CheckIsHide("forge_strengthen") or OpenFunData.Instance:CheckIsHide("forge_gem")
	end
	local function group_two()
		return OpenFunData.Instance:CheckIsHide("forge_quality") or OpenFunData.Instance:CheckIsHide("forge_yongheng") or OpenFunData.Instance:CheckIsHide("forge_cast")
	end
	local function group_three()
		return OpenFunData.Instance:CheckIsHide("forge_up_star") or OpenFunData.Instance:CheckIsHide("forge_jade") or OpenFunData.Instance:CheckIsHide("forge_deity_intersify")
	end
	local function group_four()
		return OpenFunData.Instance:CheckIsHide("forge_deity_suit") or OpenFunData.Instance:CheckIsHide("forge_extreme_suit") or OpenFunData.Instance:CheckIsHide("forge_jue_xing") or OpenFunData.Instance:CheckIsHide("forge_exchange")
	end

	local tab_cfg = {
		{name =	Language.Forge.TabbarName.Strengthen, bundle = "uis/images_atlas", asset = "tab_icon_uplevel", func = group_one, tab_index = TabIndex.forge_strengthen, remind_id = RemindName.ForgeGroupOne},
		{name =	Language.Forge.TabbarName.Advance, bundle = "uis/images_atlas", asset = "tab_icon_forge_advance", func = "forge_advance", tab_index = TabIndex.forge_advance, remind_id = RemindName.ForgeAdvance},
		{name = Language.Forge.TabbarName.Quality, bundle = "uis/images_atlas", asset = "tab_icon_quality", func = group_two, tab_index = TabIndex.forge_yongheng, remind_id = RemindName.ForgeGroupTwo},
		{name = Language.Forge.TabbarName.UpStar, bundle = "uis/images_atlas", asset = "tab_icon_upstar", func = group_three, tab_index = TabIndex.forge_up_star, remind_id = RemindName.ForgeGroupThree},
		{name = Language.Forge.TabbarName.DeitySuit, bundle = "uis/images_atlas", asset = "tab_icon_suit", func = group_four, tab_index = TabIndex.forge_deity_suit, remind_id = RemindName.ForgeGroupFour},
		
	}
	local sub_tab_cfg = {
		{
			{name = Language.Forge.TabbarName.Strengthen, tab_index = TabIndex.forge_strengthen, remind_id = RemindName.ForgeStrengthen, func = "forge_strengthen"},
			{name = Language.Forge.TabbarName.BaoShi, tab_index = TabIndex.forge_gem, remind_id = RemindName.ForgeBaoshi, func = "forge_gem"},
			-- {name = Language.Forge.TabbarName.Advance, tab_index = TabIndex.forge_advance, remind_id = RemindName.ForgeAdvance, func = "forge_advance"},
		},
		nil,
		{
			-- {name = Language.Forge.TabbarName.Quality, tab_index = TabIndex.forge_quality, remind_id = RemindName.ForgeQuality, func = "forge_quality"},
			{name = Language.Forge.TabbarName.Quality, tab_index = TabIndex.forge_yongheng, remind_id = RemindName.ForgeYongheng, func = "forge_yongheng"},
			{name = Language.Forge.TabbarName.Cast, tab_index = TabIndex.forge_cast, remind_id = RemindName.ForgeCast, func = "forge_cast"},
		},
		{
			{name = Language.Forge.TabbarName.UpStar, tab_index = TabIndex.forge_up_star, remind_id = RemindName.ForgeUpStar, func = "forge_up_star"},
			{name = Language.Forge.TabbarName.Jade, tab_index = TabIndex.forge_jade, remind_id = RemindName.ForgeJade, func = "forge_jade"},
			{name = Language.Forge.TabbarName.DeityIntersify, tab_index = TabIndex.forge_deity_intersify, remind_id = RemindName.ForgeDeityIntersify, func = "forge_deity_intersify"},
			--{name = Language.Forge.TabbarName.JadeRefine, tab_index = TabIndex.forge_jade_refine, remind_id = RemindName.ForgeJadeRefine},
		},
		{
			{name = Language.Forge.TabbarName.DeitySuit, tab_index = TabIndex.forge_deity_suit, remind_id = RemindName.ForgeDeitySuit, func = "forge_deity_suit"},
			{name = Language.Forge.TabbarName.JueXing, tab_index = TabIndex.forge_jue_xing, remind_id = RemindName.ForgeJueXing, func = "forge_jue_xing"},
			{name = Language.Forge.TabbarName.Exchange, tab_index = TabIndex.forge_exchange, func = "forge_exchange"},
		},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:InitSubTab(self.node_list["TopTabContent"], sub_tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	self.equip_change_callback = BindTool.Bind(self.OnEquipDataChange, self)
	self.zhuanzhi_equip_change_callback = BindTool.Bind(self.OnZhuanzhiEquipDataChange, self)
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	EquipData.Instance:NotifyDataChangeCallBack(self.equip_change_callback, nil, true)
	ForgeData.Instance:NotifyZhuanzhiDataChangeCallBack(self.zhuanzhi_equip_change_callback, true)

	RemindManager.Instance:Fire(RemindName.ForgeAdvance)
	RemindManager.Instance:Fire(RemindName.ForgeStrengthen)
	RemindManager.Instance:Fire(RemindName.ForgeBaoshi)
	RemindManager.Instance:Fire(RemindName.ForgeQuality)
	RemindManager.Instance:Fire(RemindName.ForgeYongheng)
	RemindManager.Instance:Fire(RemindName.ForgeCast)
	RemindManager.Instance:Fire(RemindName.ForgeUpStar)
	RemindManager.Instance:Fire(RemindName.ForgeJade)
	RemindManager.Instance:Fire(RemindName.ForgeJadeRefine)
	RemindManager.Instance:Fire(RemindName.ForgeDeityIntersify)
	RemindManager.Instance:Fire(RemindName.ForgeDeitySuit)
	RemindManager.Instance:Fire(RemindName.ForgeJueXing)

	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_EQUIP_INFO)
	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_INFO)
	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_SUIT_INFO)
	ForgeCtrl.Instance:SendCSEquipBaptizeOperaReq(EQUIP_BAPTIZE_OPERA_TYPE.EQUIP_BAPTIZE_OPERA_TYPE_ALL_INFO)

	
	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Forge, BindTool.Bind(self.GetUiCallBack, self))
	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN)
	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Duan_Zao)
	if is_open then
		local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
			end)
				node_list["TextYiZhe"].text.text = data.button_name
				self:StartCountDown(data, node_list)
		end
		CommonDataManager.SetYiZheBtnJump(self, self.node_list["BtnYiZheJump"], callback)
	end

end


-- 一折抢购跳转
function ForgeView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				self.node_list["BtnYiZheJump"]:SetActive(false)
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 一折抢购跳转
function ForgeView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function ForgeView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ForgeView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- 监听玩家金额
function ForgeView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

-- 普通装备
function ForgeView:OnEquipDataChange()
	if false == self:IsLoaded() then return end

	local cur_index = self:GetShowIndex()
	if nil ~= self.role_equip_list and FORGE_TAB_INDEX[cur_index] and 
		cur_index == TabIndex.forge_advance or cur_index == TabIndex.forge_strengthen or cur_index == TabIndex.forge_gem or 
		cur_index == TabIndex.forge_quality or cur_index == TabIndex.forge_cast then
		self.role_equip_list:Flush("reload")
	end
end

-- 转职装备
function ForgeView:OnZhuanzhiEquipDataChange()
	if false == self:IsLoaded() then return end

	local cur_index = self:GetShowIndex()
	if nil ~= self.role_equip_list and FORGE_TAB_INDEX[cur_index] and 
		cur_index == TabIndex.forge_jade or cur_index == TabIndex.forge_jade_refine or cur_index == TabIndex.forge_deity_intersify or TabIndex.forge_jue_xing then
		self.role_equip_list:Flush("reload")
	end
end

function ForgeView:OnItemDataChange()
	if false == self:IsLoaded() then return end

	local cur_index = self:GetShowIndex()
	if nil ~= self.role_equip_list and FORGE_TAB_INDEX[cur_index] then
		self.role_equip_list:Flush("flushview")
	end

	if cur_index == TabIndex.forge_advance then
		self:Flush("advance")
	elseif cur_index == TabIndex.forge_strengthen then
		self:Flush("strengthen")
	elseif cur_index == TabIndex.forge_gem then
		self:Flush("gem")
	elseif cur_index == TabIndex.forge_quality then
		self:Flush("quality")
	elseif cur_index == TabIndex.forge_yongheng then
		self:Flush("yongheng")
	elseif cur_index == TabIndex.forge_cast then
		self:Flush("cast")
	elseif cur_index == TabIndex.forge_up_star then
		self:Flush("up_star")
	elseif cur_index == TabIndex.forge_jade then
		self:Flush("jade")
	elseif cur_index == TabIndex.forge_jade_refine then
		self:Flush("jade_refine")
	elseif cur_index == TabIndex.forge_deity_intersify then
		self:Flush("deity_intersify")
	elseif cur_index == TabIndex.forge_deity_suit then
		self:Flush("deity_suit")
	elseif cur_index == TabIndex.forge_extreme_suit then
		self:Flush("extreme_suit")
	elseif cur_index == TabIndex.forge_jue_xing then
		self:Flush("jue_xing")
	-- elseif cur_index == TabIndex.forge_exchange then
	-- 	self:Flush("exchange")
	end
end

function ForgeView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		self:InitPanel(index, index_nodes)
	end

	self:StopAutoClick()
	self:StopShowEffect()
	self[FORGE_TAB_INDEX[index] or FORGE_TAB_INDEX[1][index] or FORGE_TAB_INDEX[2][index]]:Flush("ui_tween")


	if nil ~= self.role_equip_list and self[FORGE_TAB_INDEX[index]] then
		self.role_equip_list:SetViewIndex(index)
		-- 取消延时 为了任务点开界面能刷到其他界面对应的装备List	
		self.role_equip_list:CancelDelayFlushTimer()
		self.role_equip_list:Flush("uitween")
		self.role_equip_list:Flush("click")
	end

	if index == TabIndex.forge_yongheng and OpenFunData.Instance:CheckIsHide("forge_yongheng") then
		local callback = function()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
			for k,v in pairs(vo.appearance) do
				temp_vo.appearance[k] = v
			end
			temp_vo.appearance.halo_used_imageid = 0
			temp_vo.appearance.wing_used_imageid = 0
			UIScene:SetRoleModelResInfo(temp_vo)
			vo.is_normal_wuqi = vo.appearance.fashion_wuqi_is_special == 0 and true or false
			UIScene:SetRoleModelResInfo(vo)

			UIScene:SetActionEnable(true)
	
			local base_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
		self.node_list["RotateEventTrigger"]:SetActive(true)
		local call_back_2 = function ()
			self.node_list["UnderBg"]:SetActive(true)
			self.node_list["TaiZi"]:SetActive(true)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_common1_under", "bg_common1_under.jpg", call_back_2)
	else
		UIScene:ChangeScene(nil)
		local call_back = function ()
			self.node_list["UnderBg"]:SetActive(true)
			self.node_list["TaiZi"]:SetActive(false)
		end
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_forge_view", "bg_forge_view.jpg", call_back)
		self.node_list["RotateEventTrigger"]:SetActive(false)
	end

	-- if index == TabIndex.forge_yongheng  then
		-- if nil ~= self.model then
		-- 	self.model:Flush("ui_tween")
		-- end
	-- end

	self:ClcikEquipItemCell()
end

-- 初始化面板
function ForgeView:InitPanel(index, index_nodes)
	-- 装备列表
	if (index == TabIndex.forge_advance or index == TabIndex.forge_strengthen or index == TabIndex.forge_gem 
		or index == TabIndex.forge_quality or index == TabIndex.forge_cast or index == TabIndex.forge_jade 
		or index == TabIndex.forge_jade_refine or index == TabIndex.forge_deity_intersify or index == TabIndex.forge_jue_xing)
		and nil == self.role_equip_list and index_nodes["RoleEquipBar"] then

		self.role_equip_list = ForgeRoleEquipList.New(index_nodes["RoleEquipBar"], self)
		self.role_equip_list:SetSelectCallBack(BindTool.Bind(self.OnClickEquipListCallBack, self))
	end

	-- 人物模型 用UIScene
	-- if index == TabIndex.forge_yongheng and nil == self.model then
	-- 	self.model = ForgeModelView.New(index_nodes["DisPlayPanel"])
	-- end


	if index == TabIndex.forge_advance then
		self.advance_view = ForgeAdvance.New(index_nodes["ForgeAdvanceContent"], self)
	elseif index == TabIndex.forge_strengthen then
		self.strengthen_view = ForgeStrengthen.New(index_nodes["StrengthContent"], self)
	elseif index == TabIndex.forge_gem then
		self.gem_view = ForgeGem.New(index_nodes["GemContent"], self)
	elseif index == TabIndex.forge_quality then
		self.quality_view = ForgeQuality.New(index_nodes["ForgeQualityContent"], self)
	elseif index == TabIndex.forge_yongheng then
		self.yongheng_view = ForgeYongHengView.New(index_nodes["YongHengContent"], self)
	elseif index == TabIndex.forge_cast then
		self.cast_view = ForgeCast.New(index_nodes["CastContent"], self)
	elseif index == TabIndex.forge_up_star then
		self.up_star_view = ForgeUpStarView.New(index_nodes["UpStarContent"], self)
	elseif index == TabIndex.forge_jade then
		self.jade_view = ForgeJade.New(index_nodes["JadeContent"], self)
	elseif index == TabIndex.forge_jade_refine then
		self.jade_refine_view = ForgeJadeRefine.New(index_nodes["JadeRefineContent"], self)
	elseif index == TabIndex.forge_deity_intersify then
		-- self.deity_intersify_view = ForgeDeityIntersify.New(index_nodes["DeityIntersifyContent"], self) --原附灵-改洗练
		self.deity_intersify_view = ForgeClearView.New(index_nodes["ForgeClearContent"], self)
	elseif index == TabIndex.forge_deity_suit then
		self.deity_suit_view = ForgeDeitySuit.New(index_nodes["DeitySuitContent"], self)
	elseif index == TabIndex.forge_extreme_suit then
		self.extreme_suit_view = ForgeExtremeSuit.New(index_nodes["ExtremeSuitContent"], self)
	elseif index == TabIndex.forge_jue_xing then
		self.jue_xing_view = ForgeJueXingView.New(index_nodes["ForgeJueXingContent"], self)
	elseif index == TabIndex.forge_exchange then
		self.exchange_view = ForgeExchangeView.New(index_nodes["ForgeComposeContent"], self)
	end
end

function ForgeView:GetStrengthenView()
	return self.strengthen_view
end

-- 点击装备列表回调
function ForgeView:OnClickEquipListCallBack(cell_index)
	local cur_index = self:GetShowIndex()
	if self[FORGE_TAB_INDEX[cur_index]] then
		self[FORGE_TAB_INDEX[cur_index]]:ClickEquipListCallBack(cell_index)
	end
end

-- 初始化点击格子(有装备列表的通过回调实现)
function ForgeView:ClcikEquipItemCell()
	local index = self:GetShowIndex()
	local data =  {}
	if index == TabIndex.forge_yongheng then
		data = EquipData.Instance:GetDataList()
	elseif index == TabIndex.forge_up_star then
		data = ForgeData.Instance:GetZhuanzhiEquipAll()
	else
		return
	end

	for k, v in pairs(data) do
		if v.item_id and v.item_id > 0 then
			self[FORGE_TAB_INDEX[1][index]]:ClcikEquipItemCell(v.index)
			break
		end
	end
end

function ForgeView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k,v in pairs(param_t) do
		if k == "advance" and cur_index == TabIndex.forge_advance and self.advance_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.advance_view:Flush()
		elseif k == "strengthen" and cur_index == TabIndex.forge_strengthen and self.strengthen_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.strengthen_view:Flush()
		elseif k == "gem" and cur_index == TabIndex.forge_gem and self.gem_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.gem_view:Flush()
		elseif k == "quality" and cur_index == TabIndex.forge_quality and self.quality_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.quality_view:Flush()
		elseif k == "yongheng" and cur_index == TabIndex.forge_yongheng and self.yongheng_view then
			self.yongheng_view:Flush()
		elseif k == "cast" and cur_index == TabIndex.forge_cast and self.cast_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.cast_view:Flush()
		elseif k == "up_star" and cur_index == TabIndex.forge_up_star and self.up_star_view then
			self.up_star_view:Flush()
		elseif k == "jade" and cur_index == TabIndex.forge_jade and self.jade_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.jade_view:Flush()
		elseif k == "jade_refine" and cur_index == TabIndex.forge_jade_refine and self.jade_refine_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.jade_refine_view:Flush()
		elseif k == "deity_intersify" and cur_index == TabIndex.forge_deity_intersify and self.deity_intersify_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.deity_intersify_view:Flush()
		elseif k == "deity_suit" and cur_index == TabIndex.forge_deity_suit and self.deity_suit_view then
			-- self.role_equip_list:Flush("flushview")
			self.deity_suit_view:Flush()
		elseif k == "jump_index" and cur_index == TabIndex.forge_deity_suit and self.deity_suit_view then
			self.deity_suit_view:JumpToIndexByIndex(v["jump_index"])
		elseif k == "extreme_suit" and cur_index == TabIndex.forge_extreme_suit and self.extreme_suit_view then
			self.extreme_suit_view:Flush()
		elseif k == "task_forge_advance" then
			local index = TabIndex[v[1]]
			self:ShowIndex(index)
		elseif k == "jue_xing" and cur_index == TabIndex.forge_jue_xing and self.jue_xing_view and self.role_equip_list then
			self.role_equip_list:Flush("flushview")
			self.jue_xing_view:Flush()
		elseif k == "exchange" and cur_index == TabIndex.forge_exchange and self.exchange_view then
			self.exchange_view:Flush("item_change")
		end
	end
end

-- 停止自动升级
function ForgeView:StopAutoClick()
	if self.last_index then
		if self.last_index == TabIndex.forge_gem and self.gem_view then
			self.gem_view:CancelAutoUpgradeClick()
		elseif self.last_index == TabIndex.forge_up_star and self.up_star_view then
			self.up_star_view:StopAutoQuest()
		elseif self.last_index == TabIndex.forge_jade and self.jade_view then
			self.jade_view:CancelAutoUpgradeClick()
		elseif self.last_index == TabIndex.forge_jade_refine and self.jade_refine_view then
			self.jade_refine_view:OnBtnStopAuto()
		end
	end
end

-- 停止播强化成功失败特效
function ForgeView:StopShowEffect()
	if self.strengthen_view then
		self.strengthen_view:StopShowEffect()
	end
end

function ForgeView:CloseCallBack()
	if self.gem_view then
		self.gem_view:CancelAutoUpgradeClick()
	end
	if self.up_star_view then
		self.up_star_view:StopAutoQuest()
	end
	if self.jade_view then
		self.jade_view:CancelAutoUpgradeClick()
	end
	if self.jade_refine_view then
		self.jade_refine_view:OnBtnStopAuto()
	end
	if self.strengthen_view then
		self.strengthen_view:CloseCallBack()
	end
	if self.deity_intersify_view then
		self.deity_intersify_view:CloseCallBack()
	end
	if self.jue_xing_view then
		self.jue_xing_view:CloseCallBack()
	end
end

function ForgeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		local root_node = self.tabbar:GetTabButton(index).root_node
			local callback = BindTool.Bind(self.ChangeToIndex, self, index)
		if index == self.show_index then
			return NextGuideStepFlag
		else
			return root_node, callback
		end
	elseif ui_name == GuideUIName.ForgeAdvanceBtn then
		if self.advance_view then
			return self.advance_view:GetAdvanceCall()
		end
	elseif ui_name == GuideUIName.ForgeStrengthenTab or ui_name == GuideUIName.ForgeAdvancetn then
		local index = TabIndex[ui_name]
		if self.tabbar:GetSubButton(index) then
			local root_node = self.tabbar:GetSubButton(index).root_node
			local callback = BindTool.Bind(self.ChangeToIndex, self, index)
			if index == self.show_index then
				return NextGuideStepFlag
			else
				return root_node, callback
			end
		end
	elseif ui_name == GuideUIName.ForgeBtnStrength then
		if self.strengthen_view then
			return self.strengthen_view:GetBtnStrength()
		end
	elseif ui_name == GuideUIName.ForgeUpStarBtn then
		if self.up_star_view then
			return self.up_star_view:GetUpStarBtn()
		end
	elseif ui_name == GuideUIName.ForgeBtnPromoteBtn then
		if self.yongheng_view then
			return self.yongheng_view:GetYongHengBtn()
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end





----------------------------------
--------- 人物模型 ForgeModelView
ForgeModelView = ForgeModelView or BaseClass(BaseRender)
function ForgeModelView:__init()
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display)
	self:Flush()
end

function ForgeModelView:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function ForgeModelView:OnFlush(param_t)
	if self.model_view == nil then return end
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			UITween.AlpahShowPanel(self.node_list["Display"] , true, 0.5, DG.Tweening.Ease.InExpo)
		end
	end


	if self.node_list["Display"].gameObject.activeInHierarchy then
		self.model_view:SetScale(Vector3(1.5, 1.5, 1.5))
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.model_view:ResetRotation()
		self.model_view:SetModelResInfo(role_vo, nil, nil, nil, nil, true)
	end
end

