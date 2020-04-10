#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=resources\app-ico-firewall.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Description=Interface para cotrolar el Firewall de Windows
#AutoIt3Wrapper_Res_LegalCopyright=Creado por @as_informatico para el evento C0r0n4con.com
#AutoIt3Wrapper_Res_Language=1034
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs
==============================================================================================
	Evento:					C0r0n4con.com
	Proyecto:				Demo para taller "Iniciación a la programación con Autoit"
	Contenido:				Ejemplo de GUI para controlar el Firewall de Windows.
	Autor:					Jesús Pacheco - @as_informatico
	Fecha de creación:		07/04/2020
	Última modificación:	08/04/2020
	Notas adicionales:		No olvideis hacer vuestra donación a Cruz Roja.
==============================================================================================
#ce
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>
#include <GUIListView.au3>
#include <Array.au3>
#include <File.au3>
#include <reglas.au3>
Global $status
Global $Ruta_Datos = @ScriptDir & "\datafiles\reglas.dat"
_Leer_Estado()

#Region Ventana Principal
$FormPrincipal = GUICreate("Windows Firewall - C0r0n4con.com ", 478, 680, 1200, 124)
GUISetIcon(@ScriptDir & "\resources\app-ico-firewall.ico", -1)

$btn_estatus = GUICtrlCreateButton("", 0, 0, 475, 73)
$btn_on_off = GUICtrlCreateButton("Desactivar Firewall", 24, 88, 427, 89)
$btn_reset = GUICtrlCreateButton("Cargar Valores por defecto", 24, 200, 163, 81)
$btn_ping = GUICtrlCreateButton("Responder a PING", 288, 200, 163, 81)
$btn_crear_regla = GUICtrlCreateButton("Añadir Nueva Regla", 24, 304, 163, 81, $BS_ICON)
GUICtrlSetImage(-1, @ScriptDir & "\resources\add.ico", 2)
$btn_eliminar_regla = GUICtrlCreateButton("Eliminar Regla", 288, 304, 163, 81, $BS_ICON)
GUICtrlSetImage(-1, @ScriptDir & "\resources\delete.ico", 2)

$Label_reglas = GUICtrlCreateLabel("Reglas Creadas", 32, 400, 75, 17)

$Listado_reglas = GUICtrlCreateListView("Descripción|Dirección|Acción|Protocolo|Puerto Local|Puerto Remoto|Programa", 24, 424, 433, 185)
$Logo = GUICtrlCreatePic(@ScriptDir & "\resources\logo.jpg", 136, 616, 200, 40)
$barra_de_estado = _GUICtrlStatusBar_Create($FormPrincipal)

If $status == 0 Then
	GUICtrlSetBkColor($btn_estatus, 0xFF0000)
	GUICtrlSetData($btn_estatus, "Firewall Desactivado")
	GUICtrlSetData($btn_on_off, "Activar Firewall")
	TraySetIcon(@ScriptDir & "\resources\off.ico")
ElseIf $status == 1 Then
	GUICtrlSetBkColor($btn_estatus, 0x00FF00)
	GUICtrlSetData($btn_estatus, "Firewall Activado")
	GUICtrlSetData($btn_on_off, "Desactivar Firewall")
	TraySetIcon(@ScriptDir & "\resources\on.ico")
Else
	GUICtrlSetBkColor($btn_estatus, 0xFFFF00)
	GUICtrlSetData($btn_estatus, "No ha sido posible comprobar el estado del Firewall")
	GUICtrlSetData($btn_on_off, "Activar/Desactivar Firewall")
	GUICtrlSetState($btn_on_off, 128)
	TraySetIcon(@ScriptDir & "\resources\error.ico")
EndIf

GUISetState(@SW_SHOW, $FormPrincipal)
#EndRegion

_Cargar_Reglas()

#Region Acciones
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_SECONDARYDOWN
			MsgBox(64,"NECESITAMOS TU AYUDA!!!", "No olvides hacer tu donación a Cruz Roja, no hay importe mínimo")
		; elementos de la ventana "principal" >>>>>>>>>>>>>>>>>>>>>
		Case $btn_on_off
			_on_off($status)
		Case $btn_reset
			_valores_defecto()
		Case $btn_ping
			_responder_PING()
		Case $btn_crear_regla
			_nueva_regla(0)
		Case $btn_eliminar_regla
			_eliminar_regla()
		; elementos de la ventana "nueva regla" >>>>>>>>>>>>>>>>>
		Case $btn_Crear_Nueva_Regla
			If GUICtrlRead($InputPrograma) == "" Then
				_nueva_regla(1)
			Else
				_nueva_regla(2)
			EndIf
		Case $btn_Cancelar_Nueva_Regla
			_limpiar_creacion_regla()
		Case $RadioPuerto
			GUICtrlSetState($InputPuertoL, $GUI_SHOW)
			GUICtrlSetState($InputPuertoR, $GUI_SHOW)
			GUICtrlSetState($LabelPuertoL, $GUI_SHOW)
			GUICtrlSetState($LabelPuertoR, $GUI_SHOW)
			GUICtrlSetState($LabelPrograma, $GUI_HIDE)
			GUICtrlSetState($InputPrograma, $GUI_HIDE)
			GUICtrlSetState($btn_Programa, $GUI_HIDE)
			GUICtrlSetData($InputPrograma, "")
		Case $RadioPrograma
			GUICtrlSetState($InputPuertoL, $GUI_HIDE)
			GUICtrlSetState($InputPuertoR, $GUI_HIDE)
			GUICtrlSetState($LabelPuertoL, $GUI_HIDE)
			GUICtrlSetState($LabelPuertoR, $GUI_HIDE)
			GUICtrlSetState($LabelPrograma, $GUI_SHOW)
			GUICtrlSetState($InputPrograma, $GUI_SHOW)
			GUICtrlSetState($btn_Programa, $GUI_SHOW)
		Case $btn_Programa
			_seleccionar_programa()
	EndSwitch
