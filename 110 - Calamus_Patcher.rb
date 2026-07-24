# 110 - Calamus_Injector.rb
# Dictionary: Item ID = ITID
# ==============================================================================
#      ++++++++++++++++++++++++ CalamusInjector ++++++++++++++++++++++++++++++
#
# 1. Press R to open ModMenu.
# 2. Use current ACTION keybind to select
# 
# - CalamusInjector v0.5-GA
# - Licensed under the GNU GPL v3 license.
# - Last updated this section: 20/07/2026 11:57 AM UTC+8
# 
#      ++++++++++++++++++++++++ LEGAL ++++++++++++++++++++++++++++++
# - CalamusInjector is not affiliated, nor endorsed by Future Cat LLC in any way.
# - OneShot, its characters, story, assets, and code are the property of Future Cat LLC.
# - CalamusInjector, and the contents of 110 - Calamus_Injector.rb are property of the creator.
# - CalamusInjector is made, developed, built, maintained, by Kip at github.com/frizzy-cmd/CalamusInjector.
#
#     ++++++++++++++++++++++++ READ ME ++++++++++++++++++++++++++++++
# - PLEASE backup your unmodified xScripts.rxdata, save.dat and other save files. This mod menu MAY corrupt your save files. I am not responsible for any corrupt files!
# - This mod menu has been tested on: 64 bit Windows 10 LTSC 2021 IoT, OneShot 64 bit [Steam client] | No dependencies required.
# - May conflict wth other scripts that heavily alias Scene_Map#update. Not guranteed it'll conflict, not guranteed it won't conflict.
# - View the changelogs on the Releases section of the GitHub repo. github.com/frizzy-cmd/CalamusInjector
# 
#    ++++++++++++++++++++++++ TO MODDERS +++++++++++++++++++++++++++++
# - Thank you for using CalamusInjector!
# - Some variables are claimed by CalamusInjector, please read below for the list.
#
# Variable 88: Stores chosen track index number when using BGM jukebox
# Variable 89: Holds the Item ID specified by the player when using the Delete Item ID option.
# Variable 91: Stores the input option for diagnostics sub menu.
# Veriable 92: Stores the target FPS input by player for Game Speed FPS.
# Variable 93: Captures the raw numeric value the player wants to assign to a game variable with the Dev State Flip option
# Variable 94: Holds the menu choice for the Dev State Flip type (determining whether the plr wants to toggle a switch which is 01, or variable which is 92.)
# Variable 95: Tracks the specific switch ID or variable ID targeted for modification in the Dev State Flip routine
# Variable 96: Holds the target Map ID when performing a Map ID jump
# Variable 97: Stores the raw 7 to 8 digit coordinate string used to parse X and Y positions for Coord TP
# Variable 98: Holds the menu for Coord TP behavior (determing wtheter the plr wants to enter new coord or jump to last coord)
# Variable 99: Stores the Item ID input by the plr for Custom item ID injector.
# 
# (Used as temporary input buffers, but will overwrite existing data in these slots)
#
#
# - Thank you for using CalamusInjector. 
# ==============================================================================

# START!

# TO INSTALL THIS MOD, PLEASE REVIEW THE GITHUB REPO INSTEAD!! github.com/frizzy-cmd/CalamusInjector github.com/frizzy-cmd/CalamusInjector github.com/frizzy-cmd/CalamusInjector



# ++== NOTES TO SELF SECTION: [DO NOT MIND IF YOU ARE NOT ME] ==++

# 068, 067 .rb is built-in debug ux for oneshot but we use our diagnostics for detail.
# FILES, 061, 062, 063, 060 HANDLE DIALOGUE BOXES
# 061 = Window name input
# 062 Window input number
# 063 Window msg (default dialogue box, pretty sure)
# 060 Window name Edit

# #{pc_user} [computer username], defined line 626. not global. pls make global soon.

# FOUND OUT TODAY THAT if you surround text in $game_temp.message_text("[HELLO]") it does the robot sfx

# force save function may be not working.. may deprecate.. it uses backup save file isntead of save.dat, it says its corrupted apparently.
# picky..
# i think xScripts.rxdata (incl this script gets launched only when ingame? pressing r in main menu doesnt work. obvs.)

# to see dialogues for reference/tinkering, go to C:\Users\Kip\Desktop\extracteddata\extracted_common_events
# for ex, in 051 - prophet explains the lightbulb.json,
# this is the lines:

#     {
#       "parameters": [
#         "@niko Your... \\.\\.\\@niko_speak sun?" # YOU CAN LIKE MAKE PAUSES IN DIALOGUES WITH \\.\\.\\ [DEPENDS ON TEXT?]. WHAT THE FUCK. IT TOOK ME THIS LONG. FUCKING HELL MATE
#       ],
#       "indent": 0,
#       "code": 101
#     },
#     {
#       "parameters": [
#         "@prophet_omg [Yes!]"
#       ],
#       "indent": 0,
#       "code": 101
#     },
#     {

