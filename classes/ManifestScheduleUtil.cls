/*
    @author: Shirish Goel (Thirdwave Analytics)
    @Date: 8/28/2016
    @Purpose: This is the Manifest Schedule class. This class will be responsible to schedule in Manifest Api.
*/
public class ManifestScheduleUtil {
    
    // method to schedule next upload of manifest
    public void scheduleUploadManifest(Sample_Service_Credentials__c sampleServCred) {
        String schTimer = schedule(sampleServCred, System.now());
        ManifestUploadSchedule sch = new ManifestUploadSchedule();
        if(!Test.isRunningTest() && schTimer != null)
            System.schedule('UploadManifest ' + schTimer, schTimer, sch);
    }
    
    // method to calculate next schedule time
    public String schedule(Sample_Service_Credentials__c sampleServCred, DateTime currentTime) {
        
        String schTimer;
        
        DateTime startTime = returnDateTime(currentTime.date(), sampleServCred.StartTime__c);
        DateTime endTime = returnDateTime(currentTime.date(), sampleServCred.EndTime__c);
        DateTime nextSchTime = startTime.addMinutes(Integer.valueOf(sampleServCred.Frequency__c));
        System.debug('startTime===' + startTime);
        System.debug('endTime===' + endTime);
        System.debug('nextSchTime===' + nextSchTime);
        /* check whether the next scheduled time is between specified start time and end time of the day, in sample service credentials
           if next scheduled time is less than current time then add hours to the time as specified in frequency, in sample service credentials
           as soon as next scheduled time is more than current time, return that time for scheduling
        */
        while(schTimer == null) {
            if(nextSchTime >= startTime && nextSchTime <= endTime) {
                if(nextSchTime > currentTime) {
                    schTimer = returnTimer(nextSchTime);
                
                } else {
                    nextSchTime = nextSchTime.addMinutes(Integer.valueOf(sampleServCred.Frequency__c));
                }
            } else {
                break;
            }
        }
        return schTimer;
    }
    
    // retun date time value for the date and selected start/ end time from picklist in sample service credentials
    public DateTime returnDateTime(Date dateVal, String timeStr) {
        /* time string is in format 1:00 to 24:00, stored in a picklist
           we are splitting this string by colon ':' and will get 2 numbers for hour and minute
        */
        List<String> timeSplit = timeStr.split(':');
        DateTime dt = DateTime.newInstance(dateVal.year(), dateVal.month(), dateVal.day(), Integer.valueOf(timeSplit[0]), Integer.valueOf(timeSplit[1]), 0);
        return dt;
    }
    
    // return timer in a format for scheduling
    public String returnTimer(DateTime dt) {
        String Csec,Cmin,Chr,Cday,Cmonth,CYear;
        Csec=String.valueof(dt.second());
        Cmin=String.valueof(dt.minute());
        Chr=String.valueof(dt.hour());
        Cday=String.valueof(dt.day());
        Cmonth=String.valueof(dt.month());
        CYear=String.valueof(dt.Year());
        String schTimer=Csec+' '+Cmin+' '+Chr+' '+Cday+' '+Cmonth+' ? '+CYear;
        return schTimer;
    }
}