WEnd
#EndRegion

#Region Declaración de Funciones

; DESCRIPCIÓN: Leer el estado del Firewall
;================================================================================================
Func _Leer_Estado()
	$status = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile", "EnableFirewall") ; 0 = Desactivado  1 = Activado
EndFunc

; DESCRIPCIÓN: Cargar datos de reglas creadas en el ListView.
;================================================================================================
Func _Cargar_Reglas()
	_GUICtrlListView_DeleteAllItems($Listado_reglas)
	If FileExists($Ruta_Datos) Then
		$aArray = ""
		_FileReadToArray($Ruta_Datos, $aArray, 0, "|")
		;_ArrayDisplay($aArray, "DEPURACIÓN", Default, 8)
		_GUICtrlListView_AddArray($Listado_reglas, $aArray)
	EndIf
EndFunc

; DESCRIPCIÓN: Activar o desactivar el Firewall del sistema. Recibe como parámetro el estado actual del mismo.
;================================================================================================
Func _on_off($status)
	$comando = ""
	If $status == 0 Then
		$comando = 'netsh advfirewall set allprofiles state on'
		GUICtrlSetBkColor($btn_estatus, 0x00FF00)
		GUICtrlSetData($btn_estatus,"Firewall Activado")
		GUICtrlSetData($btn_on_off, "Desactivar Firewall")
		TraySetIcon(@ScriptDir & "\resources\on.ico")
	ElseIf $status == 1 Then
		$accion = MsgBox(52, "ATENCIÓN", "Va a desactivar la protección Firewall del equipo." & @CRLF & "¿Está usted seguro?") ; si = 6 no = 7
		If $accion == 6 Then
			$comando = 'netsh advfirewall set allprofiles state off'
			GUICtrlSetBkColor($btn_estatus, 0xFF0000)
			GUICtrlSetData($btn_estatus,"Firewall Desactivado")
			GUICtrlSetData($btn_on_off, "Activar Firewall")
			TraySetIcon(@ScriptDir & "\resources\off.ico")
		EndIf
	EndIf
	RunWait(@ComSpec & " /c " & $comando, "", @SW_HIDE)
	_Leer_Estado()
EndFunc

; DESCRIPCIÓN: Elimina todas las reglas y configuraciones creadas y carga los valores por defecto del fabricante.
;================================================================================================
Func _valores_defecto()
	$accion = MsgBox(52, "VALORES POR DEFECTO", "¿Desea eliminar su configuración y cargar los valores por defecto?" & @CRLF & "ATECIÓN: Esta acción es irreversible") ; si = 6 no = 7
	If $accion == 6 Then
		$comando = 'netsh advfirewall reset'
		RunWait(@ComSpec & " /c " & $comando, "", @SW_HIDE)
		_GUICtrlListView_DeleteAllItems($Listado_reglas)
		FileDelete("datafiles\reglas.dat")
		MsgBox(64,"VALORES POR DEFECTO", "Se ha restablecido la configuración a valores de fábrica")
	EndIf
EndFunc

; DESCRIPCIÓN: Elegir si responder o no cuando nuestra máquina reciba un PING.
;================================================================================================
Func _responder_PING()
	$accion = MsgBox(36, "Respuesta a PING", "¿Responder a PING?") ; si = 6 no = 7
	If $accion == 7 Then
		$comando = 'netsh advfirewall firewall add rule name="All ICMP V4" dir=in action=block protocol=icmpv4'
		$aviso = "El equipo no responderá cuando reciba una petición PING"
	ElseIf $accion == 6 Then
		$comando = 'netsh advfirewall firewall add rule name="All ICMP V4" dir=in action=allow protocol=icmpv4'
		$aviso = "El equipo responderá cuando reciba una petición PING"
	EndIf
	RunWait(@ComSpec & " /c " & $comando, "", @SW_HIDE)
	MsgBox(64,"Acción Seleccionada", $aviso)
EndFunc

; DESCRIPCIÓN: Leer del sistema todas las reglas activas y exportarlas a un archivo de texto.
;================================================================================================
Func _reglas_activas()
$comando = 'regedit /e ' & @ScriptDir & '\reglas.list "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"'
RunWait(@ComSpec & " /c " & $comando, "", @SW_HIDE)
EndFunc

