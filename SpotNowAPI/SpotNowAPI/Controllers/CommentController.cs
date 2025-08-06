using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SpotNowAPI.Models;

namespace SpotNowAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CommentsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CommentsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("GetCommentsByUser/{userId}")]
        public async Task<IActionResult> GetCommentsByUser(int userId)
        {
            try
            {
                var comments = await _context.Comments
                    .Where(c => c.UserId == userId)
                    .ToListAsync();

                if (comments == null || !comments.Any())
                {
                    return NotFound($"No comments found for user with ID {userId}");
                }

                return Ok(comments);
            }
            catch (Exception ex)
            {
                // Log the exception as needed
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("GetCommentsOnLandmark/{id}")]
        public async Task<IActionResult> GetCommentsOnLandmark(int id)
        {
            try
            {
                var comments = await _context.Comments
                    .Where(c => c.LandmarkId == id)
                    .ToListAsync();

                if (comments == null || !comments.Any())
                {
                    return NotFound($"No comments found for landmark with ID {id}");
                }

                return Ok(comments);
            }
            catch (Exception ex)
            {
                // Log the exception as needed
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpPost("CreateComment/{userId}/{landmarkId}")]
        public async Task<IActionResult> CreateComment(int userId, int landmarkId, [FromBody] CommentDto commentDto)
        {
            if (string.IsNullOrWhiteSpace(commentDto.Content))
            {
                return BadRequest("Comment content is required.");
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                return NotFound("User not found.");
            }

            var landmark = await _context.Landmarks.FindAsync(landmarkId);
            if (landmark == null)
            {
                return NotFound("Landmark not found.");
            }

            // Check if the user has already commented on this landmark in the last hour
            var oneHourAgo = DateTime.UtcNow.AddHours(-1);
            bool hasRecentComment = await _context.Comments
                .AnyAsync(c => c.UserId == userId &&
                               c.LandmarkId == landmarkId &&
                               c.Date >= oneHourAgo);

            if (hasRecentComment)
            {
                return Conflict(new
                {
                    errorCode = "COMMENT_TOO_SOON",
                    errorMessage = "You have already commented on this landmark within the last hour."
                });
            }

            if (string.IsNullOrWhiteSpace(commentDto.Content))
            {
                return BadRequest(new
                {
                    errorCode = "EMPTY_COMMENT",
                    errorMessage = "Comment content is required."
                });
            }

            var comment = new Comment
            {
                UserId = userId,
                LandmarkId = landmarkId,
                Content = commentDto.Content,
                Date = DateTime.UtcNow,
                Name = user.name
            };

            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();

            return Ok(comment);
        }



    }
}
