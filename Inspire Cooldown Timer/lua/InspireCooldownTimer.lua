if RequiredScript == "lib/managers/hudmanagerpd2" then
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "InspireCT_bufflist_setup_player_info_hud_pd2", function(self, ...)
        self._hud_buff_list = HUDBuffList:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
    end)

    function HUDManager:update_inspire_timer(buff)
        self._hud_buff_list:update_inspire_timer(buff)
    end
	
	HUDBuffList = HUDBuffList or class()
	function HUDBuffList:init()
		if managers.hud ~= nil then 
		    self.hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
			self._cooldown_panel = self.hud.panel:panel()

            self.cooldown_text = self._cooldown_panel:text({
                layer = 2,
                visible = false,
                font = tweak_data.hud.medium_font_noshadow
            })
            self._inspire_cooldown_icon = self._cooldown_panel:bitmap({
                name = "inspire_cooldown_icon",
                texture = "guis/textures/pd2/skilltree_2/icons_atlas_2",
                texture_rect = { 4 * 80, 9 * 80, 80, 80 },
                visible = false,
                layer = 1
            })
            self._inspire_cooldown_timer_bg = self._cooldown_panel:bitmap({
                name = "inspire_cooldown_timer_bg",
                texture = "guis/textures/pd2/crimenet_marker_glow",
                texture_rect = { 1, 1, 62, 62 }, 
                color = Color("66ffff"),
                visible = false
			})
		end
	end
	
	function HUDBuffList:update_timer_visibility_and_position()
		local inspire_visible = InspireCT.Options:GetValue("Inspire")
		local panel = self._cooldown_panel
		local timer = self.cooldown_text
        local pos_x = 10 * (InspireCT.Options:GetValue("TimerX") or 0)
        local pos_y = 10 * (InspireCT.Options:GetValue("TimerY") or 0)
		local inspire_timer_scale = (InspireCT.Options:GetValue("TimerScale") or 1)
		
		timer:set_visible(inspire_visible)
		panel:child("inspire_cooldown_icon"):set_visible(inspire_visible)
		panel:child("inspire_cooldown_timer_bg"):set_visible(inspire_visible)

		panel:set_x(pos_x)
		panel:set_y(pos_y)

		timer:set_x(13 * inspire_timer_scale)
		timer:set_y(25 * inspire_timer_scale)
		timer:set_font_size(16 * inspire_timer_scale)
		panel:child("inspire_cooldown_timer_bg"):set_w(40 * inspire_timer_scale)
		panel:child("inspire_cooldown_timer_bg"):set_h(40 * inspire_timer_scale)
		panel:child("inspire_cooldown_timer_bg"):set_y(13 * inspire_timer_scale)
		panel:child("inspire_cooldown_icon"):set_w(28 * inspire_timer_scale)
		panel:child("inspire_cooldown_icon"):set_h(28 * inspire_timer_scale)
    end

    function HUDBuffList:update_inspire_timer(duration)
        local timer = self.cooldown_text
        local timer_bg = self._inspire_cooldown_timer_bg
        local icon = self._inspire_cooldown_icon

        timer:set_alpha(1)
        timer_bg:set_alpha(0.5)
        icon:set_alpha(1)

        if duration and duration > 1 then
            timer:stop()
            timer:animate(function(o)
                local t_left = duration
				self:update_timer_visibility_and_position()

                while t_left >= 0 do
                    if t_left <= 0.1 then
                        self:fade_out("inspire")
                        return
                    end
                    t_left = t_left - coroutine.yield()
                    o:set_text(string.format(t_left < 9.9 and "%.1f" or "%.f", t_left))
                    self:update_timer_visibility_and_position()
                end
            end)
        end
    end
	
	function HUDBuffList:fade_out(buff_type)
		local start_time = os.clock()
		local text, bg, icon
		local duration

		if buff_type == "inspire" then
			text = self.cooldown_text
			bg = self._inspire_cooldown_timer_bg
			icon = self._inspire_cooldown_icon
			duration = 0.1
		end

		if text and bg and icon then
			text:animate(function()
				while true do
					local alpha = math.max(1 - (os.clock() - start_time) / duration, 0)
					text:set_alpha(alpha)
					bg:set_alpha(0.5 * alpha)
					icon:set_alpha(alpha)

					if alpha <= 0 then
						icon:set_visible(false)
						bg:set_visible(false)
						text:set_text("")
						break
					end

					coroutine.yield()
				end
			end)
		end
	end
elseif RequiredScript == "lib/managers/playermanager" then
		Hooks:PostHook(PlayerManager, "disable_cooldown_upgrade", "InspireCT_PlayerManager_disable_cooldown_upgrade", function(self, category, upgrade)
        local upgrade_value = self:upgrade_value(category, upgrade)
        if upgrade_value and upgrade_value[1] ~= 0 and InspireCT.Options:GetValue("Inspire") then
            managers.hud:update_inspire_timer(upgrade_value[2])
        end
    end)
end