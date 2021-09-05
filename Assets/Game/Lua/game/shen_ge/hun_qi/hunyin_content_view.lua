-- 异火-魂石
HunYinContentView = HunYinContentView or BaseClass(BaseRender)

local NumOfHunyinCells = 12
local LingShuMaxLevel = 100	  -- 魂石最大等级
local ShenglingInlayCount = 8
local SHOW_TEXT_TYPE = {
	XIANGQIAN = 0,
	SHENGJI = 1,
}

function HunYinContentView:OpenCallBack()
	local left_pos = self.node_list["HunqiListView"].transform.anchoredPosition
	local left_bg_pos = self.node_list["leftbg"].transform.anchoredPosition
	local right_pos = self.node_list["Right"].transform.anchoredPosition
	local bottom_pos = self.node_list["NodeBottom"].transform.anchoredPosition
	local upsuit_pos = self.node_list["NodeAllviewAndSuit"].transform.anchoredPosition
	local upexchang_pos = self.node_list["NodeResolveAndExchange"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["HunqiListView"], Vector3(left_bg_pos.x - 300, left_bg_pos.y, left_bg_pos.z))
	UITween.MoveShowPanel(self.node_list["leftbg"], Vector3(left_pos.x - 300, left_pos.y, left_pos.z))
	UITween.MoveShowPanel(self.node_list["Right"], Vector3(right_pos.x + 500, right_pos.y, right_pos.z))
	UITween.MoveShowPanel(self.node_list["NodeBottom"], Vector3(bottom_pos.x, bottom_pos.y - 300, bottom_pos.z))
	UITween.MoveShowPanel(self.node_list["NodeAllviewAndSuit"], Vector3(upsuit_pos.x, upsuit_pos.y + 200, upsuit_pos.z))
	UITween.MoveShowPanel(self.node_list["NodeResolveAndExchange"], Vector3(upexchang_pos.x, upexchang_pos.y + 200, upexchang_pos.z))
	UITween.AlpahShowPanel(self.node_list["Center"], true, nil, DG.Tweening.Ease.InExpo)

	self.show_text = SHOW_TEXT_TYPE.XIANGQIAN
	self:FlushToggleRemind()
	self:InitView(true)
end

function HunYinContentView:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtPower1"])
	self.hunqi_btn_list = {}								-- 魂器按钮
	for i = 1, HunQiData.SHENZHOU_WEAPON_COUNT do
		local hunqi_btn = HunQiBtn.New(self.node_list["hunqi_" .. i])
		hunqi_btn:SetIndex(i)
		hunqi_btn:SetClickCallBack(BindTool.Bind(self.HunQiBtnClick, self))
		table.insert(self.hunqi_btn_list, hunqi_btn)
	end

	self.shengling_inlay_list = {}
	for i = 1, ShenglingInlayCount do
		local inlay_obj = self.node_list["ShenglingList"].transform:GetChild(i - 1).gameObject
		local inlay_cell = ShenglingInlayCell.New(inlay_obj)
		inlay_cell.parent_view = self
		inlay_cell:SetIndex(i)
		inlay_cell:SetClickCallBack(BindTool.Bind(self.InlayClick, self))
		table.insert(self.shengling_inlay_list, inlay_cell)
	end

	self.node_list["BtnSuit"].button:AddClickListener(BindTool.Bind(self.OnClickSuit, self))
	self.node_list["BtnAllAttr"].button:AddClickListener(BindTool.Bind(self.OnClickAllAttr, self))
	self.node_list["BtnActivity1"].button:AddClickListener(BindTool.Bind(self.OnClickActivity1, self))
	self.node_list["BtnActivity2"].button:AddClickListener(BindTool.Bind(self.OnClickActivity2, self))
	self.node_list["BtnActivity3"].button:AddClickListener(BindTool.Bind(self.OnClickActivity3, self))
	self.node_list["BtnActivity11"].button:AddClickListener(BindTool.Bind(self.OnClickActivity1, self))
	self.node_list["BtnActivity22"].button:AddClickListener(BindTool.Bind(self.OnClickActivity2, self))
	self.node_list["BtnActivity33"].button:AddClickListener(BindTool.Bind(self.OnClickActivity3, self))
	self.node_list["BtnResolve"].button:AddClickListener(BindTool.Bind(self.ClickResolve, self))
	self.node_list["BtnZhuLing"].button:AddClickListener(BindTool.Bind(self.OnShenglingUpdate, self))
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.ClickExchange, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickRule, self))
	self.node_list["ToggleTotalInlay"].toggle:AddClickListener(BindTool.Bind(self.OnClickTotalInlay,self))
	self.node_list["ToggleUpLevel"].toggle:AddClickListener(BindTool.Bind(self.OnClickLingshuUpdate, self))
	self.node_list["YiJianZhuLingButton"].button:AddClickListener(BindTool.Bind(self.OnClickYiJian, self))

	self.node_list["BtnActivity1_bg"]:SetActive(true)
	self.node_list["BtnActivity2_bg"]:SetActive(true)
	self.node_list["BtnActivity3_bg"]:SetActive(true)
	self.node_list["BtnActivity11_bg"]:SetActive(true)
	self.node_list["BtnActivity22_bg"]:SetActive(true)
	self.node_list["BtnActivity33_bg"]:SetActive(true)

	-- 魂印背包
	self.hunyin_cell_list = {}
	local page_simple_delegate = self.node_list["HunYinCells"].page_simple_delegate
	page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

	self.hunyin_get_info = HunQiData.Instance:GetHunYinGet()
	self.getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way

	self.current_select_hunqi = 1
	self.current_selcet_shengling = 1
	self.curren_click_cell_index = -1
	self.cur_level_index = 0
	self.show_text = SHOW_TEXT_TYPE.XIANGQIAN
	self.all_hunyin_info = {}
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_select_hunqi) or {}
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
	-- 魂印ID对应魂器信息
	self.item_id_list = {}

	for k,v in pairs(self.hunyin_info) do
		table.insert(self.item_id_list, k)
	end

	self:InitView(true)
end

function HunYinContentView:__delete()
	for k,v in pairs(self.hunqi_btn_list) do
		v:DeleteMe()
	end
	self.hunqi_btn_list = {}

	for k, v in pairs(self.hunyin_cell_list) do
		v:DeleteMe()
	end
	self.hunyin_cell_list = {}

	for k,v in pairs(self.shengling_inlay_list) do
		v:DeleteMe()
	end
	self.shengling_inlay_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.HunYinContentView)
	self.fight_text = nil
	self.fight_text2 = nil
end

