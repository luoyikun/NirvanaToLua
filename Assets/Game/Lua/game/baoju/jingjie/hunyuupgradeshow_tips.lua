HunyuUpgradeShowTips = HunyuUpgradeShowTips or BaseClass(BaseView)

function HunyuUpgradeShowTips:__init()
	self.ui_config = {{"uis/views/baoju_prefab", "HunyuUpgradeShowTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = true							-- 是否点击其它地方要关闭界面
end

function HunyuUpgradeShowTips:__delete()

end

function HunyuUpgradeShowTips:LoadCallBack()
	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClickOK, self))

	self.fight_text_curr = CommonDataManager.FightPower(self, self.node_list["CurFightText"], "FightPower3")
	self.fight_text_next = CommonDataManager.FightPower(self, self.node_list["NextFightText"], "FightPower3")
end

function HunyuUpgradeShowTips:ReleaseCallBack()
	self.fight_text_curr = nil
	self.fight_text_next = nil

	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function HunyuUpgradeShowTips:OpenCallBack()
	self.ok_callback = function ()
		self:Close()
	end

	self.cancle_callback = function ()
		self:Close()
	end
	self:Flush()
end

function HunyuUpgradeShowTips:CloseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function HunyuUpgradeShowTips:OnFlush(param_list)
	self:CalTime()
	self:SetInfo()
end

function HunyuUpgradeShowTips:SetData(data, next_data, ok_callback)
	self.data = data
	self.next_data = next_data
	self.ok_callback = ok_callback
end

function HunyuUpgradeShowTips:SetInfo()
	if nil == self.data then
		return
	end
	self.node_list["CurGongJi"].text.text = Language.Player.AttrNameShengYin.gongji .. ToColorStr(self.data.gongji, Color.WHITE)
	self.node_list["CurFangYu"].text.text = Language.Player.AttrNameShengYin.fangyu .. ToColorStr(self.data.fangyu, Color.WHITE)
	self.node_list["CurHp"].text.text = Language.Player.AttrNameShengYin.maxhp .. ToColorStr(self.data.maxhp, Color.WHITE)
	self.node_list["CurHunyuName"].text.text = self.data.name_hunyu
	if self.fight_text_curr and self.fight_text_curr.text then
		self.fight_text_curr.text.text = CommonDataManager.GetCapabilityCalculation(self.data)
	end
	self.node_list["CurItemImage"].image:LoadSprite(ResPath.GetHunyuIcon(self.data.pic_hunyu))
	self.node_list["CurItembg"].image:LoadSprite(ResPath.GetQualityIcon(self.data.color))

	if nil == self.next_data then
		self.node_list["NodeNext"]:SetActive(false)
		self.node_list["NodeArrow"]:SetActive(false)
		return
	end
	self.node_list["NodeNext"]:SetActive(true)
	self.node_list["NodeArrow"]:SetActive(true)
	self.node_list["NextGongJi"].text.text = Language.Player.AttrNameShengYin.gongji .. ToColorStr(self.next_data.gongji, Color.WHITE)
	self.node_list["NextFangYu"].text.text = Language.Player.AttrNameShengYin.fangyu .. ToColorStr(self.next_data.fangyu, Color.WHITE)
	self.node_list["NextHp"].text.text = Language.Player.AttrNameShengYin.maxhp .. ToColorStr(self.next_data.maxhp, Color.WHITE)
	self.node_list["NextHunyuName"].text.text = self.next_data.name_hunyu
	if self.fight_text_next and self.fight_text_next.text then
		self.fight_text_next.text.text = CommonDataManager.GetCapabilityCalculation(self.next_data)
	end
	self.node_list["NextItemImage"].image:LoadSprite(ResPath.GetHunyuIcon(self.next_data.pic_hunyu))
	self.node_list["NextItembg"].image:LoadSprite(ResPath.GetQualityIcon(self.next_data.color))
end

function HunyuUpgradeShowTips:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 10
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			if self.ok_callback then
				self.ok_callback()
			end
			self:Close()
			self.cal_time_quest = nil
		else
			self.node_list["TxtDescText"].text.text = string.format(Language.Tips.PaTaTipsWithRewardBtnTxt, math.floor(timer_cal))
		end
	end, 0)
end

---点击事件
function HunyuUpgradeShowTips:OnClickOK()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end