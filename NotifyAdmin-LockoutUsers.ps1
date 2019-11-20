$Report= "c:\Admin\html.html"

$HTML=@"
<title>Account locked out Report</title>
<style>
BODY{background-color :#FFFFF}
TABLE{Border-width:thin;border-style: solid;border-color:Black;border-collapse: collapse;}
TH{border-width: 1px;padding: 1px;border-style: solid;border-color: black;background-color: ThreeDShadow}
TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color: Transparent}
H2{color: #457dcf;font-family: Arial, Helvetica, sans-serif;font-size: medium; margin-left: 40px;
</style>
"@

$Account_Name = @{n='Account name';e={$_.ReplacementStrings[-1]}}
$Account_domain = @{n='Account Domain';e={$_.ReplacementStrings[-2]}}
$Caller_Computer_Name = @{n='Caller Computer Name';e={$_.ReplacementStrings[-1]}}

            
$event= Get-EventLog -LogName Security -InstanceId 4740 -Newest 1 |
   Select TimeGenerated,ReplacementStrings,"Account name","Account Domain","Caller Computer Name" |
   % {
     New-Object PSObject -Property @{
      "Account name" = $_.ReplacementStrings[-7]
      "Account Domain" = $_.ReplacementStrings[5]
      "Caller Computer Name" = $_.ReplacementStrings[1]
      Date = $_.TimeGenerated
    }
   }
   
  $event | ConvertTo-Html -Property "Account name","Account Domain","Caller Computer Name",Date -head $HTML -body  "<H2> User is locked in the Active Directory</H2>"|
	 Out-File $Report -Append

$secpasswd = ConvertTo-SecureString "12345678@sta.com" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ("Notification@integrant.com",$secpasswd)
$MailBody= Get-Content $Report
$MailSubject= "User Account locked out"
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "smtp.office365.com"
$SmtpClient.port = "587"
$SmtpClient.Credentials = $creds
$SmtpClient.EnableSsl = "true"
$MailMessage = New-Object System.Net.Mail.MailMessage
$MailMessage.from = "DC.Alerts@integrant.com"
$MailMessage.To.add("it@integrant.com")
$MailMessage.Subject = $MailSubject
$MailMessage.IsBodyHtml = 1
$MailMessage.Body = $MailBody
$SmtpClient.Send($MailMessage )
del c:\Admin\html.html
