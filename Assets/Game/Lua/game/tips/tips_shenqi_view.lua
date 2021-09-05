ShenQiTipsView = ShenQiTipsView or BaseClass(BaseView)
local QUALITYA = 4
local ITEM_NUM = 4
local QIBINGNUM = 3 			--奇兵数量
local DUNJIANUM = 3 			--遁甲数量

function ShenQiTipsView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
		{"uis/views/tips/shenqitips_prefab", "ShenQiEffectTips"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_3"},
	}

	self.data = nil
	self.data_list = nil
	self.index = 1
	self.is_modal = true
	self.show_type = ShenqiData.ChooseType.JianLing
	self.item_id = 0
	self.texiao_index = 0
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenQiTipsView:__delete()

end

local MOVE_TIME = 0.5


function ShenQiTipsView:LoadCallBack()
	-- UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(739 , -21 , 0 ) , MOVE_TIME )
	-- UITween.MoveShowPanel(self.node_list["LeftPanel"] , Vector3(-918 , 30 , 0 ) , MOVE_TIME )
	--event
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	-- self:ListenEvent("ClickClose", BindTool.Bind(self.ClickClose, self))
	self.node_list["ClickGo"].button:AddClickListener(BindTool.Bind(self.ClickActive, self))
	self.node_list["ButtonUse"].button:AddClickListener(BindTool.Bind(self.ClickUse, self))
	self.node_list["ButtonShouGou"].button:AddClickListener(BindTool.Bind(self.OnButtonShouGou, self))
	-- self:ListenEvent("ClickActive", BindTool.Bind(self.ClickActive, self))
	-- self:ListenEvent("ClickUse", BindTool.Bind(self.ClickUse, self))
	 local  info = ShenqiData.Instance:GetShenqiAllInfo()
	self.texiao_index = info.texiao_open_flag
	if self.texiao_index == 1 then
		self.node_list["Toggle1"].toggle.isOn = true
	else
		self.node_list["Toggle1"].toggle.isOn = false
	end
	self.node_list["Toggle1"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleShenqiOnClick,self))
	self.node_list['Toggle1']:SetActive(false)
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	
	--obj
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display,MODEL_CAMERA_TYPE.BASE)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
end

function ShenQiTipsView:ReleaseCallBack()
	if self.model then
		self.model:RemoveHead()
		if self.model.draw_obj ~= nil then
			self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 0)
		end		
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.item_data_event = nil
end

function ShenQiTipsView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ShenQiTipsView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function ShenQiTipsView:OnFlush()
	self:FlushCfg()
	self:FlushOther()
	self:FlushAttribute()
	self:FlushNowEffect()
	self:FlushModel()
end
	
function ShenQiTipsView:Show(index, cfg, shenqi_type)
	if nil == cfg and nil == cfg[index] then
		return
	end
	self.cfg = cfg
	self.index = index
	local is_active1 = false
	local select_index = index
	if shenqi_type == ShenqiData.ChooseType.JianLing then
		is_active1 = ShenqiData.Instance:GetJiangLingTeXiaoByIndex(self.index)
		if is_active1 then 
			select_index = select_index + QIBINGNUM
		end
	elseif shenqi_type == ShenqiData.ChooseType.BaoJia then
		is_active1 = ShenqiData.Instance:GetBaoJiaTeXiaoByIndex(self.index)
		if is_active1 then 
			select_index = select_index + DUNJIANUM
		end
	end
	self.data = cfg[select_index]
	self.show_type = shenqi_type
end

function ShenQiTipsView:FlushOther()
	if nil == self.data then
		return
	end
	self.node_list["Name"].text.text = self.data.name
	self.node_list["TitleText"].text.text = self.data.name
	self.node_list["TeXiaoText"].text.text = self.data.str1
	self.node_list["TeXiaoText1"].text.text = self.data.str3 
end

