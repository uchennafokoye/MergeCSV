require_relative 'merge_csv'
class Main
  include DataType

  @@column1 = "Column1"
  @@column2 = "Column2"
  @@column3 = "Column3"
  @@column4 = "Column4"
  @@column5 = "Column5"
  @@column6 = "Column6"
  @@column7 = "Column7"
  @@column8 = "Column8"
  @@column9 = "Column9"
  @@column10 = "Column10"
  @@column11 = "Column11"
  @@column12 = "Column12"
  @@column13 = "Column13"
  @@column14 = "Column14"


  @@attributes = {@@column1 => STRING,
                  @@column2 => INTEGER,
                  @@column3 => INTEGER,
                  @@column4 => INTEGER,
                  @@column7 => TIME,
                  @@column9 => INTEGER,
                  @@column11 => INTEGER,
                  @@column12 => INTEGER,
                  @@column13 => INTEGER,
                  @@column14 => INTEGER
  }

  @@asset1 = "Asset_1";
  @@asset2 = "Asset_2";
  @@asset3 = "Asset_3";
  @@asset4 = "Asset_4";
  @@asset5 = "Asset_5";
  @@asset6 = "Asset_6";
  @@asset7 = "Asset_7";



  @@paths = [@@asset1, @@asset2, @@asset3, @@asset4, @@asset5, @@asset6, @@asset7];




  def self.run
    merge_csv_helper
  end


  private
  def self.merge_csv_helper

    prefix = "asset/";
    postfix = ".csv";

    mergeCSV = MergeCSV.new(@@attributes, @@column1)

    @@paths.each do |path|
      mergeCSV.add(prefix + path + postfix)
    end

    mergeCSV.export(additionalTitles) do |hash|
      [].unshift(calculateAverageTimeWatched(hash), calculateAveragePlaysRequested(hash))
    end
  end

  def self.additionalTitles()
    [@@column8, @@column10]
  end

  def self.calculateAverageTimeWatched(hash)
    hoursWatchedInSec = hash[@@column7]
    videoStarts = hash[@@column4]
    result = (videoStarts == 0) ? 0 : hoursWatchedInSec.to_f / videoStarts
    result = result.round
    MergeCSV.convert_sec_to_time(result)
  end

  def self.calculateAveragePlaysRequested(hash)
    playRequested = hash[@@column3]
    uniqueUsers = hash[@@column9]
    result = (uniqueUsers == 0) ? 0 : playRequested.to_f / uniqueUsers
    result.round(2)
  end
end
#result = Main.run
#puts "All done"


