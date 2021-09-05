require("game/marriage/marriage_honeymoon_view")
require("game/marriage/marriage_fuben_view")
require("game/marriage/baobao/baobao_view")
-- require("game/marriage/equip/marry_equip_content_view")
require("game/marriage/equip/marry_equip_info_view")
require("game/marriage/equip/marry_equip_suit_view")
require("game/marriage/equip/marry_equip_recyle_info_view")
require("game/marriage/marriage_halo_content")
require("game/marriage/ring_count_view")
require("game/marriage/marriage_biaobai_view")

local MARRIAGE_TAB_INDEX =
{
	TabIndex.marriage_honeymoon,
 	TabIndex.marriage_love_halo,
 	TabIndex.marriage_baobao,
 	TabIndex.marriage_fuben,
}

MarriageView = MarriageView or BaseClass(BaseView)

function MarriageView:__init()
	self.ui_config = {
		{"uis/views/marriageview_prefab", "BaseSecondPanel_1"},
			
		{"uis/views/marriageview_prefab", "HoneyMoonContentView", {TabIndex.marriage_lover, TabIndex.marriage_honey}},
		{"uis/views/marriageview_prefab", "RingCountView", {TabIndex.marriage_ring}},
		-- {"uis/views/marriageview_prefab", "HunYanContent", {TabIndex.marriage_weeding}},
		{"uis/views/marriageview_prefab", "LoveContractContent", {TabIndex.marriage_love_contract}},
		{"uis/views/marriageview_prefab", "MarryEquipView", {TabIndex.marriage_equip}},
		{"uis/views/marriageview_prefab", "HaloContent", {TabIndex.marriage_halo}},
		{"uis/views/marriageview_prefab", "FuBenContentView", {TabIndex.marriage_fuben}},
		{"uis/views/marriageview_prefab", "MarryBiaoBaiView", {TabIndex.marriage_biaobai}},
		{"uis/views/marriageview_prefab", "BaseSecondPanel_2"},	
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}
	self.is_modal = true
	self.full_screen = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenMarry)
	end
	self.play_audio = true
	self.select_honeymoon_index = 0
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	self.def_index = TabIndex.marriage_honey
end

function MarriageView:__delete()

end

function MarriageView:ReleaseCallBack()
	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:DeleteMe()
		self.marriage_honeymoon_view = nil
	end

	if self.marriage_ring_view then
		self.marriage_ring_view:DeleteMe()
		self.marriage_ring_view = nil
	end

	if self.marriage_wedding_view then
		self.marriage_wedding_view:DeleteMe()
		self.marriage_wedding_view = nil
	end

	if self.marriage_fuben_view then
		self.marriage_fuben_view:DeleteMe()
		self.marriage_fuben_view = nil
	end

	if self.baobao_view then
		self.baobao_view:DeleteMe()
		self.baobao_view = nil
	end

	if self.marriage_biaobai_view then
		self.marriage_biaobai_view:DeleteMe()
		self.marriage_biaobai_view = nil
	end
	
	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.shengdi_view then
		self.shengdi_view:DeleteMe()
		self.shengdi_view = nil
	end

	if self.halo_view then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end

	if self.love_contract_view then
		self.love_contract_view:DeleteMe()
		self.love_contract_view = nil
	end

	if self.suit_view then
		self.suit_view:DeleteMe()
		self.suit_view = nil
	end

	if self.recyle_view then
		self.recyle_view:DeleteMe()
		self.recyle_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.red_point_list = nil
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function MarriageView:ShowOrHideHoneyTab()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	return main_vo.lover_uid > 0
end

