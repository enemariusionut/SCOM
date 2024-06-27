' VBScript to start a specified Windows service. To be used as a service monitor recovery task.

' Check if a service name was provided as an argument
If WScript.Arguments.Count = 0 Then
    WScript.Echo "Usage: cscript startService.vbs <ServiceName>"
    WScript.Quit 1
End If

' Get the service name from the arguments
serviceName = WScript.Arguments(0)

' Create a WMI object to connect to the local computer
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")

' Get the service object based on the provided service name
Set colServiceList = objWMIService.ExecQuery("Select * from Win32_Service Where Name='" & serviceName & "'")

' Check if the service exists
If colServiceList.Count = 0 Then
    WScript.Echo "Service '" & serviceName & "' not found."
    WScript.Quit 1
End If

' Iterate through the service collection (there should be only one)
For Each objService in colServiceList
    ' Check if the service is not already running
    If objService.State <> "Running" Then
        ' Start the service
        intReturn = objService.StartService()
        
        ' Check the return code
        If intReturn = 0 Then
            WScript.Echo "Service '" & serviceName & "' started successfully."
        Else
            WScript.Echo "Failed to start service '" & serviceName & "'. Error code: " & intReturn
        End If
    Else
        WScript.Echo "Service '" & serviceName & "' is already running."
    End If
Next