-- 共鸣 GongMingContent
GoddessGongMingView = GoddessGongMingView or BaseClass(BaseRender)

local TWEEN_TIME = 0.5
function GoddessGongMingView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Number"])
	for i = 0, 3 do
		self["gongming_shengwu_icon" .. i] = GoddessGongMingShengWuIconItem.New(self.node_list["GoddessGongMingShengWuIcon_" .. i])
	end

	for i = 0, 28 do
		self["gongming_icon" .. i] = GoddessGongMingIconItem.New(self.node_list["GoddessGongMingIcon" .. i])
		self["gongming_icon" .. i]:SetGridId(i)
	end

	for i = 0, 28 do
		self.node_list["GoddessGongMingIcon" .. i].button:AddClickListener(BindTool.Bind(self.OnClickGongMingIcon, self, i))
	end

	self.node_list["PerfectButton"].button:AddClickListener(BindTool.Bind(self.OnClickBtnMingLing, self))
	self.node_list["BtnGongMingTip"].button:AddClickListener(BindTool.Bind(self.OnClickGongMingTip, self))
	self.node_list["Tip"].button:AddClickListener(BindTool.Bind(self.OnClickTip, self))
	self.node_list["ToggleCloseInfo"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickCloseInfo, self))

	self:InitLine()
	self.is_close_info = false
end

function GoddessGongMingView:InitLine()
	local line_cfg = GoddessData.Instance:GetGridLineAllCfg()
	for k, v in pairs(line_cfg) do
		local grid_id = tonumber(v.grid_id)
		local grid_y_id_1 = tonumber(v.grid_y_id_1)
		local grid_y_id_2 = tonumber(v.grid_y_id_2)

		if grid_y_id_1 then
			self["line" .. grid_id .. "_" .. grid_y_id_1] = GoddessGongMingLineItem.New(self.node_list["line" .. grid_id .. "_1"])
			self["line" .. grid_id .. "_" .. grid_y_id_1]:SetGridId(grid_id)
			self["line" .. grid_id .. "_" .. grid_y_id_1]:SetGridShowId(grid_y_id_1)
		end

		if grid_y_id_2 then
			self["line" .. grid_id .. "_" .. grid_y_id_2] = GoddessGongMingLineItem.New(self.node_list["line" .. grid_id .. "_2"])
			self["line" .. grid_id .. "_" .. grid_y_id_2]:SetGridId(grid_id)
			self["line" .. grid_id .. "_" .. grid_y_id_2]:SetGridShowId(grid_y_id_2)
		end
	end
end

function GoddessGongMingView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

function GoddessGongMingView:UpdataLine()
	local line_cfg = GoddessData.Instance:GetGridLineAllCfg()
	for k, v in pairs(line_cfg) do
		local grid_id = tonumber(v.grid_id)
		local grid_y_id_1 = tonumber(v.grid_y_id_1)
		local grid_y_id_2 = tonumber(v.grid_y_id_2)
		if grid_y_id_1 and self["line" .. grid_id .. "_" .. grid_y_id_1] then
			self["line" .. grid_id .. "_" .. grid_y_id_1]:SetGridShowId(grid_y_id_1)
		end
		if grid_y_id_2 and self["line" .. grid_id .. "_" .. grid_y_id_2] then
			self["line" .. grid_id .. "_" .. grid_y_id_2]:SetGridShowId(grid_y_id_2)
		end
	end
	-- 总战力显示
	local cap = CommonDataManager.GetCapability(GoddessData.Instance:GetXiannvGridTotalAttr())
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cap
	end
end

function GoddessGongMingView:OnClickCloseInfo()
	self.is_close_info = not self.is_close_info
	self:Flush()
end

function GoddessGongMingView:DeleteLine()
	local line_cfg = GoddessData.Instance:GetGridLineAllCfg()
	for k, v in pairs(line_cfg) do
		local grid_id = tonumber(v.grid_id)
		local grid_y_id_1 = tonumber(v.grid_y_id_1)
		local grid_y_id_2 = tonumber(v.grid_y_id_2)
		if grid_y_id_1 and self["line" .. grid_id .. "_" .. grid_y_id_1] then
			self["line" .. grid_id .. "_" .. grid_y_id_1]:DeleteMe()
			self["line" .. grid_id .. "_" .. grid_y_id_1] = nil
		end
		if grid_y_id_2 and self["line" .. grid_id .. "_" .. grid_y_id_2] then
			self["line" .. grid_id .. "_" .. grid_y_id_2]:DeleteMe()
			self["line" .. grid_id .. "_" .. grid_y_id_2] = nil
		end
	end
end

function GoddessGongMingView:UpdataGongMingGrid()
	for i = 0, 28 do
		if self["gongming_icon" .. i] then
			self["gongming_icon" .. i]:SetGridId(i)
		end
	end

	self:UpdataLine()
	self:UpdataGongMingLingYe()
	self:FlushRedPoint()
