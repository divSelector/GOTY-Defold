local input = require "modules.input"
local utils = require "modules.utils"
local state = require "modules.state"

M = {}

M.show_menu = false

local function menu_style()
    local dark_green = {0.15, 0.25, 0.15, 1} -- Darker green for backgrounds  
    local mid_green = {0.30, 0.45, 0.30, 1}  -- Mid-tone green for elements  
    local light_green = {0.433, 0.571, 0.359, 1} -- Your original green for highlights  

    -- Text Colors  
    -- imgui.set_style_color(imgui.ImGuiCol_Text, 0.90, 0.90, 0.90, 0.90)  
    -- imgui.set_style_color(imgui.ImGuiCol_TextDisabled, 0.60, 0.60, 0.60, 1.00)  

    -- Darker Window Background  
    -- imgui.set_style_color(imgui.ImGuiCol_WindowBg, dark_green[1], dark_green[2], dark_green[3], 1.00)  
    -- imgui.set_style_color(imgui.ImGuiCol_PopupBg, dark_green[1] * 0.8, dark_green[2] * 0.8, dark_green[3] * 0.8, 0.85)  

    -- Borders  
    imgui.set_style_color(imgui.ImGuiCol_Border, mid_green[1], mid_green[2], mid_green[3], 0.65)  
    imgui.set_style_color(imgui.ImGuiCol_BorderShadow, 0.00, 0.00, 0.00, 0.00)  

    -- Frames (Inputs, Dropdowns, Sliders)  
    imgui.set_style_color(imgui.ImGuiCol_FrameBg, dark_green[1] * 1.2, dark_green[2] * 1.2, dark_green[3] * 1.2, 1.00)  
    imgui.set_style_color(imgui.ImGuiCol_FrameBgHovered, mid_green[1], mid_green[2], mid_green[3], 0.40)  
    imgui.set_style_color(imgui.ImGuiCol_FrameBgActive, mid_green[1] * 1.2, mid_green[2] * 1.2, mid_green[3] * 1.2, 0.45)  

    -- Titles & Menubars  
    imgui.set_style_color(imgui.ImGuiCol_TitleBg, dark_green[1] * 1.1, dark_green[2] * 1.1, dark_green[3] * 1.1, 0.83)  
    imgui.set_style_color(imgui.ImGuiCol_TitleBgActive, mid_green[1], mid_green[2], mid_green[3], 0.87)  
    imgui.set_style_color(imgui.ImGuiCol_MenuBarBg, dark_green[1] * 0.9, dark_green[2] * 0.9, dark_green[3] * 0.9, 0.80)  

    -- Buttons  
    imgui.set_style_color(imgui.ImGuiCol_Button, mid_green[1] * 0.8, mid_green[2] * 0.8, mid_green[3] * 0.8, 0.49)  
    imgui.set_style_color(imgui.ImGuiCol_ButtonHovered, light_green[1], light_green[2], light_green[3], 0.68)  
    imgui.set_style_color(imgui.ImGuiCol_ButtonActive, light_green[1] * 1.2, light_green[2] * 1.2, light_green[3] * 1.2, 1.00)  

    -- Tabs  
    imgui.set_style_color(imgui.ImGuiCol_Tab, mid_green[1] * 0.7, mid_green[2] * 0.7, mid_green[3] * 0.7, 0.85)  
    imgui.set_style_color(imgui.ImGuiCol_TabHovered, light_green[1], light_green[2], light_green[3], 1.00)  
    imgui.set_style_color(imgui.ImGuiCol_TabActive, light_green[1] * 1.2, light_green[2] * 1.2, light_green[3] * 1.2, 1.00)  

    -- Sliders, Checkmarks, Grabs  
    imgui.set_style_color(imgui.ImGuiCol_CheckMark, light_green[1], light_green[2], light_green[3], 0.83)  
    imgui.set_style_color(imgui.ImGuiCol_SliderGrab, light_green[1], light_green[2], light_green[3], 0.62)  
    imgui.set_style_color(imgui.ImGuiCol_SliderGrabActive, light_green[1] * 1.2, light_green[2] * 1.2, light_green[3] * 1.2, 0.84)  

    -- Text Selection Background  
    imgui.set_style_color(imgui.ImGuiCol_TextSelectedBg, light_green[1], light_green[2], light_green[3], 0.35)  

end

