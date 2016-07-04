#!/usr/bin/ruby 
# Bailiwick.rb - a web front-end to async_rdns

require 'sinatra/base'
require 'active_record'
require 'ipaddr'
require 'netaddr'

module Model

    ActiveRecord::Base.establish_connection(
        :adapter => 'sqlite3',
        :database =>  'db/addresses.db'
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
            @ci = params[:ci]

            # data validation
            @hash = Hash.new

            if @ci then
                range = NetAddr::CIDR.create(@ci)
                first = IPAddr.new(range.first).to_i           
                last = IPAddr.new(range.last).to_i 
                @addresses = Model::Address.order(:address).where("address >= #{first} and address <= #{last}") 
                @addresses.each do |ar|
                    # determining default view should go here
                    (@hash[ar.dotquad.to_s] ||= []) << { ar.created_at.to_s => ar.rdns.to_s }
                end
                #puts hash.inspect
            end
            erb :index
        end
        
        post '/' do

            @sv = params[:sv]
            @ci = params[:ci]

            # data validation here
            raw_output = `bin/async_rdns -i #{@sv} #{@ci}`.split("\n")
            # check for rv/err

            raw_output.each do |line|
                dotquad, rdns = line.split
                myip = IPAddr.new dotquad
                address = Model::Address.new
                address.rdns = rdns
                address.status = 0
                address.address = myip.to_i
                address.dotquad = dotquad
                address.created_at = Time.now
                address.save

                redirect to("/?ci=#{@ci}&sv=#{@sv}")

            end

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
      <% if defined?(@ci) %>
        - <%= @ci %>
       <% end %>
    </h1>
    <form action="/" method="POST">
    <div class="row">
     <div class="eight columns">
         <label for="ci">Enter an IP range:</label>
         <input class="u_full_width"  id="ci" name="ci">
           <% if defined?(@ci) %>
             <%= @ci %></input>
           <% end %>
       <label for="sv">Enter a skip value between 1 and 128:</label>
         <!-- <input class="u-full-width"  id="sv"> -->
         <select class="u_full_width" id="sv" name="sv">
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
