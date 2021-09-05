require("game/rank/rank_content_view")
require("game/rank/rank_mingren_view")
require("game/rank/qingyuan_content")
RankView = RankView or BaseClass(BaseView)

function RankView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/rank_prefab", "RankView"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/rank_prefab", "QingYuanContent"},
		
	}
	self.camera_mode = UICameraMode.UICameraMid
	self.full_screen = true
	self.play_audio = true
	self.cell_list = {}
	self.top_type = RANKPANEL.GEREN
	self.def_index = RANK_TAB_TYPE.ZHANLI
	self.index = RANK_TAB_TYPE.ZHANLI

	local language = Language.Rank.RankTabName
	local bundle = "uis/images_atlas"
	self.tab_cfg = {
--个人
		{name = language[0], bundle = bundle, asset = "tab_icon_zhanli", 	tab_index = RANK_TAB_TYPE.ZHANLI, 	rank_type = RANKPANEL.GEREN},--战力
		{name = language[1], bundle = bundle, asset = "tab_icon_grade", 	tab_index = RANK_TAB_TYPE.LEVEL, 	rank_type = RANKPANEL.GEREN},--等级
		{name = language[8], bundle = bundle, asset = "tab_icon_mount", 	tab_index = RANK_TAB_TYPE.MOUNT, 	rank_type = RANKPANEL.GEREN, 		func = "rank_mount"},--坐骑
		{name = language[11], bundle = bundle, asset = "tab_icon_wing", 	tab_index = RANK_TAB_TYPE.WING, 	rank_type = RANKPANEL.GEREN, 		func = "rank_wing"},--羽翼
		{name = language[63], bundle = bundle, asset = "tab_icon_fashion", 	tab_index = RANK_TAB_TYPE.FASHION, 	rank_type = RANKPANEL.GEREN, 		func = "rank_shizhuan"},--时装
		{name = language[48], bundle = bundle, asset = "tab_icon_spirit", 	tab_index = RANK_TAB_TYPE.SPIRIT, 	rank_type = RANKPANEL.GEREN, 		func = "rank_spirit"},--仙宠
		{name = language[64], bundle = bundle, asset = "tab_icon_wuqi", 	tab_index = RANK_TAB_TYPE.SHENBING, rank_type = RANKPANEL.GEREN, 		func = "rank_shenbing"},--神兵
		{name = language[62], bundle = bundle, asset = "tab_icon_fabao", 	tab_index = RANK_TAB_TYPE.FABAO, 	rank_type = RANKPANEL.GEREN, 		func = "rank_fabao"},--法宝
		{name = language[65], bundle = bundle, asset = "tab_icon_foot", 	tab_index = RANK_TAB_TYPE.FOOT, 	rank_type = RANKPANEL.GEREN, 		func = "rank_foot"},--足迹
		{name = language[44], bundle = bundle, asset = "tab_icon_halo", 	tab_index = RANK_TAB_TYPE.HALO, 	rank_type = RANKPANEL.GEREN, 		func = "rank_halo"},--光环
		{name = language[52], bundle = bundle, asset = "tab_icon_fightmount", tab_index = RANK_TAB_TYPE.FIGHT_MOUNT, rank_type = RANKPANEL.GEREN, 	func = "rank_fightmount"},--战骑
		{name = language[81], bundle = bundle, asset = "tab_icon_pifeng", 	tab_index = RANK_TAB_TYPE.CLOAK, 	rank_type = RANKPANEL.GEREN, 		func = "rank_cloat"},--披风
		-- {name = language[82], bundle = bundle, asset = "tab_icon_lingren", 	tab_index = RANK_TAB_TYPE.LINGREN, 	rank_type = RANKPANEL.GEREN, 	func = "rank_"},--灵刃
		{name = language[69], bundle = bundle, asset = "tab_icon_toushi", 	tab_index = RANK_TAB_TYPE.TOUSHI, 	rank_type = RANKPANEL.GEREN, 		func = "rank_toushi"},--头饰
		{name = language[71], bundle = bundle, asset = "tab_icon_mask", 	tab_index = RANK_TAB_TYPE.MASK, 	rank_type = RANKPANEL.GEREN, 		func = "rank_mask"},--面饰
		{name = language[68], bundle = bundle, asset = "tab_icon_waist", 	tab_index = RANK_TAB_TYPE.YAOSHI, 	rank_type = RANKPANEL.GEREN, 		func = "rank_yaoshi"},--腰饰
		{name = language[70], bundle = bundle, asset = "tab_icon_qilinbi", 	tab_index = RANK_TAB_TYPE.QILINBI, 	rank_type = RANKPANEL.GEREN, 		func = "rank_qilinbi"},--麒麟臂
		{name = language[2], bundle = bundle, asset = "tab_icon_goddess", 	tab_index = RANK_TAB_TYPE.GODDESS, 	rank_type = RANKPANEL.GEREN, 		func = "rank_goddess"},--仙女
		{name = language[45], bundle = bundle, asset = "tab_icon_shengong", tab_index = RANK_TAB_TYPE.SHENGONG, rank_type = RANKPANEL.GEREN, 		func = "rank_goddesshalo"},--仙环
		{name = language[46], bundle = bundle, asset = "tab_icon_shenyi", 	tab_index = RANK_TAB_TYPE.SHENYI, 	rank_type = RANKPANEL.GEREN, 		func = "rank_goddesszhen"},--仙阵
		{name = language[72], bundle = bundle, asset = "tab_icon_lingzhu", 	tab_index = RANK_TAB_TYPE.LINGZHU, 	rank_type = RANKPANEL.GEREN, 		func = "rank_lingzhu"},--灵珠
		{name = language[73], bundle = bundle, asset = "tab_icon_xianbao", 	tab_index = RANK_TAB_TYPE.XIANBAO, 	rank_type = RANKPANEL.GEREN, 		func = "rank_xianbao"},--仙宝
		{name = language[74], bundle = bundle, asset = "tab_icon_lingtong", tab_index = RANK_TAB_TYPE.LINGTONG, rank_type = RANKPANEL.GEREN, 		func = "rank_lingtong"},--灵童
		{name = language[75], bundle = bundle, asset = "tab_icon_linggong", tab_index = RANK_TAB_TYPE.LINGGONG, rank_type = RANKPANEL.GEREN, 		func = "rank_linggong"},--灵弓
		{name = language[76], bundle = bundle, asset = "tab_icon_lingqi", 	tab_index = RANK_TAB_TYPE.LINGQI, 	rank_type = RANKPANEL.GEREN, 		func = "rank_lingqi"},--灵骑
		{name = language[77], bundle = bundle, asset = "tab_icon_weiyan", 	tab_index = RANK_TAB_TYPE.WEIYAN, 	rank_type = RANKPANEL.GEREN, 		func = "rank_weiyan"},--尾焰
		{name = language[78], bundle = bundle, asset = "tab_icon_shouhuan", tab_index = RANK_TAB_TYPE.SHOUHUAN, rank_type = RANKPANEL.GEREN, 		func = "rank_shouhuan"},--手环
		{name = language[79], bundle = bundle, asset = "tab_icon_tail", 	tab_index = RANK_TAB_TYPE.TAIL, 	rank_type = RANKPANEL.GEREN, 		func = "rank_tail"},--尾巴
		{name = language[80], bundle = bundle, asset = "tab_icon_flypet", 	tab_index = RANK_TAB_TYPE.FLYPET, 	rank_type = RANKPANEL.GEREN, 		func = "rank_flypet"},--飞宠
		-- {name = language[50], bundle = bundle, asset = "tab_icon_strengthen", tab_index = RANK_TAB_TYPE.FORGE},
		-- {name = language[51], bundle = bundle, asset = "tab_icon_gem", 		tab_index = RANK_TAB_TYPE.BAOSHI},
		-- {name = language[3], 	bundle = bundle, asset = "shengxiao_equip", tab_index = RANK_TAB_TYPE.EQUIP},
		
--魅力
		{name = language[4], bundle = bundle, asset = "tab_icon_charm", 	tab_index = RANK_TAB_TYPE.MEILI, 	rank_type = RANKPANEL.MEILI},--魅力
		{name = language[5], bundle = bundle, asset = "tab_icon_answer", 	tab_index = RANK_TAB_TYPE.DATI, 	rank_type = RANKPANEL.MEILI},--答题
--情缘
		{name = language[13], bundle = bundle, asset = "tab_icon_qingyuan", tab_index = RANK_TAB_TYPE.QINGYUAN, rank_type = RANKPANEL.QINGYUAN},--情缘
		{name = language[27], bundle = bundle, asset = "icon_tab_baobao", 	tab_index = RANK_TAB_TYPE.BAOBAO, 	rank_type = RANKPANEL.QINGYUAN, func = "rank_baobao"},--宝宝
		{name = language[47], bundle = bundle, asset = "icon_tab_chongwu", 	tab_index = RANK_TAB_TYPE.LITTLEPET,rank_type = RANKPANEL.QINGYUAN, func = "rank_little_pet"},--小宠物
--名人堂
		-- {name = language[6], bundle = bundle, asset = "tab_icon_mingren", 	tab_index = RANK_TAB_TYPE.MINGREN, 	rank_type = RANKPANEL.MINGREN},
--跨服
		{name = language[0], bundle = bundle, asset = "tab_icon_zhanli", 	tab_index = RANK_TAB_TYPE.KUAFUZHANLI,	rank_type = RANKPANEL.KUAFU},--跨服战力
		{name = language[1], bundle = bundle, asset = "tab_icon_grade", 	tab_index = RANK_TAB_TYPE.KUAFULEVEL,	rank_type = RANKPANEL.KUAFU},--跨服等级
	}
