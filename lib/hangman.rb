class Hangman
  @@contents = File.readlines("5desk.txt")

  def initialize
    @winner = false
    @hidden_word = ""
    @word = choose_word.downcase
    @lose_message = "Better luck next time. The correct answer was: #{@word}"

    @word.length.times {@hidden_word += "_ "}
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
  def show_letters(failed_guesses)
    puts "\n" + @hidden_word
    print "\nFailed guesses: #{failed_guesses.join(' ')}"
  end
  #check to see if the game has finished
  def game_over?(attempts_left)
    if @word.match(/[a-z]/) == nil
      @winner = true
      puts "Congratulations! You guessed the word!"
      return true
    elsif attempts_left < 1
      puts @lose_message
      return true
    else
      return false
    end
  end

  private
  #choose valid hidden_word
  def choose_word
    random_word = ""
    while random_word.length < 5 || random_word.length > 12
      random_word = @@contents[rand(0...@@contents.length)]
    end
    return random_word.chomp
  end
end

#validate input
def get_input(already_guessed)
  input = ""
  valid_input = false
  while valid_input == false
    if (input = gets.chomp.downcase) && (input.length != 1)
      puts "Please enter a single letter"
    elsif input.match(/[a-z]/) == nil
      puts "Please enter a single letter"
    elsif already_guessed.include?(input)
      puts "You already guessed that"
    else
      valid_input = true
    end
  end
  return input
end

attempts_left = 9
failed_guesses = []
already_guessed = []

h_man = Hangman.new
puts "\nHANGMAN\n"
h_man.show_letters(failed_guesses)
puts " Attempts_left: #{attempts_left}"

#game loop
while !h_man.game_over?(attempts_left)
  letter = get_input(already_guessed)
  if h_man.contains(letter) == true
    h_man.update_hidden_word(letter)
    already_guessed << letter
  else
    failed_guesses << letter
    already_guessed << letter
    attempts_left -= 1
  end
  h_man.show_letters(failed_guesses)
  puts " Attempts_left: #{attempts_left}"
end