function HunYinContentView:InitView(is_inlay)
	if nil == is_inlay then
		return
	end

	HunQiData.Instance:SetIsInlayOrUpdate(is_inlay)
	self.node_list["NodeTotalInlayContent"]:SetActive(is_inlay)
	self.node_list["NodeHunyinUpdateContent"]:SetActive(not is_inlay)
	self.node_list["NodeResolveAndExchange"]:SetActive(not is_inlay)
	if is_inlay then
		--总览镶嵌
		self.node_list["HunYinCells"].list_view:JumpToIndex(0)
		self.node_list["ToggleTotalInlay"].toggle.isOn = true
		self.node_list["ToggleUpLevel"].toggle.isOn = false
		self:FlushModel()
		--刷新背包
		self:FlushTotalInlayBag()
		self.hunqi_name_table = HunQiData.Instance:GetHunQiNameTable()
		self:FlushHunQiBtn()
		--刷新默认魂器的圣灵信息
		self:FlushCurrentShenglingList(self.current_hunyin_list_info)
		self:FlushAttrAndActivityBtn()
	else
		--灵枢升级
		self.node_list["ToggleTotalInlay"].toggle.isOn = false
		self.node_list["ToggleUpLevel"].toggle.isOn = true
		self:OnClickLingshuUpate()
	end
	self:FlushHigh()
	self:FlushRightIcon()
end

-- 刷新右侧icon 名称 及特效
function HunYinContentView:FlushRightIcon()
	local current_hunyin = self.current_hunyin_list_info[self.current_selcet_shengling]
	local hunyin_id = current_hunyin.hunyin_id
	local hunyin_info = {}
	if 0 ~= hunyin_id then
		local lingshu_level = self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level
		local lingshu_info = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, lingshu_level)
		self.node_list["ImgInlay"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(hunyin_id)))
		self.node_list["ImgUpdate"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(hunyin_id)))

		if lingshu_info and lingshu_info.effect and lingshu_info.effect ~= 0 then
			self.node_list["EffectInlay"]:SetActive(true)
			self.node_list["EffectUpdate"]:SetActive(true)
			self.node_list["EffectInlay"]:ChangeAsset(ResPath.GetHunYinEffect(lingshu_info.effect))
			self.node_list["EffectUpdate"]:ChangeAsset(ResPath.GetHunYinEffect(lingshu_info.effect))
		else
			self.node_list["EffectInlay"]:SetActive(false)
			self.node_list["EffectUpdate"]:SetActive(false)
		end
		self.node_list["ImgInlay"]:SetActive(true)
		self.node_list["ImgUpdate"]:SetActive(true)

		if nil == self.hunyin_info[hunyin_id] then
			return
		end

		hunyin_info = self.hunyin_info[hunyin_id][1]
		--设置icon名称
		if self.node_list["NodeTotalInlayContent"].gameObject.activeSelf then
			local item_cfg = ItemData.Instance:GetItemConfig(hunyin_id)
			local txt = string.format(Language.HunQi.HunYinName2, Language.HunYinSuit["color_" .. hunyin_info.hunyin_color], item_cfg.name)
			self.node_list["TxtTitle"].text.text = txt
			self.node_list["TxtTitle1"].text.text = txt
		else
			local color_id = 0
			local left = 0
			local txt1 = string.format(Language.HunQi.HunYinName2, Language.HunYinSuit["color_" .. lingshu_info.lingshu_color], lingshu_info.name)
			self.node_list["TxtTitle"].text.text = txt1
			self.node_list["TxtTitle1"].text.text = txt1
		end
	else
		--无物品
		self.node_list["EffectInlay"]:SetActive(false)
		self.node_list["EffectUpdate"]:SetActive(false)
		self.node_list["ImgInlay"]:SetActive(false)
		self.node_list["ImgUpdate"]:SetActive(false)
		if self.node_list["NodeTotalInlayContent"].gameObject.activeSelf then
			--镶嵌界面  相应的名字
			local lingshu_level = self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level
			local lingshu_info = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, lingshu_level)
			if lingshu_info and lingshu_info.hunyin_slot then
				local txt2 = string.format(Language.HunQi.HunYinName2, Language.HunYinSuit.color_0, Language.HunQi.HunShiName[lingshu_info.hunyin_slot + 1])
				self.node_list["TxtTitle"].text.text = txt2
				self.node_list["TxtTitle1"].text.text = txt2
			end
		else
			--升级界面
			local lingshu_level = self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level
			local lingshu_info = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, lingshu_level)
			if lingshu_info and lingshu_info.name then
				local color_id = 0
				local left = 0
				local txt3 = string.format(Language.HunQi.HunYinName2, Language.HunYinSuit["color_" .. color_id], lingshu_info.name)
				self.node_list["TxtTitle"].text.text = txt3
				self.node_list["TxtTitle1"].text.text = txt3
			end
		end
	end

	local suit_attr = HunQiData.Instance:GetTaoZhuangAttr(self.current_select_hunqi)
	local cap = CommonDataManager.GetCapability(suit_attr)
	if cap > 0 then
		self.node_list["SuitCapBg"]:SetActive(true)
		self.node_list["SuitCap"].text.text = string.format(Language.Common.GaoZhanLi, cap)
		self.node_list["GaoPer"]:SetActive(false)
	else
		self.node_list["SuitCapBg"]:SetActive(false)
		self.node_list["SuitCap"].text.text = ""
		self.node_list["GaoPer"]:SetActive(true)
	end
end

-- 刷新右侧属性和活动按钮
function HunYinContentView:FlushAttrAndActivityBtn()
	local hunyin_id = self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id
	if 0 == hunyin_id then
		self.node_list["ListMiddleContain"]:SetActive(false)
		self.node_list["NodeMiddleNone"]:SetActive(true)
		self.node_list["ListMiddleContain2"]:SetActive(false)
		self.node_list["NodeMiddleNone2"]:SetActive(true)
		self:SetHunYinPower()
		self:FlushActivityBtns()
		self:FlushRightIcon()
	else
		--刷新当前魂器的属性数据
		self:FlushHunYinAttr()
		self.node_list["ListMiddleContain"]:SetActive(true)
		self.node_list["NodeMiddleNone"]:SetActive(false)
		self.node_list["ListMiddleContain2"]:SetActive(true)
		self.node_list["NodeMiddleNone2"]:SetActive(false)
	end
end

--镶嵌后刷新
function HunYinContentView:FlushView()
	--刷新魂印
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_select_hunqi)
	--刷新背包
	if self.node_list["NodeTotalInlayContent"].gameObject.activeSelf then
		self:FlushCurrentShenglingList(self.current_hunyin_list_info)
		self:FlushTotalInlayBag()
		--刷新数据
		self.node_list["ListMiddleContain"]:SetActive(true)
		self.node_list["NodeMiddleNone"]:SetActive(false)
		self.node_list["ListMiddleContain2"]:SetActive(true)
		self.node_list["NodeMiddleNone2"]:SetActive(false)
		self:FlushHunYinAttr()
		self.curren_click_cell_index = -1
		self:InitView(true)
	else
		--灵枢升级右边数据
		self:FlushLingShuInfo(true)
	end
	self:FlushHigh()
	self:FlushHunQiBtn()
	-- RemindManager.Instance:Fire(RemindName.HunYin_LingShu)
