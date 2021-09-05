WeaponFBMap = WeaponFBMap or BaseClass(BaseCell)

local number = 0

function WeaponFBMap:__init()
	local async_loader = AllocResAsyncLoader(self, "WeaponMap")
	async_loader:Load("uis/views/fubenview_prefab", "WeaponMap", nil,
		function(prefab)
			if IsNil(self.root_node.transform) then
				ResMgr:Destroy(prefab)
				return
			end

			local obj = U3DObject(ResMgr:Instantiate(prefab))
			obj.transform:SetParent(self.root_node.transform, false)
			self.prefab = obj

			local name_table = obj:GetComponent(typeof(UINameTable))			-- 名字绑定
			self.node_list = U3DNodeList(name_table, self)

			self.level_limit = self.node_list["TextLevel"]
			self.fight_power = self.node_list["TextFightPower"]
			self.select_chapter = self.node_list["SeletChapter"]

			-- self.variables[i].rank_text = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("RankText"))
			self.node_list["ButtonBox"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
			self.prefab_load = true
			self:Flush()
		end)
	self.cur_select_index = 1
	self.init_scorller_num = 0
	self.cell_list = {}
end


function WeaponFBMap:__delete()
	if self.prefab then
		ResMgr:Destroy(self.prefab.gameObject)
		self.prefab = nil
	end
end

function WeaponFBMap:SetData(data)
	self.data = data
	self:Flush()
end

function WeaponFBMap:SetIndex(index)
	self.index = index
end

function WeaponFBMap:OnFlush()
	self:ConstructData()
	self:SetModel()
	self:SetInfo()
end

function WeaponFBMap:ConstructData()
	if self.prefab_load and self.data then
		self.construct = true
	else
		self.construct = nil
	end
end

function WeaponFBMap:SetFlag(flag)
	if self.select_chapter then
		self.select_chapter:SetActive(flag)
	end
end

function WeaponFBMap:SetModel()
	if self.construct == nil then
		return
	end
end

function WeaponFBMap:SetClickCallBack(callback)
	self.click_callback = callback
end

function WeaponFBMap:SetInfo()
	if self.construct == nil then	
		return
	end
	self.fight_power.text.text = Language.FuBen.CanChallnge
	self.level_limit.text.text = (self.data.role_level .. Language.Player.Ji)
	for i = 1, 3 do
		if self.data.star < i and self.node_list["ImageStart" .. i] then
			UI:SetGraphicGrey(self.node_list["ImageStart" .. i], true)
		else
			UI:SetGraphicGrey(self.node_list["ImageStart" .. i], false)
		end
	end
	self.node_list["NameBg"]:SetActive((self.data.is_cur_level and self.data.star == 0))
	local bundle, asset = ResPath.GetLevelIcon(self.data.chapter_pic)
	self.node_list["ButtonBox"].image:LoadSprite(bundle, asset, function ()
		self.node_list["ButtonBox"].image:SetNativeSize()
	end)
	local is_grey = self.data.is_open or self.data.is_cur_level
	UI:SetGraphicGrey(self.node_list["ButtonBox"], not is_grey)
	self.node_list["StarList"]:SetActive(is_grey)
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	if self.data.is_cur_level and self.data.star == 0  then
		if my_level < self.data.role_level  then
			self.node_list["Mylevel"].text.text = string.format(Language.FuBen.WeaponFBChallenge,self.data.role_level)
			self.node_list["StarList"]:SetActive(false)
			self.node_list["NameBg"]:SetActive(false)
			self.node_list["ChallgeLevel"]:SetActive(true)
		else
			self.node_list["ChallgeLevel"]:SetActive(false)
		end
	else
		self.node_list["ChallgeLevel"]:SetActive(false)
		-- self.node_list["StarList"]:SetActive(true)
	end


	if self.data.is_cur_level then
		self:OnClick()
	end
end

function WeaponFBMap:FlushHL()
	
end

function WeaponFBMap:OnClick()
	if self.click_callback then
		self.click_callback(self.data.chapter, self.index)
	end
end


SlaughterFBMapChapter = SlaughterFBMapChapter or BaseClass(BaseRender)

function SlaughterFBMapChapter:__init()
	self.maps = {}
end

function SlaughterFBMapChapter:__delete()
	for k,v in pairs(self.maps) do
		v:DeleteMe()
		v = nil
	end
end

function SlaughterFBMapChapter:SetData(data)
	self.data = data
	if self.maps[1] ~= nil then
		for i = 1, 8 do
			self.maps[i]:SetData(data[i - 1])
		end
	end