function MarriageView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.Marriage.TabbarName.HoneyMoon, bundle = "uis/images_atlas", asset = "tab_icon_honeymoon", tab_index = TabIndex.marriage_honeymoon, remind_id = RemindName.HoneyMoon, func = "marriage_honeymoon"},
		{name = Language.Marriage.TabbarName.EquipSuit, bundle = "uis/images_atlas", asset = "tab_icon_marryqinshi", tab_index = TabIndex.marriage_equip, remind_id = RemindName.MarryEquip, func = "marriage_equip"},
		{name = Language.Marriage.TabbarName.HaloContent, bundle = "uis/images_atlas", asset = "tab_icon_marryhalo", tab_index = TabIndex.marriage_halo, remind_id = RemindName.MarryCoupHalo, func = "marriage_halo"},
		{name = Language.Marriage.TabbarName.FuBen, bundle = "uis/images_atlas", asset = "tab_icon_marryfuben", tab_index = TabIndex.marriage_fuben, remind_id = RemindName.MarryFuBen, func = "marriage_fuben"},
		{name = Language.Marriage.TabbarName.BiaoBai, bundle = "uis/images_atlas", asset = "tab_icon_marryfuben", tab_index = TabIndex.marriage_biaobai, func = "marriage_biaobai"}
	}
	local sub_tab_cfg = {
		{
			{name = Language.Marriage.TabbarName.HoneyOther, tab_index = TabIndex.marriage_honey, func = BindTool.Bind(self.ShowOrHideHoneyTab, self), remind_id = RemindName.MarryAffection},
			{name = Language.Marriage.TabbarName.MarriageRing, tab_index = TabIndex.marriage_ring, func = BindTool.Bind(self.ShowOrHideHoneyTab, self), remind_id = RemindName.MarryRing},
			-- {name = Language.Marriage.TabbarName.Weeding, tab_index = TabIndex.marriage_weeding, func = BindTool.Bind(self.ShowOrHideHoneyTab, self)},
			{name = Language.Marriage.TabbarName.LoveContract, tab_index = TabIndex.marriage_love_contract, func = BindTool.Bind(self.ShowOrHideHoneyTab, self), remind_id = RemindName.MarryLoveContent},
		},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg, true)
	self.tabbar:InitSubTab(self.node_list["TopTabPanel"], sub_tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["TitleText"].text.text = Language.Marriage.MarriageName
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))

	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_GET_ROLE_INFO)
end

function MarriageView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		if remind_name == RemindName.MarryEquip or remind_name == RemindName.MarrySuit or remind_name == RemindName.MarryEquipRecyle then
			local remind_m = RemindManager.Instance
			local num = remind_m:GetRemind(RemindName.MarryEquip) + remind_m:GetRemind(RemindName.MarrySuit) + remind_m:GetRemind(RemindName.MarryEquipRecyle)
			self.red_point_list[remind_name]:SetActive(num > 0)
			self:Flush("equip")
		else
			self.red_point_list[remind_name]:SetActive(num > 0)
		end
	end
end

function MarriageView:ShowOrHideTab()
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list["tab_honeymoon"] = open_fun_data:CheckIsHide("marriage_honeymoon")
	show_list["tab_halo"] = open_fun_data:CheckIsHide("marriage_halo")
	show_list["tab_fb"] = open_fun_data:CheckIsHide("marriage_fuben")
	show_list["tab_biaobai"] = open_fun_data:CheckIsHide("marriage_biaobai")
	for k,v in pairs(show_list) do
		if self[k] then
			self[k]:SetActive(v)
		end
	end
end

function MarriageView:OpenCallBack()
	MarriageCtrl.Instance:SendQingYuanFBInfoReq(QINGYUAN_FB_OPERA_TYPE.QINGYUAN_FB_OPERA_TYPE_BASE_INFO)
	MarriageCtrl.Instance:SendQingyuanBuyLoveContract(LOVE_CONTRACT_REQ_TYPE.LC_REQ_TYPE_INFO)

	self:ShowOrHideTab()

	self.fun_open_bind = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	RemindManager.Instance:Fire(RemindName.MarryAffection)
end

