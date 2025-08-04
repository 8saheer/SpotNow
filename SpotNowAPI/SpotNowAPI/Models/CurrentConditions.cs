using System;

namespace SpotNowAPI.Models
{
    public class CurrentConditions
    {
        public int Id { get; set; }

        // Foreign key to Landmark
        public int LandmarkId { get; set; }
        public Landmark Landmark { get; set; }

        // Ratings / Indicators (nullable so that if not reported, it can be N/A)
        public double? CrowdednessRating { get; set; } // 1-5
        public double? BugRating { get; set; } // 1-5
        public double? WaterCleanlinessRating { get; set; } // 1-5 (if applicable)
        public bool? ParkingAvailable { get; set; }

        public double? NoiseLevel { get; set; } // 1-5                           
        public double? SmellRating { get; set; } // 1-5

        public bool? PicnicSpotAvailable { get; set; }
    }
}