end

function HunYinContentView:OnClickTotalInlay()
	self.show_text = SHOW_TEXT_TYPE.XIANGQIAN
	self:InitView(true)
end

function HunYinContentView:OnClickLingshuUpdate()
	self.show_text = SHOW_TEXT_TYPE.SHENGJI
	self:InitView(false)
end

function HunYinContentView:OnClickYiJian()
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_AUTO_UPLEVEL_LINGSHU, self.current_select_hunqi - 1)
	local current_lingshu_info = self.current_hunyin_list_info[self.current_selcet_shengling]
	local data = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, current_lingshu_info.lingshu_level)
	local current_lingzhi = HunQiData.Instance:GetLingshuExp()
	if current_lingshu_info.lingshu_level == LingShuMaxLevel or current_lingshu_info.hunyin_id == 0 or current_lingzhi < data.up_level_exp then
		return
	end
	self:FlushStars(current_lingshu_info.lingshu_level + 1, true, self.current_selcet_shengling)
end

--获取当前魂印属性信息
function HunYinContentView:GetCurrentShengLingInfo()
	local current_hunyin_id = self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id
	local all_attr_info = {}
	if 0 ~= current_hunyin_id and nil ~= self.current_hunyin_list_info[self.current_selcet_shengling] then
		local hunyin_id = self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id

		if nil ~= self.hunyin_info[hunyin_id] then
			local current_hunyi_info = self.hunyin_info[hunyin_id][1]
			all_attr_info = CommonStruct.AttributeNoUnderline()
			all_attr_info.fangyu = current_hunyi_info.fangyu + all_attr_info.fangyu
			all_attr_info.baoji = current_hunyi_info.baoji + all_attr_info.baoji
			all_attr_info.jianren = current_hunyi_info.jianren + all_attr_info.jianren
			all_attr_info.mingzhong = current_hunyi_info.mingzhong + all_attr_info.mingzhong
			all_attr_info.maxhp = current_hunyi_info.maxhp + all_attr_info.maxhp
			all_attr_info.gongji = current_hunyi_info.gongji + all_attr_info.gongji
			all_attr_info.shanbi = current_hunyi_info.shanbi + all_attr_info.shanbi	
		end
	end
	return all_attr_info
end

--刷新魂印战力
function HunYinContentView:SetHunYinPower(lingshu_info_addper)
	--当前魂印的属性+加灵枢的加成
	if nil == lingshu_info_addper then
		lingshu_info_addper = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1,
		self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level).add_per * 0.01
	end
	local all_attr_info = self:GetCurrentShengLingInfo()
	local power = 0
	power = math.ceil(CommonDataManager.GetCapability(all_attr_info) * (1 + lingshu_info_addper))
	self.fight_text.text.text = power
end

--刷新魂印属性数据
function HunYinContentView:FlushHunYinAttr()
	--当前魂印的属性+加灵枢的加成
	local all_attr_info = self:GetCurrentShengLingInfo()
	if nil == next(all_attr_info) then
		all_attr_info = CommonStruct.AttributeNoUnderline()
	end
	local lingshu_info_addper = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1,
	self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level).add_per * 0.0001

	self.node_list["TxtAmp"].text.text = string.format(Language.HunQi.TxtAmp, lingshu_info_addper * 100) .. "%"
	self.node_list["TxtHp"].text.text = math.floor(all_attr_info.maxhp * (1 + lingshu_info_addper))
	self.node_list["TxtFangYu"].text.text = math.floor(all_attr_info.fangyu * (1 + lingshu_info_addper))
	self.node_list["TxtMingZhong"].text.text = math.floor(all_attr_info.mingzhong * (1 + lingshu_info_addper))
	self.node_list["TxtGongJi"].text.text = math.floor(all_attr_info.gongji * (1 + lingshu_info_addper))
	self.node_list["TxtBaoJi"].text.text = math.floor(all_attr_info.baoji * (1 + lingshu_info_addper))
	self.node_list["TxtJianRen"].text.text = math.floor(all_attr_info.jianren * (1 + lingshu_info_addper))
	self.node_list["TxtShanBi"].text.text = math.floor(all_attr_info.shanbi * (1 + lingshu_info_addper))

	self.node_list["amp"]:SetActive(lingshu_info_addper * 100 > 0)
	self.node_list["Text_hp"]:SetActive(all_attr_info.maxhp * (1 + lingshu_info_addper) > 0)
	self.node_list["Text_fangyu"]:SetActive(all_attr_info.fangyu * (1 + lingshu_info_addper) > 0)
	self.node_list["Text_mingzhong"]:SetActive(all_attr_info.mingzhong * (1 + lingshu_info_addper) > 0)
	self.node_list["Text_gongji"]:SetActive(all_attr_info.gongji * (1 + lingshu_info_addper) > 0)
	self.node_list["Text_baoji"]:SetActive(all_attr_info.baoji * (1 + lingshu_info_addper) > 0)
	self.node_list["Text_kangbao"]:SetActive(all_attr_info.jianren * (1 + lingshu_info_addper) > 0)
	self.node_list["Text_shanbi"]:SetActive(all_attr_info.shanbi * (1 + lingshu_info_addper) > 0)

	self:FlushRightIcon()
	--刷新战力
	self:SetHunYinPower(lingshu_info_addper)
end

function HunYinContentView:FlushActivityBtns()
	local str = self.hunyin_get_info[self.current_selcet_shengling].get_way
	local activ_1_id = tonumber(Split(str,',')[1])
	local activ_2_id = tonumber(Split(str,',')[2])
	local activ_3_id = tonumber(Split(str,',')[3])
	if nil ~= activ_1_id then
		self.activity_1_cfg = self.getway_cfg[activ_1_id]
		self.node_list["BtnActivity1"].image:LoadSprite(ResPath.GetMainUI(self.activity_1_cfg.icon))
		self.node_list["BtnActivity11"].image:LoadSprite(ResPath.GetMainUI(self.activity_1_cfg.icon))
		self.node_list["BtnActivity1"].image:SetNativeSize()
		self.node_list["BtnActivity11"].image:SetNativeSize()
		self.node_list["BtnActivity1_bg"]:SetActive(true)
		self.node_list["BtnActivity11_bg"]:SetActive(true)
	else
		self.node_list["BtnActivity1_bg"]:SetActive(false)

		self.node_list["BtnActivity11_bg"]:SetActive(false)
	end
	if nil ~= activ_2_id then
		self.activity_2_cfg = self.getway_cfg[activ_2_id]
		self.node_list["BtnActivity2"].image:LoadSprite(ResPath.GetMainUI(self.activity_2_cfg.icon))
		self.node_list["BtnActivity22"].image:LoadSprite(ResPath.GetMainUI(self.activity_2_cfg.icon))
		self.node_list["BtnActivity2"].image:SetNativeSize()
		self.node_list["BtnActivity22"].image:SetNativeSize()
		self.node_list["BtnActivity2_bg"]:SetActive(true)
		self.node_list["BtnActivity22_bg"]:SetActive(true)
	else
		self.node_list["BtnActivity22_bg"]:SetActive(false)
		self.node_list["BtnActivity2_bg"]:SetActive(false)
	end
	if nil ~= activ_3_id then
		self.activity_3_cfg = self.getway_cfg[activ_3_id]
		self.node_list["BtnActivity33"].image:LoadSprite(ResPath.GetMainUI(self.activity_3_cfg.icon))
		self.node_list["BtnActivity3"].image:LoadSprite(ResPath.GetMainUI(self.activity_3_cfg.icon))
		self.node_list["BtnActivity3_bg"]:SetActive(true)
		self.node_list["BtnActivity33_bg"]:SetActive(true)
	else
		self.node_list["BtnActivity33_bg"]:SetActive(false)
		self.node_list["BtnActivity3_bg"]:SetActive(false)
	end
