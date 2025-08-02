using Microsoft.EntityFrameworkCore;

namespace SpotNowAPI.Models
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        // 1. Rename property to `Landmarks` for clarity (optional but conventional)
        public DbSet<Landmark> Landmarks { get; set; }
        public DbSet<User> Users { get; set; }

        // 2. Explicit table mapping
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Landmark>().ToTable("Landmarks");
            modelBuilder.Entity<User>().ToTable("Users");              // maps to Postgres table
        }
    }
}
