importPackage(Packages.org.csstudio.opibuilder.scriptUtil);

var macroInput = DataUtil.createMacrosInput(true);
var pv = PVUtil.getString(pvArray[0]);


//ConsoleUtil.writeInfo("script external");


var mainOpiLinker = display.getWidget("MainOpiLinker");


mainOpiLinker.setPropertyValue("opi_file", "");

macroInput.put("Device2Macro", pv);
mainOpiLinker.setPropertyValue("macros", macroInput);

mainOpiLinker.setPropertyValue("opi_file", widget.getMacroValue("MAIN_OPI_FILE"));