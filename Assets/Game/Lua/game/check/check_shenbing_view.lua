CheckShenBingView = CheckShenBingView or BaseClass(BaseRender)
function CheckShenBingView:__init(instance)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanli"])
end

function CheckShenBingView:__delete()
	self.shenbing_attr = nil
	self.fight_text = nil
end


function CheckShenBingView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["RightFrame"], CheckData.TweenPosition.RightFrame , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end


function CheckShenBingView:OnFlush()
	if self.shenbing_attr then
		local shenbing_attr = self.shenbing_attr
		self.node_list["TxtGongji"].text.text = self.shenbing_attr.gong_ji
		self.node_list["TxtFangyu"].text.text = self.shenbing_attr.fang_yu
		self.node_list["TxtShengming"].text.text = self.shenbing_attr.max_hp
		self.node_list["TxtMingzhong"].text.text = self.shenbing_attr.ming_zhong
		self.node_list["TxtShanbi"].text.text = self.shenbing_attr.shan_bi
		self.node_list["TxtBaoji"].text.text = self.shenbing_attr.bao_ji
		self.node_list["TxtKangbao"].text.text = self.shenbing_attr.jian_ren
		self.node_list["TxtZengshang"].text.text = self.shenbing_attr.per_pofang
		self.node_list["TxtMianshang"].text.text = self.shenbing_attr.per_mianshang

		self.node_list["GongJi"]:SetActive(self.shenbing_attr.gong_ji and self.shenbing_attr.gong_ji > 0)
		self.node_list["FangYu"]:SetActive(self.shenbing_attr.fang_yu and self.shenbing_attr.fang_yu > 0)
		self.node_list["ShengMing"]:SetActive(self.shenbing_attr.max_hp and self.shenbing_attr.max_hp > 0)
		self.node_list["MingZhong"]:SetActive(self.shenbing_attr.ming_zhong and self.shenbing_attr.ming_zhong > 0)
		self.node_list["ShanBi"]:SetActive(self.shenbing_attr.shan_bi and self.shenbing_attr.shan_bi > 0)
		self.node_list["BaoJi"]:SetActive(self.shenbing_attr.bao_ji and self.shenbing_attr.bao_ji > 0)
		self.node_list["KangBao"]:SetActive(self.shenbing_attr.jian_ren and self.shenbing_attr.jian_ren > 0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = self.shenbing_attr.capability
		end
		local grade = self.shenbing_attr.client_grade + 1

			local shengbing_cfg = MountData.Instance:GetMountGradeCfg(grade)
			if shengbing_cfg == nil then return end
			local image_id = shengbing_cfg.image_id

			local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
			local image_id_cfg = FashionData.Instance:GetShizhuangImg(image_id)
			if not image_id_cfg then return end

			local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_id_cfg.image_name.."</color>"


		if self.shenbing_attr.client_grade == 0 then

			self.node_list["TxtName"].text.text = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(self.shenbing_attr.client_grade)
			self.node_list["TxtName"].text.text = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])

		end
		self:SetModle()

	end
end

function CheckShenBingView:SetAttr()
	local check_attr = CheckData.Instance:UpdateAttrView()
	if check_attr and check_attr.shenbing_attr then
		self.shenbing_attr = check_attr.shenbing_attr
		self:Flush()
	end
	self:SetModle()
end

function CheckShenBingView:SetModle()
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info == nil then return end
	
	if self.shenbing_attr.client_grade + 1 ~= 0 then
		local info = {}
		info.prof = role_info.prof
		info.sex = role_info.sex
		info.is_not_show_weapon = false

		local fashion_info = role_info.shizhuang_part_list[2]
		local wuqi_info = role_info.shizhuang_part_list[1]
		local is_used_special_img = fashion_info.use_special_img
		info.is_normal_fashion = is_used_special_img == 0
		info.is_normal_wuqi = true
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		local wuqi_id = wuqi_info.grade == 0 and wuqi_info.grade or wuqi_info.grade - 1
		info.shizhuang_part_list = {{image_id = wuqi_id}, {image_id = fashion_id}}
		UIScene:SetRoleModelResInfo(info)

		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetBool(ANIMATOR_PARAM.FIGHT, true)
		end
	end
end