end

function HunYinContentView:FlushModel()
	if self.current_select_hunqi > 0 then
		local bundle, asset = ResPath.GetYiHuoImg(self.current_select_hunqi)
		self.node_list["ImgYiHuo"].image:LoadSprite(bundle,asset)
		self.node_list["NodeEffect"]:ChangeAsset(ResPath.GetHunYinEffect(HunQiData.EFFECT_PATH[self.current_select_hunqi]))
	end
end

-- 刷新左边魂器按钮
function HunYinContentView:FlushHunQiBtn()
	for k,v in pairs(self.hunqi_name_table) do
		--设置图标
		local parma = self.hunqi_name_table[k].res_id - 17000
		local hunqi_btn = self.hunqi_btn_list[k]
		hunqi_btn.node_list["Img"].image:LoadSprite(ResPath.GetHunQiImg("HunQi_" .. parma))	

		--设置魂器属性
		local hunqi_name, _ = HunQiData.Instance:GetHunQiNameAndColorByIndex(k - 1)
		local hunqi_name_color = ITEM_COLOR[self.hunqi_name_table[k].color]
		hunqi_name = ToColorStr(hunqi_name,hunqi_name_color)
		hunqi_btn.node_list["TxtTitleName1"].text.text = hunqi_name
		hunqi_btn.node_list["TxtTitleName2"].text.text = hunqi_name

		UI:SetGraphicGrey(hunqi_btn.node_list["Img"], true)
		hunqi_btn:OnFlush()
	end
	local level = 0
	local open_level = 0
	for i = 0, HunQiData.SHENZHOU_WEAPON_COUNT - 1 do
		level = HunQiData.Instance:GetHunQiLevelByIndex(i)
		--拥有的魂器
		open_level = HunQiData.Instance:GetHunQiHunYinOpenLevel(i)
		self.hunqi_btn_list[i + 1].node_list["TxtLevel1"].text.text = Language.HunQi.LevelText .. level
		self.hunqi_btn_list[i + 1].node_list["TxtLevel"].text.text = Language.HunQi.LevelText .. level

		if open_level <= level then
			--点亮图标
			local hunqi_btn = self.hunqi_btn_list[i + 1]
			UI:SetGraphicGrey(hunqi_btn.node_list["Img"], false)
		end
	end
end

-- 刷新镶嵌背包部分
function HunYinContentView:FlushTotalInlayBag()
	self:GetAllItemInfo(self.item_id_list)
	self.node_list["HunYinCells"].list_view:Reload()
end

-- 根据魂器索引刷新对应的魂印
function HunYinContentView:FlushCurrentShenglingList(hunyin_list_info, is_reflush)
	--初始化圣灵选择索引
	is_reflush = is_reflush or false
	if is_reflush then
		self.current_selcet_shengling = 1
	end
	self.shengling_inlay_list[self.current_selcet_shengling].root_node.toggle.isOn = true

	--获取当前魂器对应的圣灵列表
	for k,v in pairs(self.shengling_inlay_list) do
		local hunyin_id = hunyin_list_info[k].hunyin_id
		local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_select_hunqi, k)
		if hunyin_id == 0 then
			v:SetData({
					solt_index = k - 1,
					hunqi_index = self.current_select_hunqi,
					is_lock = is_lock,
					inlay_or_update = self.node_list["NodeTotalInlayContent"],
					is_bind = hunyin_list_info[k].is_bind,
					hunyin_id = hunyin_id,
					lingshu_level = hunyin_list_info[k].lingshu_level,
					is_show_lock = hunyin_list_info[k].is_lock,
					})
		elseif nil ~= self.hunyin_info[hunyin_id] then
			local hunyin_data = self.hunyin_info[hunyin_id][1]
			v:SetData({
					solt_index = k - 1,
					hunqi_index = self.current_select_hunqi,
					is_lock = is_lock,
					name = hunyin_data.name,
					hunyin_color = hunyin_data.hunyin_color,
					inlay_or_update = self.node_list["NodeTotalInlayContent"],
					is_bind = hunyin_list_info[k].is_bind,
					hunyin_id = hunyin_id,
					lingshu_level = hunyin_list_info[k].lingshu_level,
					is_show_lock = hunyin_list_info[k].is_lock,
					})
		end
	end
end

-- 刷新当前魂石信息
function HunYinContentView:FlushLingShuInfo(is_update)
	--如果是魂石升级
	if not self.node_list["NodeTotalInlayContent"].gameObject.activeSelf then
		local current_lingshu_info = self.current_hunyin_list_info[self.current_selcet_shengling]
		-- if true ~= is_update then
		-- 	is_update = false
		-- end
		self:FlushStars(current_lingshu_info.lingshu_level, false, self.current_selcet_shengling)
		self:FlushHunLingShuAttr(current_lingshu_info)
		self:FlushCurrentShenglingList(self.current_hunyin_list_info)
		local is_remind_btn_zhuling = HunQiData.Instance:ShowLingShuUpdateRep(self.current_selcet_shengling)
		self.node_list["ImgRedPoint"]:SetActive(is_remind_btn_zhuling)
	end
	self:FlushRightIcon()
end

