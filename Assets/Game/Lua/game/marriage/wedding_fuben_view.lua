WeddingFuBenView = WeddingFuBenView or BaseClass(BaseView)

--撒花特效播放时间
local EFFECT_TIME = 3
local ITEM_ID = {
	[1] = 23878,			--真情烟花
	[2] = 23879,			--幸福鞭炮
} 
function WeddingFuBenView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "WeddingFuBenView"}}
	self.cd_time_count = 0
	self.flower_effect_list = {}
	self.active_close = false
	self.fight_info_view = true
	self.is_auto_buy1 = false
	self.is_auto_buy2 = false
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
end

function WeddingFuBenView:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v.item_cell:DeleteMe()
	end
	self.item_list = {}

	self:RemoveCountDown()
end

function WeddingFuBenView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function WeddingFuBenView:LoadCallBack()
	-- self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.OnClicBless, self))	祝福
	-- self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.OnClickScatterFlower, self))	撒花
	self.node_list["BtnFlowerBall"].button:AddClickListener(BindTool.Bind(self.OnClickScatterFlowerBall, self))
	self.node_list["BtnInvite"].button:AddClickListener(BindTool.Bind(self.OnClickInvite, self))
	self.node_list["BtnBride"].button:AddClickListener(BindTool.Bind(self.OnClickBaiTang,self))
	self.node_list["BtnZhuFu"].button:AddClickListener(BindTool.Bind(self.OnClickZhufu,self))
	self.node_list["UseYanhua"].button:AddClickListener(BindTool.Bind(self.BtnUseYanhua,self))
	self.node_list["UseBianpiao"].button:AddClickListener(BindTool.Bind(self.BtnUseBianpiao,self))
	self.node_list["TxtCDTime"].text.text = ""
	-- self.node_list["Countdown"].text.text = TimeUtil.FormatSecond(MarriageData.Instance:GetHunYanTime(), 4) 

	self.item_list = {}
	for i = 1, 2 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		item_cell:SetData(nil)
		table.insert(self.item_list, {item_obj = self.node_list["Item" .. i], item_cell = item_cell})
	end

	self.cd_time_max = MarriageData.Instance:GetActivityCfg().paohuaqiu_cd_s

	self.item_id_list = MarriageData.Instance:GetBlessHunYanItemList()
end

--拜堂
function WeddingFuBenView:OnClickBaiTang()
	local other_uid = MarriageData.Instance:GetMarryOhterUser()
	local info = MarriageData.Instance:GetWeddingRoleInfo()
	
	if other_uid ~= nil and next(info) ~= nil then
		if info.is_baitang == 2 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.AgreeBaitang)
			return
		end
		if Scene.Instance:GetObjByUId(other_uid) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.WaitAgreeBaitang)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NearLover)
			return
		end

		MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_BAITANG_REQ)
	end
end

function WeddingFuBenView:OpenCallBack()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self.chat_hight_change = GlobalEventSystem:Bind(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE,
		BindTool.Bind(self.FulshBtnPosition, self))

	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_GET_WEDDING_ROLE_INFO)
	self:SetNotifyDataChangeCallBack()
	self:Flush()
end

function WeddingFuBenView:FulshBtnPosition(param)
	if self.node_list["Content"].gameObject.activeInHierarchy then
		local delay_time = 0.05
		local y = 420
		if param == "to_length" then
			y = 520
		end
		local tween = self.node_list["Content"].rect:DOAnchorPosY(y, 0.4, false)
		tween:SetEase(DG.Tweening.Ease.Linear)
		tween:SetDelay(delay_time)
	end
end

function WeddingFuBenView:SwitchButtonState(enable)
	self.node_list["PanelTaskParent"]:SetActive(enable)
	self.node_list["BtnZhuFu"]:SetActive(enable)
	self.node_list["BtnBride"]:SetActive(enable)
	self.node_list["BtnInvite"]:SetActive(enable)
end

function WeddingFuBenView:OnClickInvite(is_click)
	MarriageCtrl.Instance:OpenInviteView()
end

function WeddingFuBenView:OnClickZhufu()
	ViewManager.Instance:Open(ViewName.WeddingBlessView)
end
function WeddingFuBenView:CloseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.chat_hight_change then
		GlobalEventSystem:UnBind(self.chat_hight_change)
		self.chat_hight_change = nil
	end
	if self.time_quest then
		CountDown.Instance:RemoveCountDown(self.time_quest)
		self.time_quest = nil
	end

	for k, v in pairs(self.flower_effect_list) do
		ResPoolMgr:Release(v)
	end
	self.flower_effect_list = {}
	if self.hua_effect then
		local game_obj = self.hua_effect.gameObject
		if not IsNil(game_obj) then
			ResMgr:Destroy(game_obj)
		end
		self.hua_effect = nil
	end

	self:RemoveNotifyDataChangeCallBack()
