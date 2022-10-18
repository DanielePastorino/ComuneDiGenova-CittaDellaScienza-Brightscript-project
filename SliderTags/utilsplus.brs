'
' Imposta l'indirizzo IP statico per il BrightSign
' Version 1.0.e 02/11/2017 (dani)
'
Library "v30/bslCore.brs"

Sub SetFixedIPAddress(ipAddress, gateway, netmask)

	l_NetworkConfiguration = CreateObject("roNetworkConfiguration", 0)
	l_NetworkConfiguration.SetIP4Address(ipAddress)
	l_NetworkConfiguration.SetIP4Netmask(netmask)
	l_NetworkConfiguration.SetIP4Gateway(gateway)
	l_NetworkConfiguration.Apply()
	
End Sub

'
' Imposta l'indirizzo IP statico per il BrightSign tralasciando il Gateway (per utilizzo su switch)
'
Sub SetFixedIPAddressNoGate(ipAddress, netmask)

	l_NetworkConfiguration = CreateObject("roNetworkConfiguration", 0)
	l_NetworkConfiguration.SetIP4Address(ipAddress)
	l_NetworkConfiguration.SetIP4Netmask(netmask)
	l_NetworkConfiguration.Apply()
	
End Sub

'
' WIFI
'
Sub ConnectWIFIwithDHCP(ap, pass)
	l_NetworkConfiguration = CreateObject("roNetworkConfiguration", 1)
	l_NetworkConfiguration.SetWiFiESSID(ap)
	l_NetworkConfiguration.SetWiFiPassphrase(pass)
	l_NetworkConfiguration.SetDHCP()
	l_NetworkConfiguration.Apply()
End Sub

Sub ConnectWIFIwithoutDHCP(ap, pass, ipAddress, netmask, gateway)
	l_NetworkConfiguration = CreateObject("roNetworkConfiguration", 1)
	l_NetworkConfiguration.SetIP4Address(ipAddress)
	l_NetworkConfiguration.SetIP4Netmask(netmask)
	l_NetworkConfiguration.SetIP4Gateway(gateway)
	l_NetworkConfiguration.SetWiFiESSID(ap)
	l_NetworkConfiguration.SetWiFiPassphrase(pass)
	l_NetworkConfiguration.Apply()
End Sub

'
' Enable DHCP
'
Sub EnableDHCP()
	l_NetworkConfiguration = CreateObject("roNetworkConfiguration", 0)
	l_NetworkConfiguration.SetDHCP()
	l_NetworkConfiguration.Apply()
End Sub

'
' Imposta una luce sulla scheda dimer.( nota: nei parametri non bisogna mettere "as Byte" altrimenti si verifica un errore)
'
Sub SetLight(serialPort as Object, channel, speed, intensity)

	message = CreateObject("roByteArray")
	message[0] = &HFF
	message[1] = channel
	message[2] = speed
	message[3] = intensity
	serialPort.Sendblock(message)

End Sub

Sub TurnOnLight(serialPort as Object, channel)

	SetLight(serialPort, channel, &H00, &HFE)

End Sub

Sub TurnOffLight(serialPort as Object, channel)

	SetLight(serialPort, channel, &H00, &H00)

End Sub

'
' Spegne tutte le luci.
'
Sub TurnOffLights(serialPort as Object)

	SetLight(serialPort, &H00, &H00, &H00)
	SetLight(serialPort, &H01, &H00, &H00)
	SetLight(serialPort, &H02, &H00, &H00)
	SetLight(serialPort, &H03, &H00, &H00)
	SetLight(serialPort, &H04, &H00, &H00)
	SetLight(serialPort, &H05, &H00, &H00)
	SetLight(serialPort, &H06, &H00, &H00)
	SetLight(serialPort, &H07, &H00, &H00)

End Sub

