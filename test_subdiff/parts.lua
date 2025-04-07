local parts = {}

local OP_SUBDIFF_OFF	= get_property_op()
local OP_SUBDIFF_ON	= get_property_op()
local TIMER_SUBDIFF	= get_customTimer_id()

parts.property = {
	{name = "subdiff", item = {
		{name = "OFF",	op = OP_SUBDIFF_OFF},
		{name = "ON",	op = OP_SUBDIFF_ON}
	},def = "ON"}
}

parts.filepath = {}
parts.offset = {}

local function load()

	if skin_config.option["subdiff"] == OP_SUBDIFF_ON then
	
		local function split(str, d)
			local s = str
			local t = {}
			local p = "%s*(.-)%s*" .. d .. "%s*"
			local f = function(v) table.insert(t, v) end
			if s ~= nil then
				string.gsub(s, p, f)
				f(string.gsub(s, p, ""))
			end
			return t
		end
		
		local now_song = {
			md5 = "",
			sha256 = "",
		}
		local display = {
            subdiff = "INITIAL",
		}
		local analysis = {
			lookup		= {1,1,1},
			md5		= {},
			sha256		= {},
			subdiff		= {},
		}
		
		do
			local c = 1
			local file_csv = io.open("skin/m_select/subdiff.csv", "r")
			for line in file_csv:lines() do
				local str = line
				str = string.gsub( str, "\r", "")
				local t = split(str, ",")
				if c > 1 then
					table.insert(analysis.md5,	tostring(t[analysis.lookup[1]]))
					table.insert(analysis.sha256,	tostring(t[analysis.lookup[2]]))
					table.insert(analysis.subdiff,	tostring(t[analysis.lookup[3]]))
				else
					for i, v in pairs(t) do
						if		v == "md5"	then analysis.lookup[1] = i
						elseif	v == "sha256"		then analysis.lookup[2] = i
						elseif	v == "subdiff"		then analysis.lookup[3] = i
						end
					end
				end
				c = c + 1
			end
			file_csv:close()
		end
		
		parts.source = {
			-- {id = "src-analysis", path = "customize/advanced/test_bmsanal/parts.png"}
		}
		parts.font = {}
		parts.image = {
			-- {id = "ui-analysis", src = "src-analysis", x = 0, y = 0, w = -1, h = -1}
		}
		parts.imageset = {}
		parts.value = {}
		parts.graph = {}

		parts.text = {
			{id = "subdiff",	font = "font-default-commonparts-sub", size = 24, align = 0, value = function() return display.subdiff end},
		}
		
		-- 表示切替用
		parts.customTimers = {
			{id = TIMER_SUBDIFF, timer = function()
				
				 -- TODO: TOTAL値を楽曲特定に使うと動作がおかしい
				 -- ハッシュ値使いたい
				local display_song = {
					md5 = main_state.text(1030),
					sha256 = main_state.text(1031),
				}

				if now_song.md5 ~= display_song.md5
				then
					-- TODO: 検索の効率化
					--[[
						csv側でフルタイトル順にソートしておく
						レベル毎にテーブルを分ける table_level = {{},{},...}
						選択中の楽曲レベルを添え字として使用する table_level[n + 1]
					--]]
					for i, v in pairs(analysis.md5) do
						if	analysis.md5[i] == display_song.md5
						or	analysis.sha256[i] == display_song.sha256
						then
							display.subdiff		= analysis.subdiff[i]
							now_song.md5		= display_song.md5
							now_song.sha256		= display_song.sha256
							break
						end
					end
					if now_song.md5 ~= display_song.md5
					then
						display.subdiff		= "---"
						now_song.md5		= display_song.md5
						now_song.sha256		= display_song.sha256
					end
				end
			end}
		}
		
		parts.destination = {
          {
            id = "subdiff",
            dst = {
              {x = 380, y = 782, w = 544, h = 24},
            },
            -- timer = 11,
            -- loop = 300,
            -- dst = {
            --   {time = 0, x = 380, y = 812, w = 544, h = 24, acc=2, a= 0},
            --   {time = 300, y = 782, a = 255},
            -- },
          },
        }
	end
			
	return parts	
end

return {
	parts = parts,
	load = load
}
