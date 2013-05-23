------------------------- BSD License  -----------------------
-- Copyright (c) 2013, Creative Tools AB
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

--  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------

ruleStrings = #(#("main","A"),#("A","fr(30)[/+A][-*A]"))
reps = 5
validLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
ruleActions = #(#(#("f",#())))
validActions = #(#("f","Straight Line"),#("[","Start Branch"),#("]","End Branch"),#("b","Bend"),
	#("t","Twist"),#("i","Instance Rule"),#("s","Alter Settings"))
ruleNames = #("main")
	
LFloater = newRolloutFloater "CT L-System" 400 850 
	
struct SettingsStruct
(
	step,
	ang,
	angY,
	twis,
	nSplines = 1,
	obj = undefined,
	pos=[0,0,0],
	spline = 1
)

function updateActionSettings = (
	execute "updateActionSettings_()" 
)

rollout InstanceRollout "Instance Settings"
(
	dropdownlist instanceRule "Rule" items:#("")
	on InstanceRollout open do(
		a = #()
		for entry in ruleNames do(
			if entry != "main" then(
				append a entry
			)
		)
		instanceRule.items = a
	)
	on instanceRule selected sel do updateActionSettings()
)

rollout BendRollout "Bend Settings"
(
	radiobuttons bendDirection "Direction" labels:#("+","-") across:2
	radiobuttons bendAxis "Axis" labels:#("X","Y")
	on bendDirection changed val do updateActionSettings()
	on bendAxis changed val do updateActionSettings()
)

rollout TwistRollout "Twist Settings"
(
	radiobuttons twistDirection "Direction" labels:#("+","-") across:2
	on twistDirection changed val do updateActionSettings()
)

rollout MultiplySettingsRollout "Multiply Settings"
(
	dropdownlist type "Type"  items:#("Multiply","Add","Set")
	spinner stepSize "Segment Size" range:[-300, 300, 1]
	spinner angleIncrement "Angle Increment" range:[-300, 300, 1]
	spinner twistIncrement "Twist Increment" range:[-300, 300, 1]
	on type selected val do updateActionSettings()
	on stepSize buttonup val do updateActionSettings()
	on stepSize entered val bal do updateActionSettings()
	on angleIncrement buttonup val  do updateActionSettings()
	on angleIncrement entered val bal do updateActionSettings()
	on twistIncrement buttonup val do updateActionSettings()
	on twistIncrement entered val bal do updateActionSettings()
)

rollout BranchRollout "Branch Settings"
(
	spinner prob "Probability" type:#float range:[0.0, 100.0, 100.0]
	checkbox separate "Separate Object"
	on prob buttonup val do updateActionSettings()
	on prob entered val bal do updateActionSettings()
	on separate changed val do updateActionSettings()
)
	
