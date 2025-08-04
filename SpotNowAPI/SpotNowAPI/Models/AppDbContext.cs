using Microsoft.EntityFrameworkCore;

namespace SpotNowAPI.Models
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Landmark> Landmarks { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<CurrentConditions> CurrentConditions { get; set; }
        public DbSet<LandmarkDetails> LandmarkDetails { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Explicit table mappings
            modelBuilder.Entity<Landmark>().ToTable("Landmarks");
            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<CurrentConditions>().ToTable("current_conditions");
            modelBuilder.Entity<LandmarkDetails>().ToTable("LandmarkDetails");

            // CurrentConditions → Landmark (1:1)
            modelBuilder.Entity<CurrentConditions>()
                .HasOne(cc => cc.Landmark)
                .WithOne()
                .HasForeignKey<CurrentConditions>(cc => cc.LandmarkId)
                .OnDelete(DeleteBehavior.Cascade);

            // LandmarkDetails → Landmark (1:1)
            modelBuilder.Entity<LandmarkDetails>()
                .HasOne(ld => ld.Landmark)
                .WithOne()
                .HasForeignKey<LandmarkDetails>(ld => ld.LandmarkId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