'
' Accende tutte le luci.
'
Sub TurnOnLights(serialPort as Object)

	SetLight(serialPort, &H00, &H00, &Hfe)
	SetLight(serialPort, &H01, &H00, &Hfe)
	SetLight(serialPort, &H02, &H00, &Hfe)
	SetLight(serialPort, &H03, &H00, &Hfe)
	SetLight(serialPort, &H04, &H00, &Hfe)
	SetLight(serialPort, &H05, &H00, &Hfe)
	SetLight(serialPort, &H06, &H00, &Hfe)
	SetLight(serialPort, &H07, &H00, &Hfe)

End Sub

'
' Spegne tutte le luci di un array di canali.
'
Sub TurnOffLightsChannels(serialPort as Object, channelLights as Object)

	for each ch in channelLights
		SetLight(serialPort, ch, &H00, &H00)
	end for

End Sub

'
' Accende tutte le luci di un array di canali.
'
Sub TurnOnLightsChannels(serialPort as Object, channelLights as Object)

	for each ch in channelLights
		SetLight(serialPort, ch, &H00, &Hfe)
	end for

End Sub

'
' Legge il file di configurazione dell'applicazione e restituisce un array associativo delle coppie chiave valore trovate.
'
Function ReadConfig(configPath as String) As Object

	tableConfig = CreateObject("roAssociativeArray")
	xmlFile = ReadAsciiFile(configPath)
	xmlRead = CreateObject("roXMLElement")
	if xmlRead.Parse(xmlFile) then
		dataread = xmlRead.GetName()
		if xmlRead.GetChildElements()<>invalid then
			for each e in xmlRead.GetChildElements()
				tableConfig[e.GetName()] = e.GetText()
			end for
		endif
	endif
	
	return tableConfig

End Function

'
' Legge il file di configurazione JSON e restituisce un oggetto
'
Function ReadConfigJson(configPath as String) As Object
	
	objOutput = invalid
	file = ReadAsciiFile(configPath)
	if file <> invalid then
		objJson = ParseJson(file.trim())
		if objJson <> invalid then
			objOutput = objJson
		else
			print "Errore creazione Json da config"
		end if
	else
		print "Errore lettura file: " + configPath
	end if
	return objOutput
	
End Function

'	
' Apro e faccio il parse del file di sottotitoli (se presente).
'
Function ParseSubtitle(file as String, player as Object) As Object

	subFile = CreateObject("roReadFile", file)
	if not(subFile = invalid) then
		subCounter = 0
		subList = CreateObject("roList")
		regexObj = CreateObject("roRegex", " --> ", "")
		while (not subFile.AtEof())
			line = subFile.ReadLine()			
			lineSplit = regexObj.Split(line)
			if lineSplit.Count() = 2
				timeStart = TimeToMsec(lineSplit[0])
				timeStop = TimeToMsec(lineSplit[1])
				player.AddEvent(subCounter, timeStart)
				subCounter = subCounter + 1
				player.AddEvent(subCounter, timeStop)
				subCounter = subCounter + 1
				' Leggo la linea successiva, che corrisponde al testo
				line = subFile.ReadLine()
				subList.AddTail(line)
			end if
		end while
		return subList
	else
		return invalid
	end if

End Function

' Per decodeLayoutIfNeeded
'Function isShiftedString(s as String) as Boolean
	
'	For Each elem In [")", "!", "@", "#", "$", "%", "^", "&", "*", "(", "_", "ç"]
		
'		if ( Instr(1, s, elem) > 0 ) then 
'			return true
'		end if
		
'	End for
	
'	return false

'End Function

' Per decodeLayoutIfNeeded
Function decodeChar(c as String) as String

	if (c = ")") then return "0"
	if (c = "!") then return "1"
	if (c = "@") then return "2"
	if (c = "#") then return "3"
	if (c = "$") then return "4"
	if (c = "%") then return "5"
	if (c = "^") then return "6"
	if (c = "&") then return "7"
	if (c = "*") then return "8"
	if (c = "(") then return "9"
	if (c = "_") then return "-"
	if (c = "ç") then return ":"
	
	return c

End Function

