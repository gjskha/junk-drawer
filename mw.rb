#!ruby

require 'uri'
require 'net/http'
require 'getopt/std'
require 'json'

# prints the command line
def help

	puts <<-eohelp
		#{$0} -- get a definition from the Merriam-Webster dictionary
		Usage:
		$ #{$0} -h
		$ #{$0} [-s -p -x -c -C] -w [word]
		
		Where :
		
		-h prints this message
		-c cache the results
		-C use specified config file
		-x check cache first for definition
		-s play associated sound file, if available
		-p display associated image, if available
	eohelp
	
	exit

end

# takes a location and returns a config
def parse_config(location)

	# testme 
	#config = JSON.parse("{}")
	config = nil

	if File.exists?(location)

		config = JSON.parse(IO.read(location))
	end
	config
end

def play_sounds(sound_files,caching)

sound_files.each { |x|
	puts x
	# these rules per the API documentation.
	# Start with the base URL: http://media.merriam-webster.com/soundc11/
	# If the file name begins with "bix", the subdirectory should be "bix".
	# If the file name begins with "gg", the subdirectory should be "gg".
	# If the file name begins with a number, the subdirectory should be "number".
	# fetchme += "number/"
	# Else add the first letter of the wav file as a subdirectory

	if caching
		puts "saving"
	else
		puts "deleting"
	end
}

end

###############################################################################

# defaults for things the user can season to taste.
$defaults = { 
	:player => "mplayer", 
	:viewer => "shotwell", 
	:cache =>  ENV['HOME'] + "/.mw", 
	:config => ENV['HOME'] + "/.mwrc", 
	"key" => "default"
}

base_url =  'https://www.dictionaryapi.com/api/v3/references/collegiate/json/'
# this is the server where the sound files live
sound_url = 'http://media.merriam-webster.com/soundc11/'
# some entries have gif files associated with them
art_url = 'http://www.merriam-webster.com/art/dict/'

# parse command line options

opt = Getopt::Std.getopts("chspxw:C:")

if opt["h"]
    help
end

# deal with configuration file
if opt["C"]
	config = parse_config(opt["C"])
else
	config = parse_config($defaults[:config])
end

if config == nil
	config = $defaults
end

word = String.new
if opt["w"]
    word = opt["w"]
else
    help
end

# XXX create cache directory
caching = false
if opt["c"]
	caching = true
end

# XXX
if opt["x"] && File.exists?(cache + "/" + word + ".json")
	# XXX
	json = JSON.parse(IO.read(cache + "/" + word + ".json"))
else
	body = Net::HTTP.get(URI(base_url + word + '?key=' + config["key"]))
	json = JSON.parse(body)
end

#puts body.to_s

sound_files = Array.new
#downloads = Array.new
#json.each_with_index { |entry, idx|
json.each { |entry|

	# display image
	if opt["p"]
		if entry["art"]
			puts "art " + entry["art"]["artid"]
		end
	end

	# play sound(s)
	if opt["s"]

		# seems to be in two possible locations
		if entry.dig('uros', 0, 'prs', 0, 'sound', 'audio')
			sound_files.push(entry.dig('uros', 0, 'prs', 0, 'sound', 'audio'))
		end

		if entry.dig('hwi', 'prs', 0, 'sound', 'audio')
			sound_files.push(entry.dig('hwi', 'prs', 0, 'sound', 'audio'))
		end
		#	sound_files.push(entry["uros"].first["prs"].first["sound"]["audio"])
		#	sound_files.push(entry["hwi"]["prs"].first["sound"]["audio"])
	end

	#print the definition
	puts entry["meta"]["id"] 

	entry["shortdef"].each { |shortdef|
		
		puts  " -- " + shortdef
	}
}

play_sounds(sound_files,caching) 
