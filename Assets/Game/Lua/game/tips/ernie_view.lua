--转转乐视图
ErnieView = ErnieView or BaseClass(BaseView)
local IconCount = 5

function ErnieView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/ernieview_prefab", "ErnieView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function ErnieView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(1010, 618, 0)
	self.node_list["Txt"].text.text = Language.ZhuanZhuanLe.Title

	self:InitScroller()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnHandUp"].button:AddClickListener(BindTool.Bind(self.ClickRollOnce, self))
	self.node_list["BtnOnce"].button:AddClickListener(BindTool.Bind(self.ClickRollOnce, self))
	self.node_list["BtnTen"].button:AddClickListener(BindTool.Bind(self.ClickRollTen, self))
	self.node_list["SkipToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.ClickSkip, self))
	self.node_list["BtnDisplay"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))

	self.roll_bar_anim = self.node_list["RollBar"]:GetComponent(typeof(UnityEngine.Animator))

	self.box_list = {}
	for i = 1, 4 do
		self.box_list[i] = {}
		self.box_list[i].obj = self.node_list["Box" .. i]
		self.box_list[i].cell = ErnieBox.New(self.box_list[i].obj)
		self.box_list[i].cell:SetIndex(i)
	end

	self.complete_list = {}
	self.is_rolling = false
	self.box_index = 1
	self.info_list = {}

	self.has_set_trigger = false
	self.need_anim_back = false
	self.node_list["SkipToggle"].toggle.isOn = ShengXiaoData.Instance:GetErnieIsStopPlayAni()
	self.price = 0

	local other_cfg = ShengXiaoData.Instance:GetOtherCfg()
	if other_cfg then
		self.price = other_cfg.ggl_consume_gold or 0
		self.node_list["TxtPriceOnce"].text.text = self.price
		self.node_list["TxtPriceTen"].text.text = self.price * 9
	end
	self.node_list["TxtFreeTime"]:SetActive(false)
	self:FlushTime()
	self:SetYiZheJumpTwo()
end

-- 寻宝钥匙，一折抢购跳转
function ErnieView:SetYiZheJumpTwo()
	local key_item_id_one = ShengXiaoData.Instance:GetReplaceOneID() or 0
	local select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_one)

	if not phase then
		local key_item_id_two = ShengXiaoData.Instance:GetReplaceTenID() or 0
		select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_two)
		if not phase then
			return
		end
	end

	local info = DisCountData.Instance:GetDiscountInfoByType(phase, true)
	if not info then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.level < info.active_level then
		return
	end

	if info.close_timestamp then
		if info.close_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
			local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
				end)
				self:StartCountDown(info, node_list)
			end
			CommonDataManager.SetYiZheBtnJumpTwo(self, self.node_list["BtnYiZheJumpTwo"], callback)
		end
	end
end

-- 寻宝钥匙，一折抢购跳转
function ErnieView:StartCountDown(data, node_list)
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

-- 寻宝钥匙，一折抢购跳转
function ErnieView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function ErnieView:OpenCallBack()
	if self.need_anim_back then
		self.roll_bar_anim:SetTrigger("Back")
		self.need_anim_back = false
	end
	self:FlushShowFree()
end

function ErnieView:CloseCallBack()
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.ErnieView)
end

function ErnieView:ReleaseCallBack()
	for k,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end
	self.scroller_list = {}

	for k,v in pairs(self.box_list) do
		v.cell:DeleteMe()
	end
	self.box_list = {}

	self.roll_bar_anim = nil

	if self.is_rolling then
		if ItemData.Instance then
			ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_ZODIAC_GGL_REWARD)
		end
	end
	self:RemoveCountDown()
	self:StopCountDown()
end

