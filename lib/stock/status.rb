#coding: utf-8
class Status

  class Orderd < Status; end
  class Cancel < Status; end
  class Contracted < Status; end
  class OutDated < Status; end
  class Denied < Status; end
  class Edited < Status; end

  def self.create(str)
    return Orderd.new if str =~ /注文済/ or str =~ /注文中/
    return Contracted.new if str =~ /約定済/
    return OutDated.new if str =~ /出来ズ/
    return Cancel.new if str =~ /取消済/
    return Edited.new if str =~ /訂正済/
  end

end