--刷新当前灵枢属性
function HunYinContentView:FlushHunLingShuAttr(current_lingshu_info)
	local data = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, current_lingshu_info.lingshu_level)
	self.node_list["TxtUpdateMingZhong"].text.text = data.mingzhong
	self.node_list["TxtUpdateGongJi"].text.text = data.gongji
	self.node_list["TxtUpdateBaoJi"].text.text = data.baoji
	self.node_list["TxtUpdateJianRen"].text.text = data.jianren
	self.node_list["TxtUpdateShanBi"].text.text = data.shanbi
	self.node_list["TxtUpdateHp"].text.text = data.maxhp
	self.node_list["TxtUpdateFangYu"].text.text = data.fangyu
	self.node_list["TxtUpdateAdd"].text.text = string.format(Language.HunQi.TxtAddper, (data.add_per * 0.01) .. "%")


	HunQiData.Instance:SetLingShuExpAndCurrentNeed(current_lingzhi,data.up_level_exp)

	local current_lingzhi = HunQiData.Instance:GetLingshuExp()
	if current_lingshu_info.lingshu_level == LingShuMaxLevel then
		self.node_list["TxtZhuLing"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnZhuLing"], false)
		self.node_list["TxtEXPCost"].text.text = Language.Common.MaxLevelDesc
	else
		self.node_list["TxtZhuLing"].text.text = Language.HunQi.ZhuLing
		UI:SetButtonEnabled(self.node_list["BtnZhuLing"], true)
		if current_lingzhi < data.up_level_exp then
			self.node_list["TxtEXPCost"].text.text = string.format(Language.HunQi.EXPCost, TEXT_COLOR.RED_4, current_lingzhi, data.up_level_exp)
		else
			self.node_list["TxtEXPCost"].text.text = string.format(Language.HunQi.EXPCost, TEXT_COLOR.GREEN_4, current_lingzhi, data.up_level_exp)
		end
	end
	self:SetLingShuPower(data)
end

function HunYinContentView:SetLingShuPower(data)
	local lingshu_attr = CommonStruct.AttributeNoUnderline()
	lingshu_attr.fangyu = data.fangyu
	lingshu_attr.baoji = data.baoji
	lingshu_attr.gongji = data.gongji
	lingshu_attr.jianren = data.jianren
	lingshu_attr.mingzhong = data.mingzhong
	lingshu_attr.maxhp = data.maxhp
	lingshu_attr.shanbi = data.shanbi
	local power = 0
	power = CommonDataManager.GetCapability(lingshu_attr)
	self.fight_text2.text.text = power
end

--刷新所有星星
function HunYinContentView:FlushStars(index, isUpdate, cur_index)
	--获取当前圣灵等级
 	if 0 ~= index then
		index = index % 5
		if index == 0 then
			index = 5
		end 
	end

	for i = 1, index do
		UI:SetGraphicGrey(self.node_list["start_" .. i], false)
	end
	for i = index + 1, 5 do
		UI:SetGraphicGrey(self.node_list["start_" .. i], true)
	end

	if 0 ~= index then
		if isUpdate then
			local bundle_name, asset_name = ResPath.GetMiscEffect("Effect_baodian")
			EffectManager.Instance:PlayAtTransform(bundle_name, asset_name, self.node_list["start_" .. index].transform, 1.0, nil, nil)
		end
	end
end

function HunYinContentView:FlushHigh()
	for i,v in ipairs(self.hunqi_btn_list) do
		if v:GetIndex() == self.current_select_hunqi then
			v:SetShowHigh(true)
		else
			v:SetShowHigh(false)
		end
	end
end

-- 刷新
function HunYinContentView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "resolve" then
			local current_lingshu_info = self.current_hunyin_list_info[self.current_selcet_shengling]
			self:FlushHunLingShuAttr(current_lingshu_info)
			self.node_list["ImgRedPoint"]:SetActive(HunQiData.Instance:ShowLingShuUpdateRep(self.current_selcet_shengling))
			for k,v in pairs(self.hunqi_btn_list) do
				v:Flush()
			end
			for k,v in pairs(self.shengling_inlay_list) do
				v:Flush()
				self:FlushToggleRemind()
			end
			self:FlushTotalInlayBag()
			self:FlushHunYinAttr()
		end
	end
end

function HunYinContentView:NumberOfCellsDel()
	return NumOfHunyinCells 
end

-- 获取背包中所有魂印配置信息
function HunYinContentView:GetAllItemInfo(item_id_list)
	self.all_hunyin_info = {}
	for k, v in pairs(item_id_list) do
		local count = ItemData.Instance:GetItemNumInBagById(v)
		local  cfg = ItemData.Instance:GetItemConfig(v)
		local solt_index = self.hunyin_info[v][1].inlay_slot + 1
		if count > 0 and solt_index == self.current_selcet_shengling then
			local group_count = math.ceil(count / 999)
			if group_count > 1 then
				for i = 1, group_count - 1 do
					table.insert(self.all_hunyin_info, {item_id = v, num = 999, is_bind = 0, color = cfg.color})
				end
				count = count % 999
				table.insert(self.all_hunyin_info, {item_id = v, num = count, is_bind = 0, color = cfg.color})
			else
				table.insert(self.all_hunyin_info, {item_id = v, num = count, is_bind = 0, color = cfg.color})
			end
		end
	end
	table.sort(self.all_hunyin_info, SortTools.KeyUpperSorter("color"))
end
-- cell刷新 每个进入一次
function HunYinContentView:CellRefreshDel(data_index, cell)
	--每次进入前清空数据
	data_index = data_index + 1

	local item_cell = self.hunyin_cell_list[cell]
	if nil == item_cell then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cell.gameObject)
		item_cell:SetToggleGroup(self.node_list["HunYinCells"].toggle_group)
		self.hunyin_cell_list[cell] = item_cell
	end
	item_cell.root_node.toggle.isOn = false
	--有数据插入数据 没数据设置nil
	if data_index % 6 == 2 then 
		data_index = data_index + 2
	elseif data_index % 6 == 3 then
		data_index = data_index - 1
	elseif data_index % 6 == 4 then
		data_index = data_index + 1
	elseif data_index % 6 == 5 then
		data_index = data_index - 2
	end
	local current_data = self.all_hunyin_info[data_index]
	item_cell:SetData(current_data)
	item_cell:SetIndex(data_index)
	if current_data then
		item_cell:ListenClick(BindTool.Bind(self.OnClickItem, self, item_cell))
		item_cell:SetInteractable(true)
		item_cell.node_list["Icon"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(current_data.item_id)))
		if current_data.num > 1 then
			item_cell.node_list["Number"]:SetActive(true)
			item_cell.node_list["Number"].text.text = current_data.num
		end
	else
		item_cell:SetInteractable(false)
	end
end