-- 转一次
function ErnieView:ClickRollOnce()
	if self.is_rolling then
		return
	end

	local function func()
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 0)
	end
	local is_free = ShengXiaoData.Instance:ErnieRedPointOne()
	if is_free then
		func()
	else
		local str = string.format(Language.Tip.ChouJiangOneTips, self.price)
		TipsCtrl.Instance:ShowCommonTip(func, nil, str, nil, nil, true, nil, "ernie_roll_1", 
				nil, nil, nil, true, nil, nil, Language.Common.Cancel)
	end
end

-- 转十次
function ErnieView:ClickRollTen()
	if self.is_rolling then
		return
	end
	local function func()
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 1)
	end
	local is_free = ShengXiaoData.Instance:ErnieRedPointTen()
	if is_free then
		func()
	else
		local str = string.format(Language.Tip.ChouJiangTenTips, self.price * 9)
		TipsCtrl.Instance:ShowCommonTip(func, nil, str, nil, nil, true, nil, "ernie_roll_10", 
			nil, nil, nil, true, nil, nil, Language.Common.Cancel)
	end
end

-- 是否屏蔽动画
function ErnieView:ClickSkip(switch)
	ShengXiaoData.Instance:SetErnieIsStopPlayAni(switch)
end

function ErnieView:InitScroller()
	self.scroller_list = {}
	for i = 1, 3 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self.node_list["Scroller" .. i]
		self.scroller_list[i].cell = ErnieScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
	end
end

-- 转动完毕回调
function ErnieView:RollComplete(index)
	self.complete_list[index] = true
	if self:CheckComplete() then
		self.complete_list = {}
		if self.is_real_open then
			for i = 1, 3 do
				self:EffectComplete(i)
			end
		else
			self:ShowReward()
		end
	end
end

-- 特效播放完毕回调
function ErnieView:EffectComplete(index)
	self.complete_list[index] = true
	if self:CheckComplete() then
		self.complete_list = {}
		self:ShowReward()
	end
end

-- 显示奖励面板
function ErnieView:ShowReward()
	if self.has_set_trigger then
		self.roll_bar_anim:SetTrigger("Back")
		self.has_set_trigger = false
		if not self.is_real_open then
			self.need_anim_back = true
		end
	end
	
	self.is_rolling = false
	--self.box_list[self.box_index].cell:OpenBox()
	ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_ZODIAC_GGL_REWARD)

	if self.is_real_open then
		if #self.info_list <= 1 then
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1)
		else
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10)
		end
	end
end

-- 检查转盘是否全部滚动完毕
function ErnieView:CheckComplete()
	local flag = true
	for i = 1, 3 do
		if not self.complete_list[i] then
			flag = false
			break
		end
	end
	return flag
end

