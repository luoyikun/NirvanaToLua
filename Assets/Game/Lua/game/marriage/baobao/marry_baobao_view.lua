require("game/marriage/baobao/baobao_image_view")
require("game/marriage/baobao/baobao_attr_view")
require("game/marriage/baobao/baobao_aptitude_view")
require("game/marriage/baobao/baobao_bless_view")
require("game/marriage/baobao/baobao_guard_view")

MarryBaoBaoView = MarryBaoBaoView or BaseClass(BaseView)
local MOVE_TIME = 0.5
function MarryBaoBaoView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		--{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/marriageview/baobao_prefab", "BaoBaoContentView"},		-- 基础界面
		{"uis/views/marriageview/baobao_prefab", "BaobaoBB", {TabIndex.marriage_baobao_att}},			-- 宝宝界面
		{"uis/views/marriageview/baobao_prefab", "BaobaoZZ", {TabIndex.marriage_baobao_zizhi}},		-- 资质界面
		{"uis/views/marriageview/baobao_prefab", "BaobaoSW", {TabIndex.marriage_baobao_guard}},		-- 守卫界面
		{"uis/views/marriageview/baobao_prefab", "BaobaoBW", {TabIndex.marriage_baobao_bless}},		-- 抱娃界面
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.marriage_baobao_bless
end

function MarryBaoBaoView:ReleaseCallBack()
	-- 共用界面
	if self.image_view then
		self.image_view:DeleteMe()
		self.image_view = nil
	end

	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end
	if self.bless_view then
		self.bless_view:DeleteMe()
		self.bless_view = nil
	end
	if self.guard_view then
		self.guard_view:DeleteMe()
		self.guard_view = nil
	end
	if self.aptitude_view then
		self.aptitude_view:DeleteMe()
		self.aptitude_view = nil
	end
	if self.item_data_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end
	if self.operate_result then
		GlobalEventSystem:UnBind(self.operate_result)
		self.operate_result = nil
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.seconed_index = nil
end

function MarryBaoBaoView:LoadCallBack()
	self.image_view = BaoBaoImageView.New(self.node_list["ImageView"])
	self.node_list["ScrollRect"].rect.sizeDelta = Vector3(144,660,0) 
	-- self.node_list["SideTabContent"].gameObject:GetComponent(typeof(UnityEngine.UI.VerticalLayoutGroup)).padding.top = 15
	local tab_cfg = {
	{name = Language.MarryBaoBao.TabbarName[1], bundle = "uis/images_atlas", asset = "icon_tab_shenge_1", tab_index = TabIndex.marriage_baobao_att, remind_id = RemindName.MarryBaoBaoAttr , func = BindTool.Bind(self.ShowOrHideTab ,self)},
	{name = Language.MarryBaoBao.TabbarName[4], bundle = "uis/images_atlas", asset = "icon_tab_shenge_4", tab_index = TabIndex.marriage_baobao_zizhi, remind_id = RemindName.MarryBaoBaoZiZhi , func = BindTool.Bind(self.ShowOrHideTab ,self)},
	{name = Language.MarryBaoBao.TabbarName[3], bundle = "uis/images_atlas", asset = "icon_tab_shenge_3", tab_index = TabIndex.marriage_baobao_guard, remind_id = RemindName.MarryBaoBaoGuard, func = BindTool.Bind(self.ShowOrHideTab ,self)},
	{name = Language.MarryBaoBao.TabbarName[2], bundle = "uis/images_atlas", asset = "icon_tab_shenge_2", tab_index = TabIndex.marriage_baobao_bless, func = function () return true end},

	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TxtTitle"].text.text = Language.MarryBaoBao.ViewName
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	self.node_list["ShowButtonZiZhi"].button:AddClickListener(BindTool.Bind(self.OpenZizhiClick, self))
	self.operate_result = GlobalEventSystem:Bind(OtherEventType.OPERATE_RESULT, BindTool.Bind1(self.OnOperateResult, self))
	self.node_list["TaiZi"].transform.localPosition = Vector3(-160, -280, 0)
	self:Flush()

	self.activity_change = BindTool.Bind(self.ActivityChange, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)
end

function MarryBaoBaoView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:Flush()
	self:FlushTabbar()
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoZiZhi)
end

function MarryBaoBaoView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	local count = #baby_list
	self.seconed_index = count <= 0 and TabIndex.marriage_baobao_bless or nil
	if self.seconed_index then 
		self.tabbar:OnTabClick(self.seconed_index)
	end

	self:ShowXianShi()
end

function MarryBaoBaoView:ShowXianShi()
	if self.tabbar then
		local tab_button = self.tabbar:GetTabButton(TabIndex.marriage_baobao_bless)
		if tab_button then
			local is_has_xianshi = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BABYHALDOFF)
			local bundle, asset = ResPath.GetMarryImage("half_off")
			tab_button:ShowXianShiDuiHuan(is_has_xianshi, bundle, asset)
		end
	end	
