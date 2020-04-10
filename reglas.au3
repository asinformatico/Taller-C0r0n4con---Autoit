#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region Ventana Nueva Regla
$FormNuevaRegla = GUICreate("Nueva Regla", 412, 292, 1033, 179, $WS_EX_MDICHILD, $WS_EX_TOPMOST)

$LabelDescricion = GUICtrlCreateLabel("Descripción", 24, 16, 60, 17)
$LabelDireccion = GUICtrlCreateLabel("Dirección:", 32, 80, 52, 17)
$LabelAccion = GUICtrlCreateLabel("Acción:", 32, 112, 40, 17)
$LabelProtocolo = GUICtrlCreateLabel("Protocolo:", 32, 144, 52, 17)
$LabelPuertoL = GUICtrlCreateLabel("Puerto Local:", 32, 176, 67, 17)
$LabelPuertoR = GUICtrlCreateLabel("Puerto Remoto:", 184, 176, 78, 17)
$LabelPrograma = GUICtrlCreateLabel("Programa:", 32, 176, 67, 17)
GUICtrlSetState(-1, $GUI_HIDE)

$InputDescripcion = GUICtrlCreateInput("", 24, 40, 353, 21)
$InputPuertoL = GUICtrlCreateInput("", 104, 168, 65, 21)
$InputPuertoR = GUICtrlCreateInput("", 264, 168, 65, 21)
$InputPrograma = GUICtrlCreateInput("", 104, 168, 249, 21)
GUICtrlSetState(-1, $GUI_HIDE)

$btn_Crear_Nueva_Regla = GUICtrlCreateButton("Aceptar", 240, 208, 75, 41)
$btn_Cancelar_Nueva_Regla = GUICtrlCreateButton("Cancelar", 320, 208, 75, 41)
$btn_Programa = GUICtrlCreateButton("...", 360, 168, 43, 25)
GUICtrlSetState(-1, $GUI_HIDE)

$ComboDireccion = GUICtrlCreateCombo("In", 104, 72, 105, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Out", "In")
$ComboAccion = GUICtrlCreateCombo("Block", 104, 104, 105, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Allow", "Block")
$ComboProtocolo = GUICtrlCreateCombo("TCP", 104, 136, 105, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "UDP", "TCP")

$RadioPuerto = GUICtrlCreateRadio("Puerto", 256, 88, 113, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$RadioPrograma = GUICtrlCreateRadio("Programa", 256, 120, 113, 17)

GUISetState(@SW_HIDE)
#EndRegion
