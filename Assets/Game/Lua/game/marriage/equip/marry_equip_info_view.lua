MarryEquipInfoView = MarryEquipInfoView or BaseClass(BaseRender)


-- local EquipIdList = {[0] = {[0] = 50111, 51111, 52111, 53111}, [1] = {[0] = 50511, 51511, 52511, 53511}}
local IconList = {[1] = {[0] = 50112, 50114, 50116, 50118}, [0] = {[0] = 50111, 50113, 50115, 50117}}

function MarryEquipInfoView:__init(instance, mother_view)
	local equip_add_per = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").other[1].equip_add_per or 0

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.lover_model = RoleModel.New()
	self.lover_model:SetDisplay(self.node_list["LoverDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)

	self.cur_index = 0
	self.marry_gift_endtime = 0
	self.sex = GameVoManager.Instance:GetMainRoleVo().sex

	self.equip_t = {}
	for i = 0, 3 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Equip" .. i + 1])
		item_cell.root_node.transform:SetAsFirstSibling()
		local data = {}
		-- data.item_id = EquipIdList[self.sex or 0][i]
		-- item_cell:SetData(data)
		item_cell:SetAsset(ResPath.GetItemIcon(IconList[self.sex][i]))
		item_cell:ShowQuality(false)
		item_cell:SetIconGrayScale(true)
		item_cell:ShowEquipGrade(false)
		item_cell:ShowStrengthLable(true)
		item_cell:SetToggleGroup(self.node_list["Equip"].toggle_group)
		item_cell:ListenClick(BindTool.Bind(self.EquipClick, self, i, item_cell))
		self.equip_t[i] = item_cell
	end

	self.lover_equip_t = {}
	for i = 0, 3 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["LoverEquip" .. i + 1])
		local data = {}
		-- data.item_id = EquipIdList[self.sex == 1 and 0 or 1][i]
		-- item_cell:SetData(data)
		item_cell:SetAsset(ResPath.GetItemIcon(IconList[self.sex == 1 and 0 or 1][i]))
		item_cell:ShowQuality(false)
		item_cell:SetIconGrayScale(true)
		item_cell:ShowEquipGrade(false)
		item_cell:ShowStrengthLable(true)
		item_cell:ShowLeftUpImage(ResPath.GetMarryImage("banlv_item"))
		item_cell:SetToggleGroup(self.node_list["LoverEquip"].toggle_group)
		item_cell:ListenClick(BindTool.Bind(self.LoverEquipClick, self, i, item_cell))
		item_cell:SetInteractable(false)
		item_cell:SetStrength("Lv.0")
		self.lover_equip_t[i] = item_cell
	end

	self.need_item = ItemCell.New()
	self.need_item:SetInstanceParent(self.node_list["ItemCell"])
	-- self.need_item:SetData({item_id = EquipIdList[self.sex or 1][0]})
	self.equip_t[0]:SetHighLight(true)

	-- self.node_list["BtnTuoDan"].button:AddClickListener(BindTool.Bind(self.OnClickTuodan, self))
	self.node_list["BtnGift"].button:AddClickListener(BindTool.Bind(self.OnClickGift, self))
	self.node_list["UpBtn"].button:AddClickListener(BindTool.Bind(self.OnclickUp, self))
	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	local event_trigger = self.node_list["RotateEventTriggerLover"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragLover, self))
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtCount"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtFpCount"])
	self.fight_text3 = CommonDataManager.FightPower(self, self.node_list["FightPower"])
end

function MarryEquipInfoView:__delete()
	if self.equip_t then
		for k,v in pairs(self.equip_t) do
			v:DeleteMe()
		end
		self.equip_t = {}
	end
	if self.lover_equip_t then
		for k,v in pairs(self.lover_equip_t) do
			v:DeleteMe()
		end
		self.lover_equip_t = {}
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.lover_model then
		self.lover_model:DeleteMe()
		self.lover_model = nil
	end

	if self.marry_gift_timer then
		GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
		self.marry_gift_timer = nil
	end

	self.need_item:DeleteMe()
	self.need_item = nil
	self.fight_text1 = nil
	self.fight_text2 = nil
	self.fight_text3 = nil
end

function MarryEquipInfoView:LoverEquipClick(index, cell)
	-- local marry_equip_info = MarryEquipData.Instance:GetLoverMarryEquipInfo()
	-- if marry_equip_info[index] and marry_equip_info[index].item_id > 0 then
	-- 	local close_callback = function ()
	-- 		cell:SetHighLight(false)
	-- 	end
	-- 	TipsCtrl.Instance:OpenItem(cell:GetData(), nil, nil, close_callback)
	-- else
	-- 	cell:SetHighLight(false)
	-- 	if GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0 then
	-- 		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.SuitTips)
	-- 	end
	-- end