local function keybind_config(button_width, button_height)
    imgui.spacing()
    imgui.spacing()
    imgui.spacing()
    imgui.text("Press a button to change the keybinding:")
    imgui.spacing()
    imgui.spacing()
    imgui.spacing()

    if imgui.begin_table("keybinding_table", 2, imgui.TABLE_FLAGS_RESIZEABLE) then

        -- Setup column widths (fixed sizes)
        imgui.table_setup_column("Button", imgui.TABLE_COLUMN_FLAGS_WIDTH_FIXED)
        imgui.table_setup_column("Label", imgui.TABLE_COLUMN_FLAGS_WIDTH_FIXED)

        -- Loop through keybinds and draw buttons/labels in table rows
        for _, action in ipairs(input.keybind_order) do
            local key = input.keybinds[action]
            imgui.table_next_row()  -- Move to the next row

            -- Button column
            imgui.table_set_column_index(0)  -- Column 1 for buttons
            local available_width = imgui.get_content_region_avail() -- Get remaining width in the column
            imgui.spacing() -- Add some spacing before moving
            imgui.same_line(available_width - button_width * 2) -- Move cursor to the right
            if imgui.button(action, button_width, button_height) then
                input.waiting_for_key = action
            end
        
            -- Label column
            imgui.table_set_column_index(1)  -- Column 2 for labels
            local key_name
            if input.waiting_for_key == action then
                key_name = "Waiting for Input"
            else
                key_name = utils.extract_key_from_hash_string(tostring(key))
            end
            imgui.text(key_name)
        end

        -- End table
        imgui.end_table()
    end
end

local foul_language_enabled = false
local difficulty_levels = { "Easy", "Normal", "Hard" }
local difficulty_levels_foul = { "Bullshit", "Fucking Bullshit", "Holy Fucking God Damn Bullshit" }

-- local bases = {
--     "player_bluepants",
--     "player_greenpants",
--     "player_redpants",
--     "player_greypants"
-- }
-- local bodies = {
--     "armor01", "armor02", "armor03", "armor04", "armor05", "armor06", "armor07", "armor08",
--     "robe01", "robe02", "robe03", "robe04", "robe05", "robe06", "robe07", "robe08", "default"
-- }
-- local heads = {
--     "helm01", "helm02", "helm03", "helm04", "helm05", "helm06", "helm07", "helm08",
--     "hat01", "hat02", "hat03", "hat04", "hat05", "hat06", "hat07", "hat08", "default"
-- }
-- local accessories = {
--     "shield01", "shield02", "shield03", "shield04", "shield05", "shield06", "shield07", "shield08", 
--     "book01", "book02", "book03", "book04", "book05", "book06", "book07", "book08", "default"
-- }

local bases = {
    "blue",
    "green",
    "red",
    "grey"
}



local bodies = {
    "brown leather armor", 
    "gray plate armor", 
    "chain mail armor",
    "gold armor",
    "red leather armor", 
    "black/yellow stripe armor", 
    "black plate armor", 
    "white plate armor",
    "brown robe",
    "aqua robe",
    "lime robe",
    "blood robe",
    "white robe",
    "olive/red robe",
    "orange/yellow robe",
    "black robe",
    "default"
}
local heads = {
    "brown leather helm",
    "gray plate helm",
    "chain mail helm",
    "gold helm",
    "red mohawk roman grey helm",
    "black/yellow cross helm",
    "purple mohawk black helm",
    "white horned helm",
    "brown hat",
    "aqua hat",
    "lime hat",
    "blood hat",
    "white hat",
    "olive hat",
    "orange/yellow hat",
    "black hat",
    "default"
}
local accessories = {
    "brown buckler shield",
    "circle gray metal shield",
    "v-shaped metal shield",
    "gold shield",
    "hyrule shield",
    "red/yellow tower shield",
    "circlular orange ^ shield",
    "tall oval peach shield",
    "white book",
    "gray book",
    "red/white book",
    "black book",
    "white/peach/black book",
    "lime book",
    "aqua/white book",
    "dark purple book",
    "default"
}

