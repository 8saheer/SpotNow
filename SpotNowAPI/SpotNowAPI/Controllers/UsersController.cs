using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SpotNowAPI.Models;
using SpotNowAPI.DTOs;
using BCrypt.Net;

namespace SpotNowAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Users/GetUser/5
        [HttpGet("GetUser/{id}")]
        public async Task<ActionResult<User>> GetUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound();

            user.passwordHash = null; // Hide password
            return user;
        }

        // POST: api/Users/Register
        [HttpPost("RegisterUser")]
        public async Task<ActionResult<User>> Register([FromBody] RegisterDto dto)
        {
            if (await _context.Users.AnyAsync(u => u.email == dto.Email))
                return BadRequest("Email is already registered.");

            var user = new User
            {
                username = dto.Username,
                name = dto.Name,
                email = dto.Email,
                passwordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                language = "eng",
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            user.passwordHash = null;
            return CreatedAtAction(nameof(GetUser), new { id = user.id }, user);
        }

        // POST: api/Users/Login
        [HttpPost("LoginUser")]
        public async Task<ActionResult> Login([FromBody] LoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.email == dto.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.passwordHash))
                return Unauthorized("Invalid email or password.");

            return Ok(new
            {
                user.id,
                user.username,
                user.email
            });
        }

        // PUT: api/Users/UpdateUser/5
        //[HttpPut("UpdateUser/{id}")]
        //public async Task<IActionResult> UpdateUser(int id, User updatedUser)
        //{
        //    if (id != updatedUser.id)
        //        return BadRequest();

        //    var existingUser = await _context.Users.FindAsync(id);
        //    if (existingUser == null)
        //        return NotFound();

        //    existingUser.username = updatedUser.username;
        //    existingUser.email = updatedUser.email;

        //    if (!string.IsNullOrEmpty(updatedUser.passwordHash))
        //    {
        //        existingUser.passwordHash = BCrypt.Net.BCrypt.HashPassword(updatedUser.passwordHash);
        //    }

        //    await _context.SaveChangesAsync();
        //    return NoContent();
        //}

        // DELETE: api/Users/DeleteUser/5
        [HttpDelete("DeleteUser/{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound();

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }

    public class LoginRequest
    {
        public string email { get; set; }
        public string password { get; set; }
    }
}
