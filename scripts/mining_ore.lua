-- mining_ore.lua v2.0.2 -- by Cegaiel
-- Credits to Tallow for his Simon macro, which was used as a template to build on.
-- 
-- Brute force method, you manually click/set every stones' location and it will work every possible 3 node/stone combinations.
--

-- No longer asks for Popup Delay input!
-- Instead it now searches for new messages in main chat (feedback messages generated by mine).
-- It now keeps track of how much ore you gathered this round and your total session; displaying it on GUI.
-- If it detects that you gathered ore, then it moves immediately onto next 3 stone set. If not, then it loops forever waiting on the popup box to occur, before continuing (No workload has no value).
-- Previous versions, if lag was too high, it might try to click on the nodes while a popup box occured later (resulting in some nodes not getting highlighted properly).
-- This means the macro now auto adjusts to lag. You no longer have to find the 'best value' for popup delay and hope for the best. This runs extremely smooth and accurately now.


dofile("common.inc");

info = "Ore Mining v2.0.2 by Cegaiel --\nUses Brute Force method.\nWill try every possible 3 node/stone combination. Time consuming but it works!\n\nMAIN chat tab MUST be showing and wide enough so that each line doesn't wrap.\n\nChat MUST be minimized but Visible (Options, Chat-Related, \'Minimized chat channels are still visible\').\n\nPress Shift over ATITD window.";

-- These arrays aren't in use currently.
--Chat_Types = {
--["Your workload had"] = "workload",
--};

-- Start don't alter these ...
oreGathered = 0;
oreGatheredTotal = 0;
oreGatheredLast = 0;
lastOreGathered = 0;
miningTime = 0;
autoWorkMine = true;
timesworked = 0;
dropdown_values = {"Shift Key", "Ctrl Key", "Alt Key", "Mouse Wheel Click"};
dropdown_cur_value = 1;
dropdown_ore_values = {"Aluminum (9)", "Antimony (14)", "Copper (8)", "Gold (12)", "Iron (7)", "Lead (9)", "Lithium (10)", "Magnesium (9)", "Platinum (12)", "Silver (10)", "Strontium (10)", "Tin (9)", "Tungsten (12)", "Zinc (10)"};
dropdown_ore_cur_value = 1;
cancelButton = 0;
-- End Don't alter these ...


--Customizable
muteSoundEffects = false;
minPopSleepDelay = 100;  -- The minimum delay time used during findClosePopUp() function

function doit()
  askForWindow(info);
  promptDelays();
  getMineLoc();
  getPoints();
  clickSequence();
end


function doit2()
  promptDelays();
  getMineLoc();
  getPoints();
  clickSequence();
end


function getMineLoc()
  mineList = {};
  local was_shifted = lsShiftHeld();
  if (dropdown_cur_value == 1) then
  was_shifted = lsShiftHeld();
  key = "tap Shift";
  elseif (dropdown_cur_value == 2) then
  was_shifted = lsControlHeld();
  key = "tap Ctrl";
  elseif (dropdown_cur_value == 3) then
  was_shifted = lsAltHeld();
  key = "tap Alt";
  elseif (dropdown_cur_value == 4) then
  was_shifted = lsMouseIsDown(2); --Button 3, which is middle mouse or mouse wheel
  key = "click MWheel ";
  end

  local is_done = false;
  mx = 0;
  my = 0;
  z = 0;
  while not is_done do
    mx, my = srMousePos();
    local is_shifted = lsShiftHeld();

    if (dropdown_cur_value == 1) then
      is_shifted = lsShiftHeld();
    elseif (dropdown_cur_value == 2) then
      is_shifted = lsControlHeld();
    elseif (dropdown_cur_value == 3) then
      is_shifted = lsAltHeld();
    elseif (dropdown_cur_value == 4) then
      is_shifted = lsMouseIsDown(2); --Button 3, which is middle mouse or mouse wheel
    end

    if is_shifted and not was_shifted then
      mineList[#mineList + 1] = {mx, my};
    end
    was_shifted = is_shifted;
    checkBreak();
    lsPrint(10, 10, z, 1.0, 1.0, 0xc0c0ffff,
	    "Set Mine Location");
    local y = 60;
    lsPrint(10, y, z, 0.7, 0.7, 0xf0f0f0ff, "Lock ATITD screen (Alt+L) - OPTIONAL!");
    y = y + 20;
    lsPrint(10, y, z, 0.7, 0.7, 0xf0f0f0ff, "Suggest F5 view, zoomed about 75% out.");
    y = y + 60;
    lsPrint(10, y, z, 0.7, 0.7, 0xc0c0ffff, "Hover and " .. key .. " over the MINE !");
    y = y + 70;
    lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "TIP (Optional):");
    y = y + 20;
    lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "For Maximum Performance (least lag) Uncheck:");
    y = y + 16;
    lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "Options, Interface, Other: 'Use Flyaway Messages'");
    local start = math.max(1, #mineList - 20);
    local index = 0;
    for i=start,#mineList do
	mineX = mineList[i][1];
	mineY = mineList[i][2];
    end

  if #mineList >= 1 then
      is_done = 1;
  end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff,
                    "End script") then
      error "Clicked End Script button";
    end
  lsDoFrame();
  lsSleep(50);
  end