end

function WeddingFuBenView:OnClicBless()
	MarriageCtrl.Instance:SendMarryBless()
end

function WeddingFuBenView:OnClickScatterFlower()
	-- MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_SAXIANHUA)
end

function WeddingFuBenView:OnClickScatterFlowerBall()
	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_YANHUA)
end

--花球CD
function WeddingFuBenView:HandleHuaQiuCD(start_time)
	--抛花球的CD时间
	local cd_time = self.cd_time_max
	--先把倒计时取消掉
	if self.time_quest then
		CountDown.Instance:RemoveCountDown(self.time_quest)
		self.time_quest = nil
	end

	--判断花球是否可抛
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_cd_time = (start_time + cd_time) - server_time
	left_cd_time = math.ceil(left_cd_time)
	left_cd_time = left_cd_time > self.cd_time_max and self.cd_time_max or left_cd_time
	if left_cd_time <= 0 then
		self.node_list["TxtCDTime"].text.text = ""
		return
	end
	self.time_quest = CountDown.Instance:AddCountDown(left_cd_time, 1, BindTool.Bind(self.HuaQiuCDTimer, self))

	self.node_list["TxtCDTime"].text.text = left_cd_time
end

--花球CDTimer
function WeddingFuBenView:HuaQiuCDTimer(elapse_time, total_time)
	local left_time = total_time - elapse_time
	left_time = math.ceil(left_time)
	left_time = left_time > self.cd_time_max and self.cd_time_max or left_time
	if left_time <= 0 then
		if self.time_quest then
			CountDown.Instance:RemoveCountDown(self.time_quest)
			self.time_quest = nil
		end
		self.node_list["TxtCDTime"].text.text = ""
		return
	end

	self.node_list["TxtCDTime"].text.text = left_time
end