end

function MarryBaoBaoView:ActivityChange(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BABYHALDOFF then
		self:ShowXianShi()
		if self.cur_index == TabIndex.marriage_baobao_bless and self.bless_view then
			self.bless_view:Flush()
		end
	end
end

function MarryBaoBaoView:ShowIndexCallBack(index, index_nodes)
	self.node_list["UnderBg"]:SetActive(false)

	local bundle, asset = ResPath.GetRawImage("bg_common1_under", true)
	if index == TabIndex.marriage_baobao_guard then
		bundle, asset = ResPath.GetRawImage("bg_baobao_sw", false)
	end
	local fun = function()
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["TaiZi"]:SetActive(not (index == TabIndex.marriage_baobao_guard or index == TabIndex.marriage_baobao_bless))
	end
	self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, fun)


	self.tabbar:ChangeToIndex(index)
	BaobaoData.Instance:SetCurTabIndex(index)
	self.cur_index = index
	if nil ~= index_nodes then
		if index == TabIndex.marriage_baobao_att then
			self.attr_view = BaoBaoAttrView.New(index_nodes["BaobaoBB"] , self)				-- 宝宝界面
		elseif index == TabIndex.marriage_baobao_bless then
			self.bless_view = BaoBaoBlessView.New(index_nodes["BaobaoBW"] , self)			-- 抱娃界面
		elseif index == TabIndex.marriage_baobao_guard then
			self.guard_view = BaoBaoGuardView.New(index_nodes["BaobaoSW"] , self)			-- 守卫界面
		elseif index == TabIndex.marriage_baobao_zizhi then
			self.aptitude_view = BaoBaoAptitudeView.New(index_nodes["BaobaoZZ"] , self)		-- 资质界面
		end
	end

	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	local count = #baby_list

	if index == TabIndex.marriage_baobao_att then
		self.attr_view:UIsMove()
		UITween.AlpahShowPanel(self.node_list["ImageView"] ,true , MOVE_TIME ,DG.Tweening.Ease.InExpo)
		self.attr_view:Flush()
		self:FlushImageView()
		if count > 0 then
			self.node_list["ImageView"]:SetActive(true)
			self.node_list["LeftContent"]:SetActive(true)
			self.node_list["RightPanel"]:SetActive(true)
			self.node_list["BabyParentName"]:SetActive(true)
		end
		self:UIsMove()
		--self.node_list["BabyChangeName"]:SetActive(true)
		-- self.node_list["TaiZi"]:SetActive(true)
		
	elseif index == TabIndex.marriage_baobao_bless then
		self.bless_view:UIsMove()
		self.bless_view:Flush()
		--self:FlushImageView()
		self.node_list["ImageView"]:SetActive(false)
		self.node_list["LeftContent"]:SetActive(false)
		self.node_list["RightPanel"]:SetActive(false)
		self.node_list["BabyParentName"]:SetActive(false)
		--self.node_list["BabyChangeName"]:SetActive(false)
		-- self.node_list["TaiZi"]:SetActive(false)
	elseif index == TabIndex.marriage_baobao_guard then
		self.guard_view:UIsMove()
		UITween.AlpahShowPanel(self.node_list["ImageView"] ,true , MOVE_TIME ,DG.Tweening.Ease.InExpo)
		self.guard_view:Flush()
		self:FlushImageView()
		self.node_list["ImageView"]:SetActive(false)
		self.node_list["LeftContent"]:SetActive(false)
		self.node_list["RightPanel"]:SetActive(false)
		self.node_list["BabyParentName"]:SetActive(false)
		--self.node_list["BabyChangeName"]:SetActive(false)
		-- self.node_list["TaiZi"]:SetActive(true)
		
	elseif index == TabIndex.marriage_baobao_zizhi then
		self.aptitude_view:UIsMove()
		UITween.AlpahShowPanel(self.node_list["ImageView"] ,true , MOVE_TIME ,DG.Tweening.Ease.InExpo)
		self.aptitude_view:Flush() 
		self:FlushImageView()
		if count > 0 then
			self.node_list["ImageView"]:SetActive(true)
			self.node_list["LeftContent"]:SetActive(true)
			self.node_list["RightPanel"]:SetActive(true)
		end
		self.node_list["BabyParentName"]:SetActive(false)
		self:UIsMove()
		--self.node_list["BabyChangeName"]:SetActive(false)
		-- self.node_list["TaiZi"]:SetActive(true)
	end
	if index ~= TabIndex.marriage_baobao_att then
		if self.attr_view then
			self.attr_view:CloseCallBack()
		end
	end
	if index ~= TabIndex.marriage_baobao_guard then
		if self.guard_view then
			self.guard_view:CloseCallBack()
		end
	end
