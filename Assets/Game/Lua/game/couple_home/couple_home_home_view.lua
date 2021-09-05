require("game/couple_home/couple_home_buy_view")
require("game/couple_home/couple_home_decorate_view")

CoupleHomeHomeContentView = CoupleHomeHomeContentView or BaseClass(BaseRender)
function CoupleHomeHomeContentView:__init()
	self.buy_parent_obj = self.node_list["BuyContent"]
	self.decorate_parent_obj = self.node_list["DecorateContent"]

	local res_async_loader = AllocResAsyncLoader(self, "BuyContent")
	res_async_loader:Load("uis/views/couplehome_prefab", "BuyContent", nil,
		function(prefab)
			if nil == prefab then return end
			
			local obj = U3DObject(ResMgr:Instantiate(prefab))
			obj.transform:SetParent(self.buy_parent_obj.transform, false)
			-- obj = U3DObject(obj)
			self.buy_view = CoupleHomeBuyContentView.New(obj)
			self.buy_view:InitView()
		end)

	local res_async_loaders = AllocResAsyncLoader(self, "DecorateContent")
	res_async_loaders:Load("uis/views/couplehome_prefab", "DecorateContent", nil,
		function(prefab)
			if nil == prefab then return end

			local obj = U3DObject(ResMgr:Instantiate(prefab))
			obj.transform:SetParent(self.decorate_parent_obj.transform, false)
			-- obj = U3DObject(obj)
			self.decorate_view = CoupleHomeDecorateContentView.New(obj)
			self.decorate_view:InitView()
			self:FlushActive()
		end)
end

function CoupleHomeHomeContentView:__delete()
	if self.buy_view then
		self.buy_view:DeleteMe()
		self.buy_view = nil
	end

	if self.decorate_view then
		self.decorate_view:DeleteMe()
		self.decorate_view = nil
	end
end

--界面隐藏时调用
function CoupleHomeHomeContentView:CloseView()
	if self.buy_view then
		self.buy_view:CloseView()
	end

	if self.decorate_view then
		self.decorate_view:CloseView()
	end
end

--界面显示时调用
function CoupleHomeHomeContentView:InitView()
	if self.buy_view then
		self.buy_view:InitView()
	end
	if self.decorate_view then
		self.decorate_view:InitView()
	end

	self:FlushActive()
end

function CoupleHomeHomeContentView:FlushActive()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local house_uid = CoupleHomeHomeData.Instance:GetHouseUid()
	local show_buy_view = false
	local show_decorate_view = false
	if main_vo.role_id == house_uid or house_uid == 0 then
		--当前是自己的房子
		local house_list = CoupleHomeHomeData.Instance:GetHouseList() or {}
		if #house_list > 0 then
			--有房子，显示房子相关界面
			show_decorate_view = true
		else
			--没有房子，显示购房相关界面
			show_buy_view = true
		end
	elseif house_uid > 0 then
		show_decorate_view = true
	end

	if self.buy_view then
		self.buy_view:SetParentActive(show_buy_view)
	end
	if self.decorate_view then
		self.decorate_view:SetParentActive(show_decorate_view)
	end
end

function CoupleHomeHomeContentView:OnFlush(param_t)
	self:FlushActive()

	for k, v in pairs(param_t) do
		if k == "buy" then
			if self.buy_view then
				self.buy_view:Flush(k, v)
			end
		elseif k == "decorate" or k == "friend" or k == "guild" then
			if self.decorate_view then
				self.decorate_view:Flush(k, v)
			end
		end
	end
end