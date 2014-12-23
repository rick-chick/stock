class CodeTime < CodeDate

  attr_accessor :time

  MINUTES = [
  "0900", "0901", "0902", "0903", "0904", "0905", "0906", "0907", "0908", "0909", "0910", "0911", "0912", "0913", "0914", "0915", "0916", "0917", "0918", "0919", "0920", "0921", "0922", "0923", "0924", "0925", "0926", "0927", "0928", "0929", "0930", "0931", "0932", "0933", "0934", "0935", "0936", "0937", "0938", "0939", "0940", "0941", "0942", "0943", "0944", "0945", "0946", "0947", "0948", "0949", "0950", "0951", "0952", "0953", "0954", "0955", "0956", "0957", "0958", "0959",
  "1000", "1001", "1002", "1003", "1004", "1005", "1006", "1007", "1008", "1009", "1010", "1011", "1012", "1013", "1014", "1015", "1016", "1017", "1018", "1019", "1020", "1021", "1022", "1023", "1024", "1025", "1026", "1027", "1028", "1029", "1030", "1031", "1032", "1033", "1034", "1035", "1036", "1037", "1038", "1039", "1040", "1041", "1042", "1043", "1044", "1045", "1046", "1047", "1048", "1049", "1050", "1051", "1052", "1053", "1054", "1055", "1056", "1057", "1058", "1059",
  "1100", "1101", "1102", "1103", "1104", "1105", "1106", "1107", "1108", "1109", "1110", "1111", "1112", "1113", "1114", "1115", "1116", "1117", "1118", "1119", "1120", "1121", "1122", "1123", "1124", "1125", "1126", "1127", "1128", "1129", "1130",
  "1230", "1231", "1232", "1233", "1234", "1235", "1236", "1237", "1238", "1239", "1240", "1241", "1242", "1243", "1244", "1245", "1246", "1247", "1248", "1249", "1250", "1251", "1252", "1253", "1254", "1255", "1256", "1257", "1258", "1259",
  "1300", "1301", "1302", "1303", "1304", "1305", "1306", "1307", "1308", "1309", "1310", "1311", "1312", "1313", "1314", "1315", "1316", "1317", "1318", "1319", "1320", "1321", "1322", "1323", "1324", "1325", "1326", "1327", "1328", "1329", "1330", "1331", "1332", "1333", "1334", "1335", "1336", "1337", "1338", "1339", "1340", "1341", "1342", "1343", "1344", "1345", "1346", "1347", "1348", "1349", "1350", "1351", "1352", "1353", "1354", "1355", "1356", "1357", "1358", "1359",
  "1400", "1401", "1402", "1403", "1404", "1405", "1406", "1407", "1408", "1409", "1410", "1411", "1412", "1413", "1414", "1415", "1416", "1417", "1418", "1419", "1420", "1421", "1422", "1423", "1424", "1425", "1426", "1427", "1428", "1429", "1430", "1431", "1432", "1433", "1434", "1435", "1436", "1437", "1438", "1439", "1440", "1441", "1442", "1443", "1444", "1445", "1446", "1447", "1448", "1449", "1450", "1451", "1452", "1453", "1454", "1455", "1456", "1457", "1458", "1459",
  "1500",
  ]

  def self.blank_instances(code, date)
    MINUTES.map do |minute|
      CodeTime.new(code, date, minute)
    end
  end

  def initialize(code, date, time)
    super(code, date)
    @time = time.to_s
    @time ||= "    "
  end

  def subkey
    @subkey ||= @date + @time
  end

  def subkey=(subkey)
    @subkey = subkey[-12..-1]
  end

  def to_s
    @key ||= @code + @date + @time
  end

  def id(code, date, time)
    return @id if @id
    sql = <<-SQL
    select id 
      from code_time
     where code   = $1
       and date   = $2
       and time   = $3
    SQL
    params = []
    params << code.to_s
    params << date.to_s
    params << time.to_s
    Db.conn.exec(sql, params).each do |row|
      return @id = row["id"]
    end
    nil
  end

  def insert
    sql = <<-SQL
      insert into code_times
      (id, code, date, time, updated)
      values
      ($1, $2, $3, $4, current_timestamp)
    SQL
    params = []
    params << @id.to_i
    params << @code.to_s
    params << @date.to_s
    params << @time.to_s
    Db.conn.exec(sql, params)
    1
  rescue => ex
    p self
    puts ex.message
    p ex.backtrace
    0
  end

end
