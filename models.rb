require 'rubygems'
require 'dm-core'
require 'marc'
DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/marcdb.db")
class Record
  include DataMapper::Resource
  has n, :control_fields, :order=>[:position.asc]
  has n, :data_fields, :order=>[:position.asc]  
  property :id, Serial
  property :leader, String
  property :created_at, DateTime, :default=>Time.now
  
  def to_marc
    record = MARC::Record.new
    record.leader = self.leader
    self.control_fields.each do | ctrl |
      ctrlfield = MARC::ControlField.new(ctrl.tag, ctrl.value.strip)
      record << ctrlfield
    end
    self.data_fields.each do | data |
      datafield = MARC::DataField.new(data.tag, data.indicator1, data.indicator2)
      data.subfields.each do | subfield |
        sub = MARC::Subfield.new(subfield.code, subfield.value.strip)
        datafield.append(sub)
      end
      record << datafield
    end    
    return record
  end
end

class ControlField
  include DataMapper::Resource
  property :id, Serial
  property :tag, String, :index=>true
  property :position, Integer, :index=>true
  property :value, String, :length=>255
  belongs_to :record
end
class DataField
  include DataMapper::Resource
  property :id, Serial
  property :tag, String, :index=>true
  property :indicator1, String, :length=>1
  property :indicator2, String, :length=>1  
  property :position, Integer, :index=>true
  belongs_to :record
  has n, :subfields, :order=>[:position.asc]  
end

class Subfield
  include DataMapper::Resource
  property :id, Serial
  property :code, String, :length=>1, :index=>true
  property :value, String, :length=>255
  property :position, Integer, :index=>true
  belongs_to :data_field
end