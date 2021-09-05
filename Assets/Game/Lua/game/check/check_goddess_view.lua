CheckGoddessView = CheckGoddessView or BaseClass(BaseRender)
function CheckGoddessView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckGoddessView:__delete()
	self.all_attr = nil
	self.fight_text = nil
end

function CheckGoddessView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.xiannv_attr then
		self.all_attr = check_attr
		self:Flush()
	end
end

function CheckGoddessView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckGoddessView:OnFlush()
	if self.all_attr then
		local goddess_data = GoddessData.Instance
		self.node_list["TxtGongji"].text.text = goddess_data:GetAllSingleAttr(GODDESS_ATTR_TYPE.GONG_JI, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.present_attr.level)
		self.node_list["TxtFangyu"].text.text = goddess_data:GetAllSingleAttr(GODDESS_ATTR_TYPE.FANG_YU, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.present_attr.level)
		self.node_list["TxtShengming"].text.text = goddess_data:GetAllSingleAttr(GODDESS_ATTR_TYPE.SHENG_MING, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.present_attr.level)

		local attr = GoddessData.Instance:GetXiannvAttrByRoleInfo(self.all_attr)
		self.node_list["TxtGongji"].text.text = attr.gongji or 0
		self.node_list["TxtFangyu"].text.text = attr.fangyu or 0
		self.node_list["TxtShengming"].text.text = attr.maxhp or 0
		self.node_list["TxtMingzhong"].text.text = attr.ming_zhong or 0
		self.node_list["TxtShanbi"].text.text = attr.shan_bi or 0
		self.node_list["TxtBaoji"].text.text = attr.bao_ji or 0
		self.node_list["TxtKangbao"].text.text = attr.jian_ren or 0
		self.node_list["TxtZengshang"].text.text = attr.per_pofang or 0
		self.node_list["TxtMianshang"].text.text = attr.per_mianshang or 0

		self.node_list["GongJi"]:SetActive(attr.gongji and attr.gongji > 0)
		self.node_list["FangYu"]:SetActive(attr.fangyu and attr.fangyu > 0)
		self.node_list["ShengMing"]:SetActive(attr.maxhp and attr.maxhp > 0)
		self.node_list["MingZhong"]:SetActive(attr.ming_zhong and attr.ming_zhong > 0)
		self.node_list["ShanBi"]:SetActive(attr.shan_bi and attr.shan_bi > 0)
		self.node_list["BaoJi"]:SetActive(attr.bao_ji and attr.bao_ji > 0)
		self.node_list["KangBao"]:SetActive(attr.jian_ren and attr.jian_ren > 0)

		local zhanli = math.floor(goddess_data:GetAllPower(self.all_attr.xiannv_attr.pos_list, self.all_attr.present_attr.level, self.all_attr.xiannv_attr.xiannv_item_list, self.all_attr.xiannv_attr.xiannv_huanhua_level))
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.all_attr.xiannv_attr.capability or 0
		end
		if self.all_attr.xiannv_attr.xiannv_name ~= "" then
			self.node_list["TxtName"].text.text = self.all_attr.xiannv_attr.xiannv_name
		else
			local show_id = self.all_attr.xiannv_attr.pos_list[1]
			if show_id == -1 then
				local active_list = goddess_data:GetXiannvActiveList(self.all_attr.xiannv_attr.xiannv_item_list)
				if #active_list ~= 0 then
					show_id = active_list[1]
					self.node_list["TxtName"].text.text = goddess_data:GetXianNvCfg(show_id).name
				else

				end
			else
				self.node_list["TxtName"].text.text = goddess_data:GetXianNvCfg(show_id).name
			end
		end

		-- for k,v in pairs(self.all_attr.xiannv_attr.pos_list) do
			-- if v == -1 then
				-- local tips_text = "阵位未开启"
				-- self.node_list["TxtDesc" .. k].text.text =(tips_text)
			-- else
				-- self.node_list["TxtDesc" .. k].text.text =(math.floor(goddess_data:GetSingleCampPower(k, v, self.all_attr.xiannv_attr.xiannv_item_list)))
			-- end
		-- end
		self:SetModle()
	end
end

function CheckGoddessView:SetModle()
	UIScene:SetActionEnable(false)
	local goddess_data = GoddessData.Instance
	local info = {}
	info.role_res_id = -1
	local goddess_data = GoddessData.Instance
	local goddess_huanhua_id = self.all_attr.xiannv_attr.huanhua_id

	if goddess_huanhua_id > 0 then
		info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
	else
		local goddess_id = self.all_attr.xiannv_attr.pos_list[1]
		if goddess_id == -1 then
			goddess_id = 0
		end
		info.role_res_id = GoddessData.Instance:GetXianNvCfg(goddess_id).resid
	end

	UIScene:SetGoddessModelResInfo(info)
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end


	self:CalToShowAnim(true)
end

function CheckGoddessView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			self:PlayAnim(is_change_tab)
			is_change_tab = false
			timer = GameEnum.GODDESS_ANIM_LONG_TIME
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end
	end, 0)

end

function CheckGoddessView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
end