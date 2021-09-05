-- 副本爬塔传世名剑-TowerMojieView-魔戒仙戒就是传世名剑
TowerMojieView = TowerMojieView or BaseClass(BaseView)

function TowerMojieView:__init(instance)
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/fubenview_prefab", "TowerMojieView"},
	}

	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true
	self.play_audio = true
	self.scroller_is_load = false 							-- scroller是否完成初始化
	self.jump_index = -1 									-- 用于储存下一帧要跳转到的index
end

function TowerMojieView:__delete()
end

function TowerMojieView:LoadCallBack(instance)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(1054, 614, 0)
	self.node_list["Txt"].text.text = Language.FubenTower.ChuanShiPeiJian

	self.jump_index = -1
	self.mojie_count = FuBenData.Instance:GetMoJieCount() 	--魔戒总数目
	self.cell_list = {}
	self:InitScroller()
end

function TowerMojieView:ReleaseCallBack()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = nil
	self.scroller = nil
	if self.timer_request then
		GlobalTimerQuest:CancelQuest(self.timer_request)
		self.timer_request = nil
	end
end

function TowerMojieView:OpenCallBack()
	self.all_info = FuBenData.Instance:GetMoJieAllInfo() 	--所有魔戒信息
	self.scroller.scroller:ReloadData(0)
	self:SetMotherMaskPositon()
	if self.timer_request then
		GlobalTimerQuest:CancelQuest(self.timer_request)
		self.timer_request = nil
	end
	if nil == self.timer_request then
		self.timer_request = GlobalTimerQuest:AddRunQuest(function()
			self:SetMotherMaskPositon()
		end, 0)
	end
end

function TowerMojieView:ShowIndexCallBack(index)
	if index then
		if self.scroller_is_load then 						--scroller是否已经初始化，若未初始化调用JumpPage会报错
			--延迟一帧调用
			GlobalTimerQuest:AddDelayTimer(function ()
				self:JumpPage(index)
			end, 0)
		else
			self.jump_index = index 						--储存下一帧要跳转的index，待scroller初始化完成调用跳转
		end
	end
end

function TowerMojieView:JumpPage(page)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = -1.36
	local useSpacing = false
	local scrollerTweenType = self.scroller.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.scroller.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

--初始化滚动条
function TowerMojieView:InitScroller()
	self.scroller = self.node_list["Scroller"]
	local list_view_delegate = self.scroller.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量 策划要要求显示10把（需要其他策划理解，特殊写死）
function TowerMojieView:GetNumberOfCells()
	return 10 
end

--滚动条刷新
function TowerMojieView:RefreshView(cell, data_index)
	self.scroller_is_load = true 			--标志scroller已经完成初始化
	if self.jump_index ~= -1 then 			--若有需要跳转的index
		local page = self.jump_index
		self.jump_index = -1
		self:ShowIndexCallBack(page)
	end
	local mojie_cell = self.cell_list[cell]
	if mojie_cell == nil then
		mojie_cell = TowerMojieInfo.New(cell.gameObject)
		self.cell_list[cell] = mojie_cell
	end

	local upgrade_count = FuBenData.Instance:GetUpgradeCount()
	local data = self.all_info[data_index + 1 + upgrade_count * 10]
	data.lock = not FuBenData.Instance:GetIsActiveById(data.skill_id) --该魔戒是否锁定
	mojie_cell:SetData(data)
end

function TowerMojieView:SetMotherMaskPositon()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			if v then
				local position = self.node_list["Mask"].transform.localPosition
				v:SetMaskPositon(position)
			end
		end
	end
end


--------------------------------------- 动态生成-TowerMojieInfo ----------------------------------------------
TowerMojieInfo = TowerMojieInfo or BaseClass(BaseCell)

function TowerMojieInfo:__init()

end

function TowerMojieInfo:__delete()
end


function TowerMojieInfo:OnFlush()
	if not self.data then return end

	local data = self.data
	local tmp_id = self.data.skill_id % 10 + 1
	self:SetSkillDes(tmp_id)
	self:SetIcon(tmp_id)
	self:SetName(tmp_id)
	self:SetTips()

	local tmp_id2 = math.modf(self.data.skill_id / 10)
	local tmp_id1 = math.modf(self.data.skill_id / 10)
	tmp_id1 = tmp_id1 > 0 and 3 or 2 										--策划要求显示中级跟高级特效
	self.node_list["NodeHightLevel"]:SetActive(tmp_id1 > 0)

	local roadA = "KGH_mingjian_" .. 0 .. tmp_id .. "_0" .. tmp_id1
	local roadB = "KGH_mingjian_" .. tmp_id .. "_0" .. tmp_id1
	local asset = tmp_id < 10 and roadA or roadB
	local bundle_name, asset_name = ResPath.GetUiMingJianEffect(asset)
	self.node_list["NodeHightLevel"]:ChangeAsset(bundle_name, asset_name)

	local mojie_cfg = FuBenData.Instance:GetTowerMojieCfgBySkillId(self.data.skill_id)
	local pass_level = FuBenData.Instance:GetPassLayer()
	if mojie_cfg then
		self.node_list["TxtTitle"].text.text = mojie_cfg.name
		self.node_list["Img_JiHuo"]:SetActive(pass_level < mojie_cfg.pata_layer)
	end
end

function TowerMojieInfo:SetMaskPositon(position)
	if self.node_list["Mask"] then
		self.node_list["Mask"].transform.localPosition = position
	end
end

-- 设置技能描述
function TowerMojieInfo:SetSkillDes(tmp_id)
	local params = self.data.skill_param
	self.node_list["Txt_SkillDes"].text.text = string.format(Language.FubenTower.TowerMoJieSkillDes[tmp_id], params[1], params[2], params[3], params[4])
end

-- 设置魔戒/佩剑Icon
function TowerMojieInfo:SetIcon(tmp_id)
	local bundle, asset = ResPath.GetTowerPeiJianIcon(tmp_id)
	self.node_list["Img_Icon"].raw_image:LoadSprite(bundle, asset, function()
		self.node_list["Img_Icon"].raw_image:SetNativeSize()
		end)
end

-- 设置魔戒/佩剑名称
function TowerMojieInfo:SetName(tmp_id)
	local tmp_id2 = math.modf(self.data.skill_id / 10)
	
	self.node_list["Img_Name_Icon"]:SetActive(tmp_id2 > 0)

	if tmp_id2 > 0 then
		local bundle, asset = ResPath.GetTowerMojieLittleNameIconVertical(tmp_id2)
		self.node_list["Img_Name_Icon"].image:LoadSprite(bundle, asset)
	end

	local bundle, asset = ResPath.GetTowerMojieLittleNameVertical(tmp_id)
	self.node_list["Img_Name"].image:LoadSprite(bundle, asset)
end

-- 设置通关提示
function TowerMojieInfo:SetTips()
	if self.data.upgrade == 0 and self.data.lock then
		self.node_list["Txt_MoJieGetWay"].text.text = string.format(Language.FubenTower.GetWayDec, self.data.pata_layer)
	-- elseif self.data.upgrade == 3 then
	-- 	self.node_list["Txt_MoJieGetWay"].text.text = ""
	else
		local next_layer_count = FuBenData.Instance:GetLayerCount(self.data.skill_id + 1, self.data.upgrade + 1)
		self.node_list["Txt_MoJieGetWay"].text.text = string.format(Language.FubenTower.UpgradeDec, next_layer_count)
	end
end

-- 设置特效
function TowerMojieInfo:SetEffect()
	-- body
end