function ShenQiTipsView:FlushCfg()
	local is_active1 = false
	local select_index = self.index
	if self.show_type == ShenqiData.ChooseType.JianLing then
		is_active1 = ShenqiData.Instance:GetJiangLingTeXiaoByIndex(self.index)
		if is_active1 then 
			select_index = select_index + QIBINGNUM
		end
	elseif self.show_type == ShenqiData.ChooseType.BaoJia then
		is_active1 = ShenqiData.Instance:GetBaoJiaTeXiaoByIndex(self.index)
		if is_active1 then 
			select_index = select_index + DUNJIANUM
		end
	end
	self.data = self.cfg[select_index]
	local is_active = ""
	local is_active1 = ""
	if self.show_type == ShenqiData.ChooseType.BaoJia then
		is_active, is_active1 = ShenqiData.Instance:GetBaoJiaTeXiaoByIndex(self.index)
	else
		is_active, is_active1 = ShenqiData.Instance:GetJiangLingTeXiaoByIndex(self.index)
	end
	if is_active and not is_active1  then
		self.data_list = self.cfg[select_index - QIBINGNUM]
	end
end

function ShenQiTipsView:FlushAttribute()
	-- self.node_list["KangbaoValue"].text.text = self.data.jianren
	-- self.node_list["BaojiValue"].text.text = self.data.baoji
	-- self.node_list["MingzhongValue"].text.text = self.data.mingzhong
	-- self.node_list["JianShangValue"].text.text = self.data.jianshang_per and ((self.data.jianshang_per / 100) .. "%") or 0
	local is_active = ""
	local is_active1 = ""
	if self.show_type == ShenqiData.ChooseType.BaoJia then
		is_active, is_active1 = ShenqiData.Instance:GetBaoJiaTeXiaoByIndex(self.index)
	else
		is_active, is_active1 = ShenqiData.Instance:GetJiangLingTeXiaoByIndex(self.index)
	end


	if is_active == false and is_active1 == false then
		self.node_list["GongjiValue"].text.text = 0
		self.node_list["FangyuValue"].text.text = 0
		self.node_list["HpValue"].text.text = 0
		self.node_list["PoJiaValue"].text.text = (0 .. "%")
		self.node_list["ZhuFuValue"].text.text = (0 .. "%")
		-- self.node_list["JianShangValue"].text.text  = self.data.skill_jianshang_per and ((self.data.skill_jianshang_per / 100) .. "%") or 0 
		-- self.node_list["ShangBiValue"].text.text = self.data.shanbi_per and ((self.data.shanbi_per) / 100 .. "%") or 0
		self.node_list["pergongji"].text.text = (0 .. "%")
		self.node_list["perfangyu"].text.text = (0 .. "%") 
		self.node_list["permaxhp"].text.text = (0 .. "%") 
		self.node_list["perpofang"].text.text = (0 .. "%") 
		self.node_list["permianshang"].text.text = (0 .. "%") 
		self.node_list["skilljs"].text.text = (0 .. "%") 
		self.node_list["shanbi"].text.text = (0 .. "%") 
		self.node_list["nextgongji"].text.text = self.data.gongji
		self.node_list["nextfangyu"].text.text = self.data.fangyu
		self.node_list["nexthp"].text.text = self.data.maxhp
		self.node_list["nextpojia"].text.text = self.data.pojia_per and ((self.data.pojia_per / 100) .. "%") or 0
		self.node_list["nextzhufu"].text.text = self.data.zhufu_per and ((self.data.zhufu_per / 100) .. "%") or 0
		self.node_list["nextallgongji"].text.text = self.data.per_gongji and ((self.data.per_gongji / 100) .. "%") or 0
		self.node_list["nextallfangyu"].text.text = self.data.per_fangyu and ((self.data.per_fangyu / 100) .. "%") or 0
		self.node_list["nextmaxhp"].text.text = self.data.per_maxhp and ((self.data.per_maxhp / 100) .. "%") or 0
		self.node_list["nextpofang"].text.text = self.data.per_pofang and ((self.data.per_pofang / 100) .. "%") or 0
		self.node_list["nextmianshang"].text.text = self.data.per_mianshang and ((self.data.per_mianshang / 100) .. "%") or 0
		self.node_list["nextjianshan"].text.text = self.data.jianshang_per and ((self.data.jianshang_per / 100) .. "%") or 0
		self.node_list["nextshanbi"].text.text = self.data.shangbi_per and ((self.data.shangbi_per / 100) .. "%") or 0
		self.node_list["Imagegj"]:SetActive(true)
		self.node_list["Imagefy"]:SetActive(true)
		self.node_list["Imagehp"]:SetActive(true)
		self.node_list["Imagepj"]:SetActive(true)
		self.node_list["Imagezf"]:SetActive(true)
		self.node_list["Imageallgj"]:SetActive(true)
		self.node_list["Imageallfy"]:SetActive(true)
		self.node_list["Imagemaxhp"]:SetActive(true)
		self.node_list["Imagepf"]:SetActive(true)
		self.node_list["Imagems"]:SetActive(true)
		self.node_list["Imagejs"]:SetActive(true)
		self.node_list["Imagesb"]:SetActive(true)
		self.node_list["nextgongji"]:SetActive(true)
		self.node_list["nextfangyu"]:SetActive(true)
		self.node_list["nexthp"]:SetActive(true)
		self.node_list["nextpojia"]:SetActive(true)
		self.node_list["nextzhufu"]:SetActive(true)
		self.node_list["nextallgongji"]:SetActive(true)
		self.node_list["nextallfangyu"]:SetActive(true)
		self.node_list["nextmaxhp"]:SetActive(true)
		self.node_list["nextpofang"]:SetActive(true)
		self.node_list["nextmianshang"]:SetActive(true)
		self.node_list["nextjianshan"]:SetActive(true)
		self.node_list["nextshanbi"]:SetActive(true)
	elseif is_active == true and is_active1 == false then
		self.node_list["GongjiValue"].text.text = self.data_list.gongji
		self.node_list["FangyuValue"].text.text = self.data_list.fangyu
		self.node_list["HpValue"].text.text = self.data_list.maxhp
		self.node_list["PoJiaValue"].text.text = self.data_list.pojia_per and ((self.data_list.pojia_per / 100) .. "%") or 0
		self.node_list["ZhuFuValue"].text.text = self.data_list.zhufu_per and ((self.data_list.zhufu_per / 100) .. "%") or 0
		-- self.node_list["JianShangValue"].text.text  = self.data_list.skill_jianshang_per and ((self.data_list.skill_jianshang_per / 100) .. "%") or 0 
		-- self.node_list["ShangBiValue"].text.text = self.data_list.shanbi_per and ((self.data_list.shanbi_per) / 100 .. "%") or 0
		self.node_list["pergongji"].text.text = self.data_list.per_gongji and ((self.data_list.per_gongji) / 100 .. "%") or 0 
		self.node_list["perfangyu"].text.text = self.data_list.per_fangyu and ((self.data_list.per_fangyu) / 100 .. "%") or 0 
		self.node_list["permaxhp"].text.text = self.data_list.per_maxhp and ((self.data_list.per_maxhp) / 100 .. "%") or 0 
		self.node_list["perpofang"].text.text = self.data_list.per_pofang and ((self.data_list.per_pofang) / 100 .. "%") or 0 
		self.node_list["permianshang"].text.text = self.data_list.per_mianshang and ((self.data_list.per_mianshang) / 100 .. "%") or 0 
		self.node_list["skilljs"].text.text = self.data_list.jianshang_per and ((self.data_list.jianshang_per) / 100 .. "%") or 0 
		self.node_list["shanbi"].text.text = self.data_list.shangbi_per and ((self.data_list.shangbi_per) / 100 .. "%") or 0 
		self.node_list["nextgongji"].text.text = self.data.gongji - self.data_list.gongji
		self.node_list["nextfangyu"].text.text = self.data.fangyu - self.data_list.fangyu
		self.node_list["nexthp"].text.text = self.data.maxhp - self.data_list.maxhp
		self.node_list["nextpojia"].text.text = self.data.pojia_per and (((self.data.pojia_per - self.data_list.pojia_per) / 100) .. "%") or 0
		self.node_list["nextzhufu"].text.text = self.data.zhufu_per and (((self.data.zhufu_per - self.data_list.zhufu_per) / 100) .. "%") or 0
		self.node_list["nextallgongji"].text.text = self.data.per_gongji and (((self.data.per_gongji - self.data_list.per_gongji) / 100) .. "%") or 0
		self.node_list["nextallfangyu"].text.text = self.data.per_fangyu and (((self.data.per_fangyu - self.data_list.per_fangyu) / 100) .. "%") or 0
		self.node_list["nextmaxhp"].text.text = self.data.per_maxhp and (((self.data.per_maxhp - self.data_list.per_maxhp) / 100) .. "%") or 0
		self.node_list["nextpofang"].text.text = self.data.per_pofang and (((self.data.per_pofang - self.data_list.per_pofang) / 100) .. "%") or 0
		self.node_list["nextmianshang"].text.text = self.data.per_mianshang and (((self.data.per_mianshang - self.data_list.per_mianshang) / 100) .. "%") or 0
		self.node_list["nextjianshan"].text.text = self.data.jianshang_per and (((self.data.jianshang_per - self.data_list.jianshang_per) / 100) .. "%") or 0
		self.node_list["nextshanbi"].text.text = self.data.shangbi_per and (((self.data.shangbi_per - self.data_list.shangbi_per) / 100) .. "%") or 0
		self.node_list["Imagegj"]:SetActive(true)
		self.node_list["Imagefy"]:SetActive(true)
		self.node_list["Imagehp"]:SetActive(true)
		self.node_list["Imagepj"]:SetActive(true)
		self.node_list["Imagezf"]:SetActive(true)
		self.node_list["Imageallgj"]:SetActive(true)
		self.node_list["Imageallfy"]:SetActive(true)
		self.node_list["Imagemaxhp"]:SetActive(true)
		self.node_list["Imagepf"]:SetActive(true)
		self.node_list["Imagems"]:SetActive(true)
		self.node_list["Imagejs"]:SetActive(true)
		self.node_list["Imagesb"]:SetActive(true)
		self.node_list["nextgongji"]:SetActive(true)
		self.node_list["nextfangyu"]:SetActive(true)
		self.node_list["nexthp"]:SetActive(true)
		self.node_list["nextpojia"]:SetActive(true)
		self.node_list["nextzhufu"]:SetActive(true)
		self.node_list["nextallgongji"]:SetActive(true)
		self.node_list["nextallfangyu"]:SetActive(true)
		self.node_list["nextmaxhp"]:SetActive(true)
		self.node_list["nextpofang"]:SetActive(true)
		self.node_list["nextmianshang"]:SetActive(true)
		self.node_list["nextjianshan"]:SetActive(true)
		self.node_list["nextshanbi"]:SetActive(true)
	elseif is_active == true and is_active1 == true then
		self.node_list["GongjiValue"].text.text = self.data.gongji
		self.node_list["FangyuValue"].text.text = self.data.fangyu
		self.node_list["HpValue"].text.text = self.data.maxhp
		self.node_list["PoJiaValue"].text.text = self.data.pojia_per and ((self.data.pojia_per / 100) .. "%") or 0
		self.node_list["ZhuFuValue"].text.text = self.data.zhufu_per and ((self.data.zhufu_per / 100) .. "%") or 0
		-- self.node_list["JianShangValue"].text.text  = self.data.skill_jianshang_per and ((self.data.skill_jianshang_per / 100) .. "%") or 0 
		-- self.node_list["ShangBiValue"].text.text = self.data.shanbi_per and ((self.data.shanbi_per) / 100 .. "%") or 0
		self.node_list["pergongji"].text.text = self.data.per_gongji and ((self.data.per_gongji) / 100 .. "%") or 0 
		self.node_list["perfangyu"].text.text = self.data.per_fangyu and ((self.data.per_fangyu) / 100 .. "%") or 0 
		self.node_list["permaxhp"].text.text = self.data.per_maxhp and ((self.data.per_maxhp) / 100 .. "%") or 0 
		self.node_list["perpofang"].text.text = self.data.per_pofang and ((self.data.per_pofang) / 100 .. "%") or 0 
		self.node_list["permianshang"].text.text = self.data.per_mianshang and ((self.data.per_mianshang) / 100 .. "%") or 0 
		self.node_list["skilljs"].text.text = self.data.jianshang_per and ((self.data.jianshang_per) / 100 .. "%") or 0 
		self.node_list["shanbi"].text.text = self.data.shangbi_per and ((self.data.shangbi_per) / 100 .. "%") or 0 
		self.node_list["Imagegj"]:SetActive(false)
		self.node_list["Imagefy"]:SetActive(false)
		self.node_list["Imagehp"]:SetActive(false)
		self.node_list["Imagepj"]:SetActive(false)
		self.node_list["Imagezf"]:SetActive(false)
		self.node_list["Imageallgj"]:SetActive(false)
		self.node_list["Imageallfy"]:SetActive(false)
		self.node_list["Imagemaxhp"]:SetActive(false)
		self.node_list["Imagepf"]:SetActive(false)
		self.node_list["Imagems"]:SetActive(false)
		self.node_list["Imagejs"]:SetActive(false)
		self.node_list["Imagesb"]:SetActive(false)
		self.node_list["nextgongji"]:SetActive(false)
		self.node_list["nextfangyu"]:SetActive(false)
		self.node_list["nexthp"]:SetActive(false)
		self.node_list["nextpojia"]:SetActive(false)
		self.node_list["nextzhufu"]:SetActive(false)
		self.node_list["nextallgongji"]:SetActive(false)
		self.node_list["nextallfangyu"]:SetActive(false)
		self.node_list["nextmaxhp"]:SetActive(false)
		self.node_list["nextpofang"]:SetActive(false)
		self.node_list["nextmianshang"]:SetActive(false)
		self.node_list["nextjianshan"]:SetActive(false)
		self.node_list["nextshanbi"]:SetActive(false)
	end
		self.node_list["Gongji"]:SetActive(self.data.gongji > 0)
		self.node_list["Fangyu"]:SetActive(self.data.fangyu > 0)
		self.node_list["Hp"]:SetActive(self.data.maxhp > 0)
		self.node_list["PoJia"]:SetActive(self.data.pojia_per > 0)
		self.node_list["ZhuFu"]:SetActive(self.data.zhufu_per > 0)
		-- self.node_list["JianShang"]:SetActive(self.data.skill_jianshang_per > 0)
		-- self.node_list["ShangBi"]:SetActive(self.data.shanbi_per > 0)
		self.node_list["Allgongji"]:SetActive(self.data.per_gongji > 0)
		self.node_list["Allfangyu"]:SetActive(self.data.per_fangyu > 0)
		self.node_list["Allshenming"]:SetActive(self.data.per_maxhp > 0)
		self.node_list["Allpofang"]:SetActive(self.data.per_pofang > 0)
		self.node_list["Allmianshang"]:SetActive(self.data.per_mianshang > 0)
		self.node_list["jianshangper"]:SetActive(self.data.jianshang_per > 0)
		self.node_list["shangbiper"]:SetActive(self.data.shangbi_per > 0)


