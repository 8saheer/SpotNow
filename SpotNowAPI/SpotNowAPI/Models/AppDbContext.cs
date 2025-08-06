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
        public DbSet<Comment> Comments { get; set; } // Added Comments table

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // === Explicit table mappings ===
            modelBuilder.Entity<Landmark>().ToTable("Landmarks");
            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<CurrentConditions>().ToTable("current_conditions");
            modelBuilder.Entity<LandmarkDetails>().ToTable("LandmarkDetails");
            modelBuilder.Entity<Comment>().ToTable("Comments");

            // === CurrentConditions → Landmark (1:1) ===
            modelBuilder.Entity<CurrentConditions>()
                .HasOne(cc => cc.Landmark)
                .WithOne()
                .HasForeignKey<CurrentConditions>(cc => cc.LandmarkId)
                .OnDelete(DeleteBehavior.Cascade);

            // === LandmarkDetails → Landmark (1:1) ===
            modelBuilder.Entity<LandmarkDetails>()
                .HasOne(ld => ld.Landmark)
                .WithOne()
                .HasForeignKey<LandmarkDetails>(ld => ld.LandmarkId)
                .OnDelete(DeleteBehavior.Cascade);

            // === Comment → Landmark (many-to-1) ===
            modelBuilder.Entity<Comment>()
                .HasOne<Landmark>() // no navigation property to Landmark in Comment yet
                .WithMany()
                .HasForeignKey(c => c.LandmarkId)
                .OnDelete(DeleteBehavior.Cascade);

            // === Comment → User (many-to-1) ===
            modelBuilder.Entity<Comment>()
                .HasOne<User>() // no navigation property to User in Comment yet
                .WithMany()
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // === Property mappings for Comment ===
            modelBuilder.Entity<Comment>(entity =>
            {
                entity.Property(e => e.Id)
                    .HasColumnName("id")
                    .ValueGeneratedOnAdd();

                entity.Property(e => e.Content)
                    .HasColumnName("content")
                    .IsRequired();

                entity.Property(e => e.Date)
                    .HasColumnName("date")
                    .HasColumnType("timestamp with time zone");

                entity.Property(e => e.LandmarkId)
                    .HasColumnName("landmarkId");

                entity.Property(e => e.UserId)
                    .HasColumnName("userId");

                entity.Property(e => e.Name)
                    .HasColumnName("name");
            });
        }
    }
}
