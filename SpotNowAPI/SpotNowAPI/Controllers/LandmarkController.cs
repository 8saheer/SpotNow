using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SpotNowAPI.Models;

namespace SpotNowAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LandmarkController : ControllerBase
    {
        private readonly AppDbContext _context;

        public LandmarkController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("GetLandmarks")]
        public async Task<IActionResult> GetLandmarks()
        {
            var landmarks = await _context.Landmarks.Select(x => new Landmark
            { 
                id = x.id,
                name = x.name,
                description = x.description,
                distance = x.distance,
                imageUrl = x.imageUrl,
                overallRating = x.overallRating,
                recentRating = x.recentRating,
                categories = x.categories,
                location = x.location

            }).ToListAsync();

            return Ok(landmarks);
        }

        [HttpPost("AddLandmark")]
        public async Task<IActionResult> AddLandmark([FromBody] Landmark landmark)
        {
            if (landmark == null)
            {
                return BadRequest("Landmark cannot be null");
            }
            _context.Landmarks.Add(landmark);
            await _context.SaveChangesAsync();
            return Ok(landmark);
        }

        [HttpPut("EditLandmark")]
        public async Task<IActionResult> EditLandmark([FromBody] Landmark landmark)
        {
            if (landmark == null)
            {
                return BadRequest("Landmark cannot be null");
            }
            var existingLandmark = await _context.Landmarks.FindAsync(landmark.id);
            if (existingLandmark == null)
            {
                return NotFound("Landmark not found");
            }

            existingLandmark.name = landmark.name;
            existingLandmark.description = landmark.description;
            existingLandmark.distance = landmark.distance;
            existingLandmark.imageUrl = landmark.imageUrl;
            existingLandmark.overallRating = landmark.overallRating;
            existingLandmark.recentRating = landmark.recentRating;
            existingLandmark.categories = landmark.categories;
            existingLandmark.location = landmark.location;
            _context.Landmarks.Update(existingLandmark);
            await _context.SaveChangesAsync();
            return Ok(existingLandmark);
        }

        [HttpDelete("DeleteLandmark/{id}")]
        public async Task<IActionResult> DeleteLandmark(int id)
        {
            var landmark = await _context.Landmarks.FindAsync(id);
            if (landmark == null)
            {
                return NotFound("Landmark not found");
            }
            _context.Landmarks.Remove(landmark);
            await _context.SaveChangesAsync();
            return Ok("Landmark deleted successfully");
        }

        [HttpPost("BulkAdd")]
        public async Task<IActionResult> BulkAdd([FromBody] List<Landmark> landmarks)
        {
            if (landmarks == null || !landmarks.Any())
                return BadRequest("No landmarks provided");

            await _context.Landmarks.AddRangeAsync(landmarks);
            await _context.SaveChangesAsync();

            return Ok($"{landmarks.Count} landmarks added.");
        }

        [HttpPost("AddView/{id}")]
        public async Task<IActionResult> AddView(int id)
        {
            var landmark = await _context.Landmarks.FindAsync(id);
            if (landmark == null)
            {
                return NotFound("Landmark not found");
            }

            landmark.viewsToday += 1;
            await _context.SaveChangesAsync();

            return Ok("View count incremented");
        }

        [HttpPost("AddViewIfNotVisited")]
        public async Task<IActionResult> AddViewIfNotVisited(int userId, int landmarkId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound("User not found");

            var landmark = await _context.Landmarks.FindAsync(landmarkId);
            if (landmark == null) return NotFound("Landmark not found");

            if (user.visitedLandmarkIds == null)
                user.visitedLandmarkIds = new List<int>();

            if (user.visitedLandmarkIds.Contains(landmarkId))
                return Ok("Already visited");

            user.visitedLandmarkIds.Add(landmarkId);
            landmark.viewsToday += 1;

            _context.Users.Update(user);
            _context.Landmarks.Update(landmark);
            await _context.SaveChangesAsync();

            return Ok("View incremented");
        }

        [HttpGet("GetLandmark/{id}")]
        public async Task<IActionResult> GetLandmark(int id)
        {
            var landmark = await _context.Landmarks
                .Where(x => x.id == id)
                .Select(x => new Landmark
                {
                    id = x.id,
                    name = x.name,
                    description = x.description,
                    distance = x.distance,
                    imageUrl = x.imageUrl,
                    overallRating = x.overallRating,
                    recentRating = x.recentRating,
                    categories = x.categories,
                    location = x.location
                })
                .FirstOrDefaultAsync();

            if (landmark == null)
                return NotFound("Landmark not found");

            return Ok(landmark);
        }

    }
}
