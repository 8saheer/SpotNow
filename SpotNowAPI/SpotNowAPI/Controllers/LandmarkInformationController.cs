using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SpotNowAPI.Models;
using System.Threading.Tasks;

namespace SpotNowAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LandmarkInformationController : ControllerBase
    {
        private readonly AppDbContext _context;

        public LandmarkInformationController(AppDbContext context)
        {
            _context = context;
        }

        // ===== CURRENT CONDITIONS =====

        [HttpGet("CurrentConditions/{landmarkId}")]
        public async Task<IActionResult> GetCurrentConditions(int landmarkId)
        {
            var conditions = await _context.CurrentConditions
                .FirstOrDefaultAsync(c => c.LandmarkId == landmarkId);

            if (conditions == null)
                return NotFound("No current conditions found for this landmark.");

            return Ok(conditions);
        }

        [HttpPost("AddCurrentConditions")]
        public async Task<IActionResult> AddCurrentConditions([FromBody] CurrentConditionsCreateDto dto)
        {
            // Check if landmark exists
            var landmark = await _context.Landmarks.FindAsync(dto.LandmarkId);
            if (landmark == null)
            {
                return NotFound($"Landmark with ID {dto.LandmarkId} not found");
            }

            var conditions = new CurrentConditions
            {
                LandmarkId = dto.LandmarkId,
                Landmark = landmark, // Attach the landmark entity
                CrowdednessRating = dto.CrowdednessRating,
                BugRating = dto.BugRating,
                WaterCleanlinessRating = dto.WaterCleanlinessRating,
                ParkingAvailable = dto.ParkingAvailable,
                NoiseLevel = dto.NoiseLevel,
                SmellRating = dto.SmellRating,
                PicnicSpotAvailable = dto.PicnicSpotAvailable
            };

            _context.CurrentConditions.Add(conditions);
            await _context.SaveChangesAsync();

            return Ok(conditions);
        }

        [HttpPut("CurrentConditions/{id}")]
        public async Task<IActionResult> UpdateCurrentConditions(int id, [FromBody] CurrentConditions updatedData)
        {
            var existing = await _context.CurrentConditions.FindAsync(id);
            if (existing == null)
                return NotFound("Current conditions not found.");

            _context.Entry(existing).CurrentValues.SetValues(updatedData);
            await _context.SaveChangesAsync();
            return Ok(existing);
        }

        [HttpDelete("CurrentConditions/{id}")]
        public async Task<IActionResult> DeleteCurrentConditions(int id)
        {
            var existing = await _context.CurrentConditions.FindAsync(id);
            if (existing == null)
                return NotFound("Current conditions not found.");

            _context.CurrentConditions.Remove(existing);
            await _context.SaveChangesAsync();
            return Ok("Deleted successfully.");
        }

        // ===== GENERAL INFO =====

        [HttpGet("GeneralInfo/{landmarkId}")]
        public async Task<IActionResult> GetGeneralInfo(int landmarkId)
        {
            var info = await _context.LandmarkDetails
                .FirstOrDefaultAsync(g => g.LandmarkId == landmarkId);

            if (info == null)
                return NotFound("No general info found for this landmark.");

            return Ok(info);
        }

        [HttpPost("GeneralInfo")]
        public async Task<IActionResult> AddGeneralInfo([FromBody] LandmarkDetails data)
        {
            if (data == null)
                return BadRequest("Invalid data.");

            _context.LandmarkDetails.Add(data);
            await _context.SaveChangesAsync();
            return Ok(data);
        }

        [HttpPut("GeneralInfo/{id}")]
        public async Task<IActionResult> UpdateGeneralInfo(int id, [FromBody] LandmarkDetails updatedData)
        {
            var existing = await _context.LandmarkDetails.FindAsync(id);
            if (existing == null)
                return NotFound("General info not found.");

            _context.Entry(existing).CurrentValues.SetValues(updatedData);
            await _context.SaveChangesAsync();
            return Ok(existing);
        }

        [HttpDelete("GeneralInfo/{id}")]
        public async Task<IActionResult> DeleteGeneralInfo(int id)
        {
            var existing = await _context.LandmarkDetails.FindAsync(id);
            if (existing == null)
                return NotFound("General info not found.");

            _context.LandmarkDetails.Remove(existing);
            await _context.SaveChangesAsync();
            return Ok("Deleted successfully.");
        }
    }
}
