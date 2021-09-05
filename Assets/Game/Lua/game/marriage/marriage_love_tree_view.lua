MarriageLoveTreeView = MarriageLoveTreeView or BaseClass(BaseRender)

local EFFECT_CD = 1
local Male_bg = "MoneyTreeBg_01.jpg"
local FeMale_bg = "MoneyTreeBg_02.jpg"

function MarriageLoveTreeView:__init(instance)
	self.effect_cd = 0
	self.now_star_level = -1

	self.node_list["BtnEnterLoverTree"].button:AddClickListener(BindTool.Bind(self.EnterLoverGarden, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickWater, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.OpenHelp, self))
end

function MarriageLoveTreeView:__delete()
	self.effect_cd = 0
	self.now_star_level = -1
end

function MarriageLoveTreeView:OpenHelp()
	TipsCtrl.Instance:ShowHelpTipView(145)
end

function MarriageLoveTreeView:EnterLoverGarden()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	if main_role.lover_uid <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotLoverDes)
		return
	end
	self.now_star_level = -1
	local tree_state = MarriageData.Instance:GetTreeState()
	tree_state = tree_state == 1 and 0 or 1
	self.init_progess = true
	MarriageCtrl.Instance:SendLoveTreeInfoReq(tree_state)
end

function MarriageLoveTreeView:ClickWater()
	local tree_state = MarriageData.Instance:GetTreeState()
	local water_by = 0
	if tree_state == 0 then
		water_by = 1
	end
	MarriageCtrl.Instance:SendLoveTreeWaterReq(0, water_by)
end

function MarriageLoveTreeView:FlushLoveTreeView()
	--获取服务端返回的相思树信息
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if not next(love_tree_info) then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local res_str = ""
	local show_red_point = false

	local tree_other_cfg = MarriageData.Instance:GetTreeCfg()
	--获取当前等级的相思树信息
	local love_tree_cfg = MarriageData.Instance:GetTreeInfo(love_tree_info.other_love_tree_star_level)

	if love_tree_info.is_self == 1 then
		self.node_list["TxtEnterLoverTree"].text.text = Language.Marriage.ToOtherLoverTreeDes
		local item_data = love_tree_cfg.male_up_star_item
		if main_vo.sex == 1 then
			res_str = Male_bg
			item_data = love_tree_cfg.female_up_star_item
		else
			res_str = FeMale_bg
		end

		local assist_free_water_time = tree_other_cfg.assist_free_water_time
		local other_item_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

		if main_vo.lover_uid <= 0 then
			show_red_point = false
		elseif love_tree_info.free_water_other < assist_free_water_time then
			show_red_point = true
		elseif other_item_num >= item_data.num then
			show_red_point = true
		end
	else
		self.node_list["TxtEnterLoverTree"].text.text = Language.Marriage.ReturnOtherLoverTreeDes
		local item_data = love_tree_cfg.female_up_star_item
		if main_vo.sex == 1 then
			item_data = love_tree_cfg.male_up_star_item
			res_str = FeMale_bg
		else
			res_str = Male_bg
		end

		local self_free_water_time = tree_other_cfg.self_free_water_time
		local self_item_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)

		if love_tree_info.free_water_self < self_free_water_time then
			show_red_point = true
		elseif self_item_num >= item_data.num then
			show_red_point = true
		end
	end
	self.node_list["RedPoint"]:SetActive(show_red_point)

	local raw_bunble, raw_asset = ResPath.GetRawImage(res_str, true)
	self.node_list["ImgLeft"].raw_image:LoadSprite(raw_bunble, raw_asset)

	local now_star_level = love_tree_info.love_tree_star_level
	--拆分大等级为阶数和星级
	local big_level, star_level = math.modf(now_star_level/10)
	star_level = string.format("%.2f", star_level * 10)
	star_level = math.floor(star_level)

	if self.now_star_level > 0 and self.now_star_level < now_star_level then
		self:PlayUpStarEffect()
	end
	self.now_star_level = now_star_level					--记录现在的等级
	for i = 0, 9 then
		if star_level > i + 1
		self.node_list["ImgStarBg" .. i]:SetActive(false)
		self.node_list["ImgStar" .. i]:SetActive(true)
	end
	local order_str = Language.Common.NumToChs[big_level] .. Language.Common.Jie
	self.node_list["TxtOrder"].text.text = order_str

	--根据等级获取相思树现有属性
	local tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)
	self.node_list["TxtHpValue"].text.text = tree_info.maxhp or 0
	self.node_list["TxtGongJiValue"].text.text = tree_info.gongji or 0
	self.node_list["TxtFangYuValue"].text.text = tree_info.fangyu or 0
	self.node_list["TxtShanBiValue"].text.text = tree_info.shanbi or 0
	self.node_list["TxtMingZhongValue"].text.text = tree_info.mingzhong or 0
	self.node_list["TxtBaoJiValue"].text.text = tree_info.baoji or 0
	self.node_list["TxtRengXingValue"].text.text = tree_info.jianren or 0
	local capability = CommonDataManager.GetCapability(tree_info)
	self.node_list["TxtFightBigPowerNum"].text.text = capability

	self:UpdateUsedItem()
	self:RefreshProgress()