function WeddingFuBenView:FlushView()
	local hunyan_time = MarriageData.Instance:GetHunYanTime() - TimeCtrl.Instance:GetServerTime()
	local function diff_time_func(elapse_time, total_time)
		local left_time = math.ceil(total_time - elapse_time)
		if elapse_time < total_time then
			self.node_list["Countdown"].text.text = TimeUtil.FormatSecond(left_time, 2)
		end
	end
	local function complere_fun()
		self.node_list["Countdown"].text.text = "00:00"
	end
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(hunyan_time, 1, diff_time_func, complere_fun)

	local weeding_info = MarriageData.Instance:GetWeddingRoleInfo()
	local hunyan_cfg = MarriageData.Instance:GetHunYanCfg()
	local data = MarriageData.Instance:GetWeddingInfo()
	if not next(data) or not next(weeding_info) then
		return
	end
	if weeding_info.is_baitang == 0 then
		self.node_list["LeftTimes1"].text.text = Language.Marriage.BaiTangTip3
	elseif weeding_info.is_baitang == 1 then
		self.node_list["LeftTimes1"].text.text = Language.Marriage.BaiTangTip4
	else
		self.node_list["LeftTimes1"].text.text = Language.Marriage.BaiTangTip5
	end
	self.node_list["LeftTimes2"].text.text = weeding_info.has_gather_num .. " / " .. hunyan_cfg.gather_max
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local count = weeding_info.total_exp
	self.node_list["LeftTimes3"].text.text = CommonDataManager.ConverExp(count)

	if weeding_info.time < 1 then
		self.node_list["LeftTimes4"].text.text = Language.Boss.NotRefresh
	else
		local des = ""
		if weeding_info.wedding_liveness >= 520 and weeding_info.wedding_liveness < 1314 then
			des = string.format(Language.Marriage.RedHasRefresh, 520)
		elseif weeding_info.wedding_liveness >= 1314 and weeding_info.wedding_liveness < 3344 then
			des = string.format(Language.Marriage.RedHasRefresh, 1314)
		elseif weeding_info.wedding_liveness >= 3344 then
			des = string.format(Language.Marriage.RedHasRefresh, 3344)
		end
		self.node_list["LeftTimes4"].text.text = des
	end

	for i = 1, 2 do
		if self.item_list[i] then
			self.item_list[i].item_obj:SetActive(true)
			self.item_list[i].item_cell:SetData({item_id = self.item_id_list[i]})
		end

		local item_num = ItemData.Instance:GetItemNumInBagById(self.item_id_list[i])
		if item_num >= 1 then
			item_num = ToColorStr(item_num, TEXT_COLOR.GREEN)
		else
			item_num = ToColorStr(item_num, TEXT_COLOR.RED)
		end
		self.node_list["Count"..i].text.text = item_num .. " / 1"
	end

	-- if data.is_self_hunyan == 1 and data.paohuoqiu_timestmp > 0 then
	-- 	self:HandleHuaQiuCD(data.paohuoqiu_timestmp)
	-- else
	-- 	self.node_list["TxtCDTime"].text.text = ""
	-- end
	self.yanhui_type = data.yanhui_type
	self.marryuser_list = data.marryuser_list
	local cfg = MarriageData.Instance:GetWeddingCfgByType(self.yanhui_type)
	if nil == cfg then return end
	
	self.node_list["TxtWeddingInfo"].text.text = ""
	self.node_list["TxtWddingInfo"].text.text = ""
	if self.yanhui_type == 1 then
		self.node_list["TxtWddingInfo"].text.text = cfg.marry_name
	else
		self.node_list["TxtWeddingInfo"].text.text = cfg.marry_name
	end
	-- local is_marrier = false
	--婚宴名
	local hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
	local name_text = ""
	name_text = ToColorStr(hunyan_info.role_name, TEXT_COLOR.GREEN_4) .. Language.Marriage.AndDes .. ToColorStr(hunyan_info.lover_role_name, TEXT_COLOR.GREEN_4)
	-- local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- for k,v in pairs(self.marryuser_list) do
		-- if name_text == "" and v.marry_name ~= "" then
			-- name_text = ToColorStr(v.marry_name, TEXT_COLOR.GREEN_4)
		-- elseif v.marry_name ~= "" then
			-- name_text = name_text.. Language.Marriage.AndDes ..ToColorStr(v.marry_name, TEXT_COLOR.GREEN_4)
	-- 	end
		-- if v.marry_uid == main_role_vo.role_id then
	-- 		is_marrier = true
	-- 	end
	-- end
	-- self.node_list["PanelGuestView"]:SetActive(not is_marrier)	显示隐藏
	-- self.node_list["ToggleHideHu"]:SetActive(not is_marrier)		显示隐藏
	-- self.node_list["PanelMarrierView"]:SetActive(is_marrier)

	-- if self.yanhui_type == 1 then
	-- 	local activity_cfg = MarriageData.Instance:GetActivityCfg()
	-- 	if activity_cfg then
	-- 		local enable = activity_cfg.bind_diamonds_hy_is_phq
	-- 		if enable == 1 then
	-- 			self.node_list["BtnFlowerBall"]:SetActive(true)
	-- 		else
	-- 			self.node_list["BtnFlowerBall"]:SetActive(false)
	-- 		end
	-- 	end
	-- else
	-- 	self.node_list["BtnFlowerBall"]:SetActive(true)
	-- end

	self.node_list["TxtBannerValue"].text.text = name_text


end

function WeddingFuBenView:OnFlush(param_t)
	if param_t.sahua then
		self:AddFlowerEffect()
	end
	self:FlushView()

	self:WeddingBtn()
end

--添加撒花特效
function WeddingFuBenView:AddFlowerEffect()
	local count = 0
	for k, v in pairs(self.flower_effect_list) do
		count = count + 1
	end
	--大过三个忽略
	if count >= 3 then
		return
	end

	if not self.hua_effect then
		self.hua_effect = U3DObject(GameObject.New())
		local asset_name = Scene.Instance:GetSceneAssetName()
		local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(asset_name)
		local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)

		local effects = objects:ToTable()[1].transform:GetChild(1)
		self.hua_effect.transform:SetParent(effects.transform, false)
		self.hua_effect.transform.localPosition = Vector3(245, 263, 50)				--暂时写死特效的位置
	end

	local bundle_name, asset_name = ResPath.GetMiscEffect("Zc01_hua_1")
	ResPoolMgr:GetDynamicObjAsync(bundle_name, asset_name, function (obj)
		if nil == obj then
			return
		end
		obj.transform:SetParent(self.hua_effect.transform, false)
		self.flower_effect_list[obj] = obj

		GlobalTimerQuest:AddDelayTimer(function()
			self.flower_effect_list[obj] = nil
			ResPoolMgr:Release(obj)
		end, EFFECT_TIME)
	end)
end

