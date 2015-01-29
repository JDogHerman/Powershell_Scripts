Function Search-ADUserWithExpiringPasswords 
{ 
<# 
    .SYNOPSIS  
    Gets Active Directory user accounts with passwords that are expiring in a given time period or by a specified time. 
 
    .DESCRIPTION 
    Specifies a search for user accounts that are expiring in a given time period or by a specified time. To specify a time period, use the TimeSpan parameter. 
    To specify a specific time, use the DateTime parameter. 
     
    .PARAMETER  DateTime 
    Specifies a distinct time value for PasswordExpiring. 
 
    Time is assumed to be local time unless otherwise specified. When a time value is not specified, the time is assumed to midnight local time. When a date is not specified, the date is assumed to be the current date. The following examples show commonly-used syntax to specify a DateTime object. 
    "4/17/2006" 
    "Monday, April 17, 2006" 
    "2:22:45 PM" 
    "Monday, April 17, 2006 2:22:45 PM" 
 
    These examples specify the same date and the time without the seconds. 
    "4/17/2006 2:22 PM" 
    "Monday, April 17, 2006 2:22 PM" 
    "2:22 PM" 
 
    The following example shows how to specify a date and time by using the RFC1123 standard. This example defines time by using Greenwich Mean Time (GMT). 
    "Mon, 17 Apr 2006 21:22:48 GMT" 
 
    The following example shows how to specify a value as Coordinated Universal Time (UTC). This example represents 
    Monday, April 17, 2006 at 2:22:48 PM UTC. 
    "2000-04-17T14:22:48.0000000" 
 
    The following example shows how to set a DateTime value of June 18, 2012 at 2:00:00 AM. 
 
    -DateTime "6/18/2012 2:00:00 AM"  
     
    .PARAMETER EnabledAccountsOnly 
    Switch parameter to filter out disabled user accounts. Only non-disabled accounts will be included in search results when switch is present 
     
    .PARAMETER  TimeSpan 
    Sets a time interval.  
 
    Specify the time interval in the following format. 
       [-]D.H:M:S.F 
        where: 
          D = Days (0 to 10675199) 
          H = Hours (0 to 23) 
          M = Minutes (0 to 59) 
          S = Seconds (0 to 59) 
          F= Fractions of a second (0 to 9999999) 
 
    Note: Time values must be between the following values: -10675199:02:48:05.4775808 and 10675199:02:48:05.4775807. 
 
     The following examples show how to set this parameter. 
       Set the time to 2 days 
         -TimeSpan "2" 
       Set the time span to the previous 2 days 
        -TimeSpan "-2" 
       Set the time to 4 hours 
         -TimeSpan "4:00" 
 
     For example, to search for all accounts that are expiring in 10 days, specify the TimeSpan parameters as follows. 
 
    .PARAMETER  Properties 
    Specifies the properties of the output object to retrieve from the server. Use this parameter to retrieve prope 
    rties that are not included in the default set. 
 
    Specify properties for this parameter as a comma-separated list of names. To display all of the attributes that 
     are set on the object, specify * (asterisk). 
 
    To specify an individual extended property, use the name of the property. For properties that are not default o 
    r extended properties, you must specify the LDAP display name of the attribute. 
 
    To retrieve properties and display them for an object, you can use the Get-* cmdlet associated with the object 
    and pass the output to the Get-Member cmdlet. The following examples show how to retrieve properties for a grou 
    p where the Administrator's group is used as the sample group object. 
 
      Get-ADGroup -Identity Administrators | Get-Member 
 
    To retrieve and display the list of all the properties for an ADGroup object, use the following command: 
      Get-ADGroup -Identity Administrators -Properties *| Get-Member 
 
    The following examples show how to use the Properties parameter to retrieve individual properties as well as th 
    e default, extended or complete set of properties. 
 
    To retrieve the extended properties "OfficePhone" and "Organization" and the default properties of an ADUser ob 
    ject named "SaraDavis", use the following command: 
      GetADUser -Identity SaraDavis  -Properties OfficePhone,Organization 
 
    To retrieve the properties with LDAP display names of "otherTelephone" and "otherMobile", in addition to the de 
    fault properties for the same user, use the following command: 
       GetADUser -Identity SaraDavis  -Properties otherTelephone, otherMobile |Get-Member 
 
 
 
    .OUTPUTS 
    Microsoft.ActiveDirectory.Management.ADUser 
 
    .EXAMPLE 
    C:\PS>  Search-ADUserWithExpiringPasswords -TimeSpan "14" 
    
    DESCRIPTION 
    ----------- 
    Returns all users with passwords that will expire within 14 days from now 
     
    .EXAMPLE 
    C:\PS> Search-ADUserWithExpiringPasswords -DateTime "1/30/2010" 
     
    DESCRIPTION 
    ----------- 
    Returns all users with passwords that will expire between now and January 30th 2010 
     
    .EXAMPLE 
    C:\PS> Search-ADUserWithExpiringPasswords -TimeSpan "14" -properties emailaddress,title 
     
    DESCRIPTION 
    ----------- 
    Returns all users with passwords that will expire within 14 days from now with EmailAddress and Title properties return in addition to the default set 
 
    .Notes  
    NAME:      Search-ADUserWithExpiringPasswords 
    AUTHOR:    sblossom  
    LASTEDIT:  01/06/2010  
         
    #> 
 [CmdletBinding()] 
   Param (  
       [TimeSpan]$TimeSpan, 
       [DateTime]$DateTime, 
       [string[]]$Properties=$null, 
       [Switch]$EnabledAccountsOnly  
   )  
    
    #check for Active-Directory Module, load it if its not present 
    if ((get-module | where { $_.Name -eq "ActiveDirectory"}) -eq $null) { 
        import-module ActiveDirectory; 
        #check that the import worked and throw exception if it didn't 
        if ((get-module | where { $_.Name -eq "ActiveDirectory"}) -eq $null) {throw "ActiveDirectory Module is required."} 
        } 
         
   
    if (($TimeSpan -eq $null) -and ($DateTime -eq $null)) { throw "Either TimeSpan or DateTime parameter must be specified"} 
    if ($DateTime -ne $null) { $TimeSpan = $DateTime.Subtract([datetime]::now) } 
 
    #Get the password age limit for the domain 
    $maxAge = (new-object System.TimeSpan((Get-ADObject (Get-ADRootDSE).defaultNamingContext -properties maxPwdAge).maxPwdAge)) 
 
    #calculate the expiration timefram (in windows file time) 
    $expireToday = (([datetime]::Now).Date).Add($maxAge).tofileTime() 
    $expireFuture = (([datetime]::Now).Date).Add($maxAge.Add($TimeSpan)).tofileTime() 
 
    #$filter = "(&(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=8388608)(!userAccountControl:1.2.840.113556.1.4.803:=65536)(pwdLastSet>=$expireToday)(pwdLastSet<=$expireFuture))(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2))) 
    $filter = "(pwdlastset -gt $expireToday )" # -and (pwdlastset -lt $expireFuture) " 
    if ($EnabledAccountsOnly) { $filter += "-and (-not (userAccountControl -band 0x2))" } 
    if ($properties -eq $null) 
    { 
        Get-ADUser -filter $filter 
    } 
    else 
    { 
        Get-ADUser -properties $properties -filter $filter 
    } 
}
