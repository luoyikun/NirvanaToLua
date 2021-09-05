require("game/shenshou/shenshou_equip_view")
require("game/shenshou/shenshou_fuling_view")
require("game/shenshou/shenshou_huanling_view")
require("game/shenshou/shenshow_fuling_selectmaterial_view")
require("game/shenshou/shenshou_compose_content_view")
require("game/shenshou/shenshou_fuling_tips")
require("game/shenshou/shengqi_equip_view")

ShenShouView = ShenShouView or BaseClass(BaseView)

function ShenShouView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/shenshouview_prefab", "InfoContent", {TabIndex.shenshou_equip}},
		{"uis/views/shenshouview_prefab", "FulingContent", {TabIndex.shenshou_fuling}},
		{"uis/views/shenshouview_prefab", "ShengQiView", {TabIndex.shenshou_shengqi}},
		--{"uis/views/shenshouview_prefab", "HuanlingContent", {TabIndex.shenshou_huanling}},
		--{"uis/views/shenshouview_prefab", "ShenShouComposeContentView", {TabIndex.shenshou_compose}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/shenshouview_prefab", "HuanlingContentGold"},
	}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.shenshou_equip

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ShenShouView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
	self:StopCountDown()
end

function ShenShouView:ReleaseCallBack()
	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end
	if self.fuling_view then
		self.fuling_view:DeleteMe()
		self.fuling_view = nil
	end
	if self.huanling_view then
		self.huanling_view:DeleteMe()
		self.huanling_view = nil
	end
	if self.compose_view then
		self.compose_view:DeleteMe()
		self.compose_view = nil
	end
	if self.shengqi_view then
		self.shengqi_view:DeleteMe()
		self.shengqi_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.red_point_list = {}

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil
	self:StopCountDown()
end

function ShenShouView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.ShenShou.TabbarName.LongQi, bundle = "uis/images_atlas", asset = "tab_longqi_default", func = "shenshou_ying", tab_index = TabIndex.shenshou_equip, remind_id = RemindName.ShenShou},
		{name = Language.ShenShou.TabbarName.LongShi, bundle = "uis/images_atlas", asset = "tab_longshi_default", func = "shenshou_fuling", tab_index = TabIndex.shenshou_fuling, remind_id = RemindName.ShenShouFuling},
		{name = Language.ShenShou.TabbarName.ShengQi, bundle = "uis/images_atlas", asset = "tab_shengqi_default", func = "shenshou_shengqi", tab_index = TabIndex.shenshou_shengqi, remind_id = RemindName.ShengQi},
		--{name = Language.ShenShou.TabbarName.HuanLong, bundle = "uis/images_atlas", asset = "tab_huanlong_default", func = "shenshou_huanling", tab_index = TabIndex.shenshou_huanling, remind_id = RemindName.ShenShouHuanling},
		--{name = Language.ShenShou.TabbarName.HeCheng, bundle = "uis/images_atlas", asset = "tab_hecheng_default", func = "shenshou_hecheng", tab_index = TabIndex.shenshou_compose, remind_id = RemindName.ShenShouCompose},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TxtTitle"].text.text = Language.Title.LongQi
	self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/inlaycontent_bg2", "InlayContent_BG2.jpg", function()
			self.node_list["UnderBg"]:SetActive(true)
			self.node_list["TaiZi"]:SetActive(false)
		end)

	if self.def_index ~= TabIndex.shenshou_huanling then 
		self.node_list["BindGoldLabel"]:SetActive(false)
	else
		self.node_list["BindGoldLabel"]:SetActive(true)
	end

	self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self:Flush()

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Long_Qi)
	local is_open_two, index_two, data_two = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Sheng_Qi)
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
	elseif is_open_two then
		local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index_two})
			end)
				node_list["TextYiZhe"].text.text = data_two.button_name
				self:StartCountDown(data_two, node_list)
		end
		CommonDataManager.SetYiZheBtnJump(self, self.node_list["BtnYiZheJump"], callback)
	end

end

-- 一折抢购跳转
function ShenShouView:StartCountDown(data, node_list)
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
function ShenShouView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function ShenShouView:HuanLingIntergra()
	local score = ShenShouData.Instance:GetHuanLingScore()
	self.node_list["TxtIntegral2"].text.text = CommonDataManager.ConverMoney(score)
end

function ShenShouView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

function ShenShouView:OpenIndexCheck(to_index)
	self:ChangeToIndex(to_index)
	if to_index == TabIndex.shenshou_huanling then 
		self.node_list["BindGoldLabel"]:SetActive(true)
	else
		self.node_list["BindGoldLabel"]:SetActive(false)
	end
end

