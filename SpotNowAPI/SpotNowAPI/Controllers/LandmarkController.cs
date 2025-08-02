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
                categories = x.categories

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
    }
}