rollout RuleRollout "Rules"
(
	combobox rules "Rules" items:#("main")
	button newRule "Add Rule"
	button deleteRule "Delete Rule"
	listbox actions "Actions"
	button newAction "Add Action"
	button deleteAction "Delete Action"
	dropdownlist actionType "Action Type" 
	function updateActions = (
		a = #()
		for action in ruleActions[rules.selection] do (
			nam = ""
			for v in validActions do (
				if v[1] == action[1] then (
					nam = v[2]
				)
			)
			if action[1] == "i" then (
				if action[2][1] != undefined then
					nam += " " + action[2][1]
			)
			append a nam
		)
		actions.items = a
		actionType.enabled = a.count > 0
		removeRollout InstanceRollout LFloater
		removeRollout BendRollout LFloater
		removeRollout TwistRollout LFloater
		removeRollout MultiplySettingsRollout LFloater
		removeRollout BranchRollout LFloater
		if(actions.selection > 0) then (
			action = ruleActions[rules.selection][actions.selection]
			nam = action[1]
			setting_ = action[2]
			if(nam == "i") then (
				addRollout InstanceRollout LFloater
			)
			if(nam == "b") then (
				addRollout BendRollout LFloater
				BendRollout.bendDirection.state = setting_[1]
				BendRollout.bendAxis.state = setting_[2]
			)
			if(nam == "t") then (
				addRollout TwistRollout LFloater
				TwistRollout.twistDirection.state = setting_[1]
			)
			if(nam == "s") then (
				addRollout MultiplySettingsRollout LFloater
 				MultiplySettingsRollout.type.selection = setting_[1]
				MultiplySettingsRollout.stepSize.value = setting_[2]
				MultiplySettingsRollout.angleIncrement.value = setting_[3]
				MultiplySettingsRollout.twistIncrement.value = setting_[4]
			)
			if(nam == "[") then (
				addRollout BranchRollout LFloater
				BranchRollout.prob.value = setting_[1]
				BranchRollout.separate.checked = setting_[2]
			)
		)
	)
	on RuleRollout open do(
		a = #()
		for action in validActions do (
			append a action[2]
		)
		actionType.items = a
		updateActions()
	)
	on newRule pressed do (
		letters = 
		i = 0
		found = false
		while not found and i < validLetters.count do(
			i += 1
			found = true
			for item in rules.items do(
				if validLetters[i] == item then(
					found = false
				)
			)
		)
		a = rules.items
		append a validLetters[i]
		ruleNames = deepcopy  a
		rules.items = a
		rules.selection = a.count
		append ruleActions #()
		updateActions()
	)
	on deleteRule pressed do(
		a = rules.items
		s = rules.selection
		if s>0 then(
			deleteItem ruleActions s
			rules.items = a
			deleteItem a s
			ruleNames = deepcopy  a
			rules.items = a
			rules.selection  = a.count
			if s < rules.selection then(
				rules.selection = s
			)
		)
	)
	on rules changed val do (
		if rules.selection > 1 and val.count > 0 then (
			letter = (toUpper val)[1]
			pattern = "*" + letter + "*"
			if matchPattern validLetters pattern:pattern ignoreCase:false then(
				rules.selected = letter
				ruleNames = deepcopy rules.items
			)
		)
	)
	on rules selected sel do (
		updateActions()
	)
	on actions selected sel do(
		updateActions()
	)
	on newAction pressed do (
		entry = #("f",#())
		a = actions.items
		insertItem entry ruleActions[rules.selection] (actions.selection+1)
		updateActions()
		updateActionSettings()
	)
	on deleteAction pressed do (
		a = actions.items
		s = actions.selection
		if s>0 then(
			deleteItem ruleActions[rules.selection] s
			updateActions()
		)
	)
	on actionType selected sel do (
		if(actions.selection > 0 and rules.selection > 0) then (
			local action = validActions[sel]
			local setting_ = #()
			local string_ = action[1]
			if string_ == "i" then(
				setting_ = #("")
			)
			if string_ == "b"then(
				setting_ = #(1,1)
			)
			if string_ == "t"then(
				setting_ = #(1)
			)
			if string_ == "s"then(
				setting_ = #(1,1,1,1)
			)
			if string_ == "["then(
				setting_ = #(100, false)
			)
			ruleActions[rules.selection][actions.selection] = #(string_,setting_)
			updateActions()
			updateActionSettings()
		)
	)
)

rollout LSystemSettingsRollout "Settings"
(
	checkbox autoUpdateAllowed "Auto Generate" checked:true
	spinner stepSize "Segment Size" range:[0.0, 1000.0, 100.0]
	spinner angleIncrement "Angle Increment" range:[-180, 180, 10]
	spinner twistIncrement "Twist Increment" range:[-180, 180, 10]
	spinner generations "Generations" type:#integer  range:[1, 50, 3]
	Spinner randomSeed "Random Seed" range:[1, 10000, 1587] type:#integer
	
	function autoupdate =(
		if autoUpdateAllowed.checked then (
			execute "LSystemGenerateRollout.update()"
		)
	)
	
	on stepSize changed val do autoupdate()
	on angleIncrement changed val do autoupdate()
	on twistIncrement changed val do autoupdate()
	on generations changed val do autoupdate()
	on randomSeed changed val do autoupdate()
)

