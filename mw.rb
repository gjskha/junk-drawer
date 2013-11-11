#!/usr/pkg/bin/ruby -w

# mw.rb by gjskha

# A very long time ago I had a screen scraper shell script for the Merriam
# Webster online dictionary. Of course, it broke at some point in the first
# decade of this century, so now I have rewritten it using M-W's freemium API
# in Ruby. Oh well... I probably won't usually look up more than 1000 words a
# day anyways :-/

require 'rubygems'
require 'uri'
require 'net/http'
require 'getopt/std'
require "rexml/document"
include REXML

# Things the user can season to taste.
player = "mplayer"
viewer = "gwenview"
cache = ENV['HOME'] + "/.mw"

# you also need a key from Merriam Webster.
unless ENV['MW_FREEMIUM_KEY']
    puts "need shell variable MW_FREEMIUM_KEY in order to go forward"
    exit
end

# this is the xml you need a key for
base_url = 'http://www.dictionaryapi.com/api/v1/references/collegiate/xml/'
# this is the server where the sound files live
sound_url = 'http://media.merriam-webster.com/soundc11/'
# some entries have gif files associated with them
art_url = 'http://www.merriam-webster.com/art/dict/'


def help
    puts <<-eohelp

#{$0} -- get a definition from the Merriam-Webster dictionary
Usage:
$ #{$0} -h
$ #{$0} -s -p -x -c -w [word]

Where :

-h prints this message
-w the word to look up
-c cache the results
-x check cache first for definition
-s play associated sound file, if available
-p display associated image, if available

eohelp

    exit
end

opt = Getopt::Std.getopts("chspxw:")

if opt["h"]
    help
end

word = String.new
if opt["w"]
    word = opt["w"]
else
    help
end

caching = 0;
if opt["c"]
    caching = 1;
end

doc = ""

if opt["x"] && File.exists?(cache + "/" + word + ".xml")

    puts "do something to create body"

else
    body = Net::HTTP.get(URI(base_url + word + '?key=' + ENV['MW_FREEMIUM_KEY']))
    doc = Document.new body
end

# puts doc.to_s

sound_files = Array.new
downloads = Array.new

doc.elements.each("entry_list/entry") { |entry|

    sound_file_key = entry.attributes["id"]
                                      
    entry.elements.each("ew") { |ew|
        print "--> " + ew.text
    }

    if opt["s"]
        entry.elements.each("sound") { |sound|
            sound.elements.each("wav") { |wav|
                sound_files.push({ "sf" => sound_file_key, "wavfile" => wav.text })
            }
        }
    end

    if opt["p"]
        
        bmp_file = String.new
        
        # test
        entry.elements.each("art") { |art|
            art.elements.each("bmp") { |bmp|
                bmp_file = bmp.text
            }
        }
      
        cached_art_file = String.new(cache + "/" + bmp_file[0, bmp_file.length - 4] + ".gif")
                                
        unless opt["x"] && File.exists?(cached_art_file)
            
            art_url = String.new(art_url + bmp_file[0, bmp_file.length - 4] + ".gif")
            picbody = Net::HTTP.get(URI(art_url))
            filehandle = File.new(cached_art_file, "w+")
            filehandle.puts(picbody)
        #else
        end

        system "#{viewer} #{cached_art_file} &"
        
        downloads.push(cached_art_file)
        #unless opt["c"]
        # system "echo rm #{cached_art_file}" # built-in safer
        #end
    end

    entry.elements.each("def") { |deftag|
        deftag.elements.each("date") { |date|
            puts " (" + date.text + ")"
        }
        deftag.elements.each("dt") { |dt|
            puts " * " + dt.text
        }
    }
}

if opt["s"]

  
    # present a menu of available sound files
    i = 0
    sound_files.each() { |file|
        puts "[#{i}] " + file["sf"]
        i = i + 1
    }
    
    while true

        puts "Select a number, or press q to quit."
        input = gets.chomp
        if input.downcase == 'q'
            break
        else
            cached_file = cache + "/" + sound_files[input.to_i]["wavfile"];
            unless opt["x"] && File.exists?(cached_file)
                #system "#{player} #{cached_file}"
            #else

            # these rules per the API documentation.
                # Start with the base URL: http://media.merriam-webster.com/soundc11/
                fetchme = sound_url;
                case sound_files[input.to_i]["wavfile"]
                    # If the file name begins with "bix", the subdirectory should be "bix".
                    when sound_files[input.to_i]["wavfile"].grep(/^bix/) :
                        fetchme += "bix/"
                    # If the file name begins with "gg", the subdirectory should be "gg".
                    when sound_files[input.to_i]["wavfile"].grep(/^gg/) :
                        fetchme += "gg/"
                    # If the file name begins with a number, the subdirectory should be "number".
                    when sound_files[input.to_i]["wavfile"].grep(/^[0-9]/) :
                        fetchme += "number/"
                    # Else add the first letter of the wav file as a subdirectory
                    else
                        substr = sound_files[input.to_i]["wavfile"][0,1];
                        fetchme += substr + "/"
                end
                fetchme += sound_files[input.to_i]["wavfile"]

                wavbody = Net::HTTP.get(URI(fetchme))
                filehandle = File.new(cached_file, "w+")
                filehandle.puts(wavbody)
                downloads.push(cached_file)
            end

            # play the sound.
            system "#{player} #{cached_file}"
        end
    end
end

unless opt["c"]
    # Do not save. Delete stuff.
    downloads.each() { |dlfile|
        puts "delete #{dlfile}"
    }
else
    # write doc out
end