--点击背包格子
function HunYinContentView:OnClickItem(item_cell)
	local function close_call_back()
		item_cell:SetHighLight(false)
		self.curren_click_cell_index = -1 
	end
	local function replace_open_call_back()
		return self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id, item_cell:GetData().item_id,
			self.current_select_hunqi, self.current_selcet_shengling
	end
	HunQiCtrl.Instance:SetReplaceCallBack(close_call_back)
	HunQiCtrl.Instance:SetInlayCallBack(close_call_back)

	if nil == item_cell:GetData().item_id then return end
	local cell_hunyin_info = HunQiData.Instance:GetHunQiInfo()[item_cell:GetData().item_id][1]
	local bag_inlay_slot = cell_hunyin_info.inlay_slot

	for k,v in pairs(self.shengling_inlay_list) do
		local inlay_data = v:GetData()
		if inlay_data and inlay_data.solt_index == bag_inlay_slot then	
			if inlay_data.hunyin_id == 0 then
				--如果未镶嵌 --镶嵌界面
				local function open_call_back()
					return self.current_select_hunqi, bag_inlay_slot + 1, item_cell:GetData().item_id
				end
				HunQiCtrl.Instance:SetInlayOpenCallBack(open_call_back)
				ViewManager.Instance:Open(ViewName.HunYinInlayTips)			
			else
				--如果已经镶嵌	--可替换
			 	if inlay_data.hunyin_color <= cell_hunyin_info.hunyin_color then
			 		if inlay_data.hunyin_id == cell_hunyin_info.hunyin_id then
			 			SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HunYinIsSame)
			 		else
				 		local function replace_open_call_back()
		 					return inlay_data.hunyin_id, cell_hunyin_info.hunyin_id,
							self.current_select_hunqi, bag_inlay_slot + 1
						end
				 		HunQiCtrl.Instance:SetReplaceOpenCallBack(replace_open_call_back)
				 		ViewManager.Instance:Open(ViewName.HunYinReplaceTipsView)
				 	end
			 	else
			 		--id相同 相同魂印
			 		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HunYinLowLevel)
			 		item_cell.root_node.toggle.isOn = false
				end
			end
		end
	end
end

-- 圣灵镶嵌格子点击事件
function HunYinContentView:InlayClick(inlay_cell)
	local data = inlay_cell:GetData()
	if data and data.is_show_lock == 0 then
		inlay_cell.root_node.toggle.isOn = false
		return
	end

	self.current_selcet_shengling =	inlay_cell:GetIndex()
	if not inlay_cell.root_node.toggle.isOn then
		inlay_cell.root_node.toggle.isOn = true
		local is_inlay = self.node_list["NodeTotalInlayContent"].gameObject.activeSelf
		if is_inlay then
			if inlay_cell:GetData() and inlay_cell:GetData().hunyin_id > 0 then
				if self.all_hunyin_info and self.all_hunyin_info[1] and self.all_hunyin_info[1].item_id and inlay_cell:GetData().hunyin_color < self.all_hunyin_info[1].color then
					local function close_call_back()
						self.curren_click_cell_index = -1 
					end	 	
				 	local function replace_open_call_back()
						return inlay_cell:GetData().hunyin_id, self.all_hunyin_info[1].item_id, self.current_select_hunqi, self.current_selcet_shengling
					end
					HunQiCtrl.Instance:SetReplaceCallBack(close_call_back)
					HunQiCtrl.Instance:SetInlayCallBack(close_call_back)		
					HunQiCtrl.Instance:SetReplaceOpenCallBack(replace_open_call_back)

					ViewManager.Instance:Open(ViewName.HunYinReplaceTipsView)
				end
			else
				if self.all_hunyin_info and self.all_hunyin_info[1] and self.all_hunyin_info[1].item_id > 0 then
					HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HUNYIN_INLAY, self.current_select_hunqi - 1, 
					self.current_selcet_shengling - 1, ItemData.Instance:GetItemIndex(self.all_hunyin_info[1].item_id))
					return
				end
				if self.all_hunyin_info == nil or self.all_hunyin_info[1] == nil then
					SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HunQiError)
				end
			end
		end	
		return
	end
	local is_inlay = self.node_list["NodeTotalInlayContent"].gameObject.activeSelf
	-- 如果当前魂器等级不足 返回
	local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_select_hunqi, self.current_selcet_shengling)
	if is_lock then
		local des = ""
		if is_inlay then
			des = string.format(Language.HunQi.HunYinLock, need_level)
		else
			des = string.format(Language.HunQi.LingShuLock, need_level)
		end
		SysMsgCtrl.Instance:ErrorRemind(des)
	end
		
	self:FlushAttrAndActivityBtn()
	if is_inlay then
	--当前为镶嵌界面
		self:FlushTotalInlayBag()
		self:FlushHunYinAttr()
		if inlay_cell:GetData() and inlay_cell:GetData().hunyin_id > 0 and inlay_cell:GetData().hunyin_color then
			if self.all_hunyin_info and self.all_hunyin_info[1] and self.all_hunyin_info[1].item_id > 0 and self.all_hunyin_info[1].color and inlay_cell:GetData().hunyin_color < self.all_hunyin_info[1].color then
				local function close_call_back()
					self.curren_click_cell_index = -1 
				end	 	
			 	local function replace_open_call_back()
					return inlay_cell:GetData().hunyin_id, self.all_hunyin_info[1].item_id, self.current_select_hunqi, self.current_selcet_shengling
				end
				HunQiCtrl.Instance:SetReplaceCallBack(close_call_back)
				HunQiCtrl.Instance:SetInlayCallBack(close_call_back)		
				HunQiCtrl.Instance:SetReplaceOpenCallBack(replace_open_call_back)
				ViewManager.Instance:Open(ViewName.HunYinReplaceTipsView)

			end
		else
			if self.all_hunyin_info and self.all_hunyin_info[1] and self.all_hunyin_info[1].item_id > 0 then
				HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_HUNYIN_INLAY, self.current_select_hunqi - 1, 
				self.current_selcet_shengling - 1, ItemData.Instance:GetItemIndex(self.all_hunyin_info[1].item_id))
				return
			end
			if self.all_hunyin_info == nil or self.all_hunyin_info[1] == nil then
				SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HunQiError)
			end
		end			
	else
	--当前为升级界面
		self:FlushLingShuInfo()
		self.cur_level_index = 0
	end
end

-- 魂器按钮点击事件
function HunYinContentView:HunQiBtnClick(hunqi_btn)
	if not hunqi_btn.root_node.toggle.isOn then
		hunqi_btn.root_node.toggle.isOn = true
		return
	end
	
	self.current_selcet_shengling = 1
	self:FlushTotalInlayBag()
	local next_select_hunqi = self.current_select_hunqi
	self.current_select_hunqi = hunqi_btn:GetIndex()
	local hunqi_level = HunQiData.Instance:GetHunQiLevelByIndex(self.current_select_hunqi - 1)
	local hunqi_open_level = HunQiData.Instance:GetHunQiHunYinOpenLevel(self.current_select_hunqi - 1)
	local hunqi_name, _ = HunQiData.Instance:GetHunQiNameAndColorByIndex(self.current_select_hunqi - 1)
	
	if hunqi_level < hunqi_open_level then
		local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_select_hunqi, self.current_selcet_shengling)
		local des = string.format(Language.HunQi.HunYinLock, need_level)
		if need_level <= 1 then   --等级为1特殊提示
			des = string.format(Language.HunQi.ActiveOpen, hunqi_name)
		end
		SysMsgCtrl.Instance:ErrorRemind(des)
		self.current_select_hunqi = next_select_hunqi
		self:FlushHigh()
		return
	end

	HunQiData.Instance:SetCurrenSelectHunqi(self.current_select_hunqi)
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_select_hunqi)
	self:FlushCurrentShenglingList(self.current_hunyin_list_info)
	self:FlushLingShuInfo()
	self:FlushModel()
	self:FlushAttrAndActivityBtn()
	self:FlushToggleRemind()
