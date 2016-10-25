require "yaml"

class Hangman
  @@contents = File.readlines("5desk.txt")
  attr_reader :attempts_left, :failed_guesses, :previous_attempts

  def initialize(data = nil)
    @winner = false
    if data.nil?
      @attempts_left = 9
      @failed_guesses = []
      @previous_attempts = []
      @hidden_word = ""
      @word = choose_word.downcase
      @lose_message = "Better luck next time. The correct answer was: #{@word}"

      @word.length.times {@hidden_word += "_ "}
    else
      @attempts_left = data[:attempts_left]
      @failed_guesses = data[:failed_guesses]
      @previous_attempts = data[:previous_attempts]
      @hidden_word = data[:hidden_word]
      @word = data[:word]
      @lose_message = data[:lose_message]
    end
  end
  def to_yaml
    YAML.dump ({
      :attempts_left => @attempts_left,
      :failed_guesses => @failed_guesses,
      :previous_attempts => @previous_attempts,
      :hidden_word => @hidden_word,
      :word => @word,
      :lose_message => @lose_message
    })
  end
  def self.from_yaml
    data = YAML.load File.read("save.yaml")
    File.delete("save.yaml")
    self.new(data)
  end
  #check to see if the word contains the guessed letter
  def contains(letter)
    @word.include?(letter)
  end
  #update hidden_word
  def update_hidden_word(letter)
    while @word.index(letter) != nil
      index_to_change = @word.index(letter)*2
      @hidden_word[index_to_change] = letter
      @word[letter] = ' '
    end
  end
  #print info
  def show_letters
    puts "\n" + @hidden_word
    print "\nFailed guesses: #{@failed_guesses.join(' ')}"
  end
  #check to see if the game has finished
  def game_over?
    if @word.match(/[a-z]/) == nil
      @winner = true
      puts "Congratulations! You guessed the word!"
      return true
    elsif @attempts_left < 1
      puts @lose_message
      return true
    else
      return false
    end
  end
  #remove an attempt and update the list of incorrect guesses
  def failed_guess(letter)
    @failed_guesses << letter
    @attempts_left -= 1
  end
  #update list of previous attempts
  def update_attempts(letter)
    @previous_attempts << letter
  end

  private
  #choose valid hidden_word
  def choose_word
    random_word = ""
    while random_word.length < 6 || random_word.length > 13
      random_word = @@contents[rand(0...@@contents.length)]
    end
    return random_word.chomp
  end
end

#validate input
def get_input(h_man = nil)
  input = ""
  valid_input = false
  while valid_input == false
    if (input = gets.chomp.downcase) && (input == "save")
      save_game(h_man)
    elsif (input.length != 1) || (input.match(/[a-z]/) == nil)
      puts "Please enter a single letter"
    else
      valid_input = true
    end
  end
  return input
end

#save the game
def save_game(h_man)
  if File.exist?("save.yaml")
    File.delete("save.yaml")
  end
  f = File.new("save.yaml", "w")
  f.puts h_man.to_yaml
  f.close
  puts "Game saved"
  exit
end

#check to see if a letter was previously guessed
def already_guessed?(letter, previous_attempts)
  if previous_attempts.include?(letter)
    puts "You already guessed that"
    return true
  else
    return false
  end
end

#game loop
def game_loop(h_man_object)
  h_man = h_man_object

  puts "\nHANGMAN\n"
  h_man.show_letters
  puts " Attempts_left: #{h_man.attempts_left}  Type \"save\" in order to save and quit the game"

  while !h_man.game_over?
    letter = get_input(h_man)
    redo if already_guessed?(letter, h_man.previous_attempts) == true
    if h_man.contains(letter) == true
      h_man.update_hidden_word(letter)
      h_man.update_attempts(letter)
    else
      h_man.failed_guess(letter)
      h_man.update_attempts(letter)
    end
    h_man.show_letters
    puts " Attempts_left: #{h_man.attempts_left}"
  end
end

#ask player if they want to resume the game if possible
if File.exist?("save.yaml")
  puts "(N)ew game or (R)esume?"
  good_input = false
  while !good_input
    x = get_input
    case x
    when "n"
      game_loop(Hangman.new)
      good_input = true
      File.delete("save.yaml")
    when "r"
      game_loop(Hangman.from_yaml)
      good_input = true
    else 
      puts "Type (N) for new game or (R) to resume your previous game"
    end
  end
else
  game_loop(Hangman.new)
end