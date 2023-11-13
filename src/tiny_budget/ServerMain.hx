package tiny_budget;

enum Record {
    MoneyAsOf(time:Date, amount:Float);
    MoneyOver(start:Date, end:Date, amount:Float);
    RepeatMoneyOver(startDayOfMonth:Int, endDayOfMonth:Int, amount:Float);
}

class ServerMain {
    static function main() {
        ServerMain_.main();
    }
}
