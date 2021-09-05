JianLingView = JianLingView or BaseClass(BaseRender)
--提示文字的Id
local des_id = 287
local ITEM_NUM = 4
local COUNT_NUM = 1
local MOVE_TIME = 0.5

function JianLingView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(332 , -39 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["LeftPanel"] , Vector3(-851 , -27 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["CenterPanel"] , Vector3(-87 , -188, 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Node_top"] , Vector3(-46 , 418, 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Tips"] , Vector3(-484 , 406, 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["ShowEffect"] , Vector3(-490 , -427, 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["CenterPanel"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function JianLingView:__init()
	self.select_index = 1
	self.select_num = ShenqiData.Instance:GetShenBingNumCfg()
	self.last_index = 0
	self.left_item_list = {}
	self.is_auto = false
	self.item_id = 0
	self.total_num = 0
	self.next_time = 0
	self.now_level = 0
	self.node_list["BtnText"].text.text = Language.ShenQi.ShenQiUpLevel
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

	self.item_cell_list = {}
	self.show_up = {}

	for i = 1, ITEM_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell_" .. i])
		self.show_up[i] = self.node_list["BtnImprove" .. i]
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	local list_temp = self.node_list["ListView"].list_simple_delegate
	list_temp.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCell, self)
	list_temp.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ActivateButton"].button:AddClickListener(BindTool.Bind(self.ClickUpLevel, self))
	self.node_list["Tips"].button:AddClickListener(BindTool.Bind(self.OnClickShenqiTip, self))
	self.node_list["ShowEffect"].button:AddClickListener(BindTool.Bind(self.ClickShowEffect, self))
	self.node_list["ClickGo"].button:AddClickListener(BindTool.Bind(self.ClickGo, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["BgText"])
end

function JianLingView:__delete()

	self.fight_text = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell_list then
		for k,_ in pairs(self.item_cell_list) do
			if self.item_cell_list[k] then
				self.item_cell_list[k]:DeleteMe()
				self.item_cell_list[k] = nil
			end
		end
		self.item_cell_list = {}
	end

	if self.show_up then
		for k,_ in pairs(self.show_up) do
			if self.show_up[k] then
				self.show_up[k] = nil
			end
		end
		self.show_up = nil
	end

	if self.left_item_list then
		for k,_ in pairs(self.left_item_list) do
			if self.left_item_list[k] then
				self.left_item_list[k]:DeleteMe()
				self.left_item_list[k] = nil
			end
		end
		self.left_item_list = nil
	end

	self.is_auto = false
end

function JianLingView:OnFlush()
	self:ClearEffect()
	self:FlushModel()
	self:FlushItemCell()
	self:FlushMaterialItem()
	self:FlushLeftItemHL()
	self:FlushItemCellNum()
	self:FlushItemUpState()
	self:FlushActiveRedPoint()
	self:FlushInlaySuccess()
	self:FlushAttribute()

	if not self.select_index then return end

	local suit_attr = ShenqiData.Instance:GetJianLingTaoZhuangAttr(self.select_index)
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

function JianLingView:FlushAttribute()
	local data, data_next, exp, need_exp, data_level = ShenqiData.Instance:GetAllJiangLingAttributeByIndex(self.select_index)
	--当前属性
	self.node_list["GongJiValue"].text.text = data.gong_ji
	self.node_list["BaoJiValue"].text.text = data.max_hp
	self.node_list["MingZhongValue"].text.text = data.fang_yu

	--下级属性
	self.node_list["GongJiText"].text.text = data_next.gong_ji
	self.node_list["BaoJiText"].text.text = data_next.max_hp
	self.node_list["MingZhongText"].text.text = data_next.fang_yu
	local shenbing_upgrade_cfg = ShenqiData.Instance:GetShenbingUpgradeCfg()
	local max_level = #shenbing_upgrade_cfg
	
	if max_level == data_level then
		self.node_list["ProgressBgText"].text.text = Language.ShenQi.IsMax
		self.node_list["ProgressBg"].slider.value = 1
		self.node_list["UpLevel"]:SetActive(false)
		self.node_list["TextFalse"]:SetActive(true)
		
		UI:SetButtonEnabled(self.node_list["ActivateButton"], false)
		self.node_list["BtnText"].text.text = Language.ShenQi.IsMax
	else
		self.node_list["ProgressBgText"].text.text = exp .. " / " .. need_exp

		local need_exp = need_exp
		if tonumber(need_exp) == 0 then
			need_exp = 1
		end

		self.node_list["ProgressBg"].slider.value = (exp / need_exp)
		self.node_list["UpLevel"]:SetActive(true)
		self.node_list["TextFalse"]:SetActive(false)

		if self.is_auto then
			self.node_list["BtnText"].text.text = Language.ShenQi.StopUplevel
		else
			self.node_list["BtnText"].text.text = Language.ShenQi.ShenQiUpLevel
		end

		UI:SetButtonEnabled(self.node_list["ActivateButton"], true)
	end
	
	local count = CommonDataManager.GetCapabilityCalculation(data)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = count
	end

	if 0 == self.now_level then
		self.now_level = data_level
	end
	if self.now_level ~= data_level then
		self.node_list["LeftEffect1"]:SetActive(false)
		self.node_list["LeftEffect1"]:SetActive(true)
		self.now_level = data_level
	end

	self.node_list["LevelTitle"].text.text = string.format(Language.ShenQi.ShenQiLevel, data_level)
	
end

function JianLingView:FlushModel()
	--设置神兵模型
	if self.model then
		if self.select_index == self.last_index then 
			return 
		end

		self.last_index = self.select_index
		local res_id = ShenqiData.Instance:GetResCfgByIamgeID(self.select_index)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local main_role = Scene.Instance:GetMainRole()
		self.model:SetRoleResid(main_role:GetRoleResId())

		self.model:ShowRest()

		local prof = PlayerData.Instance:GetRoleBaseProf(main_role_vo.prof)
		if prof ~=  GameEnum.ROLE_PROF_3 then
			self.model:SetWeaponResid(res_id)
		else
			local temp = Split(res_id, ",")
			local weapon_id1 = tonumber(temp[1])
			local weapon_id2 = tonumber(temp[2])
			self.model:SetWeaponResid(weapon_id1)
			self.model:SetWeapon2Resid(weapon_id2)
		end
	end
end

--刷新下方的装备格子
function JianLingView:FlushItemCell()
	local data = ShenqiData.Instance:GetJianLingInfo(self.select_index)
	if nil == data then
		return
	end

	--设置品质颜色
	for i = 1, ITEM_NUM do
		local list = ShenqiData.Instance:GetJianLingList(self.select_index, i, data.quality_list[i])
		if nil ~= list then
			self.item_cell_list[i]:SetData({item_id = list.inlay_stuff_id})
		end

		if 0 == data.quality_list[i] then
			self.item_cell_list[i]:ShowQuality(false)
			self.item_cell_list[i]:SetIconGrayScale(true)
		else
			self.item_cell_list[i]:ShowQuality(true)
			self.item_cell_list[i]:SetIconGrayScale(false)
		end
	end
end

function JianLingView:FlushMaterialItem()
	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	if nil == shenqi_other_cfg then
		return
	end

	self.item_cell:SetData({item_id = shenqi_other_cfg.shenbing_uplevel_stuff})
	self.item_id = shenqi_other_cfg.shenbing_uplevel_stuff
end

function JianLingView:FlushItemCellNum()
	--设置item数量
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.JianLing)
	self.node_list["IsGo"]:SetActive(shenqi_all_info.shenbing_cur_image_id == self.select_index)
	self.node_list["ClickGo"]:SetActive(can_click)
	if shenqi_all_info.shenbing_cur_image_id == self.select_index then
		self.node_list["ClickGo"]:SetActive(false)
	end

	local temp_data = shenqi_all_info.shenbing_list[self.select_index]
	if nil == temp_data then
		return 
	end

	local cur_level = temp_data.level
	local shenbing_upgrade_cfg = ShenqiData.Instance:GetShenbingUpgradeCfg()
	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local max_level = #shenbing_upgrade_cfg
	local next_level = cur_level + 1 < max_level and cur_level + 1 or max_level
	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(next_level, shenbing_upgrade_cfg)	
	
	if nil == next_jianling_cfg then
		self.node_list["NeedProLabel"].text.text = "- / -"
		return 
	end

	local taotal_num = GetListNum(shenbing_upgrade_cfg)
	if cur_level == taotal_num then
		self.node_list["NeedProLabel"]:SetActive(false)
	else
		self.node_list["NeedProLabel"]:SetActive(true)
	end

	local str = ""
	if 0 == num then
		self.is_auto = false
		str = ToColorStr(num, TEXT_COLOR.RED)
	else
		str = ToColorStr(num, TEXT_COLOR.GREEN)
	end
	self.node_list["NeedProLabel"].text.text = string.format((str .. " / " .. ToColorStr(COUNT_NUM, TEXT_COLOR.GREEN)))
end

function JianLingView:FlushLeftItemHL()
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
end

function JianLingView:FlushItemUpState()
	local jianling = ShenqiData.Instance:GetJiangLingUpLevelList(self.select_index)
	self:ReleaseUpLevel()
	for i = 1, ITEM_NUM do
		if jianling[i] then
			self.item_cell_list[i]:ListenClick(BindTool.Bind(self.ClickItemCell, self, i))
			self.show_up[i]:SetActive(jianling[i])
		else
			self.item_cell_list[i]:ListenClick(nil)
			self.show_up[i]:SetActive(false)
		end
	end
end

function JianLingView:FlushLeftRedPoint()
	for k,v in pairs(self.left_item_list) do
		if v then
			v:FlushRedPoint()
		end
	end
end

function JianLingView:FlushActiveRedPoint()
	self.node_list["remindRed"]:SetActive(ShenqiData.Instance:GetJianLingActiveByIndex(self.select_index))
end

function JianLingView:FlushInlaySuccess()
	local is_success = ShenqiData.Instance:GetInlaySuccess()
	if is_success then
		self.node_list["LeftEffect2"]:SetActive(false)
		self.node_list["LeftEffect2"]:SetActive(true)
		ShenqiData.Instance:SetInlaySuccess(false)
	end
end

------------------------点击事件-----------------------
-- 自动升级
function JianLingView:ClickUpLevel()
	self.is_auto = not self.is_auto
	local can_up = ShenqiData.Instance:IsCanUpLevel(self.select_index, ShenqiData.ChooseType.JianLing)
	if not can_up then
		self.is_auto = false
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenQi.NoEnoughItem, 2)
		return
	end
	--数量为0，发送一次，服务器传回提示
	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	if 0 == num then
		self:UpdateOcne()
		return
	end

	if self.is_auto then
		self.node_list["BtnText"].text.text = Language.ShenQi.StopUplevel
		self:UpdateOcne()
	else
		self.node_list["BtnText"].text.text = Language.ShenQi.ShenQiUpLevel
	end
	
end

function JianLingView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(des_id)
end

function JianLingView:ClickShowEffect()
	local cfg = ShenqiData.Instance:GetShenbingTexiaoCfg()
	TipsCtrl.Instance:ShowShenQiEffectTips(self.select_index, cfg, ShenqiData.ChooseType.JianLing)
end

function JianLingView:ClickGo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.JianLing)
	if not can_click then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenQi.NoEnoughQuality, 2)
		return
	end
	--发送出战请求
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_USE_IMAGE, self.select_index)
end

