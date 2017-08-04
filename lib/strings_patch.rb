class String

  # adds base_name method to string
  def base_name
    File.basename(self,File.extname(self))
  end
end