function MarriageView:CloseCallBack()
	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:CloseCallBack()
	end
	if self.fun_open_bind then
		GlobalEventSystem:UnBind(self.fun_open_bind)
		self.fun_open_bind = nil
	end
	if self.halo_view then
		self.halo_view:CloseCallBack()
	end
end

function MarriageView:ClickClose()
	self:Close()
end

function MarriageView:RingChange()
	if self:IsLoaded() then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:RingInfoChange()
		end
	end
end

function MarriageView:BlessChange()
	if self:IsLoaded() then
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:Flush()
		end
	end
end

function MarriageView:OnFuBenChange()
	if self:IsLoaded() then
		if self.marriage_fuben_view then
			self.marriage_fuben_view:Flush()
		end
		if self.marriage_honeymoon_view then
			self.marriage_honeymoon_view:FlushWedding()
		end
	end
end

function MarriageView:MarryStateChange()
	if self.tabbar:GetTabButton(TabIndex.marriage_honeymoon) and self.tabbar:GetTabButton(TabIndex.marriage_honeymoon).root_node.toggle.isOn and self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:MarryStateChange()
	end
	if self.tabbar:GetTabButton(TabIndex.marriage_halo) and self.tabbar:GetTabButton(TabIndex.marriage_halo).root_node.toggle.isOn and self.halo_view then
		self.halo_view:FlushLoverModel()
		self.halo_view:FlushRoleContent()
	end
end

function MarriageView:ClickHoneyMoon()
	self:ShowIndex(TabIndex.marriage_lover)
end

function MarriageView:ClickFuBen()
	self:ShowIndex(TabIndex.marriage_fuben)
end

function MarriageView:ClickShengdiTab()
	-- 红点处理
	ClickOnceRemindList[RemindName.MarryShengDi] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.MarryShengDi)
end

function MarriageView:ClickHalo()
	self:ShowIndex(TabIndex.marriage_love_halo)
end

--决定显示那个界面
function MarriageView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)
	self:SetBg(index)

	if index_nodes then
		if index == TabIndex.marriage_honey or index == TabIndex.marriage_lover or index == TabIndex.marriage_monomer then
			if self.marriage_honeymoon_view == nil then
				self.marriage_honeymoon_view = MarriageHoneymoonView.New(index_nodes["HoneyMoonContentView"])
			end
		elseif index == TabIndex.marriage_ring then
			self.marriage_ring_view = MarriageRingCountView.New(index_nodes["RingCountView"], self)
		-- elseif index == TabIndex.marriage_weeding then
		-- 	self.marriage_wedding_view = MarriageWeddingView.New(index_nodes["HunYanContent"], self)
		elseif index == TabIndex.marriage_equip then
			self.equip_view = MarryEquipInfoView.New(index_nodes["MarryEquipView"], self)
		elseif index == TabIndex.marriage_love_contract then
			self.love_contract_view = MarriageLoveContractView.New(index_nodes["LoveContractContent"], self)
		elseif index == TabIndex.marriage_halo then
			self.halo_view = MarriageHaloContent.New(index_nodes["HaloContent"], self)
		elseif index == TabIndex.marriage_fuben then
			self.marriage_fuben_view = MarriageFuBenView.New(index_nodes["FuBenContentView"], self)
		elseif index == TabIndex.marriage_biaobai then
			self.marriage_biaobai_view = MarriageBiaoBaiView.New(index_nodes["MarryBiaoBaiView"], self)
		end
	end

	self.node_list["TopTabPanel"]:SetActive(false)

	if index == TabIndex.marriage_honey or index == TabIndex.marriage_lover or index == TabIndex.marriage_monomer then
		self.node_list["TopTabPanel"]:SetActive(true)
		-- self.node_list["UnderBg"]:
		self.marriage_honeymoon_view:Flush()
		self.marriage_honeymoon_view:ShowIndexCallBack(index)
	elseif index == TabIndex.marriage_ring then
		self.node_list["TopTabPanel"]:SetActive(true)
		self.marriage_ring_view:Flush()
	-- elseif index == TabIndex.marriage_weeding then
	-- 	self.marriage_wedding_view:Flush()
	elseif index == TabIndex.marriage_equip then
		MarryEquipCtrl.SendActiveLoverEquipInfo()
		self.equip_view:Flush()
	elseif index == TabIndex.marriage_love_contract then
		self.node_list["TopTabPanel"]:SetActive(true)
		GlobalTimerQuest:AddDelayTimer(function()
			if self.love_contract_view then
				self.love_contract_view:FlushLoveContractView()
			end
		end, 0)
	elseif index == TabIndex.marriage_halo then
		self.halo_view:FlushView()
	elseif index == TabIndex.marriage_fuben then
		self.marriage_fuben_view:Flush()
		RemindManager.Instance:SetRemindToday(RemindName.MarryFuBen)
	elseif index == TabIndex.marriage_biaobai then
		self.marriage_biaobai_view:Flush()
	end

	self.select_honeymoon_index = 0
	if self.marriage_honeymoon_view then
		self.marriage_honeymoon_view:CloseCallBack()
	end