'
' Decodifica eventuali codici shiftati che arrivano dall' HM-10 BLE
' @return String
'
Function decodeLayoutIfNeeded(s as String) as String

	out = ""
	
	for i = 1 to s.Len()
		ch = Mid(s, i, 1)
		out = out + decodeChar(ch)
	next

	return out

End Function

Function parseIBeaconString(s as String) as Object

	l = CreateObject("roList")
	regexData = CreateObject("roRegex", ":", "")
	obj = {}
	
	bleSplit = regexData.Split(s.trim())

	if (bleSplit.count() > 1) then
		for i = 1 to bleSplit.count()-1
			item = bleSplit[i]
			if (i = 1) then
				obj.factoryid = item
			end if
			if (i = 2) then
				obj.uuid = item
			end if
			if (i = 3) then	
				obj.mmp = item
			end if
			if (i = 4) then
				obj.mac = item
			end if
			if (i = 5) then
				obj.rssi = item
			end if
		next
		
		if ( obj.factoryid <> invalid and obj.uuid <> invalid and obj.mmp <> invalid and obj.mac <> invalid and obj.rssi <> invalid ) then
		
			if (not(isAlreadyPresentIBeacon(l, obj.uuid))) then
				l.AddTail(obj)
			end if
		
		end if
	end if
	
	return l
	
End Function

'
' Controlla se e' gia presente l'elemento (iBeacon)
' @return bool
'
Function isAlreadyPresentIBeacon(list as Object, uuid as String) as Boolean

	res = false
	For Each e In list
		if (e.uuid = uuid) then 
			res = true
		end if
	End For
	
	return res
	
End Function

'
' Parsing del file delle uuid/videos iBeacons
' @return Array
'
Function ParseIBeaconJson(filePath as String) As Object

	out = invalid
	file = ReadAsciiFile(filePath)
	if file <> invalid then
		objJson = ParseJson(file.trim())
		if objJson <> invalid then
			out = objJson
		else
			print "Errore Parsing Json"
		end if
	else
		print "Errore lettura file: " + filePath
	end if
	return out

End Function

'	
' Apro e faccio il parse del file di sottotitoli e Luci (se presente).
'
Function ParseSubtitleAndLights(file as String, player as Object) As Object

	lightsMap = CreateObject("roAssociativeArray")
	lightsMap["LIGHT_0"] = &H00
	lightsMap["LIGHT_1"] = &H01
	lightsMap["LIGHT_2"] = &H02
	lightsMap["LIGHT_3"] = &H03
	lightsMap["LIGHT_4"] = &H04
	lightsMap["LIGHT_5"] = &H05
	lightsMap["LIGHT_6"] = &H06
	lightsMap["LIGHT_7"] = &H07

	subFile = CreateObject("roReadFile", file)
	if not(subFile = invalid) then
		subCounter = 0
		subList = CreateObject("roList")
		lightsList = CreateObject("roList")
		dataList = CreateObject("roList")
		regexObj = CreateObject("roRegex", " --> ", "")
		while (not subFile.AtEof())
			line = subFile.ReadLine()			
			lineSplit = regexObj.Split(line)
			if lineSplit.Count() = 2
				timeStart = TimeToMsec(lineSplit[0])
				timeStop = TimeToMsec(lineSplit[1])
				player.AddEvent(subCounter, timeStart)
				subCounter = subCounter + 1
				player.AddEvent(subCounter, timeStop)
				subCounter = subCounter + 1
				' Leggo la linea successiva, che corrisponde alla luce da accendere
				line = subFile.ReadLine()
				if lightsMap.DoesExist(line) then
					lightsList.AddTail(lightsMap[line])
				else
					lightsList.AddTail(&H00)
				endif
				' Leggo la linea successiva, che corrisponde al testo
				line = subFile.ReadLine()
				subList.AddTail(line)
			end if
		end while
		dataList.AddTail(subList)
		dataList.AddTail(lightsList)
		return dataList
		'return subList
	else
		return invalid
	end if

End Function

