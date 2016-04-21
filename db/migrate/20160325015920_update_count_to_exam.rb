class UpdateCountToExam < ActiveRecord::Migration
  def up
    Exam.reset_column_information
    Exam.all.each do |e|
      e.update_attribute :examinations_count, e.examinations.length
      e.update_attribute :certificates_count, e.certificates.length
    end
  end

  def down
  end
  puts '#################################################################'
  puts '###                                                           ###'
  puts '###           20160414010720_update_count_to_exam             ###'
  puts '###                                                           ###'
  puts '###   Pamiętaj, by w modelu examination.rb za(od)komentować   ###'
  puts '###   belongs_to :exam, counter_cache: true                   ###'
  puts '###                                                           ###'
  puts '###   Pamiętaj, by w modelu certificate.rb za(od)komentować   ###'
  puts '###   belongs_to :exam, counter_cache: true                   ###'
  puts '###                                                           ###'
  puts '#################################################################'

end
