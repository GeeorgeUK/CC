-- Pre Boot Processes

local boot = os.startTimer(2)

while true do

  term.setTextColor(colours.white)
  term.setBackgroundColor(colours.black)
  term.clear()
  
  local event, a, b, c, d, e = os.pullEvent()
  if event == "timer" then
    break
  end
  
  if event == "key" then
    if a == keys.leftAlt then
      bootmenu = true
    end
  end
  
  if event == "key_up" then
    if a == keys.leftAlt then
      bootmenu = false
    end
  end
  
end

-- Define Variables

global = {}
global.nickname = "Lily"
global.version = "GeeorgeOS_v1.00-5.28"
global.input = {}
global.output = {}
global.alerts = {}

term.setTC = term.setTextColor
term.setBC = term.setBackgroundColor
term.setCP = term.setCursorPos
term.getCP = term.getCursorPos

co = colours
xz, yz = term.getSize()
os.setComputerLabel(global.version)

function term.printLine(text, align)

  if not align then align = "centre" end
  if align == "center" then align = "centre" end
  local xp, yp = term.getCP()
  term.clearLine()
  
  if align == "left" then
    
    term.setCP(1,yp)
    print(text)
    
  elseif align == "centre" then
  
    term.setCP((xz/2)-(#text/2), yp)
    print(text)
    
  elseif align == "right" then
  
    term.setCP(xz-#text, yp)
    print(text)
    
  end
end

function term.printTitle(heading, subheading, colour, subheadingcolour)
  
  term.setCP(1,1)
  term.setTC(colours.black)
  term.setBC(tonumber(colour) or co.yellow)
  term.clearLine()
  
  term.setCP(1,2)
  term.printLine(heading)
  
  term.setCP(1,3)
  term.clearLine()
  
  term.setCP(1,4)
  term.setTC(subheadingcolour or co.black)
  term.printLine(subheading)
  
  term.setCP(1,5)
  term.clearLine()
  
end

while bootmenu do
  
  term.printTitle("Boot Menu", "Press boot number to load")
  
  term.setCP(1,7)
  term.setTC(co.lightGrey)
  term.setBC(co.black)
  term.printLine(" '1' | "..global.version.." '"..global.nickname.."'")
  
  term.setCP(1,9)
  if fs.exists("disk/startup") then
    term.printLine(" '2' | Secondary Program: /disk/startup")
  end
  
  term.setCP(1,11)
  if http and recovery then
    term.printLine(" '3' | Remote Recovery Program")
  end
  
  term.printLine(" '0' | Shut Down" )
  local event, char = os.pullEvent("char")
  
  if event == "char" then
    if char == "1" then
      term.clear()
      term.setCP(1,1)
      bootmenu = false
      break
    elseif char == "2" and fs.exists("disk/startup") then
      
      term.clear()
      term.setCP(1,1)
      shell.run("disk/startup")
      os.shutdown()
    
    elseif char == "3" and http and recovery then
      -- Not implemented
    elseif char == "0" then
      os.shutdown()
    end
    
  end
end

function display(view, args)

  term.printTitle(global.version, "Type \"help\" for a command reference")
  term.setCP(1,yz)
  term.setBC(colours.black)
  term.setTC(colours.grey)
  term.clearLine()
  
  if tonumber(view) == 0 then
    term.setTC(colours.yellow)
    term.setCursorBlink(true)
    write("> ")
    term.setTC(colours.lightGrey)
    write(table.concat(global.input))
  elseif tonumber(view) == 1 and args then
    term.setCursorBlink(false)
    os.startTimer(args.timeout or 5)
    write(args.message or "Dummy Notification")
  end
  
end

if fs.exists(".auth") == false then

  global.auth = false

else
  
  global.auth = true
  shell.run(".auth")

end

tmp1 = 0
tmp2 = {}

-- Final Bit

while true do
  
  display(tmp1, tmp2)
  timeout = os.startTimer(300)
  
  local event, a, b, c, d, e = os.pullEvent()
  if event == "char" then
    
    global.input[#global.input+1] = a
  
  elseif event == "alert" then
    
    tmp1 = a
    tmp2 = {message=b, timeout=c}
    alert_off = os.startTimer(5)
    
  elseif event == "timer" then
    
    if a == alert_off then
      tmp1 = 0
      tmp2 = {}
    elseif a == timeout then
      os.shutdown()
    end
    
  elseif event == "key" then
  
    if a == keys.backspace then
      global.input[#global.input] = nil
    elseif a == keys.enter then
      
      term.clearLine()
      term.setCursorBlink(false)
      term.setCP(1, yz)
      
      local command = table.concat(global.input)
      if command == "exit" then
        os.queueEvent("terminate")
      elseif command == "reload" then
        os.reboot()
      elseif command == "help" then
        
        term.setTextColour(colours.yellow)
        print("Command Reference")
        term.setTextColour(colours.lightGrey)
        print("'help' | Show a command reference")
        print("'exit' | Exit to the terminal")
        print("'programs' | Show a list of programs")
        print("'reload' | Restart the terminal wrapper")
        print("Enter a command to run it")
      
      else
        shell.run( command )
      end
      
      global.input = {}
    end
    
  elseif event == "terminate" then
    
    if global.auth then
      shell.run("auth terminate")
    end
    global.input = {}
    global.output = {}
    
    term.clear()
    term.setCP(1,1)
    term.setTextColor(16384)
    term.setBackgroundColor(32768)
    print("Terminated")
    term.setTextColor(1)
    
  end
  
end