end

function SlaughterFBMapChapter:SetClickCallBack(click_callback)
	self.click_callback = click_callback
	if self.maps[1] ~= nil and self.prefab then
		for i = 1, 8 do
			self.maps[i]:SetClickCallBack(self.click_callback)
		end
	end
end

function SlaughterFBMapChapter:SetFlag(index)
	if self.maps[1] ~= nil then
		for i = 1, 8 do
			if index and index == i then
				self.maps[i]:SetFlag(true)
			else
				self.maps[i]:SetFlag(false)
			end
		end
	end
end

function SlaughterFBMapChapter:SetIndex(index)
	self.index = index

	local res_async_loader = AllocResAsyncLoader(self, "WeaponFBMap_loader")
	res_async_loader:Load("uis/views/fubenview_prefab", "WeaponFBMap0", nil,
		function(prefab)
			if nil == prefab then return end
			
			if self.prefab and not IsNil(self.prefab.gameObject) then
				ResMgr:Destroy(self.prefab.gameObject)
				self.prefab = nil
				for k,v in pairs(self.maps) do
					v:DeleteMe()
					v = nil
				end
				self.maps = {}
			end

			local obj = U3DObject(ResMgr:Instantiate(prefab))
			obj.transform:SetParent(self.root_node.transform, false)
			self.prefab = obj
			local name_table = obj:GetComponent(typeof(UINameTable))
			for i = 1, 8 do
				local map = WeaponFBMap.New(name_table:Find("Map" .. i))
				table.insert(self.maps, map)
			end
			for i = 1, 8 do
				self.maps[i]:SetIndex(i)
			end
			if self.click_callback then
				self:SetClickCallBack(self.click_callback)
			end
			if self.data then
				self:SetData(self.data)
			end
		end)
end

SlaghterMapReward = SlaghterMapReward or BaseClass(BaseRender)

function SlaghterMapReward:__init()
	self.icon = self.node_list["Icon"]
	self.name = self.node_list["Name"]
	self.red_point = self.node_list["RedPoint"]
	self.anim = self.icon.animator
	self.can_open = false
	self.reward_state = false
	self.callback = nil
	self.icon.button:AddClickListener(BindTool.Bind(self.OnClick, self))
	-- self:AddClickEventListener(self.icon, BindTool.Bind(self.OnClick, self))
end


function SlaghterMapReward:__delete()
	if self.shake_timer then
		GlobalTimerQuest:CancelQuest(self.shake_timer)
		self.shake_timer = nil
	end
end

function SlaghterMapReward:SetData(data)
	self.data = data
	self:Flush()
end

function SlaghterMapReward:OnFlush()
	self:ConstructData()
	self:SetInfo()
end

function SlaghterMapReward:ConstructData()
	self.construct = true
	if self.shake_timer then
		GlobalTimerQuest:CancelQuest(self.shake_timer)
		self.shake_timer = nil
	end
end
	
function SlaghterMapReward:SetInfo()
	if self.construct == nil  then
		return
	end

	self.name.text.text = (self.data.start)
	local bundle, asset = ResPath.GetFuBenBoxIcon(self.index + 1, false)
	self.icon.image:LoadSprite(bundle, asset)

	local fb_info = FuBenData.Instance:GetNeqFBInfo().chapter_list
	local cur_fb_info = fb_info[self.data.chapter + 1]
	if cur_fb_info.reward_flag[32 - self.index + 1] == 0 then
		if cur_fb_info.cur_star >= self.data.start then
			self.shake_timer = GlobalTimerQuest:AddRunQuest(function()
				self.anim:SetTrigger("Shake")
			end,1)
			self.can_open = true
			self.red_point:SetActive(true)
		else
			self.reward_state = false
			self.can_open = false
			self.red_point:SetActive(false)
		end
	else
		self.reward_state = true
		self.can_open = false
		self.red_point:SetActive(false)
		bundle, asset = ResPath.GetFuBenBoxIcon(self.index + 1, true)
		self.icon.image:LoadSprite(bundle, asset)
	end
end

function SlaghterMapReward:SetIndex(index)
	self.index = index
end


function SlaghterMapReward:SetClickCallBack(click_callback)
	self.click_callback = click_callback
end

function SlaghterMapReward:FlushHL()
	
end

function SlaghterMapReward:OnClick()
	if self.click_callback then
		self.click_callback(self.data, self.index - 1, self.can_open, self.reward_state)
	end
end