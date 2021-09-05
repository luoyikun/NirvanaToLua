BaoJiaView = BaoJiaView or BaseClass(BaseRender)
--提示文字的Id
local des_id = 287
local ITEM_NUM = 4
local COUNT_NUM = 1
local MOVE_TIME = 0.5

function BaoJiaView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(332 , -39 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["LeftPanel"] , Vector3(-851 , -27 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["CenterPanel"] , Vector3(-87 , -188 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Node_top"] , Vector3(-46 , 418, 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["CenterPanel"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["ShenqiTips"] , Vector3(-484 , 406, 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["ShowEffect"] , Vector3(-490 , -427, 0 ) , MOVE_TIME )
end

function BaoJiaView:__init()
	--默认值
	self.select_index = 1
	self.last_index = -1
	self.select_num = ShenqiData.Instance:GetBaoJiaNumCfg()
	self.left_item_list = {}
	self.is_auto = false
	self.item_id = 0
	self.now_level = 0
	self.total_num = 0
	self.next_time = 0

	--初始化的变量
	self.node_list["BtnName"].text.text = Language.ShenQi.BaoJiaUpLevel
	--obj值
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

	self.item_cell_list = {}
	self.show_up = {}
	for i = 1, ITEM_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell_" .. i])
		self.show_up[i] = self.node_list["Btn_Improve_" .. i]
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.left_list = self.node_list["ListView"]
	local list_temp = self.left_list.list_simple_delegate
	list_temp.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCell, self)
	list_temp.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.left_list.scroller:ReloadData(0)
	self.node_list["ActivateButton"].button:AddClickListener(BindTool.Bind(self.ClickUpLevel, self))
	self.node_list["ShenqiTips"].button:AddClickListener(BindTool.Bind(self.OnClickShenqiTip, self))
	self.node_list["ShowEffect"].button:AddClickListener(BindTool.Bind(self.ClickShowEffect, self))
	self.node_list["BtnClickGo"].button:AddClickListener(BindTool.Bind(self.ClickGo, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightText"])
end

function BaoJiaView:__delete()
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
		self.item_cell_list = nil
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
end

function BaoJiaView:OnFlush()
	self:ClearEffect()
	self:FlushModel()
	self:FlushAttribute()
	self:FlushItemCell()
	self:FlushMaterialItem()
	self:FlushLeftItemHL()
	self:FlushItemCellNum()
	self:FlushItemUpState()
	self:FlushActiveRedPoint()
	self:FlushInlaySuccess()

	if not self.select_index then return end

	local suit_attr = ShenqiData.Instance:GetBaoJiaTaoZhuangAttr(self.select_index)
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

function BaoJiaView:FlushAttribute()
	local data, data_next, exp, need_exp, level = ShenqiData.Instance:GetAllBaoJiaAttributeByIndex(self.select_index)
	self.node_list["HpValue"].text.text = data.fang_yu
	self.node_list["FangyuValue"].text.text = data.gong_ji
	self.node_list["ShanbiValue"].text.text = data.max_hp

	self.node_list["UpHpValue"].text.text = data_next.fang_yu
	self.node_list["UpFangYuValue"].text.text = data_next.gong_ji
	self.node_list["UpShanBiValue"].text.text = data_next.max_hp
	local baojia_cfg = ShenqiData.Instance:GetBaojiaUpgradeCfg()
	local max_level = #baojia_cfg

	if max_level == level then
		self.node_list["NumText"].text.text = Language.ShenQi.IsMax
		self.node_list["ProgressBG"].slider.value = 1
		self.node_list["UpLevel"]:SetActive(false)
		self.node_list["BtnName"].text.text = Language.ShenQi.IsMax
		UI:SetButtonEnabled(self.node_list["ActivateButton"], false)
	else
		self.node_list["NumText"].text.text = exp .. " / " .. need_exp
		self.node_list["ProgressBG"].slider.value = ( exp / need_exp)
		self.node_list["UpLevel"]:SetActive(true)
		if self.is_auto then
			self.node_list["BtnName"].text.text = Language.ShenQi.StopUplevel
		else
			self.node_list["BtnName"].text.text = Language.ShenQi.BaoJiaUpLevel
		end
		UI:SetButtonEnabled(self.node_list["ActivateButton"], true)
	end

	local count = CommonDataManager.GetCapabilityCalculation(data)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = count
	end
	
	if 0 == self.now_level then
		self.now_level = level
	end

	if self.now_level ~= level then
		self.node_list["Effect1"]:SetActive(false)
		self.node_list["Effect1"]:SetActive(true)
		self.now_level = level
	end

	self.node_list["LevelTitle"].text.text =  string.format(Language.ShenQi.ShenQiLevel, level)
end

function BaoJiaView:FlushModel()
	--设置保甲模型
	if self.model then
		if self.select_index == self.last_index then 
			return 
		end
		self.last_index = self.select_index
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local info = {}
		info.prof = main_vo.prof % 10
		info.sex = main_vo.sex
		info.appearance = {}
		info.appearance.fashion_wuqi = main_vo.appearance.fashion_wuqi
		self.model:SetModelResInfo(info, false, true, true, false, false, true, false, false)
		local res_id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(self.select_index)
		self.model:ShowRest()
		self.model:SetRoleResid(res_id)
	end
end

--刷新下方的装备格子
function BaoJiaView:FlushItemCell()
	local data = ShenqiData.Instance:GetBaojiaInfo(self.select_index)
	if nil == data then
		return
	end

	--设置品质颜色
	for i = 1, ITEM_NUM do
		local list = ShenqiData.Instance:GetBaoJiaList(self.select_index, i, data.quality_list[i])
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
function BaoJiaView:FlushMaterialItem()
	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	if nil == shenqi_other_cfg then
		return
	end

	local baojia_uplevel_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.baojia_uplevel_stuff_id)
	self.item_cell:SetData({item_id = shenqi_other_cfg.baojia_uplevel_stuff_id})
	self.item_id = shenqi_other_cfg.baojia_uplevel_stuff_id
end

function BaoJiaView:FlushItemCellNum()
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.BaoJia)
	self.node_list["BtnClickGo"]:SetActive(shenqi_all_info.baojia_cur_image_id == self.select_index)
	self.node_list["IsUse"]:SetActive(shenqi_all_info.baojia_cur_image_id == self.select_index)
	self.node_list["BtnClickGo"]:SetActive(can_click)

	if shenqi_all_info.baojia_cur_image_id == self.select_index then
		self.node_list["BtnClickGo"]:SetActive(false)
	end

	local temp_data = shenqi_all_info.baojia_list[self.select_index]
	if nil == temp_data then
		return
	end

	local baojia_upgrade_cfg = ShenqiData.Instance:GetBaojiaUpgradeCfg()
	local cur_level = temp_data.level
	local max_level = #baojia_upgrade_cfg
	local next_level = cur_level + 1 < max_level and cur_level + 1 or max_level
	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(next_level, baojia_upgrade_cfg)
	if nil == next_jianling_cfg then
		self.node_list["ItemNum"].text.text = "- / -"
		return
	end

	if cur_level == max_level then
		self.node_list["ItemNum"]:SetActive(false)
	else
		self.node_list["ItemNum"]:SetActive(true)
	end

	local str = ""
	if 0 == num then
		str = ToColorStr(num, TEXT_COLOR.RED)
	else
		str = ToColorStr(num, TEXT_COLOR.GREEN)
	end
	self.node_list["ItemNum"].text.text = (str .. " / " .. ToColorStr(COUNT_NUM, TEXT_COLOR.GREEN))
end

function BaoJiaView:FlushLeftItemHL()
	self.left_list.scroller:RefreshActiveCellViews()
end

function BaoJiaView:FlushItemUpState()
	local baojia = ShenqiData.Instance:GetBaoJiaUpLevelList(self.select_index)
	self:ReleaseUpLevel()

	for i = 1, ITEM_NUM do
		if baojia[i] then
			self.item_cell_list[i]:ListenClick(BindTool.Bind(self.ClickItemCell, self, i))
			self.show_up[i]:SetActive(baojia[i])
		else
			self.item_cell_list[i]:ListenClick(nil)
			self.show_up[i]:SetActive(false)
		end
	end
end

function BaoJiaView:FlushLeftRedPoint()
	for k,v in pairs(self.left_item_list) do
		if v then
			v:FlushRedPoint()
		end
	end
end

function BaoJiaView:FlushActiveRedPoint()
	self.node_list["RemindRed"]:SetActive(ShenqiData.Instance:GetBaoJiaActiveByIndex(self.select_index))
end

function BaoJiaView:FlushInlaySuccess()
	local is_success = ShenqiData.Instance:GetInlaySuccess()
	if is_success then
		self.node_list["Effect2"]:SetActive(false)
		self.node_list["Effect2"]:SetActive(true)
		ShenqiData.Instance:SetInlaySuccess(false)
	end
end
------------------------点击事件begin-----------------------
-- 自动升级
function BaoJiaView:ClickUpLevel()
	self.is_auto = not self.is_auto
	local can_up = ShenqiData.Instance:IsCanUpLevel(self.select_index, ShenqiData.ChooseType.BaoJia)
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
		self.node_list["BtnName"].text.text = Language.ShenQi.StopUplevel
		self:UpdateOcne()
	else
		self.node_list["BtnName"].text.text = Language.ShenQi.BaoJiaUpLevel
	end
end

function BaoJiaView:ClickGo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.BaoJia)
	if not can_click then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenQi.NoEnoughQuality, 4)
		return
	end

	--发送出战请求
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_IMAGE, self.select_index)
end

