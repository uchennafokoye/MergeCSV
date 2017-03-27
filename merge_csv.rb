require 'csv'
require 'date'

module DataType
  STRING = 1
  INTEGER = 2
  TIME = 3
end

class CustomTime

  @@regex_pattern = /^(\d?,?\d*):([0-5]?\d):([0-5]?\d)$/
  attr_reader :hour, :min, :sec

  def initialize hhmmss_timestamp
    if match = @@regex_pattern.match(hhmmss_timestamp)
       @hour = $1.delete(',').to_i
       @min = $2.to_i
       @sec = $3.to_i
    else
      raise "Invalid timestamp"
    end
  end


end

class MergeCSV

  include DataType
  attr_reader :attributes, :key


  def initialize(attributes, key)
      @hashMap = {};
      @attributes = attributes
      @key = key;
  end

  def add(path_to_csv)
      merge_csv(path_to_csv)
  end

  def export(additionalTitles= [], file_name= 'result/the_file.csv')
    column_names = @attributes.keys
    column_names.concat(additionalTitles) if !additionalTitles.empty?
    s = CSV.generate do |csv|
      csv << column_names
      @hashMap.each do |hash|
        values = getExportValues(hash)
        values.concat(yield(hash[1])) if block_given?
        csv << values
      end
    end

    File.write(file_name, s)
  end


  def self.convert_sec_to_time(timeInSec)


    hours = 0
    while (timeInSec >= 3600)
      hours += 1
      timeInSec -= 3600
    end

    minutes = 0
    while (timeInSec >= 60)
      minutes += 1
      timeInSec -= 60
    end

    sec = timeInSec

    "#{appendZeroToTime(hours)}:#{appendZeroToTime(minutes)}:#{appendZeroToTime(sec)}"
  end

  private

  def self.appendZeroToTime time
    (time >= 10) ? time.to_s : "0#{time}"
  end

  def getExportValues(hash)
    values = [hash[0]]
    hash[1].each do |key, value|
      if (@attributes[key] == TIME)
        value = self.class.convert_sec_to_time(value)
      end
      values << value
    end
    values
  end

  def merge_csv(path_to_csv)

    CSV.foreach(path_to_csv, :headers => true, :encoding => 'windows-1251:utf-8') do |row|

        hash = @hashMap[row[@key]] || {};
        @attributes.each do |attribute, dataType|
          value = row[attribute] || row[" " + attribute]
          begin
            case dataType
              when STRING
              when INTEGER
                hash[attribute] = addInteger(hash[attribute], value)
              when TIME
                hash[attribute] = addTime(hash[attribute], value)
            end
          rescue
            puts "I am rescued"
          end
        end
        @hashMap[row[@key]] = hash;
    end

  end



  def convert_time_to_sec(timestamp)
    time = CustomTime.new(timestamp)
    ((time.hour * 60) + time.min) * 60 + time.sec
  end

  def addTime(currentValue, newValue)
    currentValue ||= 0;
    currentValue + convert_time_to_sec(newValue);
  end

  def addInteger(currentValue, newValue)
    currentValue ||= 0;
    currentValue + Integer(newValue)
  end

  attr_accessor :hashMap

end