end

function MarryEquipInfoView:OnRoleDragSelf(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarryEquipInfoView:OnRoleDragLover(data)
	if self.lover_model then
		self.lover_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MarryEquipInfoView:OnClickGift()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		PlayerPrefsUtil.SetInt("MarryEquipInfoView" .. main_role_id, cur_day)
		RemindManager.Instance:Fire(RemindName.MarryEquip)
	end
	ViewManager.Instance:Open(ViewName.MarryGiftView)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("MarryEquipInfoView" .. main_role_id) or cur_day
	local cur_seq = MarryEquipData.Instance:CurPurchasedSeq()
	local cfg = MarryEquipData.Instance:GetMarryGiftSeqCfg(cur_seq)	
	if nil ~= cfg and cur_day ~= -1 and cur_day ~= remind_day then	
		self.node_list["RedPoint"]:SetActive(true)
		self:SetEquipInfoIconShake(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
		self:SetEquipInfoIconShake(false)
	end

	--MarryEquipCtrl.Instance:OpenGiftView()
end

function MarryEquipInfoView:OnclickUp()
	local info = MarryEquipData.Instance:GetEquipGiftInfo()
	local cfg = MarryEquipData.Instance:GetEquipCfgToIndex(self.cur_index, info[self.cur_index].level)

	local max_level = MarryEquipData.Instance:GetGiftMaxEquipLevel()
	if info[self.cur_index].level >= max_level then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.MaxLevel)
		self.node_list["BtnTxt"].text.text = Language.Common.YiManJi
		self.node_list["ItemCount"].text.text = Language.Common.MaxLevelDesc
		UI:SetButtonEnabled(self.node_list["UpBtn"], false)
		return
	end

	local item_id = cfg.stuff_id
	local num = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)
	if num > 0 then
		MarryEquipCtrl.SendQingyuanEquipOperate(QINGYUAN_EQUIP_REQ_TYPE.EQUIP2_UPLEVEL, self.cur_index)
	else
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, num)
		return
	end
end

function MarryEquipInfoView:EquipClick(index, cell)
	-- local better_equip = MarryEquipData.Instance:GetMaxCapEquip(index)
	-- if better_equip then
	-- 	PackageCtrl.Instance:SendUseItem(better_equip.index, 1, index, 0)
	-- 	cell:SetHighLight(false)
	-- else
	-- 	local marry_equip_info = MarryEquipData.Instance:GetMarryEquipInfo()
	-- 	if marry_equip_info[index] and marry_equip_info[index].item_id > 0 then
	-- 		local close_callback = function ()
	-- 			cell:SetHighLight(false)
	-- 		end
	-- 		TipsCtrl.Instance:OpenItem(cell:GetData(), TipsFormDef.FROM_BAG_EQUIP, {fromIndex = index}, close_callback)
	-- 	else
	-- 		cell:SetHighLight(false)
	-- 		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.MarryEquipGetTips)
	-- 	end
	-- end
	-- cell.root_node.toggle.isOn = true
	if cell then
		cell:ShowHighLight(true)
	end
	self.cur_index = index
	self:FlushRightView()
end

function MarryEquipInfoView:OnClickTuodan()
	MarriageCtrl.Instance:ShowMonomerView()
end

function MarryEquipInfoView:OpenCallBack()
	self:Flush()
end

function MarryEquipInfoView:SetEquipInfoIconShake(flag)
	if self.node_list["ShakePanel"] and self.node_list["ShakePanel"].animator and self.node_list["ShakePanel"].animator.isActiveAndEnabled then
		self.node_list["ShakePanel"].animator:SetBool("IsShake", flag)
	end
end

