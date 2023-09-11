require 'csv'
require 'set'

old_device = nil
devices = Set.new
out_files = Hash.new { |h, k| h[k] = '' }
sensors = ""
sensor_cust = ""
CSV.foreach('in.csv', col_sep: ';', headers: true) do |row|
  id = row['ID'].to_i(16)
  if id > 0
    id += 0x80000000 # Set bit to force extended mode
    name = "#{row['Group']} #{row['Module']}"
    name << " #{row['Name']}" if row['Name'].to_s != ''
    mid = "#{row['Device']}_#{row['Group']}_#{row['Module']}"
    mid <<  "_#{row['Name']}" if row['Name'].to_s != ''
    mid = mid.upcase.gsub('-', '_').gsub(/\?*/, "").gsub(/\(.*\)/, "").strip.gsub(" ", "_")
    device = row['Device']
    devices << device
    out_files[device] << "BO_ #{id} #{mid}: 4 #{row['Device']}\n"
    out_files[device] << "  SG_ #{mid} : 15|16@0- (#{row['Scale'] || '1'},0) [0|0] \"#{row['Unit']}\" DBG\n"
    out_files[device] << "\n"
    out_files["#{device}_CM"] << "CM_ BO_ #{id} \"#{row['Group']} #{row['Module']} #{row['Name']}\";\n"
    out_files["#{device}_CM"] << "CM_ SG_ #{id} #{mid} \"#{row['Annotations']}\";\n"
    out_files["#{device}_CM"] << "\n"

    sensors << "- platform: mqtt\n"
    sensors << "  name: '#{mid.downcase}'\n"
    sensors << "  unit_of_measurement: '#{row['Unit']}'\n"
    sensors << "  state_topic: \"#{mid.sub('_', '/').sub('_', '/').downcase}\"\n"

    sensor_cust << "sensor.#{mid.downcase}:\n"
    sensor_cust << "  friendly_name: '#{name}'\n"
  end
end

devices.each do |device|
  File.write("out/#{device.downcase}.dbc", <<EOF)
VERSION ""

NS_ : 
  CM_

BS_:

BU_: #{device}

#{out_files[device]}

#{out_files["#{device}_CM"]}
EOF
end
