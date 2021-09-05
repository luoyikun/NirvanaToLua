ShenGeView = ShenGeView or BaseClass(BaseView)

local SHEN_GE = 1

function ShenGeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/shengeview_prefab","InlayContent", {TabIndex.shen_ge_inlay}},
		{"uis/views/shengeview_prefab","ZhangKongContent",{TabIndex.shen_ge_zhangkong}},
		{"uis/views/shengeview_prefab","BlessContent",{TabIndex.shen_ge_bless}},
		{"uis/views/shengeview_prefab","GodBodyContent",{TabIndex.shen_ge_godbody}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.def_index = TabIndex.shenge_inlay
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
	self.cur_toggle = INFO_TOGGLE
end

function ShenGeView:ReleaseCallBack()
	if self.inlay_view then
		self.inlay_view:DeleteMe()
		self.inlay_view = nil
	end

	if self.bless_view then
		self.bless_view:DeleteMe()
		self.bless_view = nil
	end

	if self.zhangkong_view then
		self.zhangkong_view:DeleteMe()
		self.zhangkong_view = nil
	end

	if self.godbody_view then
		self.godbody_view:DeleteMe()
		self.godbody_view = nil
	end

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
	end

	if self.multi_mount_view then
		self.multi_mount_view:DeleteMe()
		self.multi_mount_view = nil
	end

	self.gold = nil
	self.bind_gold = nil
	self.toggle_multi_mount = nil
	self.multi_mount_content = nil
	self.rotate_event_trigger = nil

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self:StopCountDown()
end
function ShenGeView:LoadCallBack()
	local tab_cfg = {
		{name = Language.ShenGe.TabbarName[1], bundle = "uis/images_atlas", asset = "icon_tab_shenge_1", func = "icon_tab_shenge_1", tab_index = TabIndex.shen_ge_inlay, remind_id = RemindName.ShenGe_ShenGe},
		{name = Language.ShenGe.TabbarName[2], bundle = "uis/images_atlas", asset = "icon_tab_shenge_2", func = "icon_tab_shenge_2", tab_index = TabIndex.shen_ge_zhangkong, remind_id = RemindName.ShenGe_Zhangkong},
		{name = Language.ShenGe.TabbarName[3], bundle = "uis/images_atlas", asset = "icon_tab_shenge_3", func = "icon_tab_shenge_3", tab_index = TabIndex.shen_ge_bless, remind_id = RemindName.ShenGe_Bless},
		{name = Language.ShenGe.TabbarName[4], bundle = "uis/images_atlas", asset = "icon_tab_shenge_4", func = "icon_tab_shenge_4", tab_index = TabIndex.shen_ge_godbody, remind_id = RemindName.ShenGe_Godbody},
	}
	self.node_list["TxtTitle"].text.text = Language.ShenGe.XingHui
	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self:Flush()
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)

	self.item_data_event = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Xing_Hui)
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
function ShenGeView:StartCountDown(data, node_list)
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
function ShenGeView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function ShenGeView:OnItemDataChange()
	if false == self:IsLoaded() then return end

	local index = self:GetShowIndex()
	if index == TabIndex.shen_ge_zhangkong then
		self:Flush()
	end
end

function ShenGeView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function ShenGeView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShenGeView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
	self:StopCountDown()
end

-- function ShenGeView:OpenIndexCheck(to_index)
-- 	if to_index == TabIndex.shen_ge_inlay then 
-- 		self:ShowIndex(TabIndex.shen_ge_inlay)
-- 	elseif to_index == TabIndex.shen_ge_zhangkong then 
-- 		self:ShowIndex(TabIndex.shen_ge_zhangkong)
-- 	elseif to_index == TabIndex.shen_ge_bless then
-- 		self:ShowIndex(TabIndex.shen_ge_bless) 
-- 	elseif to_index == TabIndex.shen_ge_godbody then
-- 		self:ShowIndex(TabIndex.shen_ge_godbody) 
-- 	end
-- end

function ShenGeView:ShowIndexCallBack(index, index_nodes)

	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.shen_ge_inlay then
			self.inlay_view = ShenGeInlayView.New(index_nodes["InlayContent"])
		elseif index == TabIndex.shen_ge_zhangkong then
			self.zhangkong_view = ShenGeZhangKongView.New(index_nodes["ZhangKongContent"])
		elseif index == TabIndex.shen_ge_bless then
			self.bless_view = ShenGeBlessView.New(index_nodes["BlessContent"])
		elseif index == TabIndex.shen_ge_godbody then
			self.godbody_view = ShenGeGodBodyView.New(index_nodes["GodBodyContent"])
		end
	end

	if index == TabIndex.shen_ge_inlay then
		self.inlay_view:OpenCallBack()
		self.inlay_view:UIsMove()
		self.inlay_view:Flush()
	elseif index == TabIndex.shen_ge_zhangkong then
		self.zhangkong_view:UIsMove()
		self.zhangkong_view:Flush()
	elseif index == TabIndex.shen_ge_bless then
		self.bless_view:UIsMove()
		self.bless_view:Flush()
	elseif index == TabIndex.shen_ge_godbody then
		self.godbody_view:UIsMove()
		 self.godbody_view:Flush() 
	end

	if TabIndex.shen_ge_inlay == self.last_index then
		self.inlay_view:CloseCallBack()
	end
end


function ShenGeView:OpenCallBack()

	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE)

	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
	self:FlushTabbar()

end

function ShenGeView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.godbody_view then
		self.godbody_view:CloseCallBack()
	end

	if self.inlay_view then
		self.inlay_view:CloseCallBack()
	end
end

function ShenGeView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function ShenGeView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.shen_ge_inlay then
		if nil == self.inlay_view then return end
		self.inlay_view:Flush(param_list)
	elseif cur_index == TabIndex.shen_ge_zhangkong then
		if nil == self.zhangkong_view then return end
		self.zhangkong_view:Flush(param_list)
	elseif cur_index == TabIndex.shen_ge_bless then
		if nil == self.bless_view then return end
		self.bless_view:Flush(param_list)
	elseif cur_index == TabIndex.shen_ge_godbody then
		if nil == self.godbody_view then return end
		self.godbody_view:Flush(param_list)
	end

end

function ShenGeView:FlushGoal()
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.shen_ge_inlay then
		if nil == self.inlay_view then
			return
		end
		self.inlay_view:FlshGoalContent()
	end
end

function ShenGeView:OnDataChange(info_type, param1, param2, param3, bag_list)
	RemindManager.Instance:Fire(RemindName.ShenGe_ShenGe)
	if nil ~= self.inlay_view  then
		self.inlay_view:OnDataChange(info_type, param1, param2, param3, bag_list)
	end

	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO and nil ~= self.bless_view then
		self.bless_view:OnDataChange(info_type, param1, param2, param3, bag_list)
	end
end