end

--刷新激活状态
function ShenQiTipsView:FlushNowEffect()
	local info = ShenqiData.Instance:GetShenqiAllInfo()
	if nil == info then
		return
	end

	--没有激活
	local is_active1, is_active2 = false, false
	local is_use = false
	local data_index = 0
	if self.show_type == ShenqiData.ChooseType.JianLing then
		-- self.node_list["Gongji"]:SetActive(true)
		-- self.node_list["Mingzhong"]:SetActive(true)
		-- self.node_list["Baoji"]:SetActive(true)
		-- self.node_list["Fangyu"]:SetActive(false)
		-- self.node_list["Shanbi"]:SetActive(false)
		-- self.node_list["Kangbao"]:SetActive(false)
		-- self.node_list["Hp"]:SetActive(false)
		-- self.node_list["PoJia"]:SetActive(true)
		-- self.node_list["ZhuFu"]:SetActive(true)
		-- self.node_list["JianShang"]:SetActive(false)
		-- self.node_list["ShangBi"]:SetActive(false)
		is_active1, is_active2 = ShenqiData.Instance:GetJiangLingTeXiaoByIndex(self.index)
		if is_active1 == false then
			self.node_list["BtnText"].text.text = Language.Common.Activate
		elseif is_active1 == true then
			self.node_list["BtnText"].text.text = Language.Common.Up
		end
		is_use = (self.index == info.shenbing_cur_texiao_id)
		local data = ShenqiData.Instance:GetJianLingInfo(self.index)
		for i = 1, ITEM_NUM do 
			if data.quality_list[i] == QUALITYA then
				data_index  = data_index + 1
			end
		end
		self:WearColorQualified(data_index)
	elseif self.show_type == ShenqiData.ChooseType.BaoJia then
		-- self.node_list["Fangyu"]:SetActive(true)
		-- self.node_list["Shanbi"]:SetActive(true)
		-- self.node_list["Kangbao"]:SetActive(true)
		-- self.node_list["Hp"]:SetActive(true)
		-- self.node_list["Gongji"]:SetActive(false)
		-- self.node_list["Mingzhong"]:SetActive(false)
		-- self.node_list["Baoji"]:SetActive(false)
		-- self.node_list["JianShang"]:SetActive(true)
		-- self.node_list["ShangBi"]:SetActive(true)
		-- self.node_list["PoJia"]:SetActive(false)
		-- self.node_list["ZhuFu"]:SetActive(false)
		is_active1, is_active2 = ShenqiData.Instance:GetBaoJiaTeXiaoByIndex(self.index)
		if is_active1 == false then
			self.node_list["BtnText"].text.text = Language.Common.Activate
		elseif is_active1 == true  then
			self.node_list["BtnText"].text.text = Language.Common.Up
		end
		is_use = (self.index == info.baojia_cur_texiao_id)
		local data = ShenqiData.Instance:GetBaojiaInfo(self.index)
		for i = 1, ITEM_NUM do 
			if data.quality_list[i] == QUALITYA then
				data_index  = data_index + 1
			end
		end
		self:WearColorQualified(data_index)
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.appearance.baojia_texiao_id ~= 0 and self.show_type == ShenqiData.ChooseType.BaoJia  then
		self.node_list['Toggle1']:SetActive(false) -- 高聪让屏蔽的
	else
		self.node_list['Toggle1']:SetActive(false)
	end
	-- self.node_list["Fangyu"]:SetActive(self.data.fangyu > 0)
	-- self.node_list["Shanbi"]:SetActive(self.data.shanbi > 0)
	-- self.node_list["Kangbao"]:SetActive(self.data.jianren > 0)
	-- self.node_list["Hp"]:SetActive(self.data.maxhp > 0)
	-- self.node_list["Gongji"]:SetActive(self.data.gongji > 0)
	-- self.node_list["Mingzhong"]:SetActive(self.data.mingzhong > 0)
	-- self.node_list["Baoji"]:SetActive(self.data.baoji > 0)

	local is_active = is_active1 and is_active2
	if not is_active then
		self.node_list["ItemCell"]:SetActive(true)
		self.node_list["ButtonUse"]:SetActive(false)
		self.node_list["ClickGo"]:SetActive(true)
		self.item_cell:SetData({item_id = self.data.active_texiao_stuff_id})
		
		local now_num = ItemData.Instance:GetItemNumInBagById(self.data.active_texiao_stuff_id)
		-- local str = string.format(Language.Mount.ShowRedNum, now_num)
		-- local str1 = string.format(Language.Mount.ShowGreenNum, self.data.active_texiao_stuff_count)
		if now_num < self.data.active_texiao_stuff_count then
			self.node_list["RightPanelText"].text.text = string.format(Language.ShenQi.TipText,now_num,self.data.active_texiao_stuff_count)
		else
			self.node_list["RightPanelText"].text.text =  (ToColorStr(now_num..Language.ShenQi.TipFuHaoColor ..self.data.active_texiao_stuff_count, TEXT_COLOR.GREEN))  
		end
		self.node_list["tiaozhuangtext"].text.text = (ToColorStr(self.data.str4, TEXT_COLOR.RED))
		self.node_list["RightPanelText"]:SetActive(true)
	else
	--激活
		self.item_cell:SetData({item_id = self.data.active_texiao_stuff_id})
		self.node_list["ItemCell"]:SetActive(false)
		self.node_list["RightPanelText"]:SetActive(false)
		self.node_list["ButtonUse"]:SetActive(true)
		self.node_list["ClickGo"]:SetActive(false)
		--先将按钮置灰，后面再修改效果
		self.node_list["tiaozhuangtext"].text.text = (ToColorStr(self.data.str4, TEXT_COLOR.GREEN))
		if is_use then
			self.node_list["UseText"].text.text = Language.ShenQi.isUse
			UI:SetButtonEnabled(self.node_list["ButtonUse"], false)

		else
			self.node_list["UseText"].text.text = Language.ShenQi.Use 
			UI:SetButtonEnabled(self.node_list["ButtonUse"], true)
		end
	end	
