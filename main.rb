require_relative 'ec'


ec = EnergenieConnector.new("http://10.1.1.13", "1")

# Call the login method
is_logged_in = ec.login

# Check the login result
if is_logged_in
  puts "Successfully logged in!"
else
  puts "Login failed!"
end

#change socket3 to on
ec.changesocket(3, 1)
# Sleep for one second to allow the device to change the socket state
sleep 1
#change socket3 to off
ec.changesocket(3, 0)

# Call the logout method
is_logged_out = ec.logout

# Check the logout result
if is_logged_out
    puts "Successfully logged out!"
    else
    puts "Logout failed!"
    end