end

-- 刷新toggle镶嵌和升级的红点、
function HunYinContentView:FlushToggleRemind()
	local is_inlay_remind = HunQiData.Instance:CalcHunYinInlayRedPoint(self.current_select_hunqi)
	self.node_list["ImgInLayRedPoint"]:SetActive(is_inlay_remind)
	local is_shengji_remind = HunQiData.Instance:CalcHunYinLingShuRedPoint(self.current_select_hunqi)
	self.node_list["ImgUpRedPoint"]:SetActive(is_shengji_remind)
end

-- 点击魂印总览
function HunYinContentView:OnClickAllAttr()
	ViewManager.Instance:Open(ViewName.HunYinAllView)
end

-- 点击魂石升级
function HunYinContentView:OnClickLingshuUpate()
	--刷新数据
	self:FlushLingShuInfo()
	local current_lingshu_info = self.current_hunyin_list_info[self.current_selcet_shengling]
	self.node_list["ImgRedPoint"]:SetActive(HunQiData.Instance:ShowLingShuUpdateRep(self.current_selcet_shengling))
	self:FlushHunQiBtn()
end

-- 点击套装
function HunYinContentView:OnClickSuit()
	local function open_call_back()
		return self.current_select_hunqi, self.current_hunyin_list_info
	end
	HunQiCtrl.Instance:SetSuitOpenCallBack(open_call_back)
	ViewManager.Instance:Open(ViewName.HunYinSuitView)
end

-- 点击活动1
function HunYinContentView:OnClickActivity1()
	local view_Name = Split(self.activity_1_cfg.open_panel, '#')[1]
	local table_index= Split(self.activity_1_cfg.open_panel, '#')[2]
	ViewManager.Instance:Open(view_Name, TabIndex[table_index])

end

-- 点击活动2
function HunYinContentView:OnClickActivity2()
	local view_Name = Split(self.activity_2_cfg.open_panel, '#')[1]
	local table_index= Split(self.activity_2_cfg.open_panel, '#')[2]
	ViewManager.Instance:Open(view_Name, TabIndex[table_index])
end

-- 点击活动3
function HunYinContentView:OnClickActivity3()
 	local view_Name = Split(self.activity_3_cfg.open_panel, '#')[1]
	local table_index= Split(self.activity_3_cfg.open_panel, '#')[2]
	ViewManager.Instance:Open(view_Name, TabIndex[table_index])
end

-- 分解
function HunYinContentView:ClickResolve()
	ViewManager.Instance:Open(ViewName.HunYinResolve)
end

function HunYinContentView:ClickExchange()
	ViewManager.Instance:Open(ViewName.HunYinExchangView)
end

-- 注灵
function HunYinContentView:OnShenglingUpdate()
	local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_select_hunqi, self.current_selcet_shengling)
	if is_lock then
		local des = string.format(Language.HunQi.LingShuLock, need_level)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end

	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_UPLEVEL_LINGSHU, 
		self.current_select_hunqi - 1, self.current_selcet_shengling - 1)

	local current_lingshu_info = self.current_hunyin_list_info[self.current_selcet_shengling]
	local data = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, current_lingshu_info.lingshu_level)
	local current_lingzhi = HunQiData.Instance:GetLingshuExp()
	if current_lingshu_info.lingshu_level == LingShuMaxLevel or current_lingshu_info.hunyin_id == 0 or current_lingzhi < data.up_level_exp then
		return
	end
	self:FlushStars(current_lingshu_info.lingshu_level + 1, true, self.current_selcet_shengling)
end

function HunYinContentView:ClickRule()
	if self.node_list["NodeTotalInlayContent"].gameObject.activeSelf then
		TipsCtrl.Instance:ShowHelpTipView(195)
	else
		TipsCtrl.Instance:ShowHelpTipView(196)
	end
end

-- 魂石镶嵌格子
-----------------------ShenglingInlayCell---------------------------
ShenglingInlayCell = ShenglingInlayCell or BaseClass(BaseCell)
function ShenglingInlayCell:__init()
	self.node_list["ImgBG"]:SetActive(true)
	self.node_list["Toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["Lock"].button:AddClickListener(BindTool.Bind(self.OnClickLock, self))
	self.lingshu_effect = 0
	self.current_data = {}
end

function ShenglingInlayCell:__delete()
	self.current_data = {}
	self.parent_view = nil
	self.lingshu_effect = nil
end

function ShenglingInlayCell:OnClickLock()
	if nil == self.current_data then return end
	local hunqi_level = HunQiData.Instance:GetHunQiLevelByIndex(self.current_data.hunqi_index - 1)
	local hunqi_open_level = HunQiData.Instance:GetHunQiHunYinOpenLevel(self.current_data.hunqi_index - 1)

	if hunqi_level < hunqi_open_level then
		local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_data.hunqi_index, self.current_data.solt_index + 1)
		local des = string.format(Language.HunQi.HunYinLock, need_level)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end

	local hunyin_list = HunQiData.Instance:GetHunYinListByIndex(self.current_data.hunqi_index)
	local front_slot = hunyin_list[self.current_data.solt_index]
	if front_slot then  -- 前一个魂槽是否存在
		local curr_slot_cfg = HunQiData.Instance:GetSoltOpenCfg(self.current_data.hunqi_index, self.current_data.solt_index)
		if front_slot.is_lock == 1 then   -- 上一个魂槽是打开的
			if curr_slot_cfg.yuanbao > 0 then
				local function ok_callback()
					HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_OPEN_HUNYIN_SLOT, self.current_data.hunqi_index - 1, self.current_data.solt_index)
				end	
				local des = string.format(Language.HunQi.OpenHunYinSlot, curr_slot_cfg.yuanbao)
				TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.ShuXingCaoYiKaiQi)
			end
		else
			local need_open_slot_cfg = HunQiData.Instance:GetLingshuAttrByIndex(self.current_data.hunqi_index - 1, curr_slot_cfg.hunchao_qianzhi, 0)
			if need_open_slot_cfg and need_open_slot_cfg.name then
 				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.HunQi.NeedOpenHunYinSlot, need_open_slot_cfg.name))
			end
		end
	else  -- 第一个魂槽
		local curr_slot_cfg = HunQiData.Instance:GetSoltOpenCfg(self.current_data.hunqi_index, self.current_data.solt_index)
		if not self.current_data.is_lock and curr_slot_cfg.yuanbao > 0 then  -- 当前魂槽是锁定的
			local function ok_callback()
				HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_OPEN_HUNYIN_SLOT, self.current_data.hunqi_index - 1, self.current_data.solt_index)
			end	
			local des = string.format(Language.HunQi.OpenHunYinSlot, curr_slot_cfg.yuanbao)
			TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.ShuXingCaoYiKaiQi)
		end
	end
