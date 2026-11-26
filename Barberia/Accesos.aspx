<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %><%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) {
Cargar();
CargarVinculos();
}
}
private void CargarVinculos() {
cuentasBarbero.DataSource=Tabla("SELECT u.Id,u.Usuario + N' | Empleado actual: ' + COALESCE(e.Nombre + N' ' + e.Apellido + N' (#' + CONVERT(nvarchar(20),e.Id) + N')',N'Sin vínculo') AS Texto FROM Usuarios u LEFT JOIN UsuarioEmpleado ue ON ue.UsuarioId=u.Id LEFT JOIN Empleados e ON e.Id=ue.EmpleadoId WHERE u.Rol='Barbero' ORDER BY u.Usuario");
cuentasBarbero.DataTextField="Texto";
cuentasBarbero.DataValueField="Id";
cuentasBarbero.DataBind();
destino.DataSource=Tabla("SELECT e.Id,e.Nombre + N' ' + e.Apellido + N' (#' + CONVERT(nvarchar(20),e.Id) + N') | Citas: ' + CONVERT(nvarchar(20),(SELECT COUNT(*) FROM Citas c WHERE c.Empleado=e.Id)) AS Texto FROM Empleados e WHERE e.Activo=1 ORDER BY e.Nombre,e.Apellido,e.Id");
destino.DataTextField="Texto";
destino.DataValueField="Id";
destino.DataBind();
}
protected void Vincular(object s, EventArgs e) {
try {
if (!EsDueno()) throw new Exception("Acceso no autorizado.");
if (cuentasBarbero.SelectedValue=="" || destino.SelectedValue=="") throw new Exception("Seleccione una cuenta y un empleado.");
GuardarOperacion("SET XACT_ABORT ON; IF NOT EXISTS(SELECT 1 FROM Usuarios WHERE Id=@u AND Rol='Barbero') THROW 50001,N'Cuenta inválida.',1; IF NOT EXISTS(SELECT 1 FROM Empleados WHERE Id=@e AND Activo=1) THROW 50002,N'Empleado no disponible.',1; IF EXISTS(SELECT 1 FROM UsuarioEmpleado WHERE EmpleadoId=@e AND UsuarioId<>@u) THROW 50003,N'El empleado ya tiene otra cuenta. Revise la cuenta correcta.',1; IF EXISTS(SELECT 1 FROM UsuarioEmpleado WHERE UsuarioId=@u) UPDATE UsuarioEmpleado SET EmpleadoId=@e WHERE UsuarioId=@u; ELSE INSERT INTO UsuarioEmpleado(UsuarioId,EmpleadoId) VALUES(@u,@e);",P("@u",Convert.ToInt32(cuentasBarbero.SelectedValue)),P("@e",Convert.ToInt32(destino.SelectedValue)));
CargarVinculos();
aviso.Text="Cuenta vinculada correctamente. El barbero ya puede consultar las citas de ese empleado.";
} catch (Exception ex) {
aviso.Text=Server.HtmlEncode(ex.Message);
}
}
protected void Cambiar(object s, EventArgs e) {
usuario.Text="";
clave.Text="";
mensaje.Text="";
Cargar();
}
private void Cargar() {
perfil.DataSource=Tabla((rol.SelectedValue=="Cliente" ? "SELECT Id,Nombre+' '+Apellido AS Texto FROM Clientes WHERE Activo=1" : "SELECT Id,Nombre+' '+Apellido AS Texto FROM Empleados WHERE Activo=1"));
perfil.DataTextField="Texto";
perfil.DataValueField="Id";
perfil.DataBind();
}
protected void Guardar(object s, EventArgs e) {
try {
if (usuario.Text.Trim()=="" || clave.Text.Length<8 || perfil.SelectedValue=="") throw new Exception("Complete los datos; clave de al menos 8 caracteres.");
using (var c = Conexion()) {
c.Open();
using (var tx = c.BeginTransaction()) {
var t = (rol.SelectedValue=="Cliente" ? "UsuarioCliente" : "UsuarioEmpleado");
var campo = (rol.SelectedValue=="Cliente" ? "ClienteId" : "EmpleadoId");
using (var cmd = new SqlCommand("INSERT INTO Usuarios(Nombre,Usuario,Clave,Rol,Activo) VALUES(@n,@u,@c,@r,1); INSERT INTO " + t + "(UsuarioId," + campo + ") VALUES(CONVERT(int,SCOPE_IDENTITY()),@id)",c,tx)) {
cmd.Parameters.AddRange(new SqlParameter[]{P("@n",perfil.SelectedItem.Text),P("@u",usuario.Text.Trim()),P("@c",Hash(clave.Text)),P("@r",rol.SelectedValue),P("@id",Convert.ToInt32(perfil.SelectedValue))});
cmd.ExecuteNonQuery();
}
tx.Commit();
}
}
usuario.Text="";
clave.Text="";
mensaje.Text="Cuenta creada.";
CargarVinculos();
} catch (Exception ex) {
mensaje.Text=Server.HtmlEncode(ex.Message);
}
}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><h1>Cuentas de acceso</h1><div class="panel"><p>Registra primero al cliente o empleado y luego crea su cuenta.</p><label>Tipo</label><asp:DropDownList ID="rol" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Cambiar"><asp:ListItem>Cliente</asp:ListItem><asp:ListItem>Barbero</asp:ListItem></asp:DropDownList><label>Persona</label><asp:DropDownList ID="perfil" runat="server"/><label>Usuario</label><asp:TextBox ID="usuario" runat="server"/><label>Contraseña</label><asp:TextBox ID="clave" runat="server" TextMode="Password"/><asp:Button runat="server" Text="Crear cuenta" OnClick="Guardar"/><asp:Label ID="mensaje" runat="server" CssClass="mensaje"/></div><div class="panel"><h2>Vincular cuenta de barbero</h2><p>Seleccione la cuenta existente y el empleado correcto. Compruebe el identificador y la cantidad de citas. No se eliminan ni se trasladan citas.</p><label>Cuenta del barbero</label><asp:DropDownList ID="cuentasBarbero" runat="server"/><label>Empleado asignado</label><asp:DropDownList ID="destino" runat="server"/><asp:Button runat="server" Text="Vincular cuenta" OnClick="Vincular" OnClientClick="return confirm('¿Confirma que esta cuenta pertenece al empleado seleccionado?');"/><asp:Label ID="aviso" runat="server" CssClass="mensaje"/></div></asp:Content>