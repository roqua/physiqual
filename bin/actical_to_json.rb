#!/usr/bin/env ./bin/runner
require 'csv'
actual_data = false
data = []
start_date = 'nil'
start_time = 'nil'

File.open("ID999.AWCEE", "r") do |f|
  f.each_line.with_index do |line, index|
    if(!actual_data)
      start_date = line if index==3
      start_time = line if index==4
    else
      data << line
    end
    actual_data = true if line.include? '----------------- Begin Raw Activity Data ------------------'
  end
end
## nederlandse file -.-
#date = DateTime.strptime("#{start_date}T#{start_time}", '%d-%b-%YT%H:%M')
date = DateTime.new(2014,3,1,9,22)
start_date = DateTime.new(2014,3,1,9,22)
#{start_date}T#{start_time}
res = []
elapsed_seconds = 0
data.each_with_index do |entry, epoch|
  entry.gsub!("\n","")
  entry.gsub!("\r","")
  current = {}
  current['Epoch#'] = epoch
  current['Day#'] = (date - start_date).to_i + 1
  current['Elapsed Seconds'] = elapsed_seconds
  current['Date'] = date.strftime("%d-%b-%Y").downcase
  current['Time'] = date.strftime("%H:%M")
  current['Activity Counts'] = entry
  res << current
  date += 1.minute
  elapsed_seconds += 60
end

column_names = res.first.keys
s=CSV.generate do |csv|
  csv << column_names
  res.each do |x|
    csv << x.values
  end
end
File.write('ID999.csv', s)