# GO TO C:\Users\Kip\Desktop\calamformat.html FOR UI FORMATTER
# OR FOR QUICK REF:
#  \\. [15 FRAME PAUSE]
#  \\.\. [30 FRAME PAUSE]
#  \\| [60 FRAME PAUSE]
# 
# [ONLY PAUSE. DOES NOT WAIT FOR USER TO INTERACT WITH DIALOGUE THEN RESUME. IDK HOW TO IMPLEMENT. ITS 1 AM I AINT DOING ALLAT!!]

# NEW DISCOVERY?
# "@niko_eyeclosed \\p... someone lives here...\\>\\nWe can't just sleep in their bed.
# \\p is the player's computer username?
# \\>\\ makes a new line, waits for user interaction before continuing dialogue [possibly]
# ed_message or anything with ed and message is the fullscreen black box message box
# an example of this, is in NO FAST TRAVEL.json
# "@ed [You cannot fast travel right now.]"
# .pretty sure i know what this screen means, and to everyone else.

# now, my question is, can we try it in $game_temp.message_text = "@ed [Test]" (and also w/ the pauses and shit integrated?)
# possibly yes, but idk, the dialogues are json, this is code. so i dont know how it'll go out..

# ++== END NOTES TO SELF SECTION ==++


#move to class
class Window_CalamusCoordInput < Window_Base
  attr_reader :confirmed
  attr_reader :cancelled
  attr_reader :retp_triggered

  def initialize
    super(120, 140, 400, 200)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.z = 100001
    self.opacity = 0
    self.contents_opacity = 0
    
    @grid = [ # COORDS UI
      ["7", "8", "9", "RE-TP"],
      ["4", "5", "6", "-"],
      ["1", "2", "3", ","],
      ["0", "BACK", "OK", "EXIT"]
    ]
    @index_x = 0
    @index_y = 0
    @entered_text = ""
    @fade_in = true
    @fade_out = false
    @confirmed = false
    @cancelled = false
    @retp_triggered = false
    
    refresh
  end

  def refresh
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, width - 32, 32, "Enter coords (X,Y): #{@entered_text}")
    
    self.contents.font.color = normal_color
    4.times do |y|
      4.times do |x|
        item = @grid[y][x]
        dx = x * 90
        dy = 40 + (y * 30)
        self.contents.draw_text(dx, dy, 80, 32, item, 1)
      end
    end
  end

  def update_cursor_rect
    dx = @index_x * 90
    dy = 40 + (@index_y * 30)
    self.cursor_rect.set(dx, dy, 80, 30)
  end

  def update
    super
    
    if @fade_in
      self.opacity += 48
      self.contents_opacity += 48
      @fade_in = false if self.contents_opacity >= 255 # was == 255 b4
      return
    end

    if @fade_out
      self.opacity -= 48
      self.contents_opacity -= 48
      if self.opacity == 0
        self.dispose
      end
      return
    end

    update_cursor_rect
    
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index_x = (@index_x + 1) % 4
    elsif Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index_x = (@index_x + 3) % 4
    elsif Input.repeat?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)
      @index_y = (@index_y + 1) % 4
    elsif Input.repeat?(Input::UP)
      $game_system.se_play($data_system.cursor_se)
      @index_y = (@index_y + 3) % 4
    end

    if Input.trigger?(Input::ACTION)
      action_item = @grid[@index_y][@index_x]
      case action_item
      when "OK"
        $game_system.se_play($data_system.decision_se)
        @confirmed = true
        @fade_out = true
      when "EXIT"
        $game_system.se_play($data_system.cancel_se)
        @cancelled = true
        @fade_out = true
      when "RE-TP"
        $game_system.se_play($data_system.decision_se)
        @retp_triggered = true
        @fade_out = true
      when "BACK"
        $game_system.se_play($data_system.cancel_se)
        @entered_text.chop!
        refresh
      else
        $game_system.se_play($data_system.decision_se)
        if @entered_text.length < 12
          @entered_text += action_item
          refresh
        end
      end
    elsif Input.trigger?(Input::CANCEL)
      $game_system.se_play($data_system.cancel_se)
      @cancelled = true
      @fade_out = true
    end
  end
  
  def parsed_coordinates
    parts = @entered_text.split(',')
    return nil if parts.size != 2
    x = parts[0].to_i
    y = parts[1].to_i
    return [x, y]
  rescue
    return nil
  end
end

