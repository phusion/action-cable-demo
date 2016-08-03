class User
  include NoBrainer::Document
  field :selected_cells

  before_destroy :unlock_cell

  def lock_cell(location)
    NoBrainer.run do |r|
      SpreadsheetCell.rql_table
        .get(location)
        .replace do |row|
          r.branch(
            row.eq(nil),
            { location: location, lock: id },
            row.merge(
              r.branch(row['lock'].eq(nil), {lock: id},{})
            ))
        end
    end
  end

  def unlock_cell
    SpreadsheetCell.where(lock: id).update_all lock: nil
  end
end
