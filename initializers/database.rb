DB = Sequel.connect('sqlite://test.db')
DB.loggers << Logger.new($stdout)
