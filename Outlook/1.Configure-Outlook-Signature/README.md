# Configuring Outlook Signature Automatically

The script automatically generates a default signature in Outlook (client), using Active Directory User attributes as source of information to fill in fields like fullname, department and phone.

It is supposed to be used as a GPO Logon Script (User Configuration).

## Which does what

- [Set-OutlookClientSignature.ps1](https://github.com/esserafael/PowerShell/blob/master/Outlook/1.Configure-Outlook-Signature/Set-OutlookClientSignature.ps1): The PowerShell script that does the job itself.
  - [SignatureTemplate](https://github.com/esserafael/PowerShell/tree/master/Outlook/1.Configure-Outlook-Signature/SignatureTemplate): This folder contain the templates for the signatures, basically a .htm and a .txt file, so it is easier to change the design if needed.

## How to use it

  1. Download the files and store them, as structured here (the script will search for the files in the **SignatureTemplate** folder), in a shared network location, like ```\\mycompany.com\outlook```. Every user and workstation will need at least read permission.
  2. Create a new GPO and link it where your users are in the domain.
  3. Edit the new GPO and go to ```User Configuration\Policies\Windows Settings\Scripts\Logon```, in the ```PowerShell Scripts``` tab, click ```Add``` and navigate to the network location where the script is (step 1), then select and add it.
  4. Apply everything and you are set.

## Bonus

If you need to prevent users from adding, editing or removing the generated signature, in the Outlook Options, you can also use GPO to create and set the following Registry values as Strings:

```HKEY_CURRENT_USER\Software\Microsoft\Office\<OutlookVersion>\Common\MailSettings\NewSignature```
```HKEY_CURRENT_USER\Software\Microsoft\Office\<OutlookVersion>\Common\MailSettings\ReplySignature```

Set the value data with the same name of the generated signature files, ```Signature``` in this case (which will be same in every workstation).

The reason why it is not implemented in the script is because with that values set, the users can't change anything about signatures in the Outlook anymore, then if you need to revoke this block or grant a user the rights to edit, you can simply set the GPP to remove the registry value when the GPO is not in effect anymore, being the result of Security Filter or Delegation.