end

function MarriageView:SetBg(index)
	local call_back = function ()
		self.node_list["UnderBg"].raw_image:SetNativeSize()
		self.node_list["UnderBg"]:SetActive(true)
	end

	if index == TabIndex.marriage_honey then
		-- self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_marry_1", "bg_marry_1.png", call_back)
		self.node_list["Desk1"]:SetActive(true)
		self.node_list["Desk2"]:SetActive(false)
	elseif index == TabIndex.marriage_equip or index == TabIndex.marriage_halo or index == TabIndex.marriage_biaobai then
		-- self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_marry_1", "bg_marry_1.png", call_back)
		self.node_list["Desk2"]:SetActive(true)
		self.node_list["Desk1"]:SetActive(false)
	elseif index == TabIndex.marriage_ring or index == TabIndex.marriage_love_contract then
		-- self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_marry_1", "bg_marry_1.png", call_back)
		self.node_list["Desk2"]:SetActive(false)
		self.node_list["Desk1"]:SetActive(false)
		-- self.node_list["UnderBg"].transform.localPosition = Vector3(0, 0, 0)
	elseif index == TabIndex.marriage_fuben then
		-- self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_marry_4", "bg_marry_4.jpg", call_back)
		self.node_list["Desk2"]:SetActive(true)
		self.node_list["Desk1"]:SetActive(false)
	elseif index == TabIndex.marriage_love_contract then
		-- self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_marry_1", "bg_marry_1.png", call_back)
		self.node_list["Desk2"]:SetActive(false)
		self.node_list["Desk1"]:SetActive(false)
	else
		-- self.node_list["UnderBg"]:SetActive(false)
		self.node_list["Desk2"]:SetActive(true)
		self.node_list["Desk1"]:SetActive(false)
	end
end

function MarriageView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "equip" then
			if self.equip_view then
				self.equip_view:Flush()
			end
		elseif k == "Shendi" then 
			if self.shengdi_view then
				self.shengdi_view:Flush()
			end
		elseif k == "tuodan" then
			if self.marriage_honeymoon_view then
				self.marriage_honeymoon_view:FlushTuoDanList()
			end
		elseif k == "love_contract" then
			if self.love_contract_view then
				self.love_contract_view:FlushLoveContractView()
			end
		elseif k == "halo" then
			if self.halo_view then
				self.halo_view:FlushView()
			end
		elseif k == "lover_change" then
			self:MarryStateChange()
		elseif k == "ring" then
			if self.marriage_ring_view then
				self.marriage_ring_view:Flush()
			end
		elseif k == "wedding" then
			if self.marriage_wedding_view then
				self.marriage_wedding_view:Flush()
			end
		elseif k == "biaobai" then
			if self.marriage_biaobai_view then
				self.marriage_biaobai_view:Flush()
			end
		end
	end
	self.tabbar:FlushTabbar()
end