end

function ShenglingInlayCell:OnFlush()
	self.current_data = self:GetData()
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_data.hunqi_index) or {}
	self.node_list["TxtInlay"].text.text = self:GetIndex()
	local is_show_lock = self.current_data.is_show_lock == 0

	local num = 0
	if self.current_data then
		for i,v in pairs(self.current_hunyin_list_info) do
			if v.is_lock ~= 0 then
				num = num + 1
			end
		end
	end
	
	if num + 1 < self:GetIndex() then
		UI:SetGraphicGrey(self.node_list["Lock"], true)
	else
		UI:SetGraphicGrey(self.node_list["Lock"], false)
	end

	self.node_list["Lock"]:SetActive(is_show_lock)
	if nil ~= self.current_data then
		--设置img
		if self.current_data.lingshu_level == 0 then
			self.node_list["Effect"]:SetActive(false)
		else
			local lingshu_level = self.current_hunyin_list_info[self:GetIndex()].lingshu_level
			local lingshu_info = HunQiData.Instance:GetLingshuAttrByIndex(self.current_data.hunqi_index - 1, self:GetIndex() - 1, lingshu_level)
			if lingshu_info and lingshu_info.effect then
				if self.lingshu_effect ~= lingshu_info.effect then
					self.lingshu_effect = lingshu_info.effect
					if lingshu_info.effect ~= 0 then
						self.node_list["Effect"]:ChangeAsset(ResPath.GetHunYinEffect(lingshu_info.effect))
					end
				end
				self.node_list["Effect"]:SetActive(lingshu_info.effect ~= 0)
			end
		end

		if self.parent_view.show_text == SHOW_TEXT_TYPE.XIANGQIAN then
			if 0 ~= self.current_data.hunyin_id then
				local color, color_end = "", "</color>"
				color = Language.HunYinSuit["color_" .. self.current_data.hunyin_color]
				local item_cfg = ItemData.Instance:GetItemConfig(self.current_data.hunyin_id)
				self.node_list["TxtName"].text.text = color .. item_cfg.name .. color_end
				self.node_list["tip"]:SetActive(false)
				self.node_list["tip2"]:SetActive(false)
				self.node_list["TxtLv"]:SetActive(true)
				self.node_list["ImgBG"]:SetActive(true)
				self.node_list["ImgBG"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.current_data.hunyin_id)))
			else
				self.node_list["TxtName"].text.text = Language.HunQi.HunShiName[self:GetIndex()]
				self.node_list["ImgBG"]:SetActive(false)
				self.node_list["tip"]:SetActive(true and not is_show_lock)
				self.node_list["tip2"]:SetActive(false)
				self.node_list["TxtLv"]:SetActive(false)
			end
		elseif self.parent_view.show_text == SHOW_TEXT_TYPE.SHENGJI then
			if 0 ~= self.current_data.hunyin_id then
				local cfg = HunQiData.Instance:GetLingshuAttrByIndex(self.parent_view.current_select_hunqi - 1, self.index - 1, self.current_data.lingshu_level)
				if cfg == nil or next(cfg) == nil then
					return
				end
				local color, color_end = "", "</color>"
				color = Language.HunYinSuit["color_" .. cfg.lingshu_color]
				self.node_list["TxtName"].text.text = color .. cfg.name .. color_end
				self.node_list["tip"]:SetActive(false)
				self.node_list["tip2"]:SetActive(false)
				self.node_list["TxtLv"]:SetActive(true)
				self.node_list["ImgBG"]:SetActive(true)
				self.node_list["ImgBG"].image:LoadSprite(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.current_data.hunyin_id)))
			else
				self.node_list["TxtName"].text.text = Language.HunQi.HunShiCaoName[self:GetIndex()]
				self.node_list["ImgBG"]:SetActive(false)
				self.node_list["tip"]:SetActive(false)
				self.node_list["tip2"]:SetActive(true and not is_show_lock)
				self.node_list["TxtLv"]:SetActive(false)
			end
		end

		--如果当前为升级界面
		if not self.current_data.inlay_or_update.gameObject.activeSelf then
			if self.current_data.is_lock or self.current_data.lingshu_level <= 0 then
				-- 如果锁了
				if self.current_data.is_lock then
					self.node_list["TxtName"].text.text = Language.HunQi.HunYin .. self:GetIndex()
					self.node_list["tip"]:SetActive(self.parent_view.show_text == SHOW_TEXT_TYPE.XIANGQIAN)
					self.node_list["TxtLv"]:SetActive(false)
				end
			else
				-- 如果激活了显示魂石名字
				local lingshu_level = self.current_hunyin_list_info[self:GetIndex()].lingshu_level
				local lingshu_info = HunQiData.Instance:GetLingshuAttrByIndex(self.current_data.hunqi_index - 1, self:GetIndex() - 1, lingshu_level)
				if lingshu_info and lingshu_info.name then
					local color_id = 0
					local left = 0
					if 0 ~= lingshu_level then
						color_id, left = math.modf((lingshu_level - 1) / 20)
						color_id = color_id + 1
					end
					self.node_list["TxtName"].text.text = Language.HunYinSuit["color_" .. color_id] .. lingshu_info.name .. "</color>"
					self.node_list["tip"]:SetActive(false)
					self.node_list["TxtLv"]:SetActive(true)
				end
			end
		end
	end
	self.node_list["TxtLv"].text.text = Language.HunQi.LevelText .. self.current_data.lingshu_level

	if self.current_data.inlay_or_update.gameObject.activeSelf then
		-- 魂石镶嵌红点
		local flag = HunQiData.Instance:CalcShenglingInlayCellInlayRedPoint(self:GetIndex(), self.current_data.hunqi_index)
		self.node_list["ImgRedPoint"]:SetActive(flag and not is_show_lock)
	else
		-- 魂石升级红点
		local flag1 = HunQiData.Instance:CalcShenglingInlayCellUpdateRedPoint(self:GetIndex(), self.current_data.hunqi_index)
		self.node_list["ImgRedPoint"]:SetActive(flag1)
	end
end

---------------------HunQiBtn----------------------------
HunQiBtn = HunQiBtn or BaseClass(BaseCell)
function HunQiBtn:__init()
	self.node_list["ToggleEquip1"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function HunQiBtn:__delete()

end

function HunQiBtn:OnFlush()
	local is_remind = HunQiData.Instance:CalcHunQiBtnRedPoint(self:GetIndex())
	self.node_list["ImgRedPoint"]:SetActive(is_remind)
end

function HunQiBtn:SetShowHigh(value)
	self.root_node.toggle.isOn = value
end
