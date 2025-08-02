using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SpotNowAPI.Models
{
    public class User
    {
        [Key]
        public int id { get; set; }

        public string name { get; set; }

        [Required]
        public string username { get; set; }

        [Required]
        public string passwordHash { get; set; }

        [Required]
        public string email { get; set; }

        [Column(TypeName = "text[]")]
        public List<string> preferredCategories { get; set; } = new List<string>();

        [Column(TypeName = "integer[]")]
        public List<int> visitedLandmarkIds { get; set; } = new List<int>();

        [Column(TypeName = "integer[]")]
        public List<int> likedLandmarkIds { get; set; } = new List<int>();

        [Column(TypeName = "integer[]")]
        public List<int> dislikedLandmarkIds { get; set; } = new List<int>();

        [Column(TypeName = "text[]")]
        public List<string> recentSearches { get; set; } = new List<string>();

        public double lat { get; set; }

        public double lon { get; set; }

        public string language { get; set; }
    }
}