' Parse Light file
Function ParseLights(file as String, player as Object) As Object

	lightsFile = CreateObject("roReadFile", file)
	
	if (lightsFile <> invalid) then
		lightCounter = 0
		ledList = CreateObject("roList")
		regexObj = CreateObject("roRegex", "([0-9][0-9]):([0-5][0-9]):([0-5][0-9]),([0-9][0-9][0-9])", "")
		while (not lightsFile.AtEof())
			line = lightsFile.ReadLine()			
			if(regexObj.IsMatch(line)) then
				timeStart = TimeToMsec(line)
				player.AddEvent(lightCounter, timeStart)
				lightCounter = lightCounter + 1
				line = lightsFile.ReadLine()
				ledList.AddTail(line)
			end if
		end while
		return ledList
	else
		return invalid
	end if

End Function

'
' Get Video name from json tags (for RFID/NFC)
' @return String
'
Function GetVideoName(tag as String, objtags as Object) as String 

	if objtags <> invalid then
		For Each item In objtags.tags
			if ( item.tag = tag.trim() ) then
				return item.video
			end if
		End For
	end if
	return ""
	
End Function

Function GetPowFromMMP(m as string) as integer

	return HexToInteger(Mid(m, 9, 2))

End Function

'
' Get Beacon Distance
' @return integer
'
Function GetBeaconDistance(txPower as integer, rssi as double) as double
	
	if ( rssi = 0 ) then
		return -1.0
	end if
	
	ratio = rssi * 1.0 / txPower
	
	if (ratio < 1.0) then
		return ratio ^ 10
	else
		accuracy = 0.89976 *(ratio ^ 7.7095) + 0.111
		return accuracy
	end if

End Function

'
' Get Video object from json by UUID (for BLE)
' @return Object
'
Function GetVideoObjByUUID(arrble as Object, objjson as Object) as Object

	For Each item In arrble
		v = GetVideoObjFromUUID(item.uuid, objjson)
		if ( v <> invalid ) then
			return v
		end if
	End For
	return invalid

End Function

'
' Get Video object by UUID (ausiliaria) for GetVideoObj
' @return Object
'
Function GetVideoObjFromUUID(uuid as String, objjson as Object) as Object 
	if objjson <> invalid then
		For Each item In objjson.data
			if ( LCase(item.uuid) = LCase(uuid.trim()) ) then
				return item
			end if
		End For
	end if
	return invalid
	
End Function

'
' Get Video object from json by MMP (for BLE)
' @return Object
'
Function GetVideoObjByMMP(arrble as Object, objjson as Object) as Object

	For Each item In arrble
		v = GetVideoObjFromMMP(item.uuid, item.mmp, objjson)
		if ( v <> invalid ) then
			v.rssi = item.rssi
			v.mmp = item.mmp
			return v
		end if
	End For
	return invalid

End Function

'
' Get Video object by MMP (ausiliaria) for GetVideoObj
' @return Object
'
Function GetVideoObjFromMMP(uuid as String, mmp as String, objjson as Object) as Object 
	' mmp tipo 00010002BF

	if len(mmp) = 10 then
		maj = HexToInteger(Mid(mmp, 5, 4))
		min = HexToInteger(Mid(mmp, 1, 4))
	else 
		return invalid
	end if
	
	if objjson <> invalid then
		For Each item In objjson.data
			if LCase(item.uuid) = LCase(uuid) and item.major = maj and item.minor = min then
				return item
			end if
		End For
	end if
	return invalid
	
End Function

