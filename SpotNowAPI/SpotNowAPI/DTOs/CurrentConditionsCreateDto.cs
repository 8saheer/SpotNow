namespace SpotNowAPI.Models
{
    public class CurrentConditionsCreateDto
    {
        public int LandmarkId { get; set; }
        public double CrowdednessRating { get; set; }
        public double BugRating { get; set; }
        public double WaterCleanlinessRating { get; set; }
        public bool ParkingAvailable { get; set; }
        public double NoiseLevel { get; set; }
        public double SmellRating { get; set; }
        public bool PicnicSpotAvailable { get; set; }
    }
}
