class SetSqliteToWalMode < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    # https://www.sqlite.org/wal.html
    # Setting this once will persist the setting in the database file
    if connection.class.name =~ /SQLite/i
      connection.execute("PRAGMA journal_mode=WAL")
    end
  end

  def down
  end
end