function MarryEquipInfoView:OnFlush()
	self:FlushDisPlay()
	local marry_info = MarryEquipData.Instance:GetMarryInfo()
	local marry_equip_info = MarryEquipData.Instance:GetMarryEquipInfo()
	local info = MarryEquipData.Instance:GetEquipGiftInfo()

	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("MarryEquipInfoView" .. main_role_id) or cur_day
	local cur_seq = MarryEquipData.Instance:CurPurchasedSeq()
	local cfg = MarryEquipData.Instance:GetMarryGiftSeqCfg(cur_seq)	
	if nil ~= cfg and cur_day ~= -1 and cur_day ~= remind_day then	
		self.node_list["RedPoint"]:SetActive(true)
		self:SetEquipInfoIconShake(true)		
	else
		self.node_list["RedPoint"]:SetActive(false)
		self:SetEquipInfoIconShake(false)		
	end

	for k, v in pairs(info) do
		local cfg = MarryEquipData.Instance:GetEquipCfgToIndex(k, v.level)
		if not cfg then return end
		if v.level <= 0 then
			self.equip_t[k]:SetIconGrayScale(true)
			self.equip_t[k]:ShowQuality(false)
			self.equip_t[k]:ShowEquipGrade(false)
			self.equip_t[k]:ShowStrengthLable(true)
		else
			-- self.equip_t[k]:SetData(v)
			self.equip_t[k]:SetIconGrayScale(false)
			--显示品质
			self.equip_t[k]:ShowQuality(true)
			self.equip_t[k]:ShowStrengthLable(true)
			self.equip_t[k]:SetQualityByColor(cfg.color)
		end
		-- local data = {}
		-- data.item_id = EquipIdList[self.sex or 1][k]
		-- self.equip_t[k]:SetData(data)
		self.equip_t[k]:SetStrength("Lv." .. v.level)
	end
	for i = 0, 3 do
		self.node_list["BtnImprove" .. (i+1)]:SetActive(MarryEquipData.Instance:GetMaxCapEquip(i) ~= 0)
	end
	local all_cap = MarryEquipData.Instance:GetMarryEquipAllCap()
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = all_cap
	end
	self.node_list["TxtMarryLevel"].text.text = string.format(Language.Marriage.MarriageLevel, marry_info.marry_level)
	self:FlushRightView()

	local lover_marry_info = MarryEquipData.Instance:GetLoverMarryInfo()
	local lover_marry_equip_info = MarryEquipData.Instance:GetLoverMarryEquipInfo()
	local lover_info = MarryEquipData.Instance:GetLoveEquipGiftInfo()

	local cur_seq = MarryEquipData.Instance:CurPurchasedSeq()
	local cfg = MarryEquipData.Instance:GetMarryGiftSeqCfg(cur_seq)
	self.node_list["BtnGift"]:SetActive(cfg ~= nil)
	if cfg then
		self.marry_gift_endtime = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
		if self.marry_gift_timer == nil then
			self.marry_gift_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
	else
		if self.marry_gift_timer then
			GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
			self.marry_gift_timer = nil
		end
	end

	if GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0 or lover_info == nil then
		if self.fight_text2 and self.fight_text2.text then
			self.fight_text2.text.text = 0
		end
		return 
	end
	for k, v in pairs(lover_info) do
		local lover_cfg = MarryEquipData.Instance:GetEquipCfgToIndex(k, v.level)
		if v.level <= 0 then
			self.lover_equip_t[k]:SetIconGrayScale(true)
			self.lover_equip_t[k]:ShowQuality(false)
			self.lover_equip_t[k]:ShowEquipGrade(false)
			self.lover_equip_t[k]:ShowStrengthLable(true)
		else
			-- self.lover_equip_t[k]:SetData(v)
			--显示品质
			self.lover_equip_t[k]:ShowQuality(true)
			self.lover_equip_t[k]:SetIconGrayScale(false)
			self.lover_equip_t[k]:ShowStrengthLable(true)
			if lover_cfg ~= nil then
				self.lover_equip_t[k]:SetQualityByColor(lover_cfg.color)
			end
		end
		-- local data = {}
		-- data.item_id = EquipIdList[self.sex == 1 and 0 or 1][k]
		-- self.lover_equip_t[k]:SetData(data)
		self.lover_equip_t[k]:SetStrength("Lv." .. v.level)
		self.lover_equip_t[k]:SetInteractable(false)
	end
	all_cap = MarryEquipData.Instance:GetMarryEquipLoverCap()
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = all_cap
	end
	self.node_list["TxtLoverMarryLevel"].text.text = string.format(Language.Marriage.MarriageLevel, lover_marry_info.marry_level)
end

