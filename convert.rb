require 'csv'

old_device = nil
out_files = Hash.new { |h, k| h[k] = '' }
CSV.foreach('in.csv', col_sep: ';', headers: true) do |row|
  id = row['ID'].to_i(16)
  if id > 0
    id += 0x80000000 # Set bit to force extended mode
    name = "#{row['Group']} #{row['Module']}"
    name << " #{row['Name']}" if row['Name'].to_s != ''
    mid = "#{row['Device']}_#{row['Group']}_#{row['Module']}"
    mid <<  "_#{row['Name']}" if row['Name'].to_s != ''
    mid = mid.upcase.gsub('-', '_').gsub(/\?*/, "").gsub(/\(.*\)/, "").strip.gsub(" ", "_")
    dbc_filename = "#{row['Device'].downcase}.dbc"
    out_files[dbc_filename] << "CM_ BO_ #{id} \"#{row['Group']} #{row['Module']} #{row['Name']}\";\n"
    out_files[dbc_filename] << "BO_ #{id} #{mid}: 4 #{row['Device']}\n"
    out_files[dbc_filename] << "  SG_ #{mid} : 15|16@0- (#{row['Scale'] || '1'},0) [0|0] \"#{row['Unit']}\" DBG\n"
    out_files[dbc_filename] << "\n"

    out_files['hassio.sensors.yaml'] << "- platform: mqtt\n"
    out_files['hassio.sensors.yaml'] << "  name: '#{mid.downcase}'\n"
    out_files['hassio.sensors.yaml'] << "  unit_of_measurement: '#{row['Unit']}'\n"
    out_files['hassio.sensors.yaml'] << "  state_topic: \"#{mid.sub('_', '/').sub('_', '/').downcase}\"\n"

    out_files['hassio.customize.yaml'] << "sensor.#{mid.downcase}:\n"
    out_files['hassio.customize.yaml'] << "  friendly_name: '#{name}'\n"
  end
end

out_files.each do |filename, content|
  File.write("out/#{filename}", content)
end