end

function MarryBaoBaoView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.marriage_baobao_att then
		if nil == self.attr_view then return end
		self.attr_view:Flush(param_list)
		self:FlushImageView()
	elseif cur_index == TabIndex.marriage_baobao_bless then
		if nil == self.bless_view then return end
		self.bless_view:Flush(param_list)
		--self:FlushImageView()
	elseif cur_index == TabIndex.marriage_baobao_guard then
		if nil == self.guard_view then return end
		self.guard_view:Flush(param_list)
		self:FlushImageView()
	elseif cur_index == TabIndex.marriage_baobao_zizhi then
		if nil == self.aptitude_view then return end
		self.aptitude_view:Flush(param_list)
		self:FlushImageView()
	end
	self:FlushTabbar()

	for k,v in pairs(param_list) do
		if k == "flush_baobao" then
			self.tabbar:OnTabClick(TabIndex.marriage_baobao_att)
		end
	end
end

function MarryBaoBaoView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MarryBaoBaoView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
	-- RemindManager.Instance:Fire(RemindName.MarryBaoBaoAttr)
	-- RemindManager.Instance:Fire(RemindName.MarryBaoBaoZiZhi)
	-- RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

-- 根据宝宝数量确定Tab的显示隐藏
function MarryBaoBaoView:ShowOrHideTab()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	local count = #baby_list
	if count > 0 then 
		return true
	end
	return false 		-- 正常应该返回false，测试界面所以用了true
end

-- 物品变化刷新
function MarryBaoBaoView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.attr_view then
		self.attr_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	end
	if self.guard_view then
		self.guard_view:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	end
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoAttr)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoZiZhi)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

-- 共用面板
function MarryBaoBaoView:FlushImageView()
	if self.image_view then
		self.image_view:FlushView()
	end
end

function MarryBaoBaoView:ResetValue()
	if self.guard_view then
		self.guard_view:ResetValue()
	end
end

function MarryBaoBaoView:OpenZizhiClick(value)
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	self.is_show_aptitude = value
	if self.is_show_aptitude then
		self.aptitude_view:FlushView()
	else
		self.attr_view:FlushView()
	end
end

function MarryBaoBaoView:OnOperateResult(operate, result, param1, param2)
	
	if operate == MODULE_OPERATE_TYPE.OP_BABY_JIE_UPGRADE then
		if self.attr_view then
			self.attr_view:OnOperateResult(operate, result, param1, param2)
		end
	elseif operate == MODULE_OPERATE_TYPE.OP_BABY_JL_UPGRADE then
		if self.guard_view then
			self.guard_view:OnOperateResult(operate, result, param1, param2)
		end
	end
end

function MarryBaoBaoView:CloseCallBack()
	if self.cur_index == TabIndex.marriage_baobao_att then
		if self.attr_view then
			self.attr_view:CloseCallBack()
		end
	end
	if self.cur_index == TabIndex.marriage_baobao_guard then
		if self.guard_view then
			self.guard_view:CloseCallBack()
		end
	end
	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function MarryBaoBaoView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"] , Vector3(-200, -24, 0), MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(0, -10, 0), MOVE_TIME )
end