'
' Get free monitor/display to play video
' @return String
'
Function GetFreeDisplay(vdname as string, slave_states as Object) as String
	
	'il video signal e' già da qualche parte in esecuzione?	
	if (slave_states <> invalid and not(isVideoAlreadyPlayng(vdname, slave_states))) then
		' NO -> cerco un monitor libero...
		' ES: slaveStates = [{ name: "QuadroA", isPlayng: false, videoName: ""}, { name: "QuadroB", isPlayng: false, videoName: ""}, { name: "QuadroC", isPlayng: false, videoName: ""}]
		For Each item in slave_states
			if ( not(item.isPlayng) ) then
				return item.name
			end if
		End For
	else
		' SI è già in esecuzione ... 
		return ""
	end if

	' SE arrivo a questo punto dell'esecuzione del codice significa che non ho trovato nessuno schermo libero (su tutti gira già un video signal)
	' seleziono, in base al timestamp, quello che e' partito per prima
	monitorName = ""
	t = slave_states[0].videoStartTime
	For Each item in slave_states
		if ( t >= item.videoStartTime ) then
			t = item.videoStartTime
			monitorName = item.name
		end if
	End For

	return monitorName
	
End Function

'
' Serve a controllare se un video signal e' gia in esecuzione su qualche monitor
' @return bool
'
Function isVideoAlreadyPlayng(vdname as String, slave_states as Object) as Boolean

	if slave_states <> invalid then
		For Each item in slave_states
			if (item.videoName = vdname) then
				return true
			end if
		End For
	end if

	return false
	
End Function

'
' Parse UDP MSG
' @return array
'
Function ParseUDPMessage(msg as String) as Object
	
	regexObj = CreateObject("roRegex", ";", "")
	strSplit = regexObj.Split(msg)

	return strSplit
		
End Function

'
' Update Stato degli Slaves
' @return Object
'
Function UpdateSlaveStates(states as Object, msgudp as Object) as Object
	
	st = CreateObject("roSystemTime")
	datetime = st.GetLocalDateTime()

	'ES: toMaster;QuadroA;ciao.mp4;stop
	if (msgudp <> invalid) then
		' ES: toMaster;QuadroA;ciao.mp4;stop
		msgMonitor = msgudp[1]
		msgVideoName = msgudp[2]
		msgState =  msgudp[3]
	end if

	' [{ id: 0, name: "QuadroA", isPlayng: false, videoName: "", videoStartTime: 0}, ...]
	For each item in states
		'print "@@@@";type(item.name);item.name
		if (item.name = msgMonitor) then
			if (msgState = "play") then
				item.isPlayng = true
				item.videoName = msgVideoName
				item.videoStartTime = datetime.ToSecondsSinceEpoch()
			else if (msgState = "stop") then
				item.isPlayng = false
				item.videoName = ""
				item.videoStartTime = 0
			end if
		end if
	End For

	return states
	
End Function

'
' Parsing del file delle luci
' @return Array
'
Function ParseLightsFromJson(filePath as String) As Object

	events = invalid
	file = ReadAsciiFile(filePath)
	if file <> invalid then
		objJson = ParseJson(file.trim())
		if objJson <> invalid then
			events = objJson.events
		else
			print "Errore Parsing Json file luci"
		end if
	else
		print "Errore lettura file luci json: " + filePath
	end if
	return events

End Function

'
' Creazione degli eventi videoplayer
'
Sub CreateVideoEvent(events as Object, player as Object)

	For Each e in events
		timeStart = TimeToMsec(e.time)
		' print e.id; "--"; e.time; " ms:"; timeStart
		player.AddEvent(e.id, timeStart)
	End For

End Sub 

'
' Prendo l'array azioni di un evento passato in input come ID (int)
' @return Array
'
Function GetEventActions(events as Object, id as Integer) as Object

	For Each e in events
		if (id = e.id) then
			return e.actions
		end if
	End For
	
	return invalid
	
End Function

'	
' Converte una time string in un tempo in millisecondi.
'
Function TimeToMsec(timeStr as String) As Integer

	hp = 1
	mp = instr(hp, timeStr, ":") + 1
	sp = instr(mp, timeStr, ":") + 1
	fp = instr(sp, timeStr, ",") + 1

	hours = val(mid(timeStr, hp, mp - 1))
	minutes = val(mid(timeStr, mp, 2))
	seconds = val(mid(timeStr, sp, 2))
	frames = val(mid(timeStr, fp, 3))
	
	timeInMs = (((((hours * 60) + minutes) * 60) + seconds) * 1000) + frames
	
	return timeInMs