end

function GoddessGongMingView:__delete()
	for i = 0, 3 do
		if nil ~= self["gongming_shengwu_icon" .. i] then
			self["gongming_shengwu_icon" .. i]:DeleteMe()
			self["gongming_shengwu_icon" .. i] = nil
		end
	end

	for i = 0, 28 do
		if nil ~= self["gongming_icon" .. i] then
			self["gongming_icon" .. i]:DeleteMe()
			self["gongming_icon" .. i] = nil
		end
	end

	self:DeleteLine()
	self.show_gongming_text = nil
	self.red_point = nil
	self.toggle_close_info = nil
	self.text_cap = nil
	self.fight_text = nil
end

function GoddessGongMingView:OnFlush()
	for i = 0, 28 do
		if self["gongming_icon" .. i] then
			self["gongming_icon" .. i]:SetGridId(i)
		end
	end

	self:UpdataLine()
	self:UpdataGongMingShengWu()
	self:UpdataGongMingLingYe()
	self:FlushRedPoint()
end

function GoddessGongMingView:FlushRedPoint()
	if self.node_list["RedPoint"] ~= nil then
		self.node_list["RedPoint"]:SetActive(GoddessData.Instance:GetGongMingRed())
	end
end

function GoddessGongMingView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TopContent"], GoddessData.OtherTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], GoddessData.OtherTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], GoddessData.OtherTweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GoddessData.OtherTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["Content"], true, TWEEN_TIME, DG.Tweening.Ease.InExpo)
end

function GoddessGongMingView:UpdataGongMingShengWu()
	for i = 0, 3 do
		if nil ~= self["gongming_shengwu_icon" .. i] then
			self["gongming_shengwu_icon" .. i]:SetShengWuId(i)
		end
	end
end

function GoddessGongMingView:UpdataGongMingLingYe()
	self.node_list["TextValue"].text.text = GoddessData.Instance:GetShengWuLingYeValue()
end

function GoddessGongMingView:OnClickBtnMingLing()
   ViewManager.Instance:Open(ViewName.GoddessSearchAuraView)
end

function GoddessGongMingView:OnClickGongMingTip()
	local total_attr = GoddessData.Instance:GetXiannvGridTotalAttr()
	TipsCtrl.Instance:ShowAttrAllView(total_attr)
end

function GoddessGongMingView:OnClickGongMingIcon(index)
	if self.is_close_info then
		local level = GoddessData.Instance:GetXiannvShengwuGridLevel(index)
		local info_data = GoddessData.Instance:GetXianNvGridIconCfg(index)
		local can_click = true
		if info_data then
			can_click = GoddessData.Instance:GetXianNvGridIconIsCan(info_data)
		end

		local next_data = GoddessData.Instance:GetXianNvGongMingCfg(index, level)
		if next_data == nil then
			info_data = nil
			return
		end
		
		if next(next_data) then
			local cur_lingye = GoddessData.Instance:GetShengWuLingYeValue()
			if cur_lingye >= next_data.upgrade_need_ling and can_click then
				GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.UPGRADE_GRID, index)
			elseif can_click == false then
				TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextNoClick)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextNo)
			end
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextManJi)
		end
		info_data = nil
	else
		GoddessCtrl.Instance:OpenGoddessGongMingUpView(index)
	end
end

function GoddessGongMingView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(Language.Goddess.GoddessGongMingTip)
end

--------------------------------------------------------------------------------------
-- 共鸣icon

GoddessGongMingIconItem = GoddessGongMingIconItem or BaseClass(BaseRender)
function GoddessGongMingIconItem:__init()
	self.grid_id = 0
	self.grid_level = 1
	self.grid_color = 1
	self.effect = nil
	self.show_eff = false
	self:Flush()
end

function GoddessGongMingIconItem:__delete()
	if self.effect then
		ResMgr:Destroy(self.effect)
		self.effect = nil
	end
end

function GoddessGongMingIconItem:CreateEffect()
	if self.effect then
		self.effect:SetActive(true)
		return
	end

	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_zhishengyijie_002")
	self.async_loader = self.async_loader or AllocAsyncLoader(self, "effect_loader")
	self.async_loader:SetParent(self.root_node.transform)
	self.async_loader:Load(bundle_name, asset_name,
		function (obj)
			if IsNil(obj) then
				return
			end

			local transform = obj.transform
			self.effect = obj.gameObject
			self.effect:SetActive(self.show_eff)

			if self.grid_id == GODDRESS_XIANNV_GRID_ID_12 then
				obj.transform.localScale = Vector3(0.6, 0.6, 0.6)
			elseif self.grid_id == GODDRESS_XIANNV_GRID_ID_25 or
				self.grid_id == GODDRESS_XIANNV_GRID_ID_26 or
				self.grid_id == GODDRESS_XIANNV_GRID_ID_27 or
				self.grid_id == GODDRESS_XIANNV_GRID_ID_28 then
				obj.transform.localScale = Vector3(0.6, 0.6, 0.6)
			else
			obj.transform.localScale = Vector3(0.5, 0.5, 0.5)
			end
		end)
