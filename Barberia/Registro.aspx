<%@ Page Language="C#" Inherits="PaginaBase" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
protected void Registrar(object s, EventArgs e) {
try {
var n = nombre.Text.Trim(); var a = apellido.Text.Trim(); var t = telefono.Text.Trim(); var co = correo.Text.Trim(); var u = usuario.Text.Trim();
if (n=="" || a=="" || t=="" || co=="" || u=="") throw new Exception("Complete todos los campos.");
if (n.Length>200 || a.Length>200 || t.Length>200 || co.Length>200 || u.Length>200) throw new Exception("Los datos son demasiado largos.");
if (!System.Text.RegularExpressions.Regex.IsMatch(t,"^[0-9+ ()-]{7,20}$")) throw new Exception("Teléfono no válido.");
var mail = new System.Net.Mail.MailAddress(co);
if (mail.Address!=co) throw new Exception("Correo no válido.");
if (clave.Text.Length<8 || clave.Text.Length>128) throw new Exception("La contraseña debe tener entre 8 y 128 caracteres.");
if (clave.Text!=confirmar.Text) throw new Exception("Las contraseñas no coinciden.");
Inicializar();
using (var c = Conexion()) {
c.Open();
using (var tx = c.BeginTransaction()) {
using (var cmd = new SqlCommand("INSERT INTO Clientes(Nombre,Apellido,Telefono,Correo,Activo) VALUES(@n,@a,@t,@co,1); DECLARE @id int=CONVERT(int,SCOPE_IDENTITY()); INSERT INTO Usuarios(Nombre,Usuario,Clave,Rol,Activo) VALUES(@nombre,@u,@clave,'Cliente',1); INSERT INTO UsuarioCliente(UsuarioId,ClienteId) VALUES(CONVERT(int,SCOPE_IDENTITY()),@id);",c,tx)) {
cmd.Parameters.AddRange(new SqlParameter[]{P("@n",n),P("@a",a),P("@t",t),P("@co",co),P("@nombre",(n + " " + a).Substring(0,Math.Min(200,n.Length+a.Length+1))),P("@u",u),P("@clave",Hash(clave.Text))});
cmd.ExecuteNonQuery();
}
tx.Commit();
}
}
Response.Redirect("Login.aspx?registro=1",false);
Context.ApplicationInstance.CompleteRequest();
} catch (SqlException ex) {
mensaje.Text=(ex.Number==2601 || ex.Number==2627 ? "Ese usuario ya existe." : "No se pudo crear la cuenta. Intente nuevamente.");
} catch (FormatException ex) {
mensaje.Text="Correo no válido.";
} catch (Exception ex) {
mensaje.Text=Server.HtmlEncode(ex.Message);
}
}
</script>
<!DOCTYPE html><html lang="es"><head><meta charset="utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/><title>Barbería | Registro</title><link rel="stylesheet" href="estilo.css"/></head><body class="login-page"><form runat="server" class="login registro"><div class="login-brand">✂</div><h1>Barbería</h1><h2>Crear cuenta de cliente</h2><p>Regístrate para reservar y consultar tus citas.</p><asp:TextBox ID="nombre" runat="server" placeholder="Nombre" MaxLength="200"/><asp:TextBox ID="apellido" runat="server" placeholder="Apellido" MaxLength="200"/><asp:TextBox ID="telefono" runat="server" placeholder="Teléfono" MaxLength="20"/><asp:TextBox ID="correo" runat="server" placeholder="Correo electrónico" TextMode="Email" MaxLength="200"/><asp:TextBox ID="usuario" runat="server" placeholder="Usuario" MaxLength="200"/><asp:TextBox ID="clave" runat="server" placeholder="Contraseña (mínimo 8 caracteres)" TextMode="Password"/><asp:TextBox ID="confirmar" runat="server" placeholder="Confirmar contraseña" TextMode="Password"/><asp:Button runat="server" Text="Crear cuenta" OnClick="Registrar"/><asp:Label ID="mensaje" runat="server" CssClass="mensaje"/><p class="registro-link">¿Ya tienes cuenta? <a href="Login.aspx">Iniciar sesión</a></p></form></body></html>
