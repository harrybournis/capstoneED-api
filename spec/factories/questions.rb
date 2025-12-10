FactoryBot.define do
  factory :question do
    lecturer_id { FactoryBot.create(:lecturer).id }
    association :question_type, factory: :question_type
    text        {  ['What do you typically have for breakfast?',
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
                ].sample }
  end
end