end

--刷新物品使用
function MarriageLoveTreeView:UpdateUsedItem()
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if not next(love_tree_info) then
		return
	end
	local now_star_level = love_tree_info.love_tree_star_level
	local tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)

	local tree_cfg = MarriageData.Instance:GetTreeCfg()

	--获取相思树的主人（自己1, 别人0）
	local tree_state = MarriageData.Instance:GetTreeState()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local item_data = {}
	local free_times = 0
	local is_free = false
	if tree_state == 1 then
		is_free = love_tree_info.free_water_self < tree_cfg.self_free_water_time
		free_times = tree_cfg.self_free_water_time - love_tree_info.free_water_self
		--男女所消耗的物品不同
		if main_vo.sex == 1 then
			item_data = tree_info.male_up_star_item
		else
			item_data = tree_info.female_up_star_item
		end
	else
		is_free = love_tree_info.free_water_other < tree_cfg.assist_free_water_time
		free_times = tree_cfg.assist_free_water_time - love_tree_info.free_water_other
		--男女所消耗的物品不同
		if main_vo.sex == 1 then
			item_data = tree_info.female_up_star_item
		else
			item_data = tree_info.male_up_star_item
		end
	end

	self.is_free_water = is_free
	self.item_id = item_data.item_id
	if is_free then
		self.node_list["TxtTips"]:SetActive(false)
		self.node_list["TxtFree"]:SetActive(true)
		self.node_list["TxtFree"].text.text = string.format(Language.Marriage.FreeTime, free_times)
	else
		self.node_list["TxtTips"]:SetActive(true)
		self.node_list["TxtFree"]:SetActive(false)
		local item_name = ItemData.Instance:GetItemName(item_data.item_id)
		local need_num = item_data.num
		local have_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
		if need_num > have_num then
			have_num = ToColorStr(have_num, TEXT_COLOR.RED)
		else
			have_num = ToColorStr(have_num, TEXT_COLOR.GREEN)
		end
		self.node_list["TxtTips"].text.text = string.format(Language.Marriage.HaveNum, item_name, need_num, have_num)
	end
end

--刷新进度条
function MarriageLoveTreeView:RefreshProgress()
	local love_tree_info = MarriageData.Instance:GetLoveTreeInfo()
	if not next(love_tree_info) then
		return
	end
	local now_star_level = love_tree_info.love_tree_star_level
	local now_tree_info = MarriageData.Instance:GetTreeInfo(now_star_level)
	local next_tree_info = MarriageData.Instance:GetTreeInfo(now_star_level + 1)
	self.node_list["NodeProgressBar"]:SetActive(true)
	self.node_list["TxtTips"]:SetActive(true)
	self.node_list["TxtFree"]:SetActive(true)
	UI:SetButtonEnabled(self.node_list["Button"], true)
	self.node_list["TxtBtn"]:SetActive(true)
	self.node_list["TxtButton1"]:SetActive(false)
	if not next(next_tree_info) then
		self.node_list["NodeProgressBar"]:SetActive(false)
		self.node_list["TxtTips"]:SetActive(false)
		self.node_list["TxtFree"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["Button"], false)
		self.node_list["TxtBtn"]:SetActive(false)
		self.node_list["TxtButton1"]:SetActive(true)
		return
	end
	local need_exp = now_tree_info.need_exp
	local now_exp = love_tree_info.love_tree_cur_exp
	self.node_list["TxtProgressBar"].text.text = string.format("%s/%s", now_exp, need_exp)

	if self.init_progess then
		self.node_list["Slider"].slider.value = now_exp/need_exp
		self.init_progess = false
	else
		self.node_list["Slider"].slider.value = now_exp/need_exp
	end
end

--播放升级特效
function MarriageLoveTreeView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetMiscEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectObj"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end