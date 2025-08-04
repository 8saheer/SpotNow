namespace SpotNowAPI.Models
{
    public class LandmarkDetails
    {

        public int Id { get; set; }
        public int LandmarkId { get; set; }
        public Landmark Landmark { get; set; }
        public String Description { get; set; }

    }
}
