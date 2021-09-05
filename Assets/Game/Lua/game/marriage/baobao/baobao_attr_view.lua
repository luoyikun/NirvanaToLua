BaoBaoAttrView = BaoBaoAttrView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
local BAOBAO_MAX_COUNT = 10    -- 可生宝宝最大数
local MOVE_TIME = 0.5
function BaoBaoAttrView:UIsMove()
	UITween.AlpahShowPanel(self.node_list["MiddleContent"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["MountInfo"] , Vector3(300 , -27 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnTips"] , Vector3(284 , 150 , 0 ) , MOVE_TIME )
end
function BaoBaoAttrView:__init(instance, mother_view)
	self.progress_value = ProgressBar.New(self.node_list["ProgressValue"])
	self.node_list["ChangeNameClick"].button:AddClickListener(BindTool.Bind(self.ChageNameClick, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.AutoUpGradeClick, self))
	self.node_list["BtnTips"].button:AddClickListener(BindTool.Bind(self.ClickTitleShow, self))
	self.node_list["HelpClick"].button:AddClickListener(BindTool.Bind(self.HelpClick, self))
	self.node_list["BtnBaby"].button:AddClickListener(BindTool.Bind(self.OpenLongFengBaByView, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"])
	self.attr_t = {}
	self.attr_n = {}
	self.selectindex = 1
	for i = 1, 3 do
		self.attr_t[i] = self.node_list["TxtAttr" .. i]
		self.attr_n[i] = self.node_list["TxtNextAttr"..i]
	end

	self.temp_grade = {}
	for i = 1, BAOBAO_MAX_COUNT do
		 self.temp_grade[i] = -1
	end
	self.stuff_item = ItemCell.New()
	self.stuff_item:SetInstanceParent(self.node_list["StuffItem"])
end

function BaoBaoAttrView:__delete()
	if nil ~= self.progress_value then
		self.progress_value:DeleteMe()
		self.progress_value = nil
	end
	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.stuff_item then
		self.stuff_item:DeleteMe()
		self.stuff_item = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.temp_grade = nil
	self.attr_t = nil
	self.attr_n = nil
	self.selectindex = nil
	self.fight_text = nil
end

function BaoBaoAttrView:ChageNameClick()
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	local func = function(name)
		local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
		if selected_baby_index then
			BaobaoCtrl.Instance:SendBabyRenameReq(selected_baby_index - 1, name)
		end
	end
	TipsCtrl.Instance:ShowRename(func, true, ConfigManager.Instance:GetAutoConfig("baby_cfg_auto").other[1].rename_card_id)
end

function BaoBaoAttrView:AutoUpGradeClick()
	if self.is_auto_upgrade then
		self.is_auto_upgrade = false
		 --UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
		self.node_list["TxtAutoBtnName"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
		return
	end
	self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()-- 记录谁被进阶
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end
		local baby_grade = baby_info.grade or 0
		local upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(baby_grade)
		if upgrade_cfg == nil then return end 
			local item_id = upgrade_cfg.consume_stuff_id
	if not self.node_list["AutoBuy"].toggle.isOn and ItemData.Instance:GetItemNumInBagById(item_id) < upgrade_cfg.consume_stuff_num then
		self:AutoBuyConfirm(item_id)
		return
	end
	self.is_auto_upgrade = true
	--UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
	self:AutoUpGradeOnce()
	 
end

function BaoBaoAttrView:AutoBuyConfirm(item_id)
	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
	MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	self.node_list["AutoBuy"].toggle.isOn = is_buy_quick
	end
	TipsCtrl.Instance:ShowCommonBuyView(func, item_id, BindTool.Bind2(self.TipsCancelCallback, self), 1)
	return true
end

function BaoBaoAttrView:TipsCancelCallback()
	UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
	self.is_auto_upgrade = false
	self.node_list["TxtAutoBtnName"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
end

function BaoBaoAttrView:HelpClick()
	TipsCtrl.Instance:ShowHelpTipView(280)
end

function BaoBaoAttrView:OpenLongFengBaByView()
	ViewManager.Instance:Open(ViewName.BaoBaoLongFengTipsView)
end

function BaoBaoAttrView:UpGradeClick(auto)
	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	if #baby_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
		return
	end
	local is_one_key = 0

	local selected_baby_index = BaobaoData.Instance:GetSelectedBabyIndex()
	if nil == selected_baby_index then return end
	local baby_info = BaobaoData.Instance:GetBabyInfo(selected_baby_index)
	if nil == baby_info then return end

	local baby_grade = baby_info.grade
	local baby_upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(baby_grade)

	if baby_upgrade_cfg == nil then return end
	local next_time = baby_upgrade_cfg.next_time or 0

	if baby_grade ~= nil then
		local upgrade_all = BaobaoData.Instance:GetBabyUpgradeCfgMaxGrade()
		if baby_grade < upgrade_all then
			local is_auto_buy = self.node_list["AutoBuy"].toggle.isOn and 1 or 0
			if false == auto then
				is_one_key = 0
			elseif true == auto then
				is_one_key = 1
			end
			self.is_click_btn = true
			if not self.node_list["AutoBuy"].toggle.isOn and ItemData.Instance:GetItemNumInBagById(baby_upgrade_cfg.consume_stuff_id) < baby_upgrade_cfg.consume_stuff_num then
				self:AutoBuyConfirm(baby_upgrade_cfg.consume_stuff_id)
				return
			end
			BaobaoCtrl.Instance:SendBabyUpgradeReq(selected_baby_index - 1, is_auto_buy, 0)
			self.jinjie_next_time = Status.NowTime + next_time
		end
	end
end

function BaoBaoAttrView:CloseCallBack()
	if self.is_auto_upgrade then
		self:AutoUpGradeClick()
	end
	if nil ~= self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.node_list["Effect"]:SetActive(false)
end


function BaoBaoAttrView:AutoUpGradeOnce()
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then return end
	
	local baby_grade = baby_info.grade or 0
	local upgrade_all = BaobaoData.Instance:GetBabyUpgradeCfgLength()

	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if baby_grade >= 0 and baby_grade < upgrade_all then
		if self.is_auto_upgrade then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpGradeClick,self,true), jinjie_next_time)
		end
	end
end

function BaoBaoAttrView:OnOperateResult(operate, result, param1, param2)
	if 0 == result then
		if self.is_auto_upgrade then
			self.is_auto_upgrade = false
			UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
			self.node_list["TxtAutoBtnName"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
		end
	elseif 1 == result then
		self:AutoUpGradeOnce()

	elseif 2 == result then
		if self.is_auto_upgrade then
			self.is_auto_upgrade = false
			UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
			self.node_list["TxtAutoBtnName"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
		end
	elseif 3 == result then
		if self.is_auto_upgrade then
			self.is_auto_upgrade = false
			UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
		end
		self:FlushView()
	end
end

function BaoBaoAttrView:FlushAttr(value)
	if value then
		self.node_list["NextAttr"]:SetActive(true)
		self.node_list["AttrContent"]:SetActive(false)
		self.node_list["AttrContent"]:SetActive(true)
	else
		self.node_list["NextAttr"]:SetActive(false)
	end
end

-- 监听物品变化
function BaoBaoAttrView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if baby_info then
		local grade = baby_info.grade or 0
		local upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(grade)
		if upgrade_cfg.consume_stuff_id and upgrade_cfg.consume_stuff_id == item_id then
			self:FlushView()
		end
	end
end
function BaoBaoAttrView:OnFlush()
	self:FlushView()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end
	local is_red = BaobaoData.Instance:LongFenRemind() > 0
	self.node_list["LongFenred"]:SetActive(is_red)
end

function BaoBaoAttrView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 0 then
		self.node_list["longfen_time"]:SetActive(true)
		if time > 3600 * 24 then
			self.node_list["longfen_time"].text.text = TimeUtil.FormatSecond(time, 6)
		else
			self.node_list["longfen_time"].text.text = TimeUtil.FormatSecond(time, 3)
		end
	else
		self.node_list["longfen_time"]:SetActive(false)
	end
end

function BaoBaoAttrView:FlushView()
	self.node_list["TxtAutoBtnName"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
	local baby_info = BaobaoData.Instance:GetSelectedBabyInfo()
	if nil == baby_info then
		self.node_list["ProgressTxt"].text.text = "--/--"
		--self.node_list["ProgressValue"].slider.value = 1.0
		self.progress_value:SetValue(1.0)
		self.node_list["TxtStuff"].text.text = ""
		return
	end
	local max_baby_grade = BaobaoData.Instance:GetBabyUpgradeCfgMaxGrade()
	local cur_jie_attr = BaobaoData.Instance:GetBabyJieAttribute(baby_info.grade)
	local next_jie = baby_info.grade >= max_baby_grade and baby_info.grade or baby_info.grade + 1
	local next_jie_attr = BaobaoData.Instance:GetBabyJieAttribute(next_jie)
	local attr = BaobaoData.Instance:GetBabyInfoCfg(baby_info.baby_id)
	local change_attr = CommonDataManager.GetAttributteByClass(attr)
	local lerp_attr = CommonDataManager.LerpAttributeAttr(cur_jie_attr, next_jie_attr)    -- 属性差
	local had_next_jie = false
	if next_jie == baby_info.grade + 1 then
	   had_next_jie = true
	end
	local index = 1
	for i,v in ipairs(BaobaoData.Attr) do
		if self.attr_t[index] and Language.Common.AttrName[v] then
			if tonumber(cur_jie_attr[v]) >= 0 then
				self.attr_t[index].text.text = cur_jie_attr[v] + change_attr[v] or 0
				if had_next_jie and tonumber(lerp_attr[v]) >= 0 then
					self.attr_n[index].text.text = lerp_attr[v] or 0
				end
				index = index + 1
			end
		end
	end
	self:FlushAttr(had_next_jie)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = CommonDataManager.GetCapability(cur_jie_attr)+CommonDataManager.GetCapability(attr)
	end
	local baby_grade = baby_info.grade or 0
	local baby_bless = baby_info.bless or 0

	local upgrade_cfg = BaobaoData.Instance:GetBabyUpgradeCfg(baby_grade)
	if nil == upgrade_cfg then return end
	local item_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.consume_stuff_id)
	local item_name = ItemData.Instance:GetItemName(upgrade_cfg.consume_stuff_id) or ""
	local color = upgrade_cfg.consume_stuff_num > item_num and "#ff0000" or "#89F201"
	self.node_list["TxtStuff"].text.text = string.format(Language.Marriage.BaobaoStuffTxt, item_name, upgrade_cfg.consume_stuff_num, color, item_num)
	self.node_list["TxtItemStuff"].text.text = string.format(Language.Marriage.BaobaoStuff, color,item_num,upgrade_cfg.consume_stuff_num)
	self.stuff_item:SetData({item_id = upgrade_cfg.consume_stuff_id})
	
	if baby_bless >= 0 and 0 ~= upgrade_cfg.max_bless_value and baby_grade < max_baby_grade then
		self.node_list["ProgressTxt"].text.text = baby_bless .. "/" .. upgrade_cfg.max_bless_value
		local percent = baby_bless / upgrade_cfg.max_bless_value
		--self.node_list["ProgressValue"].slider.value = percent
		self.progress_value:SetValue(percent)
	end
	if baby_info.grade >= max_baby_grade then
		self.node_list["ProgressTxt"].text.text = Language.Common.MaxLv
		--self.node_list["ProgressValue"].slider.value = 1.0
		self.progress_value:SetValue(1.0)
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
		self.node_list["TxtAutoBtnName"].text.text = Language.Advance.MaxGradeText
		self.node_list["TxtItemStuff"].text.text = Language.Common.MaxLevelDesc
		self.node_list["TxtStuff"].text.text = string.format(Language.Marriage.BaobaoStuffTxt, item_name, upgrade_cfg.consume_stuff_num, color, item_num)
	-- else
	--     if self.is_auto_upgrade then
	--         UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
	--     else
	--         UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
	--     end
	end

	local baby_list = BaobaoData.Instance:GetListBabyData() or {}
	local selected_index = BaobaoData.Instance:GetSelectedBabyIndex()
	local cur_baby_info = BaobaoData.Instance:GetBabyInfo(selected_index)
	if cur_baby_info then
		local baby_grade = cur_baby_info.grade
		for i = 1, #baby_list do
			if selected_index == i then
				if self.temp_grade[i] ~= - 1 then
					if self.temp_grade[i] < baby_grade then
						-- 升级特效
						if not self.effect_cd or self.effect_cd <= Status.NowTime then
							self.node_list["Effect"]:SetActive(false)
							self.node_list["Effect"]:SetActive(true)
							self.effect_cd = EFFECT_CD + Status.NowTime
						end
					end
				end
				self.temp_grade[i] = baby_grade
			end
		end
	end
   
	if self.selectindex ~= BaobaoData.Instance:GetSelectedBabyIndex() then
		self.is_auto_upgrade = false
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)   
		self.node_list["TxtAutoBtnName"].text.text = self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1]
		self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()
		self:FlushView()
	end

end

function BaoBaoAttrView:ClickTitleShow()
	local baby_title_cfg = BaobaoData.Instance:GetBabyOtherCfg()
	if baby_title_cfg then
	  TipsCtrl.Instance:OpenItem({item_id = baby_title_cfg.title_show})
	end
end
