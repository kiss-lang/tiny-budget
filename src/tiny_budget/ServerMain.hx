package tiny_budget;

enum Record {
    MoneyAsOf(time:Date, amount:Float);
    MoneyOver(start:Date, end:Date, amount:Float, ?asOf:Date, ?fromLabel:String);
    RepeatMoneyOver(startDayOfMonth:Int, endDayOfMonth:Int, amount:Float, ?asOfDayOfMonth:Int);
    // TODO MoneyWeekly
}

class ServerMain {
    static function main() {
        ServerMain_.main();
    }
}
