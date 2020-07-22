#!/home/jujee/.rvm/rubies/ruby-2.6.5/bin/ruby

# rspec

require 'uri'
require 'net/http'
require 'getopt/std'
require 'json'

###############################################################################
# how to use the program 
# params: nothing
# returns: exit
def help

	puts <<-eohelp
		#{$0} -- get a definition from the Merriam-Webster dictionary
		Usage:
		$ #{$0} -h
		$ #{$0} [-s -p -x -c -C] -w [word]
		
		Where :
		
		-h prints this message
		-c cache_dir the results
		-C use specified config file
		-x check cache_dir first for definition
		-s play associated sound file, if available
		-p display associated image, if available
	eohelp
	
	exit

end

###############################################################################
# parses a config file
# params: a file location
# returns: config data structure
def parse_config(location)

	config = {}

	if File.exists?(location)
		config = JSON.parse(IO.read(location))
	end

	# for several parameters, use reasonable defaults
	if config["player"].nil? 
		config["player"] = "mplayer" 
	end

	if config["viewer"].nil? 
		config["viewer"] = "gthumb" 
	end

	if config["cache_dir"].nil? 
		config["cache_dir"] = ENV["HOME"] + "/.mw"
	end

	# We cannot continue without a key
	if config["key"].nil?
		puts "Merriam-Webster API key is missing, exiting."
		exit
	end

	config
end

###############################################################################
# If a word has an illustration we can fetch it
# params: filename string, cache_result boolean
# returns: nil
def display_image(filename, config)

	art_url = "https://www.merriam-webster.com/assets/mw/static/art/dict/" 
	art_url += filename + ".gif"
	art = Net::HTTP.get(URI(art_url))
	File.write(filename, art)
	
	system("#{config['viewer']} #{filename} 2>/dev/null &")

	if config["cache_result"]
		puts "saving"
	else
		puts "deleting"
	end

	return
end

###############################################################################
# how to pronounce the word(s)
# params: array of filenames, cache_result boolean
# returns: nil
def play_sounds(sound_files,config)

	# FIXME
	sound_files.each { |sound_file|
		puts sound_file
		# these rules per the API documentation.
		# Start with the base URL: 
		sound_url = "http://media.merriam-webster.com/soundc11/"
		#puts sound_file[0,3]
		case sound_file
			# If the file name begins with "bix", the subdirectory should be "bix".
			#when sound_file.grep(/^bix/)
			when sound_file[0,3] == "bix"
				sound_url += "bix/"
			# If the file name begins with "gg", the subdirectory should be "gg".
			#when sound_file.grep(/^gg/)
			when sound_file[0,2] == "gg"
				sound_url += "gg/" 
			# If the file name begins with a number, the subdirectory should be "number".
			#when sound_file.grep(/^[0-9]/)
			when sound_file[0] == "0" #xxx
				sound_url += "number/" 
			# Else add the first letter of the wav file as a subdirectory
			else
				substr = sound_file[0,1]
                        	sound_url += substr + "/"
                end
		sound_url += sound_file + ".wav"
		puts sound_url
		Net::HTTP.get(URI(sound_url))

		if config["cache_result"]
			puts "saving"
		else
			puts "deleting"
		end
	}

	return
end

###############################################################################
# main: entry point
# params: none
# returns: nil
def main
	
	# parse command line options
	opt = Getopt::Std.getopts("chspxw:C:")
	
	if opt["h"]
		help
	end
	
	# deal with configuration file
	config_file = ENV["HOME"] + "/.mwrc";
	if opt["C"]
		config_file = opt["C"]
	end
	config = parse_config(config_file)
	
	word = String.new
	if opt["w"]
		word = opt["w"]
	else
		help
	end
	
	config["cache_result"] = false
	if opt["c"]
		config["cache_result"] = true
		Dir.mkdir(config["cache_dir"]) unless File.exists?(config["cache_dir"])  
	end
	
	base_url =  "https://www.dictionaryapi.com/api/v3/references/collegiate/json/"
	# XXX
	if opt["x"] && File.exists?(config["cache_dir"] + "/" + word + ".json")
		# XXX
		json = JSON.parse(IO.read(config["cache_dir"] + "/" + word + ".json"))
	else
		body = Net::HTTP.get(URI(base_url + word + "?key=" + config["key"]))
		json = JSON.parse(body)
	end
	
	#puts body.to_s
	sound_files = Array.new
	
	json.each { |entry|
	
		# some entries have gif files associated with them
		if opt["p"]
			if entry["art"]
				#art_file = entry["art"]["artid"] + ".gif"
				display_image(entry["art"]["artid"],config) 
			end
		end
	
		# play sound(s)
		if opt["s"]
	
			# seems to be in two possible locations
			if entry.dig("uros", 0, "prs", 0, "sound", "audio")
				sound_files.push(entry.dig("uros", 0, "prs", 0, "sound", "audio"))
			end
	
			if entry.dig("hwi", "prs", 0, "sound", "audio")
				sound_files.push(entry.dig("hwi", "prs", 0, "sound", "audio"))
			end
		end
	
		#print the definition
		puts entry["meta"]["id"] 
	
		entry["shortdef"].each { |shortdef|
			puts  " -- " + shortdef
		}
	}
	
	###############################################################################
	# pronounce the words
	play_sounds(sound_files,config) 

	return	
end
	
main
