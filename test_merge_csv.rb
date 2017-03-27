require_relative "merge_csv"
require_relative "main"
require 'minitest/autorun'
require 'pry-rescue/minitest'


class TestMergeCSV < MiniTest::Test
  include DataType

  @@column1 = "NAME"
  @@column2 = "Displays"
  @@column3 = "Plays Requested"
  @@column4 = "Video Starts"
  @@column5 = "Play Conversion Rate"
  @@column6 = "Video Conversion Rate"
  @@column7 = "Hours Watched"
  @@column8 = "Avg. Time Watched per Video"
  @@column9 = "Unique Users"
  @@column10 = "Avg. Plays Requested per User"
  @@column11 = "Playthrough 25%"
  @@column12 = "Playthrough 50%"
  @@column13 = "Playthrough 75%"
  @@column14 = "Playthrough 100%"


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

  @@asset1 = "asset1";
  @@asset2 = "asset2";

  @@paths = [@@asset1, @@asset2];
  @@prefix = "test_files/";
  @@postfix = ".csv";



  def setup
    @merge_csv = MergeCSV.new(@@attributes, @@column1)
  end

  def test_convert_time_to_sec
      timestamp = "20:10:15"
      result = @merge_csv.send(:convert_time_to_sec, timestamp)
      assert_equal(72615, result);
  end

  def test_convert_sec_to_time
    timestamp = "20:10:15"
    timestamp_in_sec = @merge_csv.send(:convert_time_to_sec, timestamp)
    result = MergeCSV.convert_sec_to_time timestamp_in_sec
    assert_equal(timestamp, result)
  end

  def test_valid_custom_time_stamp
    timestamp = "1,400:10:15"
    result = CustomTime.new(timestamp)
    assert_equal(1400, result.hour)
    assert_equal(10, result.min)
    assert_equal(15, result.sec)
  end

  # def test_invalid_custom_time_stamp
  #   timestamp = "70:60:15"
  #   assert_raises RuntimeError do
  #     CustomTime.new(timestamp)
  #   end
  # end

  def test_average_play_requested
    @@paths.each do |path|
      path = @@prefix + path + @@postfix
      CSV.foreach(path, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
        hash = {}
        hash[@@column3] = Integer(row[@@column3])
        hash[@@column9] = Integer(row[@@column9])

        average_play_requested = Main.calculateAveragePlaysRequested(hash).to_s

        assert_equal(row[@@column10], average_play_requested)
      end
    end
  end

  def test_average_time_watched
    path = 'asset3'
    path = @@prefix + path + @@postfix
    CSV.foreach(path, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
      hash = {}
      hash[@@column7] = @merge_csv.send(:convert_time_to_sec, row[@@column7])
      hash[@@column4] = Integer(row[@@column4])


      average_time = Main.calculateAverageTimeWatched(hash).to_s

      average_time_in_sec = @merge_csv.send(:convert_time_to_sec, average_time)
      expected = @merge_csv.send(:convert_time_to_sec, row[@@column8])

      assert_in_delta(expected, average_time_in_sec, 1)
    end

  end



  def test_merge()

    @@paths.each do |path|
      @merge_csv.add(@@prefix + path + @@postfix)
    end
    @path_to_csv = @@prefix + 'test_file.csv'
    @merge_csv.export([], @path_to_csv)

    CSV.foreach(@path_to_csv, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
        assert_equal("Contact International Admission", row[@@column1])
        assert_equal("59540", row[@@column2])
        assert_equal("2719", row[@@column3])
        assert_equal("2645", row[@@column4])
        assert_equal("78:48:14", row[@@column7])
        assert_equal("2608", row[@@column9])

        playthroughs_array1 = [507,387,335,198]
        playthroughs_array2 =[797,641,521,323]
        sumArray = playthroughs_array1.zip(playthroughs_array2).map {|a| a.inject(:+).to_s}

        assert_equal(sumArray[0], row[@@column11])
        assert_equal(sumArray[1], row[@@column12])
        assert_equal(sumArray[2], row[@@column13])
        assert_equal(sumArray[3], row[@@column14])
    end
  end


  def test_merge_with_additional_titles

    @@paths.each do |path|
      @merge_csv.add(@@prefix + path + @@postfix)
    end
    @path_to_csv = @@prefix + 'test_file.csv'

    @merge_csv.export(Main.additionalTitles, @path_to_csv) do |hash|
      [].unshift(Main.calculateAverageTimeWatched(hash), Main.calculateAveragePlaysRequested(hash))
    end

    CSV.foreach(@path_to_csv, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
      videoStarts = 2645
      uniqueUsers = 2608
      playRequested = 2719
      hours_watched = "78:48:14"
      hours_watched_in_sec = @merge_csv.send(:convert_time_to_sec, hours_watched)

      average_time_watched_per_video = MergeCSV.convert_sec_to_time(hours_watched_in_sec / videoStarts)
      average_plays_requested = (playRequested.to_f / uniqueUsers).round(2).to_s;

      assert_equal(average_time_watched_per_video, row[@@column8])
      assert_equal(average_plays_requested, row[@@column10])
    end
  end


end