function WeddingFuBenView:WeddingBtn()
	local marry_cfg = MarriageData.Instance:GetHunYanCurAllInfo()
	local my_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local weeding_info = MarriageData.Instance:GetWeddingRoleInfo()

	if next(weeding_info) then
		local redu_cfg = MarriageData.Instance:GetHunYanCfgByReDu(weeding_info.wedding_liveness)
		if my_id == marry_cfg.role_id or my_id == marry_cfg.lover_role_id then
			UI:SetButtonEnabled(self.node_list["BtnBride"], true)
			UI:SetButtonEnabled(self.node_list["BtnInvite"], true)
			UI:SetButtonEnabled(self.node_list["BtnZhuFu"], false)
		else
			UI:SetButtonEnabled(self.node_list["BtnBride"], false)
			UI:SetButtonEnabled(self.node_list["BtnInvite"], false)
			UI:SetButtonEnabled(self.node_list["BtnZhuFu"], true)
		end

		local percent = 0
		if weeding_info.wedding_liveness <= redu_cfg.liveness_var then
			percent = (weeding_info.wedding_liveness / redu_cfg.liveness_var)
			self.node_list["CurBless"].text.text = weeding_info.wedding_liveness .. "/" .. redu_cfg.liveness_var	
		else
			percent = 1
			self.node_list["CurBless"].text.text = redu_cfg.liveness_var .. "/" .. redu_cfg.liveness_var
		end
		self.node_list["ProgBg"].slider.value = percent

		if not self.old_liveness_var then
			self.old_liveness_var = weeding_info.wedding_liveness
		else
			if 520 > self.old_liveness_var and 520 <= weeding_info.wedding_liveness or
				1314 >self.old_liveness_var and 1314 <= weeding_info.wedding_liveness or 
				3344 >self.old_liveness_var and 3344 <= weeding_info.wedding_liveness then
				TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.HunyanGatherTip)
			end
			self.old_liveness_var = weeding_info.wedding_liveness
		end

		-- self.node_list["CurBless"].text.text = weeding_info.wedding_liveness .. "/" .. redu_cfg.liveness_var
	end
end

--使用烟花
function WeddingFuBenView:BtnUseYanhua()
	local bag_data = ItemData.Instance:GetItem(self.item_id_list[1])
	local data = ItemData.Instance:GetItemConfig(self.item_id_list[1])
	if data then
		if bag_data then
			MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_USE_YANHUA, 0, 0)
			self:PlayerEffectAddtion(1)
		elseif not self.is_auto_buy1 then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id_list[1]]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(self.item_id_list[1])
				return
			end

			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				self.is_auto_buy1 = is_buy_quick
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id_list[1], nil, 1)
		else
			local item_shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id_list[1]]
			if GameVoManager.Instance:GetMainRoleVo().gold >= (item_shop_cfg.gold or 0) then
				self:PlayerEffectAddtion(1)
			end
			MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_USE_YANHUA, 0, 1)
		end
	end
end

function WeddingFuBenView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function WeddingFuBenView:ItemDataChangeCallback()
	self:Flush()
end

function WeddingFuBenView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

--使用鞭炮
function WeddingFuBenView:BtnUseBianpiao()
	local bag_data = ItemData.Instance:GetItem(self.item_id_list[2])
	local data = ItemData.Instance:GetItemConfig(self.item_id_list[2])
	if data then
		if bag_data then
			MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_USE_YANHUA, 1, 0)
			self:PlayerEffectAddtion(2)
		elseif not self.is_auto_buy2 then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id_list[2]]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(self.item_id_list[2])
				return
			end

			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				self.is_auto_buy2 = is_buy_quick
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id_list[2], nil, 1)
		else
			local item_shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id_list[2]]
			if GameVoManager.Instance:GetMainRoleVo().gold >= (item_shop_cfg.gold or 0) then
				self:PlayerEffectAddtion(2)
			end
			MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_USE_YANHUA, 1, 1)
		end
	end
end

--鞭炮特效
function WeddingFuBenView:PlayerEffectAddtion(item_type)
	local path, objname
	if item_type == 1 then
		path, objname = "effects/prefab/environment/tongyong/effect_yanhua_zise_prefab", "effect_yanhua_zise"
	else
		path, objname = "effects/prefab/environment/tongyong/effect_yanhua_da_prefab", "effect_yanhua_da"
	end
	local obj = Scene.Instance:GetMainRole()
	EffectManager.Instance:PlayControlEffect(obj, path, objname, obj:GetRoot().transform.position)
end