function JianLingView:ClickItemCell(index)
	local data = ShenqiData.Instance:GetJianLingInfo(self.select_index)
	if nil == data then
		return
	end
	
	local cfg = ShenqiData.Instance:GetShenbingInlayAllCfg()
	if nil == cfg then
		return
	end

	--不设置高亮
	for k,v in pairs(self.item_cell_list) do
		if v then
			v:SetHighLight(false)
		end
	end

	local quality = ShenqiData.Instance:GetMaxQualityStuff(self.select_index, index, cfg, data)
	if quality > data.quality_list[index] then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_INLAY, self.select_index, index - 1, quality)
	end
end
------------------------点击事件-----------------------

function JianLingView:UpdateOcne()
	if self.is_auto == false then
		self.is_auto = false
		self.node_list["BtnText"].text.text = Language.ShenQi.ShenQiUpLevel
		return
	end

	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.shenbing_list[self.select_index].level
	local shenbing_upgrade_cfg = ShenqiData.Instance:GetShenbingUpgradeCfg()
	local max_level = #shenbing_upgrade_cfg
	local next_level = cur_level + 1 < max_level and cur_level + 1 or max_level
	self:FlushItemCellNum()
	if nil == shenbing_upgrade_cfg then return end

	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(next_level, shenbing_upgrade_cfg)
	if next_jianling_cfg then
		self.next_time = next_jianling_cfg.next_time

		--当前数目小于需要的 auto = false
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_UPLEVEL, self.select_index, 1, next_jianling_cfg.send_pack_num)
	end
