CheckShenGongView = CheckShenGongView or BaseClass(BaseRender)
function CheckShenGongView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckShenGongView:__delete()
	self.attr = nil
	self.fight_text = nil
end


function CheckShenGongView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function CheckShenGongView:OnFlush()
	if self.attr then
		local shengong_attr = self.attr.shengong_attr
		local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_attr.grade)
		local attr = CommonDataManager.GetAttributteByClass(shengong_grade_cfg)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(ShengongShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * shengong_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shengong_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shengong_attr.shuxingdan_count

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
			self.fight_text.text.text = shengong_attr.capability or 0
		end
		local grade = self.attr.shengong_attr.client_grade + 1

		local shengong_cfg = ShengongData.Instance:GetShengongGradeCfg(grade)
		if nil == shengong_cfg then return end
		local image_id = shengong_cfg.image_id

		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShengongData.Instance:GetShengongImageCfg(image_id)[image_id].image_name.."</color>"

		if self.attr.shengong_attr.client_grade == 0 then
			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.attr.shengong_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])

		end
		self:SetModle()
	end
end

function CheckShenGongView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.xiannv_attr then
		self.attr = check_attr
		self:Flush()
	end
end

function CheckShenGongView:SetModle()
	if self.attr and self.attr.shengong_attr.client_grade + 1 ~= 0 then
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

		if self.attr.shengong_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShengongData.Instance:GetSpecialImagesCfg()[self.attr.shengong_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = ShengongData.Instance:GetShengongImageCfg()[self.attr.shengong_attr.used_imageid].res_id
		end
		info.halo_res_id = res_id

		UIScene:SetGoddessModelResInfo(info)

		if self.time_quest ~= nil then
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end
	else
		UIScene:IsNotCreateRoleModel(false)
	end
end

function CheckShenGongView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function CheckShenGongView:CalToShowAnim()
	self:CancelTheQuest()
	local part = nil
	if UIScene.role_model then
		part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	end
	self.timer = FIX_SHOW_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			if part then
				part:SetTrigger(ANIMATOR_PARAM.ATTACK1)
			end
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end
