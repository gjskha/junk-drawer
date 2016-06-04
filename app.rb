#!/usr/bin/ruby 

require 'rubygems'
require 'sinatra/base'
require 'active_record'
require 'ipaddr'

module Model
    
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database =>  'db/padbail_development.db'
    )
    
    class Address < ActiveRecord::Base
        validates :rdns, presence: true
        validates :address, presence: true
        validates :created_at, presence: true
        validates :dotquad, presence: true
    end
end

module Control    
    class Index < Sinatra::Base

        enable :inline_templates
        configure :production, :development do
            enable :logging
        end
    
        get '/' do
            @addresses = Model::Address.where(status: -1)
            @cidrInput = params['c']
            erb :index
        end
        
        post '/' do
            @skipValue = params[:skipValue]
            @cidrInput = params[:cidrInput]

            # myip = IPAddr.new dotquad

            # data validation here
            puts "skipValue: #{@skipValue}" 
            puts "cidrInput: #{@cidrInput}" 
            raw_output = `bin/async_rdns -i #{@skipValue} #{@cidrInput}`
            # map         
        end
    end
end

Control::Index.run!

__END__
@@ index
<html>
 <head>
  <link rel="stylesheet" href="http://gjskha.github.io/css/normalize.css" type="text/css" media="screen" />
  <link rel="stylesheet" href="http://gjskha.github.io/css/stdlib.css" type="text/css" media="screen" />
 </head>
 <body>
  <div class="container">
   <div class="twelve columns">
    <h1>Bailiwick
      <% if defined?(@cidrInput) %>
        - <%= @cidrInput %>
       <% end %>
    </h1>
    <form action="/" method="POST">
    <div class="row">
     <div class="eight columns">
         <label for="cidrInput">Enter an IP range:</label>
         <input class="u_full_width"  id="cidrInput" name="cidrInput">
           <% if defined?(@cidrInput) %>
             <%= @cidrInput %></input>
           <% end %>
       <label for="skipValue">Enter a skip value between 1 and 128:</label>
         <!-- <input class="u-full-width"  id="skipValue"> -->
         <select class="u_full_width" id="skipValue" name="skipValue">
           <option value="1">1</option>
           <option value="2">2</option>
           <option value="4">4</option>
           <option value="8" selected>8</option>
           <option value="16">16</option>
           <option value="32">32</option>
           <option value="64">64</option>
           <option value="128">128</option>
         </select>
        </div>
       </div>
     </div>
     <input class="button_primary" value="Submit" type="submit">
   </form>
   <br />
   <table class="u_full_width">
    <thead>
     <tr>
      <th>Address</th>
      <th>Status</th>
      <th>Scanned</th>
      <th>Reverse</th>
     </tr>
    </thead>
    <tbody>
    <% @addresses.each do |address| %>
    <tr>
     <td>
      <%= address.dotquad %>
     </td>
     <td>
      <%= address.status %>
     </td>
     <td>
      <%= address.created_at %>
     </td>
     <td>
      <%= address.rdns %>
     </td>
    </tr>
    <% end %>
    </tbody>
   </table>
   </div>
  </div>
 </body>
</html>