end

function JianLingView:ReleaseUpLevel()
	for k,v in pairs(self.show_up) do
		v:SetActive(false)
	end
end

function JianLingView:FlushUpgradeOptResult(result)
	if 0 == result then
		self.node_list["BtnText"].text.text = Language.ShenQi.ShenQiUpLevel
		self.is_auto = false
		self:FlushLeftRedPoint()
	elseif 1 == result then
		self:UpdateOcne()
	end
end
--------------------listview刷新-----------------
function JianLingView:GetNumOfCell()
	return self.select_num --GetListNum(ShenqiData.Instance:GetShenbingInlayCfg())
end

function JianLingView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local data_cfg = ShenqiData.Instance:GetShenBingCfg()
	local left_cell = self.left_item_list[cell]
	if nil == left_cell then
		left_cell = ShenQiJianLingLeftItem.New(cell.gameObject)
		left_cell.parent_view = self
		self.left_item_list[cell] = left_cell
	end
	local data = ShenqiData.Instance:GetJianLingInfo(data_cfg[data_index])
	left_cell:SetIndex(data_cfg[data_index])
	left_cell:SetData(data)
end

--------------------内部使用交互-----------------
function JianLingView:GetSelectIndex()
	return self.select_index
end

function JianLingView:SetSelectIndex(index)
	self.select_index = index
