module KcCourses
  module Concerns
    module CourseReadingMethods
      extend ActiveSupport::Concern

      included do
        has_many :ware_readings, class_name: 'KcCourses::WareReading'
        has_many :ware_reading_deltas, class_name: 'KcCourses::WareReadingDelta'
      end

      # user 已经学习了 course 多少百分比的内容，返回值是代表百分比的数字
      def read_percent_of_user(user)
        return 0 if chapters.count == 0
        read_percent_hash = {}
        chapters.each do |chapter|
          read_percent_hash[chapter] = []
        end

        ware_readings.where(:creator_id => user.id.to_s).map do |reading|
          read_percent_hash[reading.chapter] << reading.read_percent
        end

        read_percent_hash.map do |chapter, value|
          if chapter.wares.count == 0
            0
          else
            value.sum / chapter.wares.count
          end
        end.sum / chapters.count
      end

      # user 是否已经完成整个 course 的学习（read_percent 是 100 时，表示完成学习）
      def has_read_by_user?(user)
        read_percent_of_user(user) == 100
      end

      # user 截止到 time 当天（包括当天）已经学习了多少百分比的内容
      def read_percent_of_user_before_day(user, time)
        read_percents = chapters.map do |chapter|
          chapter.read_percent_of_user_before_day(user, time)
        end

        return 0 if read_percents.count == 0
        read_percents.sum / read_percents.count
      end

      # user 在 time 当天学习了多少百分比的内容
      def read_percent_change_of_user(user, time)
        read_percents = chapters.map do |chapter|
          chapter.read_percent_change_of_user(user, time)
        end

        return 0 if read_percents.count == 0
        read_percents.sum / read_percents.count
      end

    end
  end
end