function ShenShouView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.shenshou_equip then
			self.equip_view = ShenShouEquipView.New(index_nodes["InfoContent"])
			self.equip_view:OpenCallBack()
		elseif index == TabIndex.shenshou_fuling then
			self.fuling_view = ShenShouFulingView.New(index_nodes["FulingContent"])
			self.fuling_view:OpenCallBack()
		elseif index == TabIndex.shenshou_huanling then
			self.huanling_view = ShenShouHuanlingView.New(index_nodes["HuanlingContent"])
			self.huanling_view:SetIntergraCallBack(BindTool.Bind(self.HuanLingIntergra , self))
			self.huanling_view:OpenCallBack()
		elseif index == TabIndex.shenshou_compose then
			self.compose_view = ShenShouComposeView.New(index_nodes["ShenShouComposeContentView"])
			self.compose_view:OpenCallBack()
		elseif index == TabIndex.shenshou_shengqi then
			self.shengqi_view = ShengQiEquipView.New(index_nodes["ShengQiView"])
		end
	end
	if index == TabIndex.shenshou_equip then
		self.equip_view:UIsMove()
		self.equip_view:Flush()
	elseif index == TabIndex.shenshou_fuling then
		self.fuling_view:UIsMove()
		self.fuling_view:Flush()
	elseif index == TabIndex.shenshou_huanling then
		self.huanling_view:Flush()
	elseif index == TabIndex.shenshou_compose then
		self.compose_view:UIsMove()
		self.compose_view:Flush()
	elseif index == TabIndex.shenshou_shengqi then
		self.shengqi_view:Flush()
		self.shengqi_view:OpenCallBack()
	end

	local asset, bundle = "uis/rawimages/bg_common1_under", "bg_common1_under.jpg"
	local is_show_bg = false
	self.node_list["TaiZi"]:SetActive(false)
	if index == TabIndex.shenshou_equip or index == TabIndex.shenshou_fuling then
		is_show_bg = true
	elseif index == TabIndex.shenshou_shengqi then
		asset, bundle = "uis/rawimages/shengqibgfirst", "ShengqiBgFirst.jpg"
		is_show_bg = true
	else
		is_show_bg = false
	end
	self.node_list["UnderBg"].raw_image:LoadSprite(asset, bundle, function()
		self.node_list["UnderBg"]:SetActive(is_show_bg)
	end)
end


function ShenShouView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:FlushTabbar()
	self:Flush()
	self:InitTab()

	if self.equip_view then
		self.equip_view:OpenCallBack()
	end

	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU)
end

function ShenShouView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end

function ShenShouView:SetRendering(value)
	if self.is_rendering ~= value then
		self.last_role_model_show_type = nil
	end

	BaseView.SetRendering(self, value)
end

function ShenShouView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	-- if self.equip_view then
	-- 	self.equip_view:ResetCell()
	-- end
end

function ShenShouView:EquipDataChangeListen()
	if UIScene.role_model then
		UIScene.role_model:EquipDataChangeListen()
	end
end

function ShenShouView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function ShenShouView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShenShouView:InitTab()
end

function ShenShouView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function ShenShouView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k,v in pairs(param_t) do
		if k == "jump_index" and cur_index == TabIndex.shenshou_equip and self.equip_view then
			self.equip_view:SelectAndJumpToShenShouCallBack(v["jump_index"])
			return
		end
	end
	if cur_index == TabIndex.shenshou_equip then
		if self.equip_view then
			self.equip_view:Flush(param_t)
		end
	elseif cur_index == TabIndex.shenshou_fuling then
		if self.fuling_view then
			self.fuling_view:Flush(param_t)
		end
	elseif cur_index == TabIndex.shenshou_huanling then
		if self.huanling_view then
			self.huanling_view:Flush(param_t)
		end
	elseif cur_index == TabIndex.shenshou_compose then
		if self.compose_view then
			self.compose_view:Flush(param_t)
		end
	elseif cur_index == TabIndex.shenshou_shengqi then
		if self.shengqi_view then
			self.shengqi_view:Flush(param_t)
		end
	end
end

function ShenShouView:FlushAnimation()
	if self.huanling_view then
		self.huanling_view:FlushAnimation()
	end
end

ShenShouEquip = ShenShouEquip or BaseClass(ItemCell)
function ShenShouEquip:__init()
	local toggle = self.root_node.toggle
	self.image = self.root_node.image
	toggle.interactable = true
end

function ShenShouEquip:SetRootInteractable(value)
	self:ShowHighLight(value)
	--self.image.raycastTarget = value
end

function ShenShouEquip:ImageEnabled(value)
	--self.image.enabled = value
end

function ShenShouEquip:SetData(data, is_from_bag)
	ItemCell.SetData(self, data, is_from_bag)
	
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	self.shenshou_equip_cfg = shenshou_equip_cfg
	if nil == shenshou_equip_cfg then return end

	--设置图标
	local bundle, asset = ResPath.GetItemIcon(shenshou_equip_cfg.icon_id)
	self:SetAsset(bundle, asset)

	self:ShowQuality(true)
	local quality = shenshou_equip_cfg.quality
	if shenshou_equip_cfg.is_equip == 1 then
		quality = quality + 1
	else
		quality = quality + 2
	end
	self:SetQualityByColor(quality)

	local star_count = 0
	if self.data.attr_list then
		for k,v in pairs(self.data.attr_list) do
			if v.attr_type > 0 then
				local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(shenshou_equip_cfg.quality, v.attr_type) or {}
				if random_cfg.is_star_attr ==1 then
					star_count = star_count + 1
				end
			end
		end
	else
		star_count = self.data.param and self.data.param.star_level or 0
	end
	self:SetShowStar(star_count)
	local flag = self.name == "shenshou_bag" and ShenShouData.Instance:GetIsBetterShenShouEquip(self.data, self.select_shou_id or 0)
	-- self.node_list["UpArrow"]:SetActive(flag)
	self:SetShowUpArrow(flag)
	if self.data.strength_level and self.data.strength_level > 0 then
		self:ShowStrengthLable(true)
		self:SetStrength(self.data.strength_level)
	elseif self.data.param and self.data.param.strengthen_level and self.data.param.strengthen_level > 0 then
		self:ShowStrengthLable(true)
		self:SetStrength(self.data.param.strengthen_level)
	else
		self:ShowStrengthLable(false)
	end
end

function ShenShouEquip:SetShouId(select_shou_id)
	self.select_shou_id = select_shou_id
end

function ShenShouEquip:Reset(...)
	ItemCell.Reset(self, ...)
	local toggle = self.root_node.toggle
	toggle.interactable = true
end