end

function RankView:LoadCallBack()
	self.node_list["TxtTitle"].text.text = Language.Rank.TabbarName.PaiHang
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BindGoldNode"]:SetActive(false)
	self.node_list["GoldNode"]:SetActive(false)
	self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TaiZi"].transform.anchoredPosition = Vector2(-340, -300)
	-- self.node_list["TaiZi"].transform.localScale = Vector3(0.9, 0.9, 1)

	self.node_list["GeRenToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.RankClick, self))
	self.node_list["QingLvToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.TopQingLvClick, self))
	self.node_list["MeiLiToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.TopMeiLiClick, self))
	-- self.node_list["MingToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnMingClick, self))
	self.node_list["KuaFuToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnKuaFuRankClick, self))

	self.node_list["KuaFuToggle"]:SetActive(OpenFunData.Instance:CheckIsHide("kuafu_rank"))

	-- -- 名人堂仅开服前天显示
	-- local mingren_cfg = RankData.Instance:GetMingrenOtherCfg()
	-- local show_day = mingren_cfg.during_time or 3
	-- local cur_time = TimeCtrl.Instance:GetServerTime()
	-- local start_time = TimeCtrl.Instance:GetServerRealStartTime()
	-- local server_open_time = cur_time - start_time
	-- local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- local value = TimeUtil.NowDayTimeStart(start_time)
	-- local value2 = start_time - value
	-- local left_time = (86400 * show_day) - server_open_time - value2
	-- self.node_list["MingToggle"]:SetActive(server_open_day <= show_day)

	-- local function diff_time_fun(elapse_time, total_time)
	-- 	local star_time = math.floor(total_time - elapse_time + 0.5)
	-- 	local count_down_text = TimeUtil.FormatSecond(star_time, 16)
	-- 	-- self.node_list["TxtTime"].text.text = string.format(Language.XiuLuo.Time, count_down_text)
	-- 	self.node_list["TxtTime"].text.text = count_down_text

	-- 	if star_time <= 0 then
	-- 		self.node_list["TxtTime"]:SetActive(false)
	-- 		self.node_list["MingToggle"]:SetActive(false)
	-- 		if self.star_count_down ~= nil then
	-- 			CountDown.Instance:RemoveCountDown(self.star_count_down)
	-- 			self.star_count_down = nil
	-- 		end
	-- 	end
	-- end

	-- if self.star_count_down ~= nil then
	-- 	CountDown.Instance:RemoveCountDown(self.star_count_down)
	-- 	self.star_count_down = nil
	-- end
	-- self.star_count_down = CountDown.Instance:AddCountDown(left_time, 0.5, diff_time_fun)

	self.rank_content_view = RankContentView.New(self.node_list["Rank_content_view"])
	self.qingyuan_content = QingYuanContent.New(self.node_list["QingYuanCountent"])
	-- self.rank_mingren_view = RankMingRenView.New(self.node_list["Rank_mingren_view"])

	local event_trigger = self.node_list["RotateEventTrigger"]:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
end

function RankView:ReleaseCallBack()
	RankData.Instance:SetCurTopType(RANKPANEL.GEREN)
	if self.rank_content_view ~= nil then
		self.rank_content_view:DeleteMe()
		self.rank_content_view = nil
	end
	if self.rank_mingren_view ~= nil then
		self.rank_mingren_view:DeleteMe()
		self.rank_mingren_view = nil
	end
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	self.top_type = RANKPANEL.GEREN
	self.index = 1

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.qingyuan_content then
		self.qingyuan_content:DeleteMe()
		self.qingyuan_content = nil
	end

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
end

function RankView:OpenCallBack()
	RankCtrl.Instance:SendRoleCapabilityOpera()
	self.rank_content_view:ClearRoleIDCache()
	UIScene:ChangeScene(self)
	self.rank_content_view:InitSetMoudle()
	self:FlushTabbar()
	self:Flush()
	local num = RankData.Instance:GetRemind()
	self.node_list["RemindTltle"]:SetActive(num > 0)
end

function RankView:FlushTabbar()
	local list = {}
	for k,v in pairs(self.tab_cfg) do
		if v.rank_type == self.top_type then
			if nil ~= v.func and "" ~= v.func then
				if OpenFunData.Instance:CheckIsHide(v.func) then
					table.insert(list, v)
				end
			else
				table.insert(list, v)
			end
		end
	end

	self.tabbar = self.tabbar or TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], list)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	if self.index == 1 then
		self:ChangeToIndex(self.index, true)
	else
		self:ChangeToIndex(self.index)
	end
	
end

function RankView:ShowIndexCallBack(index, index_nodes, is_jump)
	if index == RANK_TAB_TYPE.MOUNT or index == RANK_TAB_TYPE.SPIRIT then
		local callback = function()
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-340, -300, 0)}, nil)
			if self.node_list["BaseFullPanel_1"].gameObject.activeSelf then
				self.node_list["BaseFullPanel_1"]:SetActive(false)
			end
		end
		UIScene:ChangeScene(self, callback)
	else
		self.node_list["BaseFullPanel_1"]:SetActive(true)
	end
	self:ReloadView()
	if self.top_type == RANKPANEL.MINGREN then--名人堂不用点击
		self.node_list["UnderBg"]:SetActive(false)
		return
	end

	if nil ~= self.tabbar then
		self:SetCurRankIndex(index)
		if nil ~= self.tabbar.tab_button_list[index] then
			self.tabbar.tab_button_list[index]:SetHighLight(false)		--刷新高光
		end
		self.tabbar:ChangeToIndex(index, is_jump)
	end

	if self.top_type == RANKPANEL.KUAFU then
		self.node_list["UnderBg"]:SetActive(true)
		local rank_type_list = RankData.Instance:GetRankTypeList()
		self.rank_content_view:SetCurType(nil)
		self.rank_content_view:SetCurKuaFuType(rank_type_list[index])
		self.rank_content_view:SetIsNeedJump(true)
		CrossRankCtrl.Instance:SendGetPersonCrossRankList(rank_type_list[index])
	elseif self.top_type ~= RANKPANEL.QINGYUAN then
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["QingYuanCountent"]:SetActive(false)
		local rank_type_list = RankData.Instance:GetRankTypeList()
		self.rank_content_view:SetCurType(rank_type_list[index])
		self.rank_content_view:SetCurKuaFuType(nil)
		self.rank_content_view:SetIsNeedJump(true)
		RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[index])
	else
		self.node_list["UnderBg"]:SetActive(false)
		local cur_type = 0
		if RANK_TAB_TYPE.QINGYUAN == index then
			cur_type = 0
		elseif RANK_TAB_TYPE.BAOBAO == index then
			cur_type = 1
		elseif RANK_TAB_TYPE.LITTLEPET == index then
			cur_type = 2
		end
		-- if cur_type ~= 0 then
		self.qingyuan_content:OnItemClick(cur_type)
		-- end
	end

	if (self.top_type == RANKPANEL.GEREN or self.top_type == RANKPANEL.MEILI or self.top_type == RANKPANEL.KUAFU) and (self.old_top_type == self.top_type) then
		self.old_top_type = self.top_type

		local callback = function ()
			self:Flush("flush_model")
		end
		UIScene:ChangeScene(self, callback)
	end
