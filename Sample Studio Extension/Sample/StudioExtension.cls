Class Sample.StudioExtension Extends %Studio.Extension.Base [ DependsOn = Sample.SelfInstallingExtension ]
{

Projection InstallMe As Sample.SelfInstallingExtension;

XData Menu
{
<MenuBase>

<Menu Name="Sample Top Menu" Type="0">
<MenuItem Name="Save, then Show Output" Save="100" />
<MenuItem Separator="1"/>
<MenuItem Name="Open Management Portal" />
<MenuItem Name="Open Google - Protocol Relative" />
<MenuItem Name="Open Google - No Protocol" />
<MenuItem Name="Open Notepad?" />
<MenuItem Separator="1"/>
<MenuItem Name="Open Class Method" />
<MenuItem Name="Open CSP" />
<MenuItem Separator="1"/>
<MenuItem Name="Alert" />
<MenuItem Name="Get Yes/No/Cancel" />
<MenuItem Name="Prompt" />
<MenuItem Separator="1"/>
<MenuItem Name="Open New Document Template" />
<MenuItem Name="Open Text Template" />
</Menu>

<Menu Name="Sample Popup Menu" Type="1">

<MenuItem Name="Show Output" Save="100" />
<MenuItem Name="Open All Classes in Package" />
<MenuItem Name="Quote Text" />
</Menu>

</MenuBase>
}

/// This is called when the user performs an action that may need to interact with
/// the server, such as selecting a menu or adding a new document. This encompases what the deprecated Flags
/// parameter did and allows additional flexibility.<p>
/// The Type argument values are:<ul>
/// <li>0 : Server defined menu item selected</li>
/// <li>1 : Other Studio action</li></ul>
/// ...
/// The Action argument is set by this method to tell Studio what to do. Possible return
/// values for this are:<ul>
/// <li>0 : Do nothing, note that this method can still perform some action such as check
/// an item out of source control, but Studio will not ask for user input.</li>
/// <li>1 : Display the default Studio dialog with a yes/no/cancel button.
/// The text for this dialog is provided in the 'Target' return argument.</li>
/// <li>2 - Run a CSP page/Template. The Target is the full url to the CSP page/Template, as usual the page will be
/// passed the current document name, any selected text, the project name, the namespace.</li>
/// ...
/// <li>4 - Insert the text in Target in the current document at the current selection point</li>
/// <li>5 - Studio will open the documents listed in Target, if there are multiple documents to open they
/// will be separated with commas. If the document name is 'test.mac:label+10' it will open the document
/// 'test.mac' and goto 'label+10'.</li>
/// <li>6 - Display an alert dialog in Studio with the text from the Target variable</li>
/// <li>7 - Display a dialog with a textbox and Yes/No/Cancel buttons. The text for this dialog is
/// provided by the 'Target' return argument. The initial text for the textbox is provided by the 
/// 'Msg' return argument.</li></ul>
/// If the <var>Reload</var> argument is set to true then the current document will be reloaded in Studio,
/// this is useful if you change the document to change its attribute so Studio will pick up these changes.
Method UserAction(Type As %Integer, Name As %String, InternalName As %String, SelectedText As %String, ByRef Action As %String, ByRef Target As %String, ByRef Msg As %String, ByRef Reload As %Boolean) As %Status
{
	If (Type = 1) {
		Write "Type: ",Type,"; Name: ",Name,"; InternalName: ",InternalName,!
		Quit $$$OK
	}
	
	Set tSC = $$$OK
	
	Try {
		Set $ListBuild(Action,Target,Msg,Reload) = $Case(Name,
			"Sample Top Menu,Save, then Show Output":$ListBuild(0,"","",0),
			"Sample Top Menu,Open Class Method":$ListBuild(5,"Sample.Class.cls:SomeMethod","",0),
			"Sample Top Menu,Open CSP":$ListBuild(5,"/csp/sourcecontrol/sample.csp","",0),
			"Sample Top Menu,Open Management Portal":$ListBuild(2,"/csp/sys/UtilHome.csp","",0),
			"Sample Top Menu,Open Google - Protocol Relative":$ListBuild(3,"http://www.google.com/","",0),
			"Sample Top Menu,Open Google - No Protocol":$ListBuild(3,"www.google.com","",0),
			"Sample Top Menu,Open Notepad?":$ListBuild(3,"notepad.exe","",0),
			"Sample Top Menu,Alert":$ListBuild(6,InternalName,"",0),
			"Sample Top Menu,Get Yes/No/Cancel":$ListBuild(1,"Give me an answer.","",0),
			"Sample Top Menu,Prompt":$ListBuild(7,"This is a prompt.","This is the default text.",0),
			"Sample Top Menu,Open New Document Template":$ListBuild(2,"/csp/sys/%25ZEN.Template.ZENApplicationWizard.cls","",0),
			"Sample Top Menu,Open Text Template":$ListBuild(2,"/isc/studio/templates/SQLTemplate.csp","",0),
			"Sample Popup Menu,Show Output":$ListBuild(0,"","",0),
			"Sample Popup Menu,Open All Classes in Package":$ListBuild(5,..GetClassesInPackage(InternalName),"",0),
			"Sample Popup Menu,Quote Text":$ListBuild(4,""""_$Replace(SelectedText,"""","""""")_"""","",0))
			
		If (Name [ "Show Output") {
			Write "Here, have some console output.",!
			Write "Internal name: ",InternalName,!
			Write "Selected text: ",SelectedText,!
		}
	} Catch anyException {
		Set tSC = anyException.AsStatus()
	}
		
	Quit tSC
}

/// This is called after the <method>UserAction</method> and after any template is run or dialog is displayed.
/// For list of input arguments see <method>UserAction</method>
/// In the case of the dialog the button pushed by the user is passed in Answer:<ul>
/// <li>0 - No</li>
/// <li>1 - Yes</li>
/// <li>2 - Cancel</li></ul>
/// For the dialog that contains a textbox field the text of this field is passed in 'Msg' argument.
/// In the case of a template if the template was closed from the 'x' button then Answer=2 to indicate
/// the user attempted to cancel the operation. Otherwise if the template closed normally by getting
/// to the end Answer=1.
/// For the cases where Studio did not perform any interaction this method is not called.
/// The default implementation is to call the standard source control tags as Studio did in Cache 5.0.
/// If the <var>Reload</var> argument is set to true by this method then the current document will be reloaded in Studio
Method AfterUserAction(Type As %Integer, Name As %String, InternalName As %String, Answer As %Integer, Msg As %String = "", ByRef Reload As %Boolean) As %Status
{
	Quit:Type=1 $$$OK
	
	
	Set tSC = $$$OK
	
	Try {
		Set $ListBuild(tWriteMsg,Reload) = $Case(Name,
			"Sample Top Menu,Open Management Portal":$ListBuild("Closed Management Portal",0),
			"Sample Top Menu,Get Yes/No/Cancel":$ListBuild($Case(Answer,0:"No",1:"Yes",2:"Cancel"),0),
			"Sample Top Menu,Prompt":$ListBuild(Msg_"/"_$Case(Answer,0:"No",1:"Yes",2:"Cancel"),0),
			"Sample Top Menu,Open New Document Template":$ListBuild("Closed New Document Template",0),
			"Sample Top Menu,Open Text Template":$ListBuild("Closed Text Template",0),
			"Sample Top Menu,Open Add-In Template":$ListBuild("Closed Add-In Template",0))
			
		Write tWriteMsg,!
		
		Write "Answer: ",Answer,!
		Write "Msg: ",Msg,!
	} Catch anyException {
		Set tSC = anyException.AsStatus()
	}
		
	Quit tSC
}

/// This is called for every menu item returned to Studio to allow the menu to be enabled/disabled without
/// having to write a custom query for <query>MenuItems</query>. The <var>DisplayName</var> of this menu is
/// also passed by reference and this may be modified to change the appearance of this menu item. The <var>MenuName</var>
/// is the main menu name then the submenu name separated by a ','. If <var>Enabled</var> is set to -1 then it will remove
/// this menu item from the list totally, 0 will gray the menu item out and the default 1 will display the menu item as normal.
Method OnMenuItem(MenuName As %String, InternalName As %String, SelectedText As %String, ByRef Enabled As %Boolean, ByRef DisplayName As %String) As %Status
{
	Set Enabled = $Case(MenuName,
		"Sample Popup Menu,Open All Classes in Package":($Extract(InternalName,*-2,*)="PKG"),
		"Sample Popup Menu,Quote Text":$Case(SelectedText,"":0,:1),
		:1)
	
	Set DisplayName = $Case(MenuName,
		"Sample Top Menu,Alert":$Case(InternalName,"":"",:"Alert "_InternalName),
		:DisplayName)
		
	Quit $$$OK
}

Method GetClassesInPackage(pPackageName As %String) As %String
{
	Set tList = ""
	Set tRes = ##class(%SQL.Statement).%ExecDirect(,"select Name from %Dictionary.ClassDefinition where Name %STARTSWITH ?",$Extract(pPackageName,1,*-3))
	While tRes.%Next() {
		Set tList = tList_$ListBuild(tRes.%Get("Name")_".cls")
	}
	Quit $ListToString(tList)
}

}