End Function


' sort in ascending order alphabetically
Sub BubbleSortFileNames(fileNames As Object)

	if type(fileNames) = "roList" then
	
		n = fileNames.Count()

		while n <> 0
			newn = 0
			for i = 1 to (n - 1)
				if fileNames[i-1] > fileNames[i] then
					k = fileNames[i]
					fileNames[i] = fileNames[i-1]
					fileNames[i-1] = k
					newn = i
				endif
			next
			n = newn

		end while

	endif
	
End Sub

'
' Network Configuration 
' in: JSON objet
'
Sub NetConfiguration(objRete)
	' TODO: NOgateway su wifi ..se si può fare
	
	'Ethernet NO DHCP
	if ( objRete.ethernet <> invalid and objRete.ethernet.enable and not(objRete.dhcp) ) then
		' Con gateway o senza
		if (objRete.gate) then
			SetFixedIPAddress(objRete.ethernet.ipaddress, objRete.ethernet.gateway, objRete.ethernet.netmask)
		else
			SetFixedIPAddressNoGate(objRete.ethernet.ipaddress, objRete.ethernet.netmask)
		end if
	' Ethernet DHCP	
	else if (objRete.ethernet <> invalid and objRete.ethernet.enable and objRete.dhcp) then
		EnableDHCP()
	' WIFI NO DHCP
	else if ( objRete.wifi <> invalid and objRete.wifi.enable and not(objRete.dhcp)) then
		ConnectWIFIwithoutDHCP(objRete.wifi.wifiap, objRete.wifi.wifipass, objRete.wifi.ipaddress, objRete.wifi.netmask, objRete.wifi.gateway)
	' WIFI	DHCP
	else if ( objRete.wifi <> invalid and objRete.wifi.enable and objRete.dhcp) then
		ConnectWIFIwithDHCP(objRete.wifi.wifiap, objRete.wifi.wifipass)
	else
		print "ERRORE: Configurazione di rete non corretta"
	end if	

End Sub

' abilito il debug SSH
Sub EnableSSHDebug()

	reg = CreateObject("roRegistrySection", "networking")
	reg.write("ssh", "22")
	n=CreateObject("roNetworkConfiguration", 0)
	n.SetLoginPassword("password")
	n.Apply()
	
End Sub

' disabilito debug SSH
Sub DisableSSHDebug()

	reg = CreateObject("roRegistrySection", "networking")
	reg.delete("ssh")
	
End Sub

' Get un file dalla directory
Function getFileFromFolder(folder as string) as String

	' Creo una lista delle estensioni video supportate
	videoExt = CreateObject("roList")
	videoExt.AddTail(".mp4")
	videoExt.AddTail(".mov")
	videoExt.AddTail(".wmv")

	videoFolder = ListDir(folder.trim())
	if videoFolder = invalid or videoFolder.Count() = 0 then
		print ("Video folder empty or not found.")
		return ""
	end if

	videoSignal = invalid
	For each file in ListDir(folder)
		For each ext in videoExt
			if (Instr(1, LCase(file.GetString()), ext) = (file.Len() - 3)) then
				' Ho trovato un video
				videoSignal = folder + file.GetString()
				exit for
			end if
		end for
		if videoSignal <> invalid then
			exit for
		end if
	end for

	return videoSignal
	
End Function

' Prende tutti i file dalla directory come roList
Function getAllFilesFromFolderAsList(folder as string) as Object

	' Creo una lista delle estensioni video supportate
	videoExt = CreateObject("roList")
	videoExt.AddTail(".mp4")
	videoExt.AddTail(".mov")
	videoExt.AddTail(".wmv")
	videoExt.AddTail(".txt")

	videoFolder = ListDir(folder.trim())
	if videoFolder = invalid or videoFolder.Count() = 0 then
		print ("Video folder empty or not found.")
		return invalid
	end if

	res = CreateObject("roList")
	video = invalid
	For each file in ListDir(folder)
		For each ext in videoExt
			if (Instr(1, LCase(file.GetString()), ext) = (file.Len() - 3)) then
				' Ho trovato un video
				video = folder + file.GetString()
				res.AddTail(video)
				exit for
			end if
		end for
	end for

	return res
	