end

function ShenQiTipsView:WearColorQualified(index)
	if index == 4 then
		self.node_list["ActiveText"].text.text = (ToColorStr(self.data.str2, TEXT_COLOR.GREEN))
	else
		self.node_list["ActiveText"].text.text = (ToColorStr(self.data.str2, TEXT_COLOR.RED))
	end
end


function ShenQiTipsView:OnButtonShouGou()
	MarketData.Instance:SetPurchaseItemId(6)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 6})
end

function ShenQiTipsView:OnToggleShenqiOnClick()
	local index = 0
	if self.node_list["Toggle1"].toggle.isOn == true then
		index = 1 
	else
		index = 0
	end
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_OPEN_TEXIAO, index)
end

--宝甲 GetBaojiaResCfgByIamgeID
function ShenQiTipsView:FlushModel()
	if self.model then
		if self.show_type == ShenqiData.ChooseType.JianLing then
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetRoleResid(main_role:GetRoleResId())			
			local head_id = ShenqiData.Instance:GetHeadResId(self.index)
			if head_id then
				local bundle, name = ResPath.GetHeadModel(head_id)
				self.model:SetHeadRes(bundle, name)
			end

			self.model:SetLoadComplete(function()
				self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 0)
			end)
			--两次强制关闭舞蹈
			self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 0)
		elseif self.show_type == ShenqiData.ChooseType.BaoJia then
			if self.model ~= nil and self.model.draw_obj ~= nil then
				self.model:RemoveHead()
				local id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(self.index)
				if nil ~= id then
					self.model:SetRoleResid(id)
					self.model:SetLoadComplete(function()
						self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 1)
					end)
					--两次强制跳舞
					self.model.draw_obj:GetPart(SceneObjPart.Main):SetLayer(ANIMATOR_PARAM.DANCE1_LAYER - 1 + self.index, 1)
				end
			end
		end		
	end
end

function ShenQiTipsView:ClickClose()
	self:Close()
end

function ShenQiTipsView:ClickActive()
	if self.show_type == ShenqiData.ChooseType.JianLing then
		-- local is_active1 = ShenqiData.Instance:GetJiangLingTeXiaoByIndex(self.index)
		-- local index = is_active1 and self.index + QIBINGNUM or self.index
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENGBING_TEXIAO_ACTIVE, self.index)
	elseif self.show_type == ShenqiData.ChooseType.BaoJia then
		-- local is_active1 = ShenqiData.Instance:GetBaoJiaTeXiaoByIndex(self.index)
		-- local index = is_active1 and self.index + DUNJIANUM or self.index
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BaoJia_TEXIAO_ACTIVE, self.index)
	end
end

function ShenQiTipsView:ClickUse()
	if self.show_type == ShenqiData.ChooseType.JianLing then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_USE_TEXIAO, self.index)
	elseif self.show_type == ShenqiData.ChooseType.BaoJia then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_TEXIAO, self.index)
	end
end

function ShenQiTipsView:ItemDataChangeCallback()
	self:FlushNowEffect()
end