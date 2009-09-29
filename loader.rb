require 'rubygems'
require 'marc'
require 'models'

def load_files(path, format)
  marc = case format
  when 'marc' then MARC::ForgivingReader.new(path)
  when 'xml'
    MARC::XMLReader.best_available!
    marc = MARC::XMLReader.new(path)
  end    
  marc.each do | record |
    field_position = 0    
    r = Record.new
    r.leader = record.leader
    r.save
    record.each do | field |
      if field.is_a?(MARC::ControlField)
        ctrl = ControlField.new
        ctrl.tag = field.tag
        ctrl.value = field.value.strip
        ctrl.position = field_position
        ctrl.record = r
        ctrl.save
      else
        data = DataField.new
        data.tag = field.tag
        data.indicator1 = field.indicator1
        data.indicator2 = field.indicator2
        data.record = r
        data.save
        subfield_position = 0
        field.each do | subfield |
          sub = Subfield.new(:data_field=>data, :code=>subfield.code, :value=>subfield.value.strip, :position=>subfield_position)
          sub.save
          subfield_position += 1
        end
      end
      field_position += 1
    end
  end
end