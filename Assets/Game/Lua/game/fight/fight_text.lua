local TypeCamera = typeof(UnityEngine.Camera)
local TypeCanvas = typeof(UnityEngine.Canvas)

local UICamera1 = GameObject.Find("GameRoot/UICamera"):GetComponent(TypeCamera)
local FloatingCanvas = GameObject.Find("GameRoot/UILayer/FloatingCanvas"):GetComponent(TypeCanvas)

FightText = FightText or BaseClass()

function FightText:__init()
	if FightText.Instance then
		print_error("[FightText]:Attempt to create singleton twice!")
	end
	FightText.Instance = self

	self.is_active = true

	self.canvas = FloatingCanvas
	self.canvas.overrideSorting = true
	self.canvas.sortingOrder = 1000 * UiLayer.FloatText
	self.canvas.worldCamera = UICamera1
	self.canvas_transform = self.canvas.transform

	self.max_text_count = 25
	self.current_text_count = 0
	self.text_t = {}
end

function FightText:__delete()
	FightText.Instance = nil
end

function FightText:GetCanvas()
	return self.canvas
end

function FightText:SetActive(value)
	if self.is_active == value 
		or nil == self.canvas_transform 
		or IsNil(self.canvas_transform.gameObject) then 
		return 
	end
	self.is_active = value
	self.canvas_transform.gameObject:SetActive(value)

	if value then
		self:RemoveAll()
	end
end

function FightText:ShowText(bundle, asset, text, attach_point, img_asset_name)
	if not self.is_active then
		return
	end
	if nil == self.canvas then
		return
	end

	if self.current_text_count > self.max_text_count then
		return
	end

	self.current_text_count = self.current_text_count + 1
	local attach_position = attach_point.position
	ResPoolMgr:GetEffectAsync(bundle, asset, function(obj)
		if not obj then
			return
		end

		if IsNil(MainCamera) then
            ResPoolMgr:Release(obj)
			return
		end

		local text_obj = obj.transform:Find("Text")
		local text_component = text_obj:GetComponent(typeof(UnityEngine.UI.Text))
		text_component.text = text

		if img_asset_name then
			local image_obj = text_obj.transform:Find("Image")
			if not IsNil(image_obj) then
				image_obj.gameObject:SetActive(true)
				local image_u3d = U3DObject(image_obj, image_obj.transform, self)
				local image = image_u3d.image
				local sprite_loader = AllocResAsyncLoader(image_u3d, "sprite_res_async_loader")
				sprite_loader:Load(
					"uis/images_atlas", 
					img_asset_name,
					typeof(UnityEngine.Sprite),
					function(sprite)
						if not IsNil(image) and not IsNil(sprite) then
							image.sprite = sprite
							image.enabled = true
							image:SetNativeSize()
						end
					end)
			end
		else
			local image_obj = text_obj.transform:Find("Image")
			if not IsNil(image_obj) then
				image_obj.gameObject:SetActive(false)
			end
		end

		local animator = obj:GetComponent(typeof(UnityEngine.Animator))
		animator:WaitEvent("exit", function(param)
			if self.text_t[obj] then
				self.text_t[obj] = nil
                ResPoolMgr:Release(obj)
				self.current_text_count = math.max(self.current_text_count - 1, 0)
			end
		end)

		obj.transform:SetParent(self.canvas_transform, false)
		obj.transform.position = UIFollowTarget.CalculateScreenPosition(
			attach_position, MainCamera, self.canvas, obj.transform.parent)
		self.text_t[obj] = true
	end)
end

function FightText:RemoveAll()
	for k,v in pairs(self.text_t) do
        ResPoolMgr:Release(k)
	end
	self.text_t = {}
	self.current_text_count = 0
end

