extends Node


func _generate_name() -> String:
	var first_name: String = generate_pronounceable_word()
	var last_name: String = generate_pronounceable_word()
	return first_name + " " + last_name
	
	
var consonants: Array[String] = [
	"b","c","d","f","g","h","j","k","l","m","n","p","r","s","t","v","w","y","z",
	"bl","br","cl","cr","dr","fl","fr","gl","gr","pl","pr","sl","sm","sn","sp","st","str","sw","tr","tw"
]

var vowels: Array[String] = [
	"a","e","i","o","u",
	"ai","au","ea","ee","ie","oa","oo","ou","ui"
]

func generate_pronounceable_word() -> String:
	var length: int = randi_range(3, 7)
	var word: String = ""
	
	# Randomly decide if we start with vowel or consonant
	var use_vowel: bool = randf() < 0.5
	
	while word.length() < length:
		if use_vowel:
			word += vowels[randi_range(0, vowels.size() - 1)]
		else:
			word += consonants[randi_range(0, consonants.size() - 1)]
		use_vowel = !use_vowel  # alternate C/V
	
	# Trim to requested length
	word = word.substr(0, length)
	
	return word.capitalize()
