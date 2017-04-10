FactoryGirl.define do
  factory :pa_form do
    questions do
      qs = ['What do you typically have for breakfast?',
            'Can you solve sudoko puzzles?',
            'Have you ever been professionally photographed?',
            'What do you like on your toast?',
            'Do you prefer green or red grapes?',
            'Can you play poker?',
            'What do you think the greatest invention has been?',
            'What horror fiction character scares you the most?',
            'At what age did you twig onto the fact Santa wasnt real?',
            'What are cooler? Dinosaurs or Dragons?',
            'Have you ever been in a helicopter?',
            'Have you ever been attacked by a wild animal?',
            'Whats your favourite precious stone?',
            'Do you collect anything?',
            'Could you ever hand milk a cow?',
            'Have you ever tossed your own pancake?',
            "Have you ever been approached by someone who knew you but you couldn't remember them for the life of you?",
            'If you were to join an emergency service which would it be?',
            'What historical period would you like to live in if you could go back in time?',
            'If you were a fashion designer, what style of clothing or accessories would you design?',
            'If you had friends round what DVDs would you have to watch?',
            'Do you prefer Honey or Jam?',
            "Whats your favourite alcoholic drink beginning with the letter V?",
            'If you were a member of the spice girls, what would your spice handle be?',
            'Have you ever owned a slinky?'
          ].sample(5)
        if QuestionType.all.any?
            type = QuestionType.all.sample
        else
            type = create :question_type
        end
      [].tap do |array|
        qs.each { |q| array << { 'text' => q, 'type_id' => type.id } }
      end
    end

    association :iteration, factory: :iteration

    start_offset { 2.days.to_i }
    end_offset { 5.days.to_i }

    factory :pa_form_seeder do
    questions do
      qs = ['What do you typically have for breakfast?',
            'Can you solve sudoko puzzles?',
            'Have you ever been professionally photographed?',
            'What do you like on your toast?',
            'Do you prefer green or red grapes?',
            'Can you play poker?',
            'What do you think the greatest invention has been?',
            'What horror fiction character scares you the most?',
            'At what age did you twig onto the fact Santa wasnt real?',
            'What are cooler? Dinosaurs or Dragons?',
            'Have you ever been in a helicopter?',
            'Have you ever been attacked by a wild animal?',
            'Whats your favourite precious stone?',
            'Do you collect anything?',
            'Could you ever hand milk a cow?',
            'Have you ever tossed your own pancake?',
            "Have you ever been approached by someone who knew you but you couldn't remember them for the life of you?",
            'If you were to join an emergency service which would it be?',
            'What historical period would you like to live in if you could go back in time?',
            'If you were a fashion designer, what style of clothing or accessories would you design?',
            'If you had friends round what DVDs would you have to watch?',
            'Do you prefer Honey or Jam?',
            "Whats your favourite alcoholic drink beginning with the letter V?",
            'If you were a member of the spice girls, what would your spice handle be?',
            'Have you ever owned a slinky?'
          ].sample(5)
      types = QuestionType.all
      [].tap do |array|
        qs.each { |q| array << { 'text' => q, 'type_id' => types.sample.id } }
      end
    end
    end
  end
end
