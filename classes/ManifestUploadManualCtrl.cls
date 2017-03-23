public class ManifestUploadManualCtrl {
    
    Boolean doSchedule = false;
    
    public manifestUploadManualCtrl() {
        
    }
    
    public void uploadManifest() {
        ManifestSPI mspi = new ManifestSPI();
        mspi.sendManifestData(doSchedule);
    }
}