function BaoJiaView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(des_id)
end

function BaoJiaView:ClickShowEffect()
	local cfg = ShenqiData.Instance:GetBaojiaTexiaoCfg()
	TipsCtrl.Instance:ShowShenQiEffectTips(self.select_index, cfg, ShenqiData.ChooseType.BaoJia)
end

function BaoJiaView:ClickItemCell(index)
	local data = ShenqiData.Instance:GetBaojiaInfo(self.select_index)
	if nil == data then
		return
	end
	
	local cfg = ShenqiData.Instance:GetBaojiaInlayAllCfg()
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
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_INLAY, self.select_index, index - 1, quality)
	end
end

------------------------点击事件end-----------------------

function BaoJiaView:UpdateOcne()
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.baojia_list[self.select_index].level
	local baojia_upgrade_cfg = ShenqiData.Instance:GetBaojiaUpgradeCfg()
	local max_level = #baojia_upgrade_cfg
	local next_level = cur_level + 1 < max_level and cur_level + 1 or max_level

	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(next_level, baojia_upgrade_cfg)
	
	if self.is_auto == false then
		self.is_auto = false
		self.node_list["BtnName"].text.text = Language.ShenQi.BaoJiaUpLevel
		return 
	end

	self:FlushItemCellNum()
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_UPLEVEL, self.select_index, 1, next_jianling_cfg.send_pack_num)
end