function ErnieView:OnFlush(param)
	local combine_type = nil
	local random_list = {}
	local result_index_list = nil
	if param then
		result_index_list = param.combine_type																																--傻逼策划非要加一个排列组合表在客户端这边让客户端自己取随机排列,就因为服务器懒得看之前逻辑
	end
	local funny_trun_combine = ShengXiaoData.Instance:GetFunnyTrunCombine()
	if funny_trun_combine then
		for k, v in pairs(funny_trun_combine) do
			if v.zuhe_shunxu then
				random_list[k] = Split(v.zuhe_shunxu, "|")
			end
		end
	end
	if result_index_list then
		combine_type = {}
		for k, v in pairs(result_index_list) do
			local result_index = math.floor(math.random(1, #random_list[v]))
			local temp_radom = random_list[v]
			combine_type[k] = tonumber(temp_radom[result_index])
		end
	end
	param.combine_type = combine_type
	for k,v in pairs(param) do
		if k == "combine_type" then
			self:StartRoll(v)
		end
	end
	self:FlushTime()
	self:FlushShowFree()
end

-- 开始转动
function ErnieView:StartRoll(info_list)
	self.info_list = info_list
	for k,v in pairs(self.box_list) do
		v.cell:ResetBox()
	end

	local first_combine_type = info_list[1]
	if first_combine_type then
		local cfg = ShengXiaoData.Instance:GetRollInfoByType(first_combine_type)
		if cfg then
			self.box_index = cfg.box_index
		end
	end
	-- 直接显示结果
	if self.node_list["SkipToggle"].toggle.isOn then
		self:ShowReward()
	else
		self.is_rolling = true
		local index1 = 1
		local index2 = 1
		local index3 = 1
		self.box_index = 1
		-- local first_combine_type = info_list[1]
		if first_combine_type then
			index1 = first_combine_type % 10 + 1
			first_combine_type = math.floor(first_combine_type / 10)
			index2 = first_combine_type % 10 + 1
			first_combine_type = math.floor(first_combine_type / 10)
			index3 = first_combine_type + 1
		end
		self.scroller_list[1].cell:StartScoller(3, index1)
		self.scroller_list[2].cell:StartScoller(4, index2)
		self.scroller_list[3].cell:StartScoller(5, index3)
		self.roll_bar_anim:SetTrigger("Roll")
		self.has_set_trigger = true
		self.complete_list = {}
	end
end

function ErnieView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(171)
end

function ErnieView:FlushTime()
	self:RemoveCountDown()
	self.node_list["TxtFreeTime"].text.text = ""
	local rest_free_count = ShengXiaoData.Instance:GetRestFreeCount()
	if rest_free_count > 0 then
		local rest_time = ShengXiaoData.Instance:GetNextFreeErnieTime() - TimeCtrl.Instance:GetServerTime()
		if rest_time > 0 then
			self:UpdateTime()
			self.count_down = CountDown.Instance:AddCountDown(rest_time + 1, 0.5, BindTool.Bind(self.UpdateTime, self))
		end
	end
end

function ErnieView:UpdateTime()
	local rest_time = ShengXiaoData.Instance:GetNextFreeErnieTime() - TimeCtrl.Instance:GetServerTime()
	local time_str = ""
	if rest_time > 0 then
		time_str = string.format(Language.Treasure.ShowFreeTime, TimeUtil.FormatSecond(rest_time))
	else
		self:FlushShowFree()
	end
	self.node_list["TxtFreeTime"].text.text = time_str
end

function ErnieView:FlushShowFree()
	local flag = ShengXiaoData.Instance:IsErnieCanFree()
	local red_one = ShengXiaoData.Instance:ErnieRedPointOne()
	local red_ten = ShengXiaoData.Instance:ErnieRedPointTen()
	local replacement_id = ShengXiaoData.Instance:GetReplaceOneID()
	local item_count_one = ItemData.Instance:GetItemNumInBagById(replacement_id)
	local open_box_30_use_itemid = ShengXiaoData.Instance:GetReplaceTenID()
	local item_count_Ten = ItemData.Instance:GetItemNumInBagById(open_box_30_use_itemid)
	self.node_list["ImgRedPoint"]:SetActive(red_one)
	self.node_list["ItemNumOne"]:SetActive(red_one and (not flag))
	self.node_list["ItemNumTen"]:SetActive(red_ten)
	self.node_list["ImgRedPointTen"]:SetActive(red_ten)
	self.node_list["TxtShowFree"]:SetActive(flag)
	self.node_list["ImgGold"]:SetActive(not red_one)
	self.node_list["ImgGoldTen"]:SetActive(not red_ten)
	self.node_list["TextKeyNumOne"].text.text = "X " .. item_count_one
	self.node_list["TextKeyNumTen"].text.text = "X " .. item_count_Ten
	self.node_list["Effect"]:SetActive(flag)
end

function ErnieView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

-----------------------------------------------Scroller--------------------------------------------
ErnieScroller = ErnieScroller or BaseClass(BaseCell)
-- 每个格子的高度
local cell_hight = 80
-- 每个格子之间的间距
local distance = 30
-- DoTween移动的距离(越大表示转动速度越快)
local movement_distance = 149

function ErnieScroller:__init(instance)

	if instance == nil then
		return
	end
	
	local size = cell_hight + distance
	self.node_list["DoTween"].transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = cell_hight - (original_hight - (cell_hight + 2 * distance)) / 2
	local hight = (IconCount + 2) * size + (cell_hight - offset * 2)
	self.percent = size / (hight - original_hight)
	self.node_list["Rect"].rect.sizeDelta = Vector2(self.node_list["Rect"].rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/ernieview_prefab", "Icon", nil, function(prefab)
		if nil == prefab then
			return
		end
		for i = 1, IconCount + 3 do
			local obj = U3DObject(ResMgr:Instantiate(prefab))
			obj.transform:SetParent(self.node_list["Rect"].transform, false)
			obj.transform.localPosition = Vector3(0, -(i - 1) * size + offset, 0)
			local res_id = i - 1
			if res_id > IconCount then
				res_id = res_id % IconCount
			end
			if res_id == 0 then
				res_id = IconCount
			end
			local asset, bundle = ResPath.GetErnieImage(res_id)
			local icon = obj.transform:FindHard("Image")
			icon = U3DObject(icon, icon.transform, self)
			icon.image:LoadSprite(asset,bundle)
		end
	end)
	self.target_x = 0
	self.target = 1
end

function ErnieScroller:__delete()
	self:RemoveCountDown()
end

function ErnieScroller:OnValueChange(value)
	local x = value.y
end

function ErnieScroller:StartScoller(time, target)
	self.node_list["DoTween"].transform.position = Vector3(self.target - 1, 0, 0)
	self.target = target or 1
	if self.target == 1 then
		self.target = IconCount + 1
	end
	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	local tween = self.node_list["DoTween"].transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.01, BindTool.Bind(self.UpdateTime, self))
end

function ErnieScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.node_list["DoTween"].transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)

	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self.index)
		end
	end
