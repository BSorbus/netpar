class UpdateCountersExam < ActiveRecord::Migration
  def up
    Exam.all.each do |e|
      Exam.reset_counters(e.id, :examinations, :certificates)
    end
  end

  def down
  end
end