function FightText:ShowHurt(text, pos, attach_point, text_type)
	local add_str = pos.is_top and "1" or ""
	text_type = text_type or FIGHT_TEXT_TYPE.NORMAL
	if text_type == FIGHT_TEXT_TYPE.NORMAL then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "HurtLeft", text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "HurtRight", text, attach_point)
		end
	elseif text_type == FIGHT_TEXT_TYPE.BAOJU then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "HurtLeftBaoJu" .. add_str, text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "HurtRightBaoJu" .. add_str, text, attach_point)
		end
	elseif text_type == FIGHT_TEXT_TYPE.NVSHEN then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "HurtLeftNvShen" .. add_str, text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "HurtRightNvShen" .. add_str, text, attach_point)
		end
	elseif text_type == FIGHT_TYPE.LINGCHONG then
		if text == 0 then
			return
		end
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "LingChongLeft", text, attach_point, "text_lingchong")
		else
			self:ShowText("uis/views/floatingtext_prefab", "LingChongRight", text, attach_point, "text_lingchong")
		end
	elseif text_type == FIGHT_TEXT_TYPE.NVSHEN_FAN then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "HurtLeft" .. add_str, Language.Common.FanShang .. text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "HurtRight" .. add_str, Language.Common.FanShang .. text, attach_point)
		end	

	elseif text_type == FIGHT_TEXT_TYPE.NVSHEN_SHA then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "HurtLeft" .. add_str, Language.Common.ShaLu .. text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "HurtRight" .. add_str, Language.Common.ShaLu .. text, attach_point)
		end		
	elseif text_type == FIGHT_TEXT_TYPE.SHENSHENG then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "HurtLeftShenSheng" .. add_str, Language.Common.ShenSheng .. text, attach_point)
		else
			self:ShowText("uis/views/floatingtext_prefab", "HurtRightShenSheng" .. add_str, Language.Common.ShenSheng .. text, attach_point)
		end
	end
end

function FightText:ShowCritical(text, pos, attach_point, text_type)
	local add_str = ""
	text_type = text_type or FIGHT_TEXT_TYPE.NORMAL
	if text_type == FIGHT_TEXT_TYPE.NORMAL then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "CriticalLeft" .. add_str, text, attach_point, "text_baoji")
		else
			self:ShowText("uis/views/floatingtext_prefab", "CriticalRight" .. add_str, text, attach_point, "text_baoji")
		end
	elseif text_type == FIGHT_TEXT_TYPE.BAOJU then
		if pos.is_left then
			self:ShowText("uis/views/floatingtext_prefab", "CriticalLeftBaoJu" .. add_str, text, attach_point, "text_baoji_3")
		else
			self:ShowText("uis/views/floatingtext_prefab", "CriticalRightBaoJu" .. add_str, text, attach_point, "text_baoji_3")
		end
	end
end

function FightText:ShowBeHurt(text, pos, attach_point)
	local add_str = pos.is_top and "1" or ""
	-- if pos.is_left then
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", text, attach_point)
	-- else
	-- 	self:ShowText("uis/views/floatingtext_prefab", "BeHurtRight", text, attach_point)
	-- end
end

function FightText:ShowBeCritical(text, pos, attach_point)
	local add_str = pos.is_top and "1" or ""
	-- if pos.is_left then
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", text, attach_point, "text_baoji_2")
	-- else
	-- 	self:ShowText("uis/views/floatingtext_prefab", "BeHurtRight", text, attach_point)
	-- end
end

function FightText:ShowDodge(pos, attach_point)
	local add_str = pos.is_top and "1" or ""
	if pos.is_left then
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtLeft", "", attach_point, "text_shanbi")
	else
		self:ShowText("uis/views/floatingtext_prefab", "BeHurtRight", "", attach_point, "text_shanbi")
	end
end

function FightText:ShowRecover(text, attach_point)
	self:ShowText("uis/views/floatingtext_prefab", "Recover", text, attach_point)
end

function FightText:ShowLingChongGongji(text, pos, attach_point, text_type)
	if pos.is_left then
		self:ShowText("uis/views/floatingtext_prefab", "LingChongLeft", text, attach_point, "text_lingchong")
	else
		self:ShowText("uis/views/floatingtext_prefab", "LingChongRight", text, attach_point, "text_lingchong")
	end
end

function FightText:ShowBeLingChongGongji(text, pos, attach_point)
	if pos.is_left then
		self:ShowText("uis/views/floatingtext_prefab", "LingChongLeft", text, attach_point, "text_lingchong")
	else
		self:ShowText("uis/views/floatingtext_prefab", "LingChongRight", text, attach_point, "text_lingchong")
	end
end

function FightText:ShowGeDang(text, pos, attach_point)
	if pos.is_left then
		self:ShowText("uis/views/floatingtext_prefab", "GeDangLeft", text, attach_point, "text_gedang")
	else
		self:ShowText("uis/views/floatingtext_prefab", "GeDangRight", text, attach_point, "text_gedang")
	end
end

function FightText:ShowHuiXinYiJi(text, pos, attach_point)
	if pos.is_left then
		self:ShowText("uis/views/floatingtext_prefab", "HuiXinYiJiLeft", text, attach_point, "text_huixinyiji_1")
	else
		self:ShowText("uis/views/floatingtext_prefab", "HuiXinYiJiRight", text, attach_point, "text_huixinyiji_1")
	end
end

function FightText:ShowBeHuiXinYiJi(text, pos, attach_point)
	self:ShowText("uis/views/floatingtext_prefab", "BeHuiXinYiJiLeft", text, attach_point, "text_huixinyiji_2")
end
