using System.Data.Entity;
public class Contexto:DbContext {
 static Contexto(){Database.SetInitializer<Contexto>(null);}
 public Contexto():base("name=Barberia"){}
 public DbSet<Servicio> Servicios {get;set;}
 protected override void OnModelCreating(DbModelBuilder b){b.Entity<Servicio>().ToTable("Servicios").HasKey(x=>x.Id);b.Entity<Servicio>().Property(x=>x.Precio).HasPrecision(10,2);b.Entity<Servicio>().Property(x=>x.Nombre).IsRequired().HasMaxLength(200);b.Entity<Servicio>().Property(x=>x.Descripcion).IsRequired().HasMaxLength(200);base.OnModelCreating(b);}
}