function MarryEquipInfoView:FlushDisPlay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vo = {}
	role_vo.prof = main_role_vo.prof
	role_vo.sex = main_role_vo.sex
	role_vo.appearance = {}
	role_vo.appearance.fashion_body = 2
	self.model:SetModelResInfo(role_vo, true, true, true, true)
	-- self.model:SetScale(Vector3(1.4, 1.4, 1.4))
	-- if role_vo.prof == 4 then
	-- 	self.model.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("loliCommon").position
	-- 	self.model.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("loliCommon").rotation
	-- else
	-- 	self.model.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("personCommon").position
	-- 	self.model.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("personCommon").rotation
	-- end

	--有伴侣才加载伴侣模型
	GlobalTimerQuest:AddDelayTimer(function()
		if main_role_vo.lover_uid > 0 then
			local lover_vo = {}
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			lover_vo.appearance = {}
			lover_vo.appearance.fashion_body = 2
			self.lover_model:SetModelResInfo(lover_vo, true, true, true, true)
			-- self.lover_model:SetScale(Vector3(1.4, 1.4, 1.4))
			-- if lover_vo.prof == 4 then
			-- 	self.lover_model.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("loliCommon").position
			-- 	self.lover_model.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("loliCommon").rotation
			-- else
			-- 	self.lover_model.display.transform:FindHard("UICamera").transform.localPosition = MarriageData.Instance:GetDisplayPosition("personCommon").position
			-- 	self.lover_model.display.transform:FindHard("UICamera").transform.eulerAngles = MarriageData.Instance:GetDisplayPosition("personCommon").rotation
			-- end
		end
	end, 0)
	local sex = self.sex ~= 0
		self.node_list["Img1"]:SetActive(sex)
		self.node_list["Img2"]:SetActive(not sex)
	self.node_list["ImgLover"]:SetActive(not (main_role_vo.lover_uid > 0))
end

function MarryEquipInfoView:FlushRightView()
	if nil == self.node_list then
		return
	end
	local info = MarryEquipData.Instance:GetEquipGiftInfo()
	self.node_list["BtnTxt"].text.text = Language.Common.Activate
	if nil == info and not info[self.cur_index] then return end

	local cfg = MarryEquipData.Instance:GetEquipCfgToIndex(self.cur_index, info[self.cur_index].level)
	if not cfg then return end

	local str = "Lv." .. info[self.cur_index].level .. " " .. cfg.name
	self.node_list["EquipName"].text.text = ToColorStr(str, ITEM_COLOR[cfg.color])
	self.node_list["EquipBg"].image:LoadSprite(ResPath.GetQualityIcon(cfg.color))
	self.node_list["EquipImage"].image:LoadSprite(ResPath.GetItemIcon(IconList[self.sex][self.cur_index]))

	self.node_list["Hp"].text.text = ToColorStr(cfg.maxhp, TEXT_COLOR.ORANGE_4)
	self.node_list["Gongji"].text.text = ToColorStr(cfg.gongji, TEXT_COLOR.ORANGE_4)
	self.node_list["Fangyu"].text.text = ToColorStr(cfg.fangyu, TEXT_COLOR.ORANGE_4)
	self.node_list["Baoji"].text.text = ToColorStr(cfg.baoji, TEXT_COLOR.ORANGE_4)
	self.node_list["MingZhong"].text.text = ToColorStr(cfg.mingzhong or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["ShanBi"].text.text = ToColorStr(cfg.shanbi or 0, TEXT_COLOR.ORANGE_4)
	self.node_list["KangBao"].text.text = ToColorStr(cfg.jianren or 0, TEXT_COLOR.ORANGE_4)

	local have_item_num = 0
	local need_item_num = 1
	have_item_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	need_item_num = cfg.stuff_num
	if info[self.cur_index].level > 0 then
		self.node_list["BtnTxt"].text.text = Language.Common.Up
	end
	local text_1 = ""
	if have_item_num >= need_item_num then
		text_1 = ToColorStr(have_item_num .. "" , TEXT_COLOR.GREEN)
	else
		text_1 = ToColorStr(have_item_num .. "" , TEXT_COLOR.RED)
	end

	self.node_list["ItemCount"].text.text = text_1 .. " / " .. need_item_num
	if self.fight_text3 and self.fight_text3.text then
		self.fight_text3.text.text = CommonDataManager.GetCapability(cfg)
	end
	local data = {}
	data.item_id = cfg.stuff_id
	self.need_item:SetData(data)

	local max_level = MarryEquipData.Instance:GetGiftMaxEquipLevel()
	UI:SetButtonEnabled(self.node_list["UpBtn"], info[self.cur_index].level < max_level)
	if info[self.cur_index].level >= max_level then
		self.node_list["BtnTxt"].text.text = Language.Common.YiManJi
		self.node_list["ItemCount"].text.text = "- / -"
	end
end

function MarryEquipInfoView:FlushNextTime()
	local time = self.marry_gift_endtime - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 * 24 then
			self.node_list["Time"].text.text = TimeUtil.FormatSecond(time, 1)
		else
			self.node_list["Time"].text.text = TimeUtil.FormatSecond(time, 3)
		end
	else
		self:Flush()
	end
end