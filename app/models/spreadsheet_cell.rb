class SpreadsheetCell
  include NoBrainer::Document

  field :location, primary_key: true
  field :value
  field :lock
end