function M.update()
    if M.show_menu then
        local w, h = window.get_size()  -- Get screen size

		if w == 0 or h == 0 then
			return  -- Don't proceed with rendering if window size is zero
		end

        imgui.set_display_size(w, h)

        -- Define window size as a percentage of screen size
        local win_width = w * 0.6   -- 60% of screen width
        local win_height = h * 0.6  -- 60% of screen height

        -- Calculate centered position
        local pos_x = (w - win_width) / 2
        local pos_y = (h - win_height) / 2

        -- Set position and size before opening window
        imgui.set_next_window_pos(pos_x, pos_y)
        imgui.set_next_window_size(win_width, win_height)

        menu_style()

        imgui.begin_window("Game Options", nil, imgui.WINDOWFLAGS_MENUBAR)

        -- Scale text dynamically (increase multiplier for larger text)
        local text_scale = (h / 800) * 1.5  -- Adjusting for larger text

        -- Clamp scale to avoid text becoming too small or too large
        text_scale = math.max(1.2, math.min(text_scale, 3.0))

		local button_width = math.max(80, math.min(w * 0.1, 200))  -- Min 80, Max 200, 10% of screen width
    	local button_height = math.max(30, math.min(h * 0.05, 100)) -- Min 30, Max 100, 5% of screen height


        imgui.set_window_font_scale(text_scale)

        if imgui.begin_tab_bar("ConfigTabs") then


            if imgui.begin_tab_item("Game") then
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()

                if imgui.button("Restart", button_width, button_height) then
                    print("Restart")
                    state.current_level_index = 1
                    state.spawn_point = 1
                    state.current_level = state.levels[state.current_level_index]
                    state.timer.time = 0
                    state.ball_count = 0
                    state.total_balls = 0
                    msg.post("game:/level#level", "restart_game")
                    msg.post("main:/main#manager", "restart_game")
                end

                imgui.end_tab_item()
            end

        
            if imgui.begin_tab_item("Keybinds") then
                keybind_config(button_width, button_height)
                imgui.end_tab_item()
            end

            if imgui.begin_tab_item("Difficulty") then

                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.text("You can adjust how annoying the dudes will be at any time:")
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()

                -- Difficulty selection enum

            
                -- Loop through difficulty levels and create radio buttons
                for i, level in ipairs(foul_language_enabled and difficulty_levels_foul or difficulty_levels) do
                    if imgui.radio_button(level, state.difficulty_level == i - 1) then
                        state.difficulty_level = i - 1 -- Update difficulty enum (assuming 0 = Easy, 1 = Normal, 2 = Hard)
                    end
                end
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
            
                -- Add the checkbox for foul language
                if imgui.checkbox("Lie to Me", not foul_language_enabled) then
                    foul_language_enabled = not foul_language_enabled  -- Toggle foul language
                end

                imgui.end_tab_item()
            end

            if imgui.begin_tab_item("Skins") then
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                imgui.text("You can change your skin:")
                imgui.spacing()
                imgui.spacing()
                imgui.spacing()
                
                if imgui.begin_table("character_table", 2, imgui.TABLE_FLAGS_RESIZEABLE) then
                    imgui.table_setup_column("Label", imgui.TABLE_COLUMN_FLAGS_WIDTH_FIXED)
                    imgui.table_setup_column("Selection", imgui.TABLE_COLUMN_FLAGS_WIDTH_FIXED)
                
                    local function draw_row(label, items, selected_index)
                        imgui.table_next_row()
                        imgui.table_set_column_index(0)
                        local available_width = imgui.get_content_region_avail() -- Get remaining width in the column
                        imgui.spacing() -- Add some spacing before moving
                        imgui.same_line(available_width - button_width * 2) -- Move cursor to the rights
                        imgui.text(string.sub(label, 3))
                        imgui.table_set_column_index(1)
                        
                        local changed, skin = imgui.combo(label, selected_index, items)

                        if changed then
                            print(changed)
                            print(skin)
                            selected_index = skin
                        end

                        return selected_index
                    end
                    
                    -- using ## causes the label to not appear automatically to the right of the dropdown
                    -- this is why we cut this off our manual label display above.
                    state.selected_base = draw_row("##Pants", bases, state.selected_base)
                    state.selected_body = draw_row("##Body", bodies, state.selected_body)
                    state.selected_head = draw_row("##Head", heads, state.selected_head)
                    state.selected_accessory = draw_row("##Accessory", accessories, state.selected_accessory)
                    
                    imgui.end_table()
                end
                
    
                imgui.end_tab_item()
            end

            imgui.end_tab_bar()
        end

		imgui.end_window()
    end
end



return M