end

function JianLingView:SetName(str)
	self.node_list["Title"].text.text = str
end

function JianLingView:SetLevel(level)
	self.now_level = level
end

function JianLingView:ClearEffect()
	self.node_list["LeftEffect1"]:SetActive(false)
	self.node_list["LeftEffect2"]:SetActive(false)
end

--------------------内部使用交互-----------------
--------------------左侧显示List-----------------
ShenQiJianLingLeftItem = ShenQiJianLingLeftItem or BaseClass(BaseCell)

function ShenQiJianLingLeftItem:__init()
	self.node_list["LeftNameItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem,self))
end

function ShenQiJianLingLeftItem:__delete()

end

function ShenQiJianLingLeftItem:OnFlush()
	if nil == self.data then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local level = string.format(Language.Boss.Level, ShenqiData.Instance:GetNowJiangLingLevelByIndex(self.index)) 
	local str = ShenqiData.Instance:GetJianLingNameByIndex(self.index) .. Language.ShenQi.Equip[main_role_vo.prof % 10] .. level
	self.node_list["name"].text.text = (ToColorStr(str, TEXT_COLOR.WHITE))
	local index = self.parent_view:GetSelectIndex()
	if self.index == index then
		self.parent_view:SetName(str)
		self.node_list["name"].text.text =(ToColorStr(str, TEXT_COLOR.YELLOW))
	end
	local res_id  = main_role_vo.prof % 10 .. self.index
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetShenQiImage(res_id))

	self:FlushRedPoint()
	self:FlushHL(index)
end

function ShenQiJianLingLeftItem:ClickItem()
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:SetLevel(0)
	self:FlushRedPoint()
	self.parent_view:Flush()
end

function ShenQiJianLingLeftItem:FlushHL(index)
	self.node_list["ShowHL"]:SetActive(index == self.index)
end

function ShenQiJianLingLeftItem:FlushRedPoint()
	local can_update = ShenqiData.Instance:GetJianLingUpdateRedPoint(self.index)
	local can_inlay = ShenqiData.Instance:GetIsShowSbXiangQiangRpByIndex(self.index)
	local can_active = ShenqiData.Instance:GetJianLingActiveByIndex(self.index)
	local is_open = ShenqiData.Instance:GetOpenJiangLing()

	if can_inlay then
		self.node_list["ShowRedPoint"]:SetActive(true)
	elseif not ShenqiData.Instance:GetJiangLingClickList(self.index) then
		self.node_list["ShowRedPoint"]:SetActive(can_update or can_active)
	else
		self.node_list["ShowRedPoint"]:SetActive(false)
	end
end

