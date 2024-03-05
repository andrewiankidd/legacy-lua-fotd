if objectiveid=="001" then
	npcscript = {"Hmm...", "Oh, hi there!","You haven't seen my key around have you?"," ","I lost them when I was walking the dog..."," "}
elseif objectiveid=="002" then
	npcscript = {"Let me know if you see my key please...", ""}
elseif objectiveid=="003" then
	npcscript = {"Oh my!", "You actually found it!","Thankyou!!!",""}
	removeitem("bobskey")
else
	npcscript = {"Hey there!", "Thanks for finding that pesky key."}
end