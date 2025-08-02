namespace SpotNowAPI.Models
{
    public class Landmark
    {
        public int id { get; set; }
        public required string name { get; set; }
        public required string description { get; set; }
        public double distance { get; set; }
        public required string imageUrl { get; set; }

        public double overallRating { get; set; }
        public double recentRating { get; set; }
        
        public required String[] categories { get; set; }
        public int viewsToday { get; set; }
    }
}