end

function GoddessGongMingIconItem:OnFlush()
	local info_data = GoddessData.Instance:GetXianNvGridIconCfg(self.grid_id)
	local level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_id)
	local info_cfg = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, level)
	self.grid_color = info_cfg.color

	if GoddessData.Instance:GetXianNvGridIconIsCanUp(self.grid_id) then
		self.show_eff = true
		self:CreateEffect()
	else
		if self.effect ~= nil then
			self.show_eff = false
			self.effect:SetActive(false)
		end
	end

	local img_str = "gongming_"

	if self.grid_id == GODDRESS_XIANNV_GRID_ID_12 then
		img_str = "gongming_s_"
	elseif self.grid_id == GODDRESS_XIANNV_GRID_ID_25 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_26 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_27 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_28 then
		img_str = "gongming_t_"
	else
		img_str = "gongming_"
	end

	local color = self.grid_color
	if level == 0 then
		color = 0
	end

	local asset, bundle = ResPath.GetGoddessRes(img_str .. color)
	self.node_list["Icon"].image:LoadSprite(asset, bundle .. ".png")
	self.node_list["Icon"].image:SetNativeSize()
	self.node_list["Text"].text.text = tostring(level)
	info_data = nil
end

function GoddessGongMingIconItem:UpdataView()
	self:Flush()
end

function GoddessGongMingIconItem:SetGridId(grid_id)
	self.grid_id = grid_id
	self:Flush()
end

--------------------------------------------------------------------------------
-- 圣物icon

GoddessGongMingShengWuIconItem = GoddessGongMingShengWuIconItem or BaseClass(BaseRender)
function GoddessGongMingShengWuIconItem:__init()
	self.shengwu_id = 0
	self.shengwu_level = 0

	self.model = RoleModel.New()

	self.model:SetDisplay(self.node_list["display"].ui3d_display)
	self.model_id = nil
end

function GoddessGongMingShengWuIconItem:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	self.model_id = nil
end

function GoddessGongMingShengWuIconItem:OnFlush()
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)
	if info_data == nil then
		return
	end
	if self.model then
		local need_change = false
		if self.model_id == nil then
			self.model_id = info_data.display_id
			need_change = true
		else
			if self.model_id ~= info_data.display_id then
				need_change = true
				self.model_id = info_data.display_id
			end
		end
		if need_change then
			local asset, bundle = ResPath.GetGatherModel(info_data.display_id)
			self.model:SetMainAsset(asset, bundle)
			self.model_id  = info_data.display_id
		end
	end

	self.node_list["level"].text.text = string.format(Language.Goddess.GoddessShengWuName, info_data.name, info_data.level)
end


function GoddessGongMingShengWuIconItem:SetShengWuId(index)
	self.shengwu_id = index
	self:Flush()
end

--------------------------------------------------------------------------------
-- 共鸣line icon

GoddessGongMingLineItem = GoddessGongMingLineItem or BaseClass(BaseRender)
function GoddessGongMingLineItem:__init()
	self.grid_id = 0
	self.grid_show_id = 0

	self.line_show_res = nil
	self:Flush()
end

function GoddessGongMingLineItem:__delete()
	self.line_show_res = nil
end

function GoddessGongMingLineItem:OnFlush()
	
	local now_level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_id)
	local line_data = GoddessData.Instance:GetGridLineCfg(self.grid_id)
	local now_line_show_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, now_level)

	if line_data and now_line_show_data then
		-- local asset, bundle = ResPath.GetGoddessRes("shengwu_line_" .. line_data.line_1 .. "_" .. now_line_show_data.color)
		-- self.node_list["Bg"].image:LoadSprite(asset, bundle .. ".png")

		if GoddessData.Instance:GetGridLineShowByGrid(self.grid_show_id) then
			local asset, bundle = ResPath.GetGoddessRes("shengwu_line_" .. line_data.line_2 .. "_" .. now_line_show_data.color)
			if line_data.line_2 == 3 then  --以前分了2种箭头，现在统一用一种，所以加一个判断
				local num = line_data.line_2 - 1
				asset, bundle = ResPath.GetGoddessRes("shengwu_line_" .. num .. "_" .. now_line_show_data.color)
			end

			self.node_list["Icon"].image:LoadSprite(asset, bundle .. ".png")
			self.node_list["Icon"].image:SetNativeSize()
			self.node_list["Icon"]:SetActive(true)
		else
			self.node_list["Icon"]:SetActive(false)
		end
	end
end

function GoddessGongMingLineItem:SetGridId(index)
	self.grid_id = index
end

function GoddessGongMingLineItem:SetGridShowId(index)
	self.grid_show_id = index
	self:Flush()
end
