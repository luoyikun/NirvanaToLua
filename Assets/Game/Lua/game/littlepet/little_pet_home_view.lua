--宠物家园
LittlePetHomeView = LittlePetHomeView or BaseClass(BaseRender)

local PERSON_CULTIVATE_MAX_NUM = 5
local MOVE_TIMER = 5
local MAX_MOVE_TIMER = 10
local MAX_ACTIVITY_AREA_WIDTH = 980
local MAX_ACTIVITY_AREA_HEIGHT = 460
local PET_FLAG = {
	MY_PET_FLAG = 1,
	LOVER_PET_FLAG = 2,
}

local PET_DIRECTION = {
	[1] = {x = 0, y = 0, z = 0},
	[2] = {x = 0, y = 45, z = 0},
	[3] = {x = 0, y = 90, z = 0},
	[4] = {x = 0, y = 135, z = 0},
	[5] = {x = 0, y = 180, z = 0},
	[6] = {x = 0, y = -135, z = 0},
	[7] = {x = 0, y = -90, z = 0},
	[8] = {x = 0, y = -45, z = 0},
}

local SPECIAL_MODEL_CAMERA = {
	[1017001] = "little_pet_home_panel_special_1",
}

function LittlePetHomeView:__init()
	--self.show_recycle_red_point = self.node_list["ShowRecycleRedPoint"]
	--self.show_lover_pet = self:FindVariable("ShowLoverPet")
	--self.fight_power = self:FindVariable("FightPower")

	self.select_box_list = {}
	self.my_pet_list = {}
	self.bg_list = {}
	self.lover_pet_list = {}
	self.my_pet_show_list = {}
	self.lover_pet_show_list = {}
	self.model_pos = {}
	self.model_pos[1] = {}
	self.model_pos[2] = {}
	self.pet_list = {}
	for i = 1, PERSON_CULTIVATE_MAX_NUM do
		-- 喂养选择框
		self.select_box_list[i] = PetHomeSelectBox.New(self.node_list["Render"..i])
		self.select_box_list[i]:SetIndex(i)
		self.select_box_list[i]:SetParent(self)

		-- 自己的宠物，初始化宠物位置
		self.my_pet_list[i] = self.node_list["MyPet"..i]
		self.my_pet_show_list[i] = self.node_list["MyPet"..i]
		self.model_pos[1][i] = {x = 0, y = 0, dis = 0}
		-- 伴侣的宠物，初始化宠物位置
		self.lover_pet_list[i] = self.node_list["LoverPet"..i]
		self.lover_pet_show_list[i] = self.node_list["LoverPet"..i]
		self.model_pos[2][i] = {x = 0, y = 0, dis = 0}

	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	self.birth_pos = self.node_list["BirthPos"]

	self.node_list["ClickHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.ClickTitleShow, self))
	self.node_list["ClickRecycle"].button:AddClickListener(BindTool.Bind(self.OnClickRecycle, self))
end

function LittlePetHomeView:__delete()
	if self.pet_list ~= nil then
		for k,v in pairs(self.pet_list) do
			if v ~= nil and v.model ~= nil then
				if v.loop_tweener ~= nil then
					v.loop_tweener:Pause()
				end

				v.model:DeleteMe()
			end
		end

		self.pet_list = {}
	end

	if self.time_quest ~= nil then
		for i = 1, PERSON_CULTIVATE_MAX_NUM + PERSON_CULTIVATE_MAX_NUM do
			if self.time_quest[i] ~= nil then
				GlobalTimerQuest:CancelQuest(self.time_quest[i])
			end
		end

		self.time_quest = nil
	end

	for k,v in pairs(self.select_box_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.select_box_list = {}

	self.my_pet_list = {}
	self.lover_pet_list = {}
	self.my_pet_show_list = {}
	self.lover_pet_show_list = {}
	self.model_pos = {}
	self.fight_text = nil
end

function LittlePetHomeView:OpenCallBack()
	Runner.Instance:AddRunObj(self, 8)

	-- 设置宠物移动地图大小
	LittlePetData.Instance:InitMap(MAX_ACTIVITY_AREA_WIDTH, MAX_ACTIVITY_AREA_HEIGHT)
	self.node_list["ShowLoverPet"]:SetActive(true)

	self:DoPanelTweenPlay()
	self:Flush()
end

function LittlePetHomeView:CloseCallBack()
	Runner.Instance:RemoveRunObj(self, 8)
end

function LittlePetHomeView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["LeftPanle"], Vector3(-170, 0, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["ClickRecycle"], Vector3(174, 290, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["ClickHelp"], Vector3(145, 210, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveAlpahShowPanel(self.node_list["Bottom"], Vector3(0, -309, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function LittlePetHomeView:OnFlush()
	-- 刷新自己的喂养框和模型
	local my_pet_equip_list = LittlePetData.Instance:GetHomeEquipPetDataList(false)
	for i = 1, PERSON_CULTIVATE_MAX_NUM do
		self.select_box_list[i]:SetData(my_pet_equip_list[i])
	end
	self:FlushPetModel(my_pet_equip_list, false)

	-- 刷新伴侣的模型
	local lover_pet_equip_list = LittlePetData.Instance:GetHomeEquipPetDataList(true)
	self:FlushPetModel(lover_pet_equip_list, true)

	--刷新总战力
	local power = 0
	power = LittlePetData.Instance:GetAllFightPower()
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
	--self.node_list["ShowRecycleRedPoint"]:SetActive(LittlePetData.Instance:CheckHomeRecycleIsShowRedPoint())

end

function LittlePetHomeView:OnClickRecycle()
	ViewManager.Instance:Open(ViewName.LittlePetHomeRecycleView)
end

-- 初始化宠物模型
function LittlePetHomeView:InitModel(index, res_id, lover_flag)
	local cultivate_pet_model = lover_flag == PET_FLAG.MY_PET_FLAG and self.my_pet_list[index] or self.lover_pet_list[index]
	local pet_list_index = lover_flag == PET_FLAG.MY_PET_FLAG and index or index + PERSON_CULTIVATE_MAX_NUM
	local show_pet = lover_flag == PET_FLAG.MY_PET_FLAG and self.my_pet_show_list[index] or self.lover_pet_show_list[index]
	
	self.pet_list[pet_list_index] = {}
	self.pet_list[pet_list_index].model = RoleModel.New("little_pet_home_panel")
	self.pet_list[pet_list_index].model:SetDisplay(cultivate_pet_model.ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.pet_list[pet_list_index].show = true
	--移动时间
	self.pet_list[pet_list_index].move_timer = 0
	local ran_value = tonumber(string.format("%2d", math.random()))
	self.pet_list[pet_list_index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER) + ran_value
	--是否可移动
	self.pet_list[pet_list_index].can_move = true
	self.pet_list[pet_list_index].res_id = res_id or 0

	if self.birth_pos ~= nil then
		local pos = self.birth_pos.transform.localPosition
		-- 随机获取出生点
		local borth_index = LittlePetData.Instance:GetPetHinderList(nil, pet_list_index)
		local pos_t = LittlePetData.Instance:GetPosByIndex(borth_index)
		cultivate_pet_model.transform:SetLocalPosition(pos_t.x, pos_t.y, pos.z)

		if self.model_pos ~= nil and self.model_pos[lover_flag][index] ~= nil then
			self.model_pos[lover_flag][index] = {x = pos_t.x, y = pos_t.y, dis = 0}
		end
	end

	self.pet_list[pet_list_index].model:SetMainAsset(ResPath.GetLittlePetModel(res_id))
	local rand_dir = math.random(1, 8)
	self.pet_list[pet_list_index].model:SetRotation(PET_DIRECTION[rand_dir])
	show_pet:SetActive(self.pet_list[pet_list_index].show)
end

-- 宠物移动
function LittlePetHomeView:MovePet(index, lover_flag)
	local cultivate_pet_model = lover_flag == PET_FLAG.MY_PET_FLAG and self.my_pet_list[index] or self.lover_pet_list[index]
	local pet_list_index = lover_flag == PET_FLAG.MY_PET_FLAG and index or index + PERSON_CULTIVATE_MAX_NUM

	if self.pet_list == nil or index == nil or self.pet_list[pet_list_index] == nil then
		return
	end

	if self.model_pos == nil or self.model_pos[lover_flag][index] == nil then
		return
	end

	local start_pos = self.model_pos[lover_flag][index]
	-- 获取当前位置和目标位置
	local start_index = LittlePetData.Instance:GetIndexByPos(start_pos)
	local end_index = LittlePetData.Instance:GetPetHinderList(start_index, pet_list_index)
	if end_index == nil then
		return
	end

	local can_move = LittlePetData.Instance:FindWay(start_index, end_index)
	if not can_move then
		return
	end

	-- 寻路(格子)
	local move_list = LittlePetData.Instance:GetMovePathPoint(start_index, end_index)
	local timer = #move_list * 0.5
	if self.time_quest == nil then
		self.time_quest = {}
	end

	if self.time_quest[pet_list_index] ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest[pet_list_index])
	end

	-- 移动
	self.pet_list[pet_list_index].model:SetInteger("status", 1)
	self.time_quest[pet_list_index] = GlobalTimerQuest:AddDelayTimer(function()
			local item = cultivate_pet_model
			local path = LittlePetData.Instance:GetReadMoveList(move_list, start_pos)
			local move_call
			local call_num = 1
			local move_dir = 0
			local move_start_pos = start_pos
			local angle = 0
			move_call = function()
				if call_num <= #path then
					local tween = item.transform:DOLocalMove(path[call_num], 0.05)
					tween:SetEase(DG.Tweening.Ease.Linear)
					tween:OnComplete(move_call)
					self.pet_list[pet_list_index].loop_tweener = tween
					if call_num > 1 then
						move_start_pos = path[call_num - 1]
					end

					if move_list[call_num] ~= nil and move_list[call_num].dis ~= nil then
						local angle = 8 - move_list[call_num].dis < 0 and 0 or 8 - move_list[call_num].dis
						if call_num > 1 then
							self.pet_list[pet_list_index].model:SetRotation(Vector3(0, angle * 40, 0))
						end
					end

					call_num = call_num + 1
				else
					self.pet_list[pet_list_index].model:SetInteger("status", 0)
					self.model_pos[lover_flag][index] = path[#path]
					local ran_value = tonumber(string.format("%2d", math.random()))
					self.pet_list[pet_list_index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER) + ran_value
					self.pet_list[pet_list_index].move_timer = 0
					self.pet_list[pet_list_index].can_move = true
				end
			end

			move_call()
		end, 0)
end

-- 宠物休闲动作
function LittlePetHomeView:PetRelaxAni(index, lover_flag)
	local cultivate_pet_model = lover_flag == PET_FLAG.MY_PET_FLAG and self.my_pet_list[index] or self.lover_pet_list[index]
	local pet_list_index = lover_flag == PET_FLAG.MY_PET_FLAG and index or index + PERSON_CULTIVATE_MAX_NUM

	if self.pet_list == nil or index == nil or self.pet_list[pet_list_index] == nil then
		return
	end

	if self.model_pos == nil or self.model_pos[lover_flag][index] == nil then
		return
	end

	if self.time_quest == nil then
		self.time_quest = {}
	end

	if self.time_quest[pet_list_index] ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest[pet_list_index])
	end

	self.pet_list[pet_list_index].model:SetTrigger("rest")
	self.time_quest[pet_list_index] = GlobalTimerQuest:AddDelayTimer(function()
		local ran_value = tonumber(string.format("%2d", math.random()))
		self.pet_list[pet_list_index].ran_time = math.random(MOVE_TIMER, MAX_MOVE_TIMER) + ran_value
		self.pet_list[pet_list_index].move_timer = 0
		self.pet_list[pet_list_index].can_move = true
		end, 6)
end

function LittlePetHomeView:ChangePet(index, res_id, lover_flag)
	local cultivate_pet_model = lover_flag == PET_FLAG.MY_PET_FLAG and self.my_pet_list[index] or self.lover_pet_list[index]
	local pet_list_index = lover_flag == PET_FLAG.MY_PET_FLAG and index or index + PERSON_CULTIVATE_MAX_NUM
	local show_pet = lover_flag == PET_FLAG.MY_PET_FLAG and self.my_pet_show_list[index] or self.lover_pet_show_list[index]

	if index == nil or res_id == nil then
		return
	end

	if self.pet_list == nil then
		self.pet_list = {}
	end

	-- 设置操作类型
	local opera_type = ""
	if self.pet_list[pet_list_index] ~= nil then
		-- 跟原来宠物一样的直接退出不作操作
		if self.pet_list[pet_list_index].res_id == res_id then
			return
		end
		opera_type = res_id == 0 and "delete" or "change"
	elseif self.pet_list[pet_list_index] == nil and res_id ~= 0 then
		opera_type = "add"
	else
		show_pet:SetActive(false)
		return
	end

	if opera_type == "add" then
		self:InitModel(index, res_id, lover_flag)
	elseif opera_type == "change" then
		if self.pet_list[pet_list_index].res_id ~= res_id then
			self.pet_list[pet_list_index].res_id = res_id
			self.pet_list[pet_list_index].model:SetMainAsset(ResPath.GetLittlePetModel(res_id))
		end

		if self.pet_list[pet_list_index].show ~= nil then
			self.pet_list[pet_list_index].show = true
		end

		show_pet:SetActive(self.pet_list[pet_list_index].show)

	elseif opera_type == "delete" then
		if self.pet_list[pet_list_index].loop_tweener ~= nil then
			self.pet_list[pet_list_index].loop_tweener:Pause()
		end

		if self.pet_list[pet_list_index] ~= nil and self.model_pos[lover_flag][index]~= nil then
			self.model_pos[lover_flag][index] = cultivate_pet_model.transform.localPosition
			self.pet_list[pet_list_index].dis = 0
		end

		if self.pet_list[pet_list_index].model then
			self.pet_list[pet_list_index].model:SetInteger("status", 0)
		end

		if self.time_quest ~= nil and self.time_quest[pet_list_index] ~= nil then
			GlobalTimerQuest:CancelQuest(self.time_quest[pet_list_index])
		end

		if self.pet_list[pet_list_index].move_timer ~= nil then
			self.pet_list[pet_list_index].move_timer = 0
		end

		if self.pet_list[pet_list_index].can_move ~= nil then
			self.pet_list[pet_list_index].can_move = true
		end

		if self.pet_list[pet_list_index].show ~= nil then
			self.pet_list[pet_list_index].show = false
		end

		if self.pet_list[pet_list_index].res_id ~= nil then
			self.pet_list[pet_list_index].res_id = 0
		end

		show_pet:SetActive(self.pet_list[pet_list_index].show)
	end

end

function LittlePetHomeView:Update(now_time, elapse_time)
	if self.pet_list ~= nil then
		for i = 1, PERSON_CULTIVATE_MAX_NUM + PERSON_CULTIVATE_MAX_NUM do
			if self.pet_list[i] ~= nil and self.pet_list[i].show then
				if self.pet_list[i].move_timer ~= nil and self.pet_list[i].ran_time ~= nil then
					self.pet_list[i].move_timer = self.pet_list[i].move_timer + elapse_time
					if self.pet_list[i].move_timer > self.pet_list[i].ran_time and self.pet_list[i].can_move then
						self.pet_list[i].can_move = false
						self:UpdatePetSatus(i)
					end
				end
			end
		end
	end
end

function LittlePetHomeView:UpdatePetSatus(index)
	local lover_flag = PET_FLAG.MY_PET_FLAG
	if index > 5 then
		index = index - PERSON_CULTIVATE_MAX_NUM
		lover_flag = PET_FLAG.LOVER_PET_FLAG
	end
	local random = math.random(1, 20)

	if random <= 10 then
		self:MovePet(index, lover_flag)
	else
		self:PetRelaxAni(index, lover_flag)
	end
end

function LittlePetHomeView:FlushPetModel(equip_data_list, lover_flag)
	local lover_index = lover_flag and PET_FLAG.LOVER_PET_FLAG or PET_FLAG.MY_PET_FLAG
	for i = 1, PERSON_CULTIVATE_MAX_NUM do
		if equip_data_list[i] ~= nil then
			self:ChangePet(i, equip_data_list[i].res_id, lover_index)
		else
			self:ChangePet(i, 0, lover_index)
		end
	end
end

function LittlePetHomeView:OnClickPutTest(index)
	ViewManager.Instance:Open(ViewName.LittlePetHomePackageView, nil, index - 1)
end

function LittlePetHomeView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(276)
end

function LittlePetHomeView:SetSpecialModle(modle_res_id)
	local display_name = "little_pet_home_panel"
	local id = tonumber(modle_res_id)
	for k,v in pairs(SPECIAL_MODEL_CAMERA) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

function LittlePetHomeView:ClickTitleShow()
	local other_cfg = LittlePetData.Instance:GetOtherCfg()
	if other_cfg and other_cfg[1] then
	  TipsCtrl.Instance:OpenItem({item_id = other_cfg[1].title_show})
	end
end


----------------------- 喂养选择框 -----------------------
PetHomeSelectBox = PetHomeSelectBox or BaseClass(BaseCell)
function PetHomeSelectBox:__init(instance)

	-- self.selected_item = ItemCell.New()
	-- self.selected_item:SetInstanceParent(self.node_list["Cell"])
	-- self.selected_item:ListenClick(BindTool.Bind(self.OnClickEquippedCell, self))
	-- self.selected_item:ShowHighLight(false)

	self.node_list["NullItem"].button:AddClickListener(BindTool.Bind(self.OnClickOpenPetBag, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickOpenPetBag, self))
	self.node_list["Demount"].button:AddClickListener(BindTool.Bind(self.OnClickDemountPet, self))
end

function PetHomeSelectBox:__delete()
	-- if self.selected_item then
	-- 	self.selected_item:DeleteMe()
	-- 	self.selected_item = nil
	-- end
end

function PetHomeSelectBox:SetIndex(index)
	self.index = index
end

function PetHomeSelectBox:OnClickOpenPetBag(index)
	local num = #LittlePetData.Instance:GetBagLittlePetDataList()
	if num > 0 then
		ViewManager.Instance:Open(ViewName.LittlePetHomePackageView, nil, "index", {self.index - 1})
	else
		ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_shop)
	end
end

function PetHomeSelectBox:SetParent(parent)
	self.parent = parent
end

function PetHomeSelectBox:SetData(data)
	self.data = data

	local num = #LittlePetData.Instance:GetBagLittlePetDataList()
	if num > 0 or data then
		self.node_list["BtnState"].text.text = Language.Common.BtnReplace
	else
		self.node_list["BtnState"].text.text = Language.Common.HuoQu
	end
	-- 红点
	self.node_list["ShowRed"]:SetActive(LittlePetData.Instance:CheckHomeSelectedBoxIsShowRedPoint(self.index))
	self.node_list["RedPoint"]:SetActive(LittlePetData.Instance:CheckHomeSelectedBoxIsShowRedPoint(self.index))
	if nil == data then
		-- self.selected_item:SetItemActive(false)
		self.node_list["Sprite"]:SetActive(false)
		self.node_list["NullItem"]:SetActive(true)
		self.node_list["Demount"]:SetActive(false)
		self.node_list["RedPoint"]:SetActive(num > 0)
		--self.node_list["none_red_point"]:SetActive(num > 0)
		self.node_list["PetName"].text.text = Language.LittlePet.ZanWu
		-- self.node_list["BtnState"].text.text = Language.Common.LingQu
		local bg_bundle, bg_asset = ResPath.GetLittlePetBg(Common_Five_Rank_Color[1])
		if bg_bundle and bg_asset then
			self.node_list["head_frame"].image:LoadSprite(bg_bundle, bg_asset)
		end
	else
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		if nil == item_cfg then
			return
		end
		-- self.selected_item:SetItemActive(true)
		local quality = item_cfg.color or 0
		self.node_list["NullItem"]:SetActive(false)
		self.node_list["Demount"]:SetActive(true)
		--self.node_list["none_red_point"]:SetActive(false)
		-- self.selected_item:SetData(data)
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["Sprite"].image:LoadSprite(bundle, asset)
		self.node_list["Sprite"]:SetActive(true)
		self.node_list["PetName"].text.text = ToColorStr(data.name, SOUL_NAME_COLOR[quality])
		local bg_bundle, bg_asset = ResPath.GetLittlePetBg(Common_Five_Rank_Color[quality])
		if bg_bundle and bg_asset then
			self.node_list["head_frame"].image:LoadSprite(bg_bundle, bg_asset)
		end
		-- self.node_list["BtnState"].text.text = Language.Common.BtnReplace
	end

end

function PetHomeSelectBox:OnClickDemountPet()
	if nil ~= self.data then 
		local pet_id = self.data.id or 0
		LittlePetData.Instance:SetTakeOffPetId(pet_id)
		LittlePetCtrl.Instance:OnMainRoleTakeOffPet()
	end

	LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_TAKEOFF, self.index - 1)
end

function PetHomeSelectBox:OnClickEquippedCell()
	TipsCtrl.Instance:OpenItem(self.data, TipsFormDef.FROM_LITTLEPET_HOME, self.index - 1)
end