end

function fetchTotalCombos()
  TotalCombos = 0;
	for i=1,#clickList do
		for j=i+1,#clickList do
			for k=j+1,#clickList do
			TotalCombos = TotalCombos + 1;
			end
		end
	end
end


function getPoints()
  clickList = {};
  if (dropdown_ore_cur_value == 1) then
  ore = "Aluminum";
  stonecount = 9;
  elseif (dropdown_ore_cur_value == 2) then
  ore = "Antimony";
  stonecount = 14;
  elseif (dropdown_ore_cur_value == 3) then
  ore = "Copper";
  stonecount = 8;
  elseif (dropdown_ore_cur_value == 4) then
  ore = "Gold";
  stonecount = 12;
  elseif (dropdown_ore_cur_value == 5) then
  ore = "Iron";
  stonecount = 7;
  elseif (dropdown_ore_cur_value == 6) then
  ore = "Lead";
  stonecount = 9;
  elseif (dropdown_ore_cur_value == 7) then
  ore = "Lithium";
  stonecount = 10;
  elseif (dropdown_ore_cur_value == 8) then
  ore = "Magnesium";
  stonecount = 9;
  elseif (dropdown_ore_cur_value == 9) then
  ore = "Platinum";
  stonecount = 12;
  elseif (dropdown_ore_cur_value == 10) then
  ore = "Silver";
  stonecount = 10;
  elseif (dropdown_ore_cur_value == 11) then
  ore = "Strontium";
  stonecount = 10;
  elseif (dropdown_ore_cur_value == 12) then
  ore = "Tin";
  stonecount = 9;
  elseif (dropdown_ore_cur_value == 13) then
  ore = "Tungsten";
  stonecount = 12;
  elseif (dropdown_ore_cur_value == 14) then
  ore = "Zinc";
  stonecount = 10;
  end

  local nodeleft = stonecount;
  local was_shifted = lsShiftHeld();
  if (dropdown_cur_value == 1) then
  was_shifted = lsShiftHeld();
  elseif (dropdown_cur_value == 2) then
  was_shifted = lsControlHeld();
  elseif (dropdown_cur_value == 3) then
  was_shifted = lsAltHeld();
  elseif (dropdown_cur_value == 4) then
  was_shifted = lsMouseIsDown(2); --Button 3, which is middle mouse or mouse wheel
  end

  local is_done = false;
  local nx = 0;
  local ny = 0;
  local z = 0;
  while not is_done do
    nx, ny = srMousePos();
    local is_shifted = lsShiftHeld();
  if (dropdown_cur_value == 1) then
  is_shifted = lsShiftHeld();
  elseif (dropdown_cur_value == 2) then
  is_shifted = lsControlHeld();
  elseif (dropdown_cur_value == 3) then
  is_shifted = lsAltHeld();
  elseif (dropdown_cur_value == 4) then
  is_shifted = lsMouseIsDown(2);
  end

    if is_shifted and not was_shifted then
      clickList[#clickList + 1] = {nx, ny};
      nodeleft = nodeleft - 1;
    end
    was_shifted = is_shifted;
    checkBreak();
    lsPrint(10, 10, z, 1.0, 1.0, 0xc0c0ffff,
	    "Set Node Locations (" .. #clickList .. "/" .. stonecount .. ")");
    local y = 60;
    lsSetCamera(0,0,lsScreenX*1.4,lsScreenY*1.4);
    autoWorkMine = lsCheckBox(15, y, z, 0xffff80ff, " Auto 'Work Mine'", autoWorkMine);
    lsSetCamera(0,0,lsScreenX*1.0,lsScreenY*1.0);
    y = y + 10
    lsPrint(10, y, z, 0.7, 0.7, 0xc0c0ffff, "Hover and " .. key .. " over each node.");
    y = y + 20;
    lsPrint(10, y, z, 0.7, 0.7, 0xff8080ff, "Make sure chat is MINIMIZED!");
    y = y + 30;
    lsPrint(10, y, z, 0.7, 0.7, 0xB0B0B0ff, "Mine Type:  " .. ore);
    y = y + 20;
    miningTimeGUI = "N/A";
    if miningTime ~= 0 then
      --miningTimeGUI = math.floor(miningTime/100)/10 .. " secs";
      miningTimeGUI = (miningTime/100)/10 .. " secs";
    end
    lsPrint(10, y, z, 0.7, 0.7, 0xf0f0f0ff, "Mine Worked:  " .. timesworked .. " times  Last: " .. miningTimeGUI);
    y = y + 20;
    --lsPrint(10, y, z, 0.7, 0.7, 0x80ff80ff, "Total Ore Found: " .. math.floor(oreGatheredTotal) .. "  (Last Round: " .. math.floor(oreGatheredLast) .. ")");
    lsPrint(10, y, z, 0.7, 0.7, 0x80ff80ff, "Total Ore Found:  " .. math.floor(oreGatheredTotal));
    lsPrint(175, y, z, 0.7, 0.7, 0x40ffffff, " Last Round: " .. math.floor(oreGatheredLast));
    y = y + 20;
    lsPrint(10, y, z, 0.7, 0.7, 0xB0B0B0ff, "Select " .. nodeleft .. " more nodes to automatically start!");
    y = y + 30;
    local start = math.max(1, #clickList - 20);
    local index = 0;
    for i=start,#clickList do
      local xOff = (index % 3) * 100;
      local yOff = (index - index%3)/2 * 15;
      lsPrint(20 + xOff, y + yOff, z, 0.5, 0.5, 0xffff80ff,
              i .. ": (" .. clickList[i][1] .. ", " .. clickList[i][2] .. ")");
      index = index + 1;
    end

    if #clickList >= stonecount then
      is_done = 1;
    end

    if #clickList == 0 then
      if lsButtonText(10, lsScreenY - 30, z, 110, 0xffff80ff, "Work Mine") then
        workMine();
      end
    end

      if lsButtonText(208, lsScreenY -65, z, 80, 0xffffffff, "Config") then
	  cancelButton = 1;
        doit2();
      end

    if #clickList > 0 then
      if lsButtonText(10, lsScreenY - 30, z, 100, 0xff8080ff, "Reset") then
        reset();
      end
    end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff,
                    "End script") then
      error "Clicked End Script button";
    end
  lsDoFrame();
  lsSleep(50);
  end
end


function fetchTotalCombos()
  TotalCombos = 0;
	for i=1,#clickList do
		for j=i+1,#clickList do
			for k=j+1,#clickList do
			TotalCombos = TotalCombos + 1;
			end
		end
	end
end


function clickSequence()
  fetchTotalCombos();
  sleepWithStatus(150, "Starting... Don\'t move mouse!");
  oreGatheredLast = 0;
  lastOreGathered = 0;
  oreGathered = 0;
  local worked = 1;
  local startMiningTime = lsGetTimer();

	for i=1,#clickList do
		for j=i+1,#clickList do
			for k=j+1,#clickList do
	--checkCloseWindows();
	-- 1st Node
	checkBreak();
      checkAbort();
	local startSetTime = lsGetTimer();
	srSetMousePos(clickList[i][1], clickList[i][2]);
	lsSleep(clickDelay);
	srKeyEvent('A'); 

		-- 2nd Node
		checkBreak();
	       checkAbort();
		srSetMousePos(clickList[j][1], clickList[j][2]);
		lsSleep(clickDelay);
		srKeyEvent('A'); 

			-- 3rd Node
			checkBreak();
			checkAbort();
			srSetMousePos(clickList[k][1], clickList[k][2]);
			lsSleep(clickDelay);
			srKeyEvent('S'); 
			findClosePopUp();

			worked = worked + 1
			local elapsedTime = lsGetTimer() - startMiningTime;
			local setTime = lsGetTimer() - startSetTime;

		       local y = 10;
		       lsPrint(10, y, 0, 0.7, 0.7, 0xB0B0B0ff, "Hold Ctrl+Shift to end this script.");
		       y = y +15
		       lsPrint(10, y, 0, 0.7, 0.7, 0xB0B0B0ff, "Hold Alt+Shift to pause this script.");
		       y = y +35
			lsPrint(10, y, 0, 0.7, 0.7, 0xB0B0B0ff, "[" .. worked .. "/" .. TotalCombos .. "] Nodes Worked: " .. i .. ", " .. j .. ", " .. k);
			y = y + 25;
			lsPrint(10, y, 0, 0.7, 0.7, 0xB0B0B0ff, "Node Click Delay: " .. clickDelay .. " ms");
			y = y + 32;
			--lsPrint(10, y, 0, 0.7, 0.7, 0xffffffff, "Last Work Time: " .. math.floor(setTime/100)/10 .. " secs");
			lsPrint(10, y, 0, 0.7, 0.7, 0xffffffff, "Last Work Time: " .. (setTime/100)/10 .. " secs");
			y = y + 32;
			--lsPrint(10, y, 0, 0.7, 0.7, 0xffffffff, "Time Elapsed: " .. math.floor(elapsedTime/100)/10 .. " secs");
			lsPrint(10, y, 0, 0.7, 0.7, 0xffffffff, "Current Time Elapsed: " .. (elapsedTime/100)/10 .. " secs");
			y = y + 16;
			lsPrint(10, y, 0, 0.7, 0.7, 0xffffffff, "Previous Time Elapsed: " .. miningTimeGUI);
			y = y + 32;
			lsPrint(10, y, 0, 0.7, 0.7, 0x40ffffff, "Ore Found this Round: " .. math.floor(oreGatheredLast));
			y = y + 20;
			lsPrint(10, y, 0, 0.7, 0.7, 0x80ff80ff, "Total Ore Found: " .. math.floor(oreGatheredTotal));
			y = y + 32;
			lsPrint(10, y, 0, 0.7, 0.7, 0xffff80ff, "HOLD Shift to Abort and Return to Menu.");
			y = y + 32;
			lsPrint(10, y, 0, 0.7, 0.7, 0xff8080ff, "Don't touch mouse until finished!");
			lsDoFrame();
			end
		end
	end

  miningTime = lsGetTimer() - startMiningTime;
  timesworked = timesworked + 1;
    if autoWorkMine then
      workMine();
    end
  reset();
end


function workMine()
      srSetMousePos(mineX, mineY);
      lsSleep(clickDelay);
      --Send 'W' key over Mine to Work it (Get new nodes)
      srKeyEvent('W'); 
      sleepWithStatus(1000, "Working mine (Fetching new nodes)");
	findClosePopUpOld();
end


function checkCloseWindows()
-- Rare situations a click can cause a window to appear for a node, blocking the view to other nodes.
-- This is a safeguard to keep random windows that could appear, from remaining on screen and blocking the view of other nodes from being selected.
	srReadScreen();
	lsSleep(10);
	local closeWindows = findAllImages("thisis.png");

	  if #closeWindows > 0 then
		for i=#closeWindows, 1, -1 do
		  -- 2 right clicks in a row to close window (1st click pins it, 2nd unpins it
		  srClickMouseNoMove(closeWindows[i][0]+5, closeWindows[i][1]+10, true);
		  lsSleep(100);
		  srClickMouseNoMove(closeWindows[i][0]+5, closeWindows[i][1]+10, true);
		end
		lsSleep(clickDelay);
	  end
end

function reset()
  getPoints();
  clickSequence();
end

function checkAbort()
  if lsShiftHeld() then
    sleepWithStatus(750, "Aborting ..."); 
    reset();
  end
end


function findClosePopUp()
  lastOreGathered = oreGathered;
  startTime = lsGetTimer();

    while 1 do
      checkBreak();
      srReadScreen();
	lsSleep(50);
	chatRead();
	lsSleep(50);
       OK = srFindImage("OK.png");

		if clickDelay < minPopSleepDelay then
		  popSleepDelay = minPopSleepDelay;
		else
		  popSleepDelay = clickDelay
		end

		--If we gathered new ore, add to tally and don't wait for popup.
		--Beware, ugly quick hack: In the rare chance you get the exact # of ore back to back, then that 6000ms countdown timer will also force the break.
	  if (lastOreGathered ~= oreGathered) or ( (lsGetTimer() - startTime) > 6000) then
	  	oreGatheredTotal = oreGatheredTotal + oreGathered;
	  	oreGatheredLast = oreGatheredLast + oreGathered;
	    lsSleep(popSleepDelay);
	    break;
	  end

	  if OK then  
	    srClickMouseNoMove(OK[0]+2,OK[1]+2, true);
	    lsSleep(popSleepDelay);
	    break;
	  end
    end
end


function findClosePopUpOld()
    while 1 do
      checkBreak();
      srReadScreen();
      lsSleep(10);
      OK = srFindImage("OK.png");
	  if OK then  
	    srClickMouseNoMove(OK[0]+2,OK[1]+2, true);
	    lsSleep(clickDelay);
	  else
	    break;
	  end
    end
end


function checkIfMain(chatText)
   for j = 1, #chatText do
      if string.find(chatText[j][2], "^%*%*", 0) then
         return true;
      end
	-- Below isn't needed unless we are going to use Chat_Types Array
      --for k, v in pairs(Chat_Types) do
         --if string.find(chatText[j][2], k, 0, true) then
            --return true;
         --end
      --end
   end
   return false;
end


function chatRead()
	--Find the last line of chat
	--lsSleep(100);
   local chatText = getChatText();
   local onMain = checkIfMain(chatText);

   if not onMain then
      if not muteSoundEffects then
         lsPlaySound("timer.wav");
      end
   end

   -- Wait for Main chat screen and alert user if its not showing
   while not onMain do
   	checkBreak();
      srReadScreen();
      chatText = getChatText();
      onMain = checkIfMain(chatText);
      sleepWithStatus(100, "Looking for Main chat screen ...\n\nIf main chat is showing, then try clicking Work Mine to clear this screen");
   end
   
   lastLine = chatText[#chatText][2];
   oreGathered = string.match(lastLine, "(%d+) " .. ore);
	if not oreGathered then
	oreGathered = 0;
	end
end


function promptDelays()
  local is_done = false;
  local count = 1;
  while not is_done do
	checkBreak();
	local y = 10;
	lsPrint(10, y, 0, 0.8, 0.8, 0xffffffff,
            "Key or Mouse to Select Nodes:");
	y = y + 35;
	lsSetCamera(0,0,lsScreenX*1.3,lsScreenY*1.3);
	dropdown_cur_value = lsDropdown("ArrangerDropDown", 10, y, 0, 200, dropdown_cur_value, dropdown_values);
	lsSetCamera(0,0,lsScreenX*1.0,lsScreenY*1.0);
	y = y + 20;
	lsPrint(10, y, 0, 0.8, 0.8, 0xffffffff, "How many Nodes?");
	y = y + 50;
	lsSetCamera(0,0,lsScreenX*1.3,lsScreenY*1.3);
	dropdown_ore_cur_value = lsDropdown("ArrangerDropDown2", 10, y, 0, 200, dropdown_ore_cur_value, dropdown_ore_values);
	lsSetCamera(0,0,lsScreenX*1.0,lsScreenY*1.0);
	y = y + 5;
      lsPrint(10, y, 0, 0.8, 0.8, 0xffffffff, "Node Click Delay (ms):");
	y = y + 22;
      is_done, clickDelay = lsEditBox("delay", 10, y, 0, 50, 30, 1.0, 1.0, 0x000000ff, 100);
      clickDelay = tonumber(clickDelay);
      if not clickDelay then
        is_done = false;
        lsPrint(75, y+6, 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
        clickDelay = 100;
      end
	y = y + 40;
      lsPrint(10, y, 0, 0.8, 0.8, 0xffffffff, "Total Ore Found Starting Value:");
	y = y + 22;
      is_done, oreGatheredTotal = lsEditBox("oreGatheredTotal", 10, y, 0, 80, 30, 1.0, 1.0, 0x000000ff, 0);
      oreGatheredTotal = tonumber(oreGatheredTotal);
      if not oreGatheredTotal then
        is_done = false;
        lsPrint(100, y+6, 20, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
        oreGatheredTotal = 0;
      end
	y = y + 40;
      lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "Node Delay: Pause between selecting each node.");
	y = y + 16;
      lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "Raise value to run slower (try increments of 25)");

	y = y + 20;
      lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "Total Ore Starting Value: Useful to keep track of");
	y = y + 16;
      lsPrint(10, y, 0, 0.6, 0.6, 0xffffffff, "ore already in the mine. Set to value of ore in mine");

	y = y + 22;
    if lsButtonText(10, lsScreenY - 30, 0, 70, 0xFFFFFFff, "Next") then
        is_done = 1;
    end

	if cancelButton == 1 then
    if lsButtonText(96, lsScreenY - 30, 0, 80, 0xFFFFFFff, "Cancel") then
	getPoints();
	cancelButton = 0;
    end
	end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, 0, 100, 0xFFFFFFff,
                    "End script") then
      error(quitMessage);
    end
  lsDoFrame();
  lsSleep(50);
  end
  return count;
end
