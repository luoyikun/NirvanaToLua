local libbit = require("bit")
bit = {data32 = {}, data64 = {}}

for i = 1, 32 do
	bit.data32[i] = 2 ^ (32 - i)
end

for i =1, 64 do
	bit.data64[i] = 2 ^ (64 - i)
end

-- number转table 1->32 高位->低位
function bit:d2b(arg)
	local tr = {}
	for i = 1, 32 do
		if arg >= self.data32[i] then
			tr[i] = 1
			arg = arg - self.data32[i]
		else
			tr[i] = 0
		end
	end
	return tr
end

-- table转number
function bit:b2d(arg)
	local nr = 0
	for i = 1, 32 do
		if arg[i] == 1 then
			nr = nr + 2 ^ (32 - i)
		end
	end
	return nr
end

-- number转table 1->64 高位->低位
function bit:ll2bn(arg)
	local tr = {}
	for i = 1, 64 do
		if arg >= self.data64[i] then
			tr[i] = 1
			arg = arg - self.data64[i]
		else
			tr[i] = 0
		end
	end
	return tr
end

-- long long转table 1->64 高位->低位
-- @high 高32位
-- @low 低32位
function bit:ll2b(high, low)
	local high_t, low_t = bit:d2b(high), bit:d2b(low)

	for i = 1, 32 do
		high_t[i + 32] = low_t[i]
	end

	return high_t
end

-- table转long long
-- @return 高32位，低32位
function bit:b2ll(arg)
	local high_t, low_t = {}, {}

	for i = 1, 32 do
		high_t[i] = arg[i]
		low_t[i] = arg[i + 32]
	end

	return bit:b2d(high_t), bit:b2d(low_t)
end

-- unsigned char转table 1->8 可无限扩展
-- @flag 8的倍数
function bit:uc2b(flag, length)
	local flag_tab = {}
	local count = 0

	if not length then
		local flag_length = 0
		for k, v in pairs(flag) do
			flag_length = flag_length + 1
		end
		length = flag_length
	end

	for i = 0, length - 1 do
		local bit_tab = bit:d2b(flag[i])
		for j = 0, 7 do
			flag_tab[count] = bit_tab[33 - 8 + j]
			count = count + 1
		end
	end
	return flag_tab
end

-- 按位与
function bit:_and(a, b)
	return libbit.band(a, b)
end

-- 按位或
function bit:_or(a, b)
	return libbit.bor(a, b)
end

-- 按位取反
function bit:_not(a)
	return libbit.bnot(a)
end

-- 按位异或
function bit:_xor(a, b)
	return libbit.bxor(a, b)
end

-- 右移
function bit:_rshift(a, n)
	return libbit.rshift(a, n)
end

-- 左移
function bit:_lshift(a, n)
	return libbit.lshift(a, n)
end