rollout LSystemGenerateRollout "Generate"
(
	button generate "Generate"
	
	function readArgs s i= (
		len = 0
		s = subString s (i+1) -1
		a = filterString  s "()" 
		if a.count >= 1 then(
			len = a[1].count
		)
		a = filterString a[1] ","
		for j=1 to a.count do(
			tmp = a[j] as number
			if tmp == undefined then (
				tmp = a[j] as booleanClass
			)
			a[j] = tmp
		)
		return #(a, len)
	)

	function getStep settings = (
		newStep = [0,0,0]
		len = settings.step * sin(settings.ang)
		newStep[3] = settings.step * cos(settings.ang) * cos(settings.angY)
		lenX = settings.step * sin(settings.ang)
		lenY = settings.step * sin(settings.angY)
		newStep[2] = lenY * cos(settings.twis) + lenX * sin(settings.twis)
		newStep[1] = lenX * cos(settings.twis) - lenY * sin(settings.twis)
		return newStep
	)

	function drawString s settings deltaSettings = (
		delete $LSystem*
		delete $LSystemBranch*
		settings.obj = line()
		settings.obj.name = "LSystem"
		addNewSpline settings.obj
		addKnot settings.obj 1 #smooth #curve settings.pos
		seed LSystemSettingsRollout.randomSeed.value
		stateList = #(settings)
		settingList = #(deltaSettings)
		settings.nSplines = 1
		local skip = 0
		i = 1
		while i <= s.count do(
			state = stateList[stateList.count]
			settings = settingList[settingList.count]
			c = s[i]
			if skip == 0 then(
				if c == "f" then(
					state.pos += getStep state
					addKnot state.obj state.spline #corner #line state.pos
				)
				if c == "b" then(
					args = readArgs s i
					i += args[2]
					args = args[1]
					if args[2] == 1 then (
						if args[1] == 1 then
							state.ang += settings.ang
						else
							state.ang -= settings.ang
					)
					else (
						if args[1] == 1 then
							state.angY+= settings.ang
						else
							state.angY -= settings.ang
					)
				)
				if c == "t" then(
					args = readArgs s i
					if args[1] == 1 then
						state.twis += settings.twis
					else
						state.twis -= settings.twis
				)
				if c == "[" then(
					args = readArgs s i
					i += args[2]
					args = args[1]
					p = (random 0 99.99)
					if p < args[1] then (
						append stateList (copy state)
						append settingList (copy settings)
						state = stateList[stateList.count]
						if args[2] then (
							state.obj = line()
							state.obj.name = "LSystemBranch"
							state.nSplines = 0
						)
						addNewSpline state.obj
						state.nSplines = numSplines state.obj
						state.spline = state.nSplines
						addKnot state.obj state.spline #corner #line state.pos
					)
					else(
						skip += 1
					)
				)
				if c == "]" then(
					if stateList.count > 1 then(
						deleteItem stateList stateList.count
						deleteItem settingList settingList.count
					)
				)
				if c == "s" then(
					args = readArgs s i
					i += args[2]
					args = args[1]
					if args[1] == 1 then (
						state.step *= args[2]
						settings.ang  *= args[3]
						settings.twis *= args[4]
					)
					if args[1] == 2 then (
						state.step += args[2]
						settings.ang  += args[3]
						settings.twis += args[4]

					)
					if args[1] == 3 then (
						state.step = args[2]
						settings.ang  = args[3]
						settings.twis = args[4]
					)
				)
			)
			else(
				if c == "]" then(
					skip -= 1
				)
			)
			i += 1
		)
	)

	function composeString strings reps= (
		s = strings[1][2]
		for i=1 to reps do(
			for entry in strings do(
				s = substituteString s entry[1] entry[2]
			)
		)
		return s
	)
	
	function doGenerate = (
		rStrings = #()
		local i =1
		for rule in ruleActions do(
			ruleString = ""
			for entry in rule do(
				ruleString += entry[1]
				if entry[2].count > 0 then (
					ruleString += "("
					for s in entry[2] do(
						ruleString += (s as string) + ","
					)
					ruleString += ")"
				)
			)
			append rStrings #(RuleRollout.rules.items[i], ruleString)
			i+=1
		)
		lString = composeString rStrings LSystemSettingsRollout.generations.value
		local step = LSystemSettingsRollout.stepSize.value
		local ang = LSystemSettingsRollout.angleIncrement.value 
		local twist_ = LSystemSettingsRollout.twistIncrement.value 
		local deltaSettings = SettingsStruct step:100 ang:ang angY:ang twis:twist_
		local settings = SettingsStruct step:step ang:0.0 angY:0.0 twis:0.0
		drawString lString settings deltaSettings
	)
	
	function update = (
		doGenerate()
	)
	
	on generate pressed do (
		doGenerate()
	)
)

function updateActionSettings_ = (
	if RuleRollout.rules.selection > 0 and RuleRollout.actions.selection > 0 then (
		action = ruleActions[RuleRollout.rules.selection][RuleRollout.actions.selection]
		nam = action[1]
		if nam== "i" then (
			action[2] = #(InstanceRollout.instanceRule.selected)
		)
		if nam == "b" then (
			action[2] = #(BendRollout.bendDirection.state,BendRollout.bendAxis.state)
		)
		if nam == "t" then (
			action[2] = #(TwistRollout.twistDirection.state)
		)
		if nam == "s" then (
			action[2] = #(MultiplySettingsRollout.type.selection ,MultiplySettingsRollout.stepSize.value, MultiplySettingsRollout.angleIncrement.value, MultiplySettingsRollout.twistIncrement.value)
		)
		if nam == "[" then (
			action[2] = #(BranchRollout.prob.value, BranchRollout.separate.checked)
		)
		RuleRollout.updateActions()
		LSystemSettingsRollout.autoupdate()
	)
)

addRollout LSystemGenerateRollout LFloater
addRollout LSystemSettingsRollout LFloater
addRollout RuleRollout LFloater