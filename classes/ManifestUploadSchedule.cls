global class ManifestUploadSchedule implements Schedulable{ 
  /*
   *  execute the Schedule batch 
   */
  global void execute(SchedulableContext sc) {
     ManifestSPI mspi = new ManifestSPI();
     mspi.sendManifestData(true);
  }
}