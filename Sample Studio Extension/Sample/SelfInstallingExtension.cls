Class Sample.SelfInstallingExtension Extends %Projection.AbstractProjection [ System = 3 ]
{

ClassMethod CreateProjection(classname As %String, ByRef parameters As %String, modified As %String, qstruct) As %Status
{
	Quit ##class(%Studio.SourceControl.Interface).SourceControlClassSet(classname,$namespace)
}

ClassMethod RemoveProjection(classname As %String, ByRef parameters As %String, recompile As %Boolean, modified As %String, qstruct) As %Status
{
	Set tSC = $$$OK
	If (##class(%Studio.SourceControl.Interface).SourceControlClassGet($namespace) = classname) {
		Set tSC = ##class(%Studio.SourceControl.Interface).SourceControlClassSet("",$namespace)
	}
	QUIT tSC
}

}