end

function ErnieScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function ErnieScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function ErnieScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

-----------------------------------------------ErnieBox--------------------------------------------
ErnieBox = ErnieBox or BaseClass(BaseCell)
function ErnieBox:__init(instance)
	if nil == instance then
		return
	end
	self.index = 0
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
end

function ErnieBox:__delete()
	if self.item_cell then 
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ErnieBox:OpenBox()
	local asset, bundle = ResPath.GetShengXiaoBoxIcon(self.index, true)
	self.node_list["CellBox"].image:LoadSprite(asset, bundle, function()
		self.node_list["CellBox"].image:SetNativeSize()
		self.node_list["CellBox"].transform.localScale = Vector3(0.5, 0.5, 1)
	end)
end

function ErnieBox:ResetBox()
	local data_cfg = ShengXiaoData.Instance:GetCfgByBoxIndex(self.index)
	if next(data_cfg) then 
		local item_data = {}
		item_data.item_id = data_cfg.reward_item[0].item_id
		self.item_cell:SetData(item_data)
		local add_one = data_cfg.display_combination1 + 1
		local add_two = data_cfg.display_combination2 + 1
		local add_three = data_cfg.display_combination3 + 1
		self.node_list["add1"].image:LoadSprite(ResPath.GetErnieImage(add_one))
		self.node_list["add2"].image:LoadSprite(ResPath.GetErnieImage(add_two))
		self.node_list["add3"].image:LoadSprite(ResPath.GetErnieImage(add_three))
	end
	self.node_list["Txt"].text.text = Language.ShengXiao.BaoXiang[self.index]
	-- local asset, bundle = ResPath.GetShengXiaoBoxIcon(self.index, false)
	-- self.node_list["CellBox"].image:LoadSprite(asset, bundle, function()
	-- 	self.node_list["CellBox"].image:SetNativeSize()
	-- 	self.node_list["CellBox"].transform.localScale = Vector3(0.8, 0.8, 1)
	-- end)
end

function ErnieBox:SetIndex(index)
	self.index = index
	self:ResetBox()
end