end

function RankView:OnFlush(param_list)
	self.rank_content_view:SetActive(self.top_type == RANKPANEL.GEREN or self.top_type == RANKPANEL.MEILI or self.top_type == RANKPANEL.KUAFU)
	self.rank_content_view:Flush()

	for k, v in pairs(param_list) do
		if k == "flush_model" then
			self.rank_content_view:Flush("flush_model")
		end
	end
end

function RankView:SetCurRankIndex(index)
	if self.top_type == RANKPANEL.GEREN then
		self.cur_rank_index = index
	elseif self.top_type == RANKPANEL.MEILI then
		self.cur_meili_index = index
	elseif self.top_type == RANKPANEL.QINGYUAN then
		self.cur_qingyuan_index = index
	end
end

function RankView:SetCurIndex(index)
	self.index = index
end

function RankView:GetCurIndex()
	return self.index
end

--顶部魅力榜按钮
function RankView:TopMeiLiClick(is_click)
	if is_click then
		self.top_type = RANKPANEL.MEILI
		RankData.Instance:SetCurTopType(self.top_type)
		--if self.cur_meili_index ~= nil then
			-- self.index = 1--self.cur_meili_index
		--end
		self.index = RANK_TAB_TYPE.MEILI
		self:FlushTabbar()
		self.rank_content_view:SetIsNeedJump(true)
		local index = self.tabbar.tabindex_to_index[self.index]
		if self.index == RANK_TAB_TYPE.DATI then
			self.tabbar.tab_button_list[1]:SetHighLight(false)		--刷新高光
			self.tabbar.tab_button_list[2]:SetHighLight(true)
			self:TabDatiClick()
		else
			self.tabbar.tab_button_list[1]:SetHighLight(true)
			self.tabbar.tab_button_list[2]:SetHighLight(false)
			self:TabMeiLiClick()
		end
		self:ReloadView()
	end
	self.node_list["Rank_content_view"]:SetActive(is_click)
end

--侧魅力榜
function RankView:TabMeiLiClick()
	--if self.rank_content_view:GetCurType() ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		self.rank_content_view:SetCurType(PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM)
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM)
	--end
end

--侧答题
function RankView:TabDatiClick()
	--if self.rank_content_view:GetCurType() ~= PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		self.rank_content_view:SetCurType(PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER)
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER)
	--end
end

function RankView:TopQingLvClick(is_click)
	if is_click then
		self:ReloadView()
		self.top_type = RANKPANEL.QINGYUAN
		self.node_list["QingYuanCountent"]:SetActive(true)
		UIScene:DeleteModel()
		RankData.Instance:SetCurTopType(self.top_type)
		self.qingyuan_content:Flush()
		self.index = RANK_TAB_TYPE.QINGYUAN
		self:FlushTabbar()
		self.node_list["UnderBg"]:SetActive(false)
	else
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["QingYuanCountent"]:SetActive(false)
	end
end

	--名人堂只有一个按钮,故不需要点击
function RankView:OnMingClick(is_click)
	if is_click then
		self:ReloadView()
		self.top_type = RANKPANEL.MINGREN
		self.index = RANK_TAB_TYPE.MINGREN
		self:FlushTabbar()
		local index = self.tabbar.tabindex_to_index[self.index]
		self.tabbar.tab_button_list[index]:SetHighLight(true)
		self.tabbar.tab_button_list[index + 1]:SetHighLight(false)
		RankData.Instance:SetCurTopType(self.top_type)
		UIScene:DeleteModel()
		self.node_list["RemindTltle"]:SetActive(false)
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local mingren_cfg = RankData.Instance:GetMingrenOtherCfg()
		if next(mingren_cfg) and (role_vo.level >= mingren_cfg.level_show_1 or role_vo.level >= mingren_cfg.level_show_2) then
			PlayerPrefsUtil.SetString("remind_level" .. role_vo.role_id, role_vo.level)
			RemindManager.Instance:Fire(RemindName.Rank)
		end
		-- RemindManager.Instance:SetRemindToday(RemindName.Rank)
	end
end

function RankView:RankClick(is_click)
	if is_click then
		self.node_list["UnderBg"]:SetActive(true)
		self:ReloadView()
		self.rank_content_view:SetIsNeedJump(true)
		self.top_type = RANKPANEL.GEREN
		self.index = 1--self.cur_rank_index
		self:FlushTabbar()
		local rank_type_list = RankData.Instance:GetRankTypeList()
		self.rank_content_view:SetCurType(rank_type_list[self.index])
		RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[self.index])
		RankData.Instance:SetCurTopType(self.top_type)
	end
end

function RankView:OnKuaFuRankClick(is_click)
	if is_click then
		self.node_list["UnderBg"]:SetActive(true)
		self:ReloadView()
		self.rank_content_view:SetIsNeedJump(true)
		self.top_type = RANKPANEL.KUAFU
		self.index = RANK_TAB_TYPE.KUAFUZHANLI
		self:FlushTabbar()
		local rank_type_list = RankData.Instance:GetRankTypeList()
		self.rank_content_view:SetCurType(rank_type_list[self.index])
		CrossRankCtrl.Instance:SendGetPersonCrossRankList(rank_type_list[index])
		RankData.Instance:SetCurTopType(self.top_type)
	end
end

function RankView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function RankView:CloseCallBack()

	self.index = RANK_TAB_TYPE.ZHANLI
	self.def_index = RANK_TAB_TYPE.ZHANLI
	self.node_list["GeRenToggle"].toggle.isOn = true
	self:FlushTabbar()
	self.rank_content_view:CancelTheQuest()
	self.rank_content_view:ClearRoleIDCache()