; DESCRIPCIÓN: Crear una nueva regla en el Firewall.
;================================================================================================
Func _nueva_regla($subaccion)
	$name = GUICtrlRead($InputDescripcion)
	$dir = GUICtrlRead($ComboDireccion)
	$action = GUICtrlRead($ComboAccion)
	$protocol = GUICtrlRead($ComboProtocolo)
	$localport = GUICtrlRead($InputPuertoL)
	$remoteport = GUICtrlRead($InputPuertoR)
	$program = GUICtrlRead($InputPrograma)
	Switch $subaccion
		Case 0 ; Abrimos la ventana de Nueva Regla.
			GUISetState(@SW_SHOW, $FormNuevaRegla)
		Case 1 ; Añadimos regla de puertos
			$comando = 'netsh advfirewall firewall add rule name="'&$name&'" dir='&$dir&' action='&$action&' protocol='&$protocol&' localport='&$localport&' remoteport='&$remoteport
		Case 2 ; Añadimos regla de programa
			$comando = 'netsh advfirewall firewall add rule name='&$name&'" dir='&$dir&' action='&$action&' program="'&$program&'" enable=yes'
		Case Else
			Exit
	EndSwitch
	If $subaccion > 0 And $name <> "" Then
		RunWait(@ComSpec & " /c " & $comando, "", @SW_HIDE)
		FileOpen($Ruta_Datos, 1)
		FileWrite($Ruta_Datos, $name&'|'&$dir&'|'&$action&'|'&$protocol&'|'&$localport&'|'&$remoteport&'|'&$program & @CRLF)
		FileClose($Ruta_Datos)
		_Cargar_Reglas()
		_limpiar_creacion_regla()
	ElseIf $subaccion > 0 And $name == "" Then
		MsgBox(64,"Nueva Regla", "Por favor, rellene el campo Descripción.")
	EndIf
EndFunc

; DESCRIPCIÓN: Eliminar una regla creada en el Firewall.
;================================================================================================
Func _eliminar_regla()
	If  _GUICtrlListView_GetSelectedCount($Listado_reglas) > 0 Then
		$accion = MsgBox(36, "Eliminar Regla", "¿Está seguro que desea eliminar la regla seleccionada?") ; si = 6 no = 7
		If $accion == 6 Then
			$aValor = _GUICtrlListView_GetSelectedIndices($Listado_reglas, True)
			$aItem = _GUICtrlListView_GetItemTextArray($Listado_reglas, $avalor[1])
			;_ArrayDisplay($aItem, "DEPURACIÓN", Default, 8)
			$sname = $aItem[1]
			$sprotocol = $aItem[4]
			$slocalport = $aItem[5]
			$sprogram = $aItem[7]
			If $slocalport > 0 Then
				$comando = 'netsh advfirewall firewall delete rule name=' & $sname & ' protocol=' & $sprotocol & ' localport=' & $slocalport
			Else
				$comando = 'netsh advfirewall firewall delete rule name=' & $sname & ' program="' & $sprogram & '"'
			EndIf
			RunWait(@ComSpec & " /c " & $comando, "", @SW_HIDE)
			_GUICtrlListView_DeleteItemsSelected($Listado_reglas)
			_ArrayDelete($aItem, $aValor)
			$aNuevosDatos = ""
			_FileReadToArray($Ruta_Datos, $aNuevosDatos, 0, "|")
			_ArrayDelete($aNuevosDatos, $aValor)
			_FileWriteFromArray($Ruta_Datos, $aNuevosDatos, 0)
			If  _GUICtrlListView_GetSelectedCount($Listado_reglas) == 0 Then FileDelete($Ruta_Datos)
			$aviso = "La regla se eliminó correctamente"
			MsgBox(64,"Regla Eliminada", $aviso)
		EndIf
	Else
		MsgBox(64,"Eliminar Regla", "Debe seleccionar antes una regla del listado")
	EndIf
EndFunc

; DESCRIPCIÓN: Seleccionar un programa o archivo ejecutable para crear una regla nueva.
;================================================================================================
Func _seleccionar_programa()
	$Seleccion = FileOpenDialog("Seleccione un archivo ejecutable", @ProgramFilesDir, "Archivos Ejecutables (*.exe)")
	GUICtrlSetData($InputPrograma, $Seleccion)
	If @error Then
		MsgBox(65, "", "No ha seleccionado ningún archivo.")
	EndIf
EndFunc

; DESCRIPCIÓN: Limpiar los datos de la ventana de creación de regla y cerrar la ventana.
;================================================================================================
Func _limpiar_creacion_regla()
	GUISetState(@SW_HIDE, $FormNuevaRegla)
	GUICtrlSetData($InputDescripcion, "")
	GUICtrlSetData($InputPuertoL, "")
	GUICtrlSetData($InputPuertoR, "")
	GUICtrlSetData($InputPrograma, "")
EndFunc
#EndRegion
