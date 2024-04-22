require 'net/http'
require 'uri'
require 'rexml/document'

class EnergenieConnector
  def initialize(baseurl, pwd)
    @loginstatustxt = ["Logged in", "Not logged in", "Login blocked", "Unknown login state"]
    @rgx_blocked = /<div>Impossible to login - there is an active session with this device at this moment.<\/div>/
    @rgx_login = /<div>&nbsp;EnerGenie Web:&nbsp;.+<\/div>/
    @rgx_loggedin = /<div class="boxmenuitem"><a href="login\.html">Log Out<\/a><\/div>/
    @rgx_socketstates = /var\s+sockstates\s+=\s+\[([01]),([01]),([01]),([01])\];/
    @baseurl = baseurl
    @pwd = pwd
  end

  # Fetch state from device
  def getstatus
    uri = URI.join(@baseurl, "/energenie.html")
    response = Net::HTTP.get_response(uri)

    if response.code.to_i == 200
      case response.body
      when @rgx_blocked
        { "login" => 2, "logintxt" => @loginstatustxt[2], "sockets" => nil }
      when @rgx_login
        { "login" => 1, "logintxt" => @loginstatustxt[1], "sockets" => nil }
      when @rgx_loggedin
        sockets = response.body.scan(@rgx_socketstates).flatten.map(&:to_i)
        { "login" => 0, "logintxt" => @loginstatustxt[0], "sockets" => sockets }
      else
        { "login" => 3, "logintxt" => @loginstatustxt[3], "sockets" => nil }
      end
    else
      { "login" => 3, "logintxt" => @loginstatustxt[3], "sockets" => nil }
    end
  end

  # Perform login
  def login
    uri = URI.join(@baseurl, "/login.html")
    response = Net::HTTP.post_form(uri, { "pw" => @pwd })

    if response.code.to_i == 200 && response.body.match?(@rgx_loggedin)
      true
    else
      false
    end
  end

  # Perform logout
  def logout
    uri = URI.join(@baseurl, "/login.html")
    response = Net::HTTP.get_response(uri)

    response.code.to_i == 200
  end

  # Change socket state
  def changesocket(socket, state)
    params = { "cte1" => "", "cte2" => "", "cte3" => "", "cte4" => "" }
    params["cte#{socket}"] = state

    uri = URI.join(@baseurl, "/")
    response = Net::HTTP.post_form(uri, params)

    response.code.to_i == 200
  end
end
