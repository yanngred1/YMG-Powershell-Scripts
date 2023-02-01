# Replace <CSV File Path> with the path to the CSV file containing the user information
$users = Import-Csv "<CSV File Path>"

foreach ($user in $users) {
  # Replace <OU Distinguished Name> with the distinguished name of the OU where you want to create the user
  $ou = "<OU Distinguished Name>"

  # Replace <Username> and <Password> with the desired username and password for the user
  $username = $user.Username
  $password = $user.Password

  # Replace <First Name> and <Last Name> with the user's first and last name
  $firstName = $user.FirstName
  $lastName = $user.LastName

  # Create the new user object
  $newUser = New-Object System.Object
  $newUser | Add-Member -Type NoteProperty -Name GivenName -Value $firstName
  $newUser | Add-Member -Type NoteProperty -Name Surname -Value $lastName
  $newUser | Add-Member -Type NoteProperty -Name SamAccountName -Value $username
  $newUser | Add-Member -Type NoteProperty -Name UserPrincipalName -Value "$username@domain.com"
  $newUser | Add-Member -Type NoteProperty -Name AccountPassword -Value (ConvertTo-SecureString $password -AsPlainText -Force)
  $newUser | Add-Member -Type NoteProperty -Name Enabled -Value $true

  # Create the new user in the specified OU
  New-ADUser @newUser -Path $ou

  # Replace <Group Name> with the name of the group you want to add the user to
  $group = $user.Group
  
  # Add the user to the specified group
  Add-ADGroupMember -Identity $group -Members $username
}
