class BaseDataSource
  def authenticate
    raise NotImplementedError, "This method must be implemented in a subclass"
  end

  def fetch_data(params)
    raise NotImplementedError, "This method must be implemented in a subclass"
  end

  def process_data(raw_data)
    raise NotImplementedError, "This method must be implemented in a subclass"
  end
end