function BaoJiaView:ReleaseUpLevel()
	for k,v in pairs(self.show_up) do
		v:SetActive(false)
	end
end

function BaoJiaView:FlushUpgradeOptResult(result)
	if 0 == result then
		self.node_list["BtnName"].text.text = Language.ShenQi.BaoJiaUpLevel
		self.is_auto = false
		self:FlushLeftRedPoint()
	elseif 1 == result then
		self:UpdateOcne()
	end
end

--------------------listview刷新-----------------
function BaoJiaView:GetNumOfCell()
	return self.select_num--GetListNum(ShenqiData.Instance:GetBaojiaInlayCfg())
end

function BaoJiaView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local data_cfg = ShenqiData.Instance:GetBaoJiaCfg()
	local left_cell = self.left_item_list[cell]
	if nil == left_cell then
		left_cell = ShenQiBaoJiaLeftItem.New(cell.gameObject)
		left_cell.parent_view = self
		self.left_item_list[cell] = left_cell
	end

	local data = ShenqiData.Instance:GetBaojiaInfo(data_cfg[data_index])
	left_cell:SetIndex(data_cfg[data_index])
	left_cell:SetData(data)
end
--------------------listview刷新-----------------

--------------------内部使用交互-----------------
function BaoJiaView:GetSelectIndex()
	return self.select_index
end

function BaoJiaView:SetSelectIndex(index)
	self.select_index = index
end

function BaoJiaView:SetName(str)
	self.node_list["ShenqiTitle"].text.text = str
end

function BaoJiaView:SetLevel(level)
	self.now_level = level
end

function BaoJiaView:ClearEffect()
	self.node_list["Effect1"]:SetActive(false)
	self.node_list["Effect2"]:SetActive(false)
end
--------------------内部使用交互-----------------
--------------------左侧显示List-----------------
ShenQiBaoJiaLeftItem = ShenQiBaoJiaLeftItem or BaseClass(BaseCell)

function ShenQiBaoJiaLeftItem:__init()
	self.node_list["LeftNameItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem,self))
end

function ShenQiBaoJiaLeftItem:__delete()

end

function ShenQiBaoJiaLeftItem:OnFlush()
	if nil == self.data then
		return
	end
	local level = string.format(Language.Boss.Level, ShenqiData.Instance:GetNowBaoJiaLevelByIndex(self.index)) 
	local str = ShenqiData.Instance:GetBaojiaNameByIndex(self.index) .. level
	
	self.node_list["name"].text.text  = (ToColorStr(str, TEXT_COLOR.WHITE))
	local index = self.parent_view:GetSelectIndex()
	if index == self.index then
		self.parent_view:SetName(str)
		self.node_list["name"].text.text = (ToColorStr(str, TEXT_COLOR.YELLOW))
	end

	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetShenQiImage("shenyi_"..self.index))
	self:FlushHL(index)
	self:FlushRedPoint()
end

function ShenQiBaoJiaLeftItem:ClickItem()
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:SetLevel(0)
	self:FlushRedPoint()
	self.parent_view:Flush()
end

function ShenQiBaoJiaLeftItem:FlushHL(index)
	self.node_list["ShowHL"]:SetActive(index == self.index)
end

function ShenQiBaoJiaLeftItem:FlushRedPoint()
	local can_update = ShenqiData.Instance:GetBaoJiaUpdateRedPoint(self.index)
	local can_inlay = ShenqiData.Instance:GetIsShowBjXiangQiangRpByIndex(self.index)
	local can_active = ShenqiData.Instance:GetBaoJiaActiveByIndex(self.index)
	local is_open = ShenqiData.Instance:GetOpenBaoJia()

	if can_inlay then
		self.node_list["ShowRedPoint"]:SetActive(true)
	elseif not ShenqiData.Instance:GetBaoJiaClickList(self.index) then
		self.node_list["ShowRedPoint"]:SetActive(can_update or can_active)
	else
		self.node_list["ShowRedPoint"]:SetActive(false)
	end
end