End Function

' Prende tutti i file dalla directory come roArray
Function getAllFilesFromFolderAsArray(folder as string) as Object
	
	out = CreateObject("roArray", 0, true)
	l = getAllFilesFromFolderAsList(folder)
	BubbleSortFileNames(l)

	if l = invalid or l.Count() = 0 then
		print ("Video folder empty or not found.")
		return invalid
	else
		For each elem in l
			out.Push(elem)
		end for
	end if
	
	return out
	
End Function

' Crea un HTML widget
Function CreateHtmlWidget(url$ as String, fonturl$ as String, msgp as Object, x as Integer, y as Integer, w as Integer, h as Integer) as Object

	rect=CreateObject("roRectangle", x, y, w, h)
	htmlWidget = CreateObject("roHtmlWidget", rect)
	htmlWidget.EnableSecurity(false)
	htmlWidget.SetUrl(url$)
	htmlWidget.EnableJavascript(true)
	htmlWidget.StartInspectorServer(2999)
	htmlWidget.EnableMouseEvents(true)
	htmlWidget.AllowJavaScriptUrls({ all: "*" })
	if (fonturl$ <> "")
		b = htmlWidget.AddFont(fonturl$)
	end if
	if (msgp <> invalid) then
		htmlWidget.setPort(msgp)
	end if
 
	return htmlWidget
	
End Function

'
' Enable local web server
' ABILITARE con EnableLocalWebServer()
'
sub EnableLocalWebServer()

	registrySection = CreateObject("roRegistrySection", "networking")

	' Diagnostic web server
	SetDWS(registrySection)

	print " -> Diagnostic web server setup done"

	' Local web server
	SetLWS(registrySection)

	print " -> Local web server setup done"

end sub

'
' Diagnostic web server
'
sub SetDWS(registrySection as object)

	dwsEnabled$ = "yes"
	dwsPassword$ = ""

	dwsAA = CreateObject("roAssociativeArray")
	if dwsEnabled$ = "yes" then
		dwsAA["port"] = "80"
		dwsAA["password"] = dwsPassword$
	else
		dwsAA["port"] = 0
	endif

	registrySection.Write("dwse", dwsEnabled$)
	registrySection.Write("dwsp", dwsPassword$)

	' Set DWS on device
	nc = CreateObject("roNetworkConfiguration", 0)

	if type(nc) <> "roNetworkConfiguration" then
		nc = CreateObject("roNetworkConfiguration", 1)
	endif

	if type(nc) = "roNetworkConfiguration" then
		rebootRequired = nc.SetupDWS(dwsAA)
	endif

End Sub

'
' Local web server
'
Sub SetLWS(registrySection As Object)

	' Delete obsolete lws keys    
	registrySection.Delete("lws")
	registrySection.Delete("lwsu")
	registrySection.Delete("lwsp")

	lwsConfig$ = "content"
	lwsUserName$ = ""
	lwsPassword$ = ""
	lwsEnableUpdateNotifications$ = "yes"
	
	if lwsEnableUpdateNotifications$ = "" then
		lwsEnableUpdateNotifications$ = "yes"
	end if

    if lwsConfig$ = "content" or lwsConfig$ = "status" then
        registrySection.Write("nlws", Left(lwsConfig$, 1))
        registrySection.Write("nlwsu", lwsUserName$)
        registrySection.Write("nlwsp", lwsPassword$)
		registrySection.Write("nlwseun", lwsEnableUpdateNotifications$)
    else
        registrySection.Delete("nlws")
        registrySection.Delete("nlwsu")
        registrySection.Delete("nlwsp")
		registrySection.Delete("nlwseun")
    end if

end sub
