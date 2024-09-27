local Color = Color
if RequiredScript == "lib/managers/hudmanagerpd2" then

	Hooks:PostHook(HUDManager, "_player_hud_layout", "EIVH_inspire_cooldown_timer", function(self)
		InspireCT:init()
	end)

	function InspireCT:init()
		if managers.hud ~= nil then 
			self.hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
			self._cooldown_panel = self.hud.panel:panel({
            name = "cooldown_panel",
            x = 0,
            y = 0
        })
			self.cooldown_text = self._cooldown_panel:text({
				layer = 2,
				visible = false,
				text = "0.0",
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 20,
				x = 14,
				y = 30,
				color = Color.white
			})
			self._inspire_cooldown_icon = self._cooldown_panel:bitmap({
				name = "inspire_cooldown_icon",
				texture = "guis/textures/pd2/skilltree_2/icons_atlas_2",
				texture_rect = { 4* 80, 9 * 80, 80, 80 },
				w = 38,
				h = 38,
				x = 0,
				y = 0,
				color = Color.white,
				visible = false,
				layer = 1
			})
			self._inspire_cooldown_timer_bg = self._cooldown_panel:bitmap({
				name = "inspire_cooldown_timer_bg",
				texture = "guis/textures/pd2/crimenet_marker_glow",
				w = 42,
				h = 42,
				x = 0,
				y = 20,
				color = Color("66ffff"),
				alpha = 0.5,
				visible = false,
				layer = 0
			})
		end
	end

	function InspireCT:update_inspire_timer(t)
		local timer = self.cooldown_text
		local panel = self._cooldown_panel
		local timer_bg = self._inspire_cooldown_timer_bg
		local icon = self._inspire_cooldown_icon
    	if t and t > 1 and timer then
        	timer:stop()
        	timer:animate(function(o)
            	o:set_visible(true)
				timer_bg:set_visible(true)
				icon:set_visible(true)
				panel:set_x(10 * InspireCT.Options:GetValue("TimerX"))
				panel:set_y(10 * InspireCT.Options:GetValue("TimerY"))
            	local t_left = t
            	while t_left >= 0.1 do
                	t_left = t_left - coroutine.yield()
					t_format = t_left < 10 and "%.1f" or "%.f"
                	o:set_text(string.format(t_format, t_left))
            	end
				icon:set_visible(false)
				timer_bg:set_visible(false)
            	o:set_text(false)
        	end)
    	end
	end
elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PreHook(PlayerManager, "disable_cooldown_upgrade", "HMH_PlayerManager_disable_cooldown_upgrade", function (self, category, upgrade)
		local upgrade_value = self:upgrade_value(category, upgrade)
		if upgrade_value == 0 then return end
		if InspireCT.Options:GetValue("Inspire") then
			InspireCT:update_inspire_timer(upgrade_value[2])
		end
	end)
end