end


function RankView:ClearRoleIDCache()
	if self.rank_content_view ~= nil then
		self.rank_content_view:ClearRoleIDCache()
	end
end


function RankView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

function RankView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		local scene_load_callback = function()
			if self.top_type ~= RANKPANEL.QINGYUAN then
				self.rank_content_view:Flush("flush_model")
			end
		end
		if self.top_type ~= RANKPANEL.QINGYUAN then
			UIScene:SetUISceneLoadCallBack(scene_load_callback)
			UIScene:ChangeScene(self)
		else
			UIScene:DeleteModel()
			UIScene:ClearWeiYanData()
		end

		--从角色查看返回
		local cur_role_info = self.rank_content_view:GetCurRoleInfo()
		local user_id = cur_role_info and cur_role_info.user_id or 0
		CheckCtrl.Instance:SendQueryRoleInfoReq(user_id)
	end
end

-- 重置上一个界面
function RankView:ReloadView()
	for k, v in pairs(self.tab_cfg) do
		if v.tab_index == self.last_index then
			if self.rank_content_view and (v.rank_type == RANKPANEL.GEREN or v.rank_type == RANKPANEL.MEILI) then
				self.rank_content_view:ReloadRankList()
			end
			-- if self.rank_mingren_view and v.rank_type == RANKPANEL.MINGREN then
			-- 	self.rank_mingren_view:ReloadRankList()
			-- end
		end
	end
end