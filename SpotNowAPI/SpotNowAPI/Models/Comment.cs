namespace SpotNowAPI.Models
{
    public class Comment
    {
        public int Id { get; set; }                // Primary key
        public int UserId { get; set; }            // Foreign key to Users table
        public string Name { get; set; }           // User's name
        public string Content { get; set; }        // Comment text
        public DateTimeOffset Date { get; set; }   // Timestamp with time zone
        public int LandmarkId { get; set; }        // Foreign key to Landmark table
    }
}