class ToolGiver_Menu < Window_Selectable
  attr_reader :commands

  def initialize
    @commands = [
      "Custom Item ID...",
      "--- Mods ---", # will remove ts useless thing next upd. | next upd, still lazy to remove.. | Kip, 1:18 am, 24/7/2026, 0.5-GA. i still dont have time to remove ts. if it works and does nothing thenim just gonna keep it for now
      "Coord TP",
      "Map ID Jump",
      "Refresh Map",
      "Dev State Flip",
      "Force Save", 
      "Walk Anywhere",
      "Game Speed FPS",
      "Diagnostics",
      "Delete Item ID",
      "Mute BGM",
      "BGM Jukebox...",
      "About"
    ]
    
    # dynamic os detection block
    plat = RUBY_PLATFORM.downcase
    if plat =~ /mswin|mingw|cygwin/
      os_str = "Windows"
    elsif plat =~ /linux/
      os_str = "Linux"
    elsif plat =~ /darwin/
      os_str = "Mac"
    else
      os_str = "IDontKnowWhatOS" # unknown OS
    end
    @header_text = "CalamusInjector v0.5-GA [#{os_str}]"
    # if upd version, make sure to go to @idr_text.bitmap.draw_text aswell to upd text for diagnostics !!
    
    # in motherland russia, we dont use ui, we build ui
    item_count = @commands.size
    column_count = 2
    width = 460
    row_max = (item_count + 1) / column_count
    # +32 to fit header row
    height = [(row_max * 32) + 32 + 32, 480].min
    
    super((640 - width) / 2, (480 - height) / 2, width, height)
    
    @item_max = item_count
    @column_max = column_count
    self.index = 0
    self.z = 100000
    self.active = true
    self.opacity = 160
    
    refresh
  end

  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    self.contents = Bitmap.new(width - 32, height - 32)
    
    # draw non select header
    self.contents.font.color = system_color
    self.contents.draw_text(0, 0, width - 32, 32, @header_text, 1) # 1 centers txt layout
    self.contents.font.color = normal_color
    
    for i in 0...@item_max
      draw_item(i)
    end
  end

  def draw_item(index)
    return if @column_max.nil? || @column_max == 0
    x = index % @column_max * (width - 32) / @column_max
    y = (index / @column_max * 32) + 32
    rect = Rect.new(x + 4, y, (width - 32) / @column_max - 8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
  end

  def update_cursor_rect
    if @index.nil? || @index < 0 || @column_max.nil? || @column_max == 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    # down 32px to follow items
    x = @index % @column_max * (width - 32) / @column_max
    y = (@index / @column_max * 32 - self.top_row * 32) + 32
    self.cursor_rect.set(x, y, (width - 32) / @column_max, 32)
  end

  def page_row_max
    return (self.height - 64) / 32
  end

  def top_row
    return self.oy / 32
  end

  def top_row=(row)
    if row < 0
      row = 0
    end
    return if @column_max.nil? || @column_max == 0
    row_max = (@item_max + @column_max - 1) / @column_max
    if row > row_max - page_row_max
      row = row_max - page_row_max
    end
    self.oy = row * 32
  end
end

class Scene_Map
  alias_method :orig_update, :update
  
  def update
    if @tool_menu && !@tool_menu.disposed?
      @tool_menu.update
      if Input.trigger?(Input::R)
        $game_system.se_play($data_system.cancel_se)
        @tool_menu.dispose
        @tool_menu = nil
      elsif Input.trigger?(Input::ACTION)
        if @tool_menu.index == 1
          $game_system.se_play($data_system.buzzer_se)
          return
        end

        $game_system.se_play($data_system.decision_se)
        
        case @tool_menu.index
        when 0 # custom item id giver
          $game_temp.num_input_variable_id = 99
          $game_temp.num_input_digits_max = 2
          $game_temp.message_text = "Enter preferred Item ID please! (01-82)"
          $game_temp.message_window_showing = true
          $pending_item_id = true
          @tool_menu.dispose
          @tool_menu = nil
        when 2 # tp coord reminde rmsg
          $game_temp.message_face = "calamus_speak"
          $game_temp.message_text = "Hey, Just remember to use syntax like: -15,30 or 5,12 to teleport properly. Good luck!"
          $game_temp.message_window_showing = true
          $pending_custom_grid_open = true
          @tool_menu.dispose
          @tool_menu = nil
        when 3 # map id jump
          $game_temp.num_input_variable_id = 96
          $game_temp.num_input_digits_max = 3
          $game_temp.message_text = "Enter Map ID to teleport to (001-263):"
          $game_temp.message_window_showing = true
          $pending_map_jump = true
          @tool_menu.dispose
          @tool_menu = nil
        when 4 # map refresh
          force_map_refresh
          @tool_menu.dispose
          @tool_menu = nil
        when 5 # dev flip
          $game_temp.num_input_variable_id = 95
          $game_temp.num_input_digits_max = 3
          $game_temp.message_text = "Enter target switch or Variable ID (001-999):"
          $game_temp.message_window_showing = true
          $pending_state_target = true
          @tool_menu.dispose
          @tool_menu = nil
        when 6 # forcesave
          force_save
          @tool_menu.dispose
          @tool_menu = nil
        when 7 # walkanywhere
          toggle_noclip
          @tool_menu.dispose
          @tool_menu = nil
        when 8 # fps engine setter
          $game_temp.num_input_variable_id = 92
          $game_temp.num_input_digits_max = 4
          $game_temp.message_text = "Input set FPS (0001 - 9999):\nDefault FPS is 0060"
          $game_temp.message_window_showing = true
          $pending_fps_val = true
          @tool_menu.dispose
          @tool_menu = nil
        when 9 # diagnostics
          if $show_diagnostics
            $show_diagnostics = false
            if $debug_coords
              $debug_coords.dispose
              $debug_coords = nil
            end
          else
            $game_temp.num_input_variable_id = 91 
            $game_temp.num_input_digits_max = 2
            $game_temp.message_text = "Select diagnostics mode:\n01: Standard diagnostics\n02: Ext. diagnostics (VISUAL)"
            $game_temp.message_window_showing = true
            $pending_diag_choice = true
          end
          @tool_menu.dispose
          @tool_menu = nil
        when 10 # item id delete
          $game_temp.num_input_variable_id = 89
          $game_temp.num_input_digits_max = 2
          $game_temp.message_text = "Enter target Item ID to banish from inventory:"
          $game_temp.message_window_showing = true
          $pending_del_item = true
          @tool_menu.dispose
          @tool_menu = nil
        when 11 # handle mute/unmute bgm
          $calamus_is_muted ||= false
          if !$calamus_is_muted
            if $game_system.playing_bgm && $game_system.playing_bgm.name != ""
              $calamus_muted_bgm = $game_system.playing_bgm
              $game_system.bgm_stop
              $calamus_is_muted = true
              $game_temp.message_face = "calamus_speak"
              $game_temp.message_text = "Muted track: #{$calamus_muted_bgm.name}"
            else
              $game_temp.message_face = "calamus_sad"
              $game_temp.message_text = "No BGM is currently playing to mute!" #woah
            end
          else
            if $calamus_muted_bgm
              $game_system.bgm_play($calamus_muted_bgm)
              $calamus_is_muted = false
              $game_temp.message_face = "calamus_smile"
              $game_temp.message_text = "Unmuted track! Resuming track: #{$calamus_muted_bgm.name}"
            else
              $game_temp.message_face = "calamus_sad"
              $game_temp.message_text = "Whoops.. No cached track found to restore." #what
              $calamus_is_muted = false
            end
          end
          $game_temp.message_window_showing = true
          @tool_menu.dispose
          @tool_menu = nil
        when 12 # BGM Jukebox
          if $bgm_list.empty?
            $game_temp.message_face = "calamus_shock"
            $game_temp.message_text = "No BGM files found in Audio/BGM? Check Audio/BGM.. Are there any sound files there?" #rare
          else
            $game_temp.num_input_variable_id = 88
            $game_temp.num_input_digits_max = 3
            max_index = $bgm_list.size - 1
            $game_temp.message_text = "Enter BGM index (000 - #{sprintf('%03d', max_index)}):\nCheck the GitHub or your OneShot game directory for the list!"
            $pending_bgm_play = true
          end
          $game_temp.message_window_showing = true
          @tool_menu.dispose
          @tool_menu = nil
        when 13 # about 
          @tool_menu.dispose
          @tool_menu = nil
          $game_temp.message_face = "alula_speak"
          $game_temp.message_text = "Calamus Injector was made by the creator of Alula Editor. [Kip!] (A OneShot save file generator/editor)" 
          # $game_temp.message_window_showing = true DEPRECATED. UNCOMMENT LINE = WILL ENABLE moved to about_dialogue_step
          $about_dialogue_step = 1
        end
      end
      return
    end

    $show_diagnostics ||= false
    if $show_diagnostics
      $debug_coords ||= Debug_Coord_Display.new
      $debug_coords.update
    elsif $debug_coords
      $debug_coords.dispose
      $debug_coords = nil
    end

    if $about_dialogue_step && $about_dialogue_step > 0 && !$game_temp.message_window_showing
      case $about_dialogue_step
      when 1 # legal n about
        $game_temp.message_face = "alula_speak"
        $game_temp.message_text = "Calamus Injector was made by the creator of Alula Editor! [Kip] \\.\\. (A OneShot save file generator/editor) [1/6]"
        $about_dialogue_step = 2
      when 2
        $game_temp.message_face = "magpie_smile"
        $game_temp.message_text = "..and also the creator of Magpie Collector! (A OneShot debugger) \\| See the flow here? Alula(Editor), \\. Calamus(Injector), \\. Magpie(Collector) :D [2/6]"
        $about_dialogue_step = 3
      when 3
        $game_temp.message_face = "af"
        $game_temp.message_text = "I HEAVILY recommend you backup your save files before using Calamus Injector. \\. It possibly may corrupt your save file. \\. With great power, \\. comes great responsibilties. [3/6]"
        $about_dialogue_step = 4
      when 4
        $game_temp.message_face = "calamus_speak"
        $game_temp.message_text = "[Legal] Calamus Injector is not affiliated, \\. nor endorsed by Future Cat LLC in any way. \\. OneShot, \\. its characters, \\. story, \\. assets, \\. and code are the property of Future Cat LLC. [4/6]"
        $about_dialogue_step = 5
      when 5
        $game_temp.message_face = "calamus_smile2"
        $game_temp.message_text = "[Legal] This script is provided for purely education, debugging, experimenting, and modding purposes, \\.\\. Pushing the boundaries of OneShot! [5/6]"
        $about_dialogue_step = 6
      when 6
        $game_temp.message_face = "calamus_sad"
        $game_temp.message_text = "Calamus Injector is built & maintained by Kip. \\.\\. | GitHub: github.com/frizzy-cmd [6/6]"
        $about_dialogue_step = 0 
      end
      $game_temp.message_window_showing = true
    end
    
    if $pending_item_id && !$game_temp.message_window_showing
      id = $game_variables[99]
      if $data_items[id] != nil
        $game_party.gain_item(id, 1)
      else
        $game_temp.message_face = "calamus_heh"
        $game_temp.message_text = "Eheh.. Invalid item ID or I couldn't find the ID.. \\| Try looking on the GitHub repository for all the item IDs!"
        $game_temp.message_window_showing = true
      end
      $pending_item_id = false
    end

    # handles diagnostics sub menu chocie
    if $pending_diag_choice && !$game_temp.message_window_showing
      diag_mode = $game_variables[91] # we read from var 91 which diag sub menu uses for input
      $pending_diag_choice = false
      
      if diag_mode == 1 || diag_mode == 2
        $show_diagnostics = true
        $debug_coords = Debug_Coord_Display.new(diag_mode)
      else
        $game_temp.message_face = "calamus_sad"
        $game_temp.message_text = "Bad option returned from user.. Select 01 or 02!"
        $game_temp.message_window_showing = true
      end
    end

    # open cust. coord ui after dialogue reminder is acknowledge
    if $pending_custom_grid_open && !$game_temp.message_window_showing
      $pending_custom_grid_open = false
      @coord_window = Window_CalamusCoordInput.new
    end

    if $pending_map_jump && !$game_temp.message_window_showing
      target_map = $game_variables[96]
      $pending_map_jump = false

      if target_map >= 264 || target_map <= 0
        $game_temp.message_face = "calamus_sad"
        $game_temp.message_text = "Hmm, I couldn't find Map ID #{target_map}. Does it exist?"
        $game_temp.message_window_showing = true
        $game_variables[96] = $game_map.map_id
      else
        execute_map_jump(target_map)
      end
    end

    if $pending_state_target && !$game_temp.message_window_showing
      $target_state_id = $game_variables[95]
      $pending_state_target = false
      
      $game_temp.num_input_variable_id = 94
      $game_temp.num_input_digits_max = 2
      $game_temp.message_text = "Target ID: #{$target_state_id}\nPick type:\n01: Toggle switch (TRUE/FALSE)\n02: Set variable value"
      $game_temp.message_window_showing = true
      $pending_state_type = true
    end

    if $pending_state_type && !$game_temp.message_window_showing
      type = $game_variables[94]
      $pending_state_type = false
      
      if type == 1
        current = $game_switches[$target_state_id]
        $game_switches[$target_state_id] = !current
        $game_map.need_refresh = true
        $game_temp.message_face = "calamus_smile2"
        $game_temp.message_text = "Switch #{$target_state_id} flipped from #{current} to #{!current}!"
        $game_temp.message_window_showing = true
      elsif type == 2
        $game_temp.num_input_variable_id = 93
        $game_temp.num_input_digits_max = 4
        $game_temp.message_text = "Enter value to set for Variable #{$target_state_id}:"
        $game_temp.message_window_showing = true
        $pending_variable_val = true
      else
        $game_temp.message_face = "calamus_sad"
        $game_temp.message_text = "Bad option returned from user.."
        $game_temp.message_window_showing = true
      end
    end

    if $pending_variable_val && !$game_temp.message_window_showing
      val = $game_variables[93]
      $pending_variable_val = false
      $game_variables[$target_state_id] = val
      $game_map.need_refresh = true
      $game_temp.message_face = "calamus_smile"
      $game_temp.message_text = "Variable #{$target_state_id} set to #{val}!"
      $game_temp.message_window_showing = true
    end

    if $pending_fps_val && !$game_temp.message_window_showing
      fps_target = $game_variables[92]
      $pending_fps_val = false
      fps_target = 1 if fps_target < 1
      fps_target = 9999 if fps_target > 9999
      Graphics.frame_rate = fps_target
      $game_temp.message_face = "calamus_smile"
      $game_temp.message_text = "Frames set to #{fps_target} FPS successfully!"
      $game_temp.message_window_showing = true
    end

    if $pending_del_item && !$game_temp.message_window_showing
      del_id = $game_variables[89]
      $pending_del_item = false
      
      if $game_party.weapon_number(del_id) > 0 || $game_party.armor_number(del_id) > 0 || $game_party.item_number(del_id) > 0 || $data_items[del_id] != nil
        $game_party.lose_item(del_id, 99)
        $game_temp.message_face = "calamus_smile"
        $game_temp.message_text = "Item ID #{del_id} has been removed from your inventory."
        $game_temp.message_window_showing = true
      else
        $game_temp.message_face = "calamus_speak"
        $game_temp.message_text = "Hmm, I couldn't find that Item ID in your inventory, or does it exist?"
        $game_temp.message_window_showing = true
      end
    end

    if $pending_bgm_play && !$game_temp.message_window_showing
      track_idx = $game_variables[88]
      $pending_bgm_play = false
      
      if track_idx >= 0 && track_idx < $bgm_list.size
        chosen_track = $bgm_list[track_idx]
        $game_system.bgm_play(RPG::AudioFile.new(chosen_track, 100, 100))
        $game_temp.message_face = "calamus_smile"
        $game_temp.message_text = "Now playing track #{track_idx}: #{chosen_track} !"
        $calamus_is_muted = false
        $calamus_muted_bgm = nil 
      else
        $game_temp.message_face = "calamus_smile2"
        $game_temp.message_text = "Sorry! Index must be between 0 and #{$bgm_list.size - 1}."
      end
      $game_temp.message_window_showing = true
    end
    
    if Input.trigger?(Input::R) && @tool_menu.nil? && @coord_window.nil?
      $game_system.se_play($data_system.decision_se)
      @tool_menu = ToolGiver_Menu.new
    end

    # custom overlay
    if @coord_window
      @coord_window.update
      if @coord_window.disposed?
        if @coord_window.confirmed
          coords = @coord_window.parsed_coordinates
          if coords
            $last_teleport_x = $game_player.x
            $last_teleport_y = $game_player.y
            $game_player.moveto(coords[0], coords[1])
            
            $game_temp.message_face = "calamus_smile"
            $game_temp.message_text = "Teleported to X: #{coords[0]}, Y: #{coords[1]}!\nSaved last coordinates."
          else
            pc_user = ENV['USER'] || ENV['USERNAME'] || "User" # if fail, then fallback to User. USER is for UNIX. USERNAME is for Windows
            $game_temp.message_face = "calamus_sad"
            $game_temp.message_text = "Err.. Format parse error! #{pc_user}, please remember to use syntax like: -15,30 or 5,12 .. Thanks!"
          end
          $game_temp.message_window_showing = true
        elsif @coord_window.retp_triggered
          # Custom back-teleport route execution
          teleport_to_backup
        end
        @coord_window = nil
      end
      return
    end
    
    orig_update
  end
end

# makes txt file
def setup_bgm_jukebox
  $bgm_list = []
  bgm_dir = "Audio/BGM/"
  if File.directory?(bgm_dir)
    Dir.entries(bgm_dir).each do |file|
      if file =~ /\.(mp3|ogg|wav|mid)$/i # kill extenmsion
        $bgm_list.push(File.basename(file, ".*"))
      end
    end
  end
  $bgm_list.sort!
  
 # writes to users oneshot game directory
  begin
    File.open("calamus_bgm_log.txt", "w") do |f|
      f.puts "=== CalamusInjector Jukebox Map | Insert one of these IDs into the mod menu and try it out! ==="
      $bgm_list.each_with_index do |track, index|
        f.puts "#{sprintf('%03d', index)}: #{track}"
      end
    end
  end
end

# init once GLOBAL
setup_bgm_jukebox

# Execution help funcs.
def execute_string_teleport(val)
  str = sprintf("%07d", val)
  sign_x = str[0, 1].to_i
  val_x  = str[1, 2].to_i
  sign_y = str[3, 1].to_i
  val_y  = str[4, 3].to_i
  
  target_x = (sign_x == 1) ? -val_x : val_x
  target_y = (sign_y == 1) ? -val_y : val_y
  
  $last_teleport_x = $game_player.x
  $last_teleport_y = $game_player.y
  
  $game_player.moveto(target_x, target_y)
  
  $game_temp.message_face = "calamus_smile"
  $game_temp.message_text = "Teleported to X: #{target_x}, Y: #{target_y}!\nSaved last coord as: #{$last_teleport_x}, #{$last_teleport_y}"
  $game_temp.message_window_showing = true
end

def teleport_to_backup
  if $last_teleport_x && $last_teleport_y
    old_x = $game_player.x
    old_y = $game_player.y
    $game_player.moveto($last_teleport_x, $last_teleport_y)
    $last_teleport_x = old_x
    $last_teleport_y = old_y
    $game_temp.message_face = "calamus_smile2"
    $game_temp.message_text = "Teleported back to last coordinate point successfully!"
  else
    $game_temp.message_face = "calamus_heh"
    $game_temp.message_text = "No backup coord found! Teleport somewhere first."
  end
  $game_temp.message_window_showing = true
end

# handle map jump
def execute_map_jump(map_id) 
  $game_temp.player_transferring = true
  $game_temp.player_new_map_id = map_id
  $game_temp.player_new_x = 15
  $game_temp.player_new_y = 15
  $game_temp.player_new_direction = 2
  
  $game_temp.message_face = "calamus_smile"
  $game_temp.message_text = "Jumping to Map ID #{map_id}! Spawning at X:15, Y:15."
  $game_temp.message_window_showing = true
end

# handles the force map refresh option
def force_map_refresh
  current_map_id = $game_map.map_id
  $game_map.setup(current_map_id)
  $game_player.moveto($game_player.x, $game_player.y)
  
  if $scene.is_a?(Scene_Map)
    $scene.instance_eval do
      if @spriteset
        @spriteset.dispose
        @spriteset = Spriteset_Map.new
      end
    end
  end

  $game_screen.start_flash(Color.new(255, 255, 255, 128), 10)

  $game_temp.message_face = "calamus_smile2"
  $game_temp.message_text = "Refreshed graphics & event states successfully!"
  $game_temp.message_window_showing = true
end

# handles force saving
def force_save
  appdata_path = ENV['APPDATA']
  save_file_path = appdata_path ? appdata_path + "/Oneshot/save.dat": "save.dat"

  # FileUtils.mkdir_p(File.dirname(save_file_path)) no for now

  file = File.open(save_file_path, "wb")
  characters = []
  characters.push([$game_player.character_name, $game_player.character_hue])
  Marshal.dump(characters, file)
  Marshal.dump(Graphics.frame_count, file)
  $game_system.save_count += 1
  $game_system.magic_number = $data_system.magic_number
  Marshal.dump($game_system, file)
  Marshal.dump($game_switches, file)
  Marshal.dump($game_variables, file)
  Marshal.dump($game_self_switches, file)
  Marshal.dump($game_screen, file)
  Marshal.dump($game_actors, file)
  Marshal.dump($game_party, file)
  Marshal.dump($game_troop, file)
  Marshal.dump($game_map, file)
  Marshal.dump($game_player, file) # Yeah my code is fucking messy shut up lol,  if you evr need a motivational quote, "Never code like Kip"
  file.close
  
  $game_temp.message_face = "calamus_smile2"
  $game_temp.message_text = "Successfully force-saved game to %appdata%/OneShot/save.dat! [or your local OneShot save file directory. not only exclusive for W10]"
  $game_temp.message_window_showing = true
end

#handles walk anywhere
def toggle_noclip
  current_state = $game_player.instance_variable_get(:@through)
  $game_player.instance_variable_set(:@through, !current_state)

  status = $game_player.through ? "enabled" : "disabled"
  $game_temp.message_face = "calamus_speak"
  $game_temp.message_text = "Wait a second, Niko, since when could you walk anywhere? [#{status}]"
  $game_temp.message_window_showing = true
end

# ++++ DIAGNOSTICS ++++

class Debug_Coord_Display
  # cache color objects ONCE so we don't spam GC :3
  COLOR_GREEN  = Color.new(0, 255, 0, 45)
  COLOR_RED    = Color.new(255, 0, 0, 75)
  COLOR_BLUE   = Color.new(0, 180, 255, 110)
  COLOR_YELLOW = Color.new(255, 230, 0, 130)

  def initialize(mode = 1)
    @mode = mode # 1 = standard text, 2 = extended visual grid
    @viewport = Viewport.new(0, 0, 640, 480)
    @viewport.z = 99999
    
    @text = Sprite.new(@viewport)
    @text.bitmap = Bitmap.new(400, 400) 
    @text.x = 10
    @text.y = 10
    
    @idr_text = Sprite.new(@viewport)
    @idr_text.bitmap = Bitmap.new(600, 32)
    @idr_text.x = 10
    @idr_text.y = 480 - 32 - 10
    @idr_text.bitmap.font.size = 16
    @idr_text.bitmap.font.bold = false
    
    label_suffix = (@mode == 2) ? "Extended Visuals" : "Standard"
    @idr_text.bitmap.draw_text(0, 0, 600, 32, "CalamusInjector v0.5-GA | Diagnostics [#{label_suffix}]")

    if @mode == 2
      @tile_overlay = Sprite.new(@viewport)
      @tile_overlay.bitmap = Bitmap.new(640, 480)

      # footer legend
      @legend = Sprite.new(@viewport)
      @legend.bitmap = Bitmap.new(220, 100)
      @legend.x = 640 - 220 - 10
      @legend.y = 480 - 100 - 10
      @legend.bitmap.font.size = 13
      @legend.bitmap.font.bold = true
      
      @legend.bitmap.draw_text(0, 0, 220, 16, "COLORS:")
      @legend.bitmap.draw_text(0, 16, 220, 16, "YELLOW: PLR HITBOX")
      @legend.bitmap.draw_text(0, 32, 220, 16, "BLUE: INTERACTABLE/NPC")
      @legend.bitmap.draw_text(0, 48, 220, 16, "GREEN: PASSABLE")
      @legend.bitmap.draw_text(0, 64, 220, 16, "RED: NOT PASSABLE")
      
      @last_px = nil
      @last_py = nil
      @last_disp_x = nil
      @last_disp_y = nil
      
      # preallocate hash to prevent alot of $game_map.passable?
      @pass_cache = {}
      @cached_map_id = nil
    end
  end

  def update
    return if @text.disposed?
    
      cur_px = $game_player.x
      cur_py = $game_player.y
      disp_x = $game_map.display_x / 4
      disp_y = $game_map.display_y / 4

      # reset cache if map reload
      if @cached_map_id != $game_map.map_id
        @pass_cache.clear
        @cached_map_id = $game_map.map_id
      end

      # if niko and cam did not move, DO NOT REDRAW CANVAS.
      if cur_px != @last_px || cur_py != @last_py || disp_x != @last_disp_x || disp_y != @last_disp_y
        @last_px = cur_px
        @last_py = cur_py
        @last_disp_x = disp_x
        @last_disp_y = disp_y
        
        @tile_overlay.bitmap.clear
        
        start_x = [disp_x / 32 - 1, 0].max
        end_x   = [(disp_x + 640) / 32 + 1, $game_map.width - 1].min
        start_y = [disp_y / 32 - 1, 0].max
        end_y   = [(disp_y + 480) / 32 + 1, $game_map.height - 1].min

        # passability grid calc (USING MEM CACHE TO BYE LAG)
        (start_x..end_x).each do |map_x|
          (start_y..end_y).each do |map_y|
            key = (map_x << 16) | map_y
            
            # lookup cache or fetch ONCE
            passable = @pass_cache[key]
            if passable.nil?
              passable = $game_map.passable?(map_x, map_y, 0)
              @pass_cache[key] = passable
            end
            
            screen_x = (map_x * 32) - disp_x
            screen_y = (map_y * 32) - disp_y
            
            color = passable ? COLOR_GREEN : COLOR_RED
            @tile_overlay.bitmap.fill_rect(screen_x, screen_y, 32, 32, color)
          end
        end

        # more optimization!
        $game_map.events.each_value do |event|
          next if event.nil? || event.instance_variable_get(:@erased)
          next if event.x < start_x || event.x > end_x || event.y < start_y || event.y > end_y
          
          ev_screen_x = (event.x * 32) - disp_x
          ev_screen_y = (event.y * 32) - disp_y
          
          @tile_overlay.bitmap.fill_rect(ev_screen_x, ev_screen_y, 32, 32, COLOR_BLUE)
        end

        # plr hitbox
        plr_screen_x = (cur_px * 32) - disp_x
        plr_screen_y = (cur_py * 32) - disp_y
        @tile_overlay.bitmap.fill_rect(plr_screen_x, plr_screen_y, 32, 32, COLOR_YELLOW)
      end
    end

    # standard diag
    @text.bitmap.clear
    can_dash = $game_player.respond_to?(:dash?) ? $game_player.dash? : "No"
    plr_sprite = $game_player.character_name != "" ? $game_player.character_name : "None"
    active_face = ($game_temp.message_face && $game_temp.message_face != "") ? $game_temp.message_face : "None"
    current_bgm = ($game_system.playing_bgm && $game_system.playing_bgm.name != "") ? $game_system.playing_bgm.name : "None"

    lines = [
      "MapID: #{$game_map.map_id}",
      "X, Y: #{$game_player.x}, #{$game_player.y}",
      "Direction: #{$game_player.direction} | Moving?: #{$game_player.moving?}",
      "Sprinting?: #{can_dash}",
      "Events: #{$game_map.events.size}",
      "ScreenX: #{$game_player.screen_x} | ScreenY: #{$game_player.screen_y}",
      "Plr sprite: #{plr_sprite}",
      "Dialogue face: #{active_face}",
      "Engine FPS: #{Graphics.frame_rate} FPS",
      "Current BGM: #{current_bgm}",
      "Save count: #{$game_system.save_count}"
    ]
    
    lines.each_with_index do |line, i|
      @text.bitmap.draw_text(0, i * 22, 400, 30, line)
    end
  end
  
  def dispose
    @text.dispose unless @text.disposed?
    @idr_text.dispose unless @idr_text.disposed?
    @tile_overlay.dispose if @tile_overlay && !@tile_overlay.disposed?
    @legend.dispose if @legend && !@legend.disposed?
    @viewport.dispose unless @viewport.disposed?
  end
end

# inject thyself to window title
begin
  # w32
  find_window = Win32API.new('user32', 'FindWindow', 'pp', 'l')
  set_text    = Win32API.new('user32', 'SetWindowText', 'lp', 'i')

  # find.
  hwnd = find_window.call('RGSS Player', nil) #possibly..
  hwnd = find_window.call(nil, 'OneShot') if hwnd == 0
  
  # if found, rename!!
  if hwnd != 0
    set_text.call(hwnd, "OneShot [Injected w/ CalamusInjector]")
  end
rescue Exception => e
  # fail silently :(
end

# probably wont work because i dont know how the fuck oneshot titles it windows i tried to find it but to no avail
# Celebrating 1041 lines of code!
