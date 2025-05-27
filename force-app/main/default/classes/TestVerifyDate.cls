@isTest
private class TestVerifyDate {
    @isTest static void test1() {
        VerifyDate.CheckDates(system.today(), (system.today().addDays(7)));
        VerifyDate.CheckDates((system.today().addDays(7)), system.today());
    }
}