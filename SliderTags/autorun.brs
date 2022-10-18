Library "utilsplus.brs"

' Region Main
Sub Main()

	' Lettura file di configurazione
	objConfig =  ReadConfigJson("config\config.json")
	
	' Abilito la funzionalità delle zone.
	' Quando le zone sono abilitate l'image layer sta sempre davanti al video layer.
	' Quando invece le zone non sono abilitate l'image layer non è visibile se c'è un video in riproduzione, e viceversa.
	EnableZoneSupport(true)
	
	' la messagePort in ascolto sugli eventi
	messagePort = CreateObject("roMessagePort")

	' =========== VIDEO CONFIG =========== 
	' Risoluzione dello schermo ("1920x1080x60p", "1024x768x60p", "1280x800x60p", "1360x768x60")
	screenMode = objConfig.video.screenmode
	videoMode = CreateObject("roVideoMode")
	' Imposto la modalità video e recupero le info
	videoMode.SetMode(screenMode)

	' =========== AUDIO CONFIG ===========
	' Audio output
	if (objConfig.audio.hdmi)
		audioOutput = CreateObject("roAudioOutput", "HDMI")
	else
		audioOutput = CreateObject("roAudioOutput", "analog")
	end if
	
	' =========== RETE CONFIG ===========
	NetConfiguration(objConfig.rete)
	
	' Abilito/disabilito SSH per debug
	if (objConfig.rete.ethernet.enable and objConfig.debug.ssh)
		EnableSSHDebug()
	else
		DisableSSHDebug()
	end if
	
	' =========== WEB SERVER ===========
	if (objConfig.rete.ethernet.enable) then
		EnableLocalWebServer()
	end if
	
	' =========== KEYBOARD ===========
	keyboard = CreateObject("roKeyboard")
	keyboard.SetPort(messagePort)
	
	' =========== VIDEOS ===========
	videoPlayer = CreateObject("roVideoPlayer")
	' rect = CreateObject("roRectangle", 0, 0, 1920, 1080)
	' videoPlayer.SetRectangle(rect)
	videoPlayer.SetPort(messagePort)
	videoPlayer.SetPcmAudioOutputs(audioOutput)
	videoPlayer.SetViewMode(0) '0 = stretch, 1 = no stretch
	videoPlayer.SetTransform(objConfig.video.rotation)
	videoPlayer.SetLoopMode(true) ' voglio che tutti i video vadano in loop
	
	' =========== OTHER CONFIG ===========
	mediaObj = CreateObject("roAssociativeArray")
	videoLoop = objConfig.media.loop
		
	For each elem in objConfig.tags
		mediaObj[elem.tag] = {path: elem.media}
	end for

	rfid = ""

'****************************
'* 			MAIN			*
'****************************
'* Questa variante del progetto funzionale SOLO con i video
'* NON c'è un video loop tra un TAG e l'altro!
'* si puo' ovviamente passare da un tag video ad un altro x cambiare video
'* il video va in loop finchè non vado su un altro tag

_MainLoop:

	' un video loop lo metto perchè mi serve per l'accensione
	' ma non passo più dal _Mainloop
	playing = "**loop**"
	videoPlayer.PlayFile(videoLoop)

_MsgLoop:

	msgReceived = wait(objConfig.waitingtime, messagePort)

	if type(msgReceived) = "roKeyboardPress" then
		
		keyPressed = chr(msgReceived.GetInt())

		if(msgReceived.GetInt() = 13)
			rfid = rfid.trim()
			print rfid

			mo = mediaObj[rfid]

			if mo <> invalid then
				if playing <> mo.path then
					playing = mo.path
					print "-->play video: ";mo.path
					videoPlayer.PlayFile(mo.path)
				end if
			end if

			' Resetto la stringa
			rfid = ""
		else
		
			rfid = rfid + keyPressed
						
		end if
	
	end if

	' if type(msgReceived) = "roVideoEvent" then

	' 	' Evento fine video
	' 	if msgReceived.GetInt() = 8 then
			
	' 		print "--FINE VIDEO: [";playing;"]"

	' 		goto _MainLoop

	' 	end if

	' end if

	' if (msgReceived = invalid) then
	
	' 	print "* [";playing;"]"
		
	' end if
		

	goto _MsgLoop

End Sub
