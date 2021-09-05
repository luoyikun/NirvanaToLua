CheckShenyiView = CheckShenyiView or BaseClass(BaseRender)
function CheckShenyiView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckShenyiView:__delete()
	self.attr = nil
	self.fight_text = nil
end

function CheckShenyiView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckShenyiView:OnFlush()
	if self.attr then
		local shenyi_attr = self.attr.shenyi_attr
		local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_attr.grade)
		local attr = CommonDataManager.GetAttributteByClass(shenyi_grade_cfg)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(ShenyiShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * shenyi_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shenyi_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shenyi_attr.shuxingdan_count

		self.node_list["TxtGongji"].text.text = (attr.gong_ji or 0) + zizhi_gongji
		self.node_list["TxtFangyu"].text.text = (attr.fang_yu or 0) + zizhi_fangyu
		self.node_list["TxtShengming"].text.text = (attr.max_hp or 0) + zizhi_hp
		self.node_list["TxtMingzhong"].text.text = attr.ming_zhong or 0
		self.node_list["TxtShanbi"].text.text = attr.shan_bi or 0
		self.node_list["TxtBaoji"].text.text = attr.bao_ji or 0
		self.node_list["TxtKangbao"].text.text = attr.jian_ren or 0
		self.node_list["TxtZengshang"].text.text = attr.per_pofang or 0
		self.node_list["TxtMianshang"].text.text = attr.per_mianshang or 0

		self.node_list["GongJi"]:SetActive(attr.gong_ji and attr.gong_ji + zizhi_gongji > 0)
		self.node_list["FangYu"]:SetActive(attr.fang_yu and attr.fang_yu + zizhi_fangyu > 0)
		self.node_list["ShengMing"]:SetActive(attr.max_hp and attr.max_hp + zizhi_hp > 0)
		self.node_list["MingZhong"]:SetActive(attr.ming_zhong and attr.ming_zhong > 0)
		self.node_list["ShanBi"]:SetActive(attr.shan_bi and attr.shan_bi > 0)
		self.node_list["BaoJi"]:SetActive(attr.bao_ji and attr.bao_ji > 0)
		self.node_list["KangBao"]:SetActive(attr.jian_ren and attr.jian_ren > 0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = shenyi_attr.capability
		end
		local grade = shenyi_attr.client_grade + 1

		local used_imageid = shenyi_attr.used_imageid
		if used_imageid > 1000 then
			used_imageid = used_imageid - 1000
		end
		local image_id = ShenyiData.Instance:GetImageListInfo(used_imageid).image_name
		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShenyiData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"

		if shenyi_attr.used_imageid == 0 then
			self.node_list["TxtName"].text.text = name_str
		else

			local grade_txt = CheckData.Instance:GetGradeName(shenyi_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
		end

		self:SetModle()
	end
end

function CheckShenyiView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.xiannv_attr then
		self.attr = check_attr
		self:Flush()
	end
end

function CheckShenyiView:SetModle()
	UIScene:SetActionEnable(false)
	if self.attr.shenyi_attr.client_grade + 1 ~= 0 then
		local info = {}
		local goddess_data = GoddessData.Instance
		info.role_res_id = -1

		local goddess_huanhua_id = self.attr.xiannv_attr.huanhua_id
		if goddess_huanhua_id > 0 then
			info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
		else
			local goddess_id = self.attr.xiannv_attr.pos_list[1]
			if goddess_id == -1 then
				goddess_id = 0
			end
			info.role_res_id = GoddessData.Instance:GetXianNvCfg(goddess_id).resid
		end

		if self.attr.shenyi_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShenyiData.Instance:GetSpecialImagesCfg()[self.attr.shenyi_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = ShenyiData.Instance:GetShenyiImageCfg()[self.attr.shenyi_attr.used_imageid].res_id
		end
		info.fazhen_res_id = res_id

		UIScene:SetGoddessModelResInfo(info)


		if self.time_quest ~= nil then
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end

		self:CalToShowAnim(true)
	else
		UIScene:IsNotCreateRoleModel(false)
	end
end

function CheckShenyiView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end
function CheckShenyiView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if timer <= 6 then
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
		end
	end, 0)

end

function CheckShenyiView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
end