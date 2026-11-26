<%@ Page Language="C#" Inherits="PaginaBase" MasterPageFile="~/Site.master" %>
<%@ Import Namespace="System.Linq" %><script runat="server">
protected void Page_Load(object s, EventArgs e) {
if (!IsPostBack) {
var r = RolActual();
var id = PerfilId(r);
reserva.Visible=(r=="Cliente" && id>0);
historial.Visible=(r=="Barbero" || r=="Cliente"); cambios.Visible=(r=="Cliente");
if (r=="Cliente") {
empleados.DataSource=Tabla("SELECT e.Id,e.Nombre + N' ' + e.Apellido + N' (#' + CONVERT(nvarchar(20),e.Id) + N')' AS Nombre FROM Empleados e JOIN UsuarioEmpleado ue ON ue.EmpleadoId=e.Id JOIN Usuarios u ON u.Id=ue.UsuarioId WHERE e.Activo=1 AND u.Activo=1 AND u.Rol='Barbero' ORDER BY e.Nombre,e.Apellido,e.Id");
empleados.DataTextField="Nombre";
empleados.DataValueField="Id";
empleados.DataBind();
using(var db=new Contexto()){ servicios.DataSource=db.Servicios.Where(x=>x.Activo).ToList().Select(x=>new {x.Id,Nombre=x.Nombre+" - $"+x.Precio.ToString("0.00")}).ToList(); }
servicios.DataTextField="Nombre";
servicios.DataValueField="Id";
servicios.DataBind();
}
Cargar();
}
}
private void Cargar() {
var r = RolActual(); var id = PerfilId(r);
if(r=="Cliente") { lista.DataSource=Datos.Tabla("SELECT c.Id,c.Fecha,c.Hora,e.Nombre Barbero,c.Estado FROM Citas c JOIN Empleados e ON e.Id=c.Empleado WHERE c.Cliente=@id",Datos.P("@id",id));lista.DataBind(); Datos.Ejecutar("UPDATE r SET Enviado=1 FROM Recordatorios r JOIN Citas c ON c.Id=r.Cita WHERE c.Cliente=@id AND r.FechaEnvio<=SYSDATETIME() AND r.Enviado=0",Datos.P("@id",id)); avisos.DataSource=Datos.Tabla("SELECT r.Mensaje,r.FechaEnvio FROM Recordatorios r JOIN Citas c ON c.Id=r.Cita WHERE c.Cliente=@id AND r.FechaEnvio<=SYSDATETIME()",Datos.P("@id",id));avisos.DataBind();return;} if (r!="Barbero") return;
if (id==0) {
lista.EmptyDataText="Tu cuenta no está vinculada a un empleado. Solicita al dueño que revise Cuentas de acceso.";
}
lista.DataSource=Tabla("SELECT c.Id,c.Fecha,c.Hora,cl.Nombre+' '+cl.Apellido AS Cliente,cl.Telefono,cl.Correo,e.Nombre AS Barbero,s.Nombre AS Servicio,d.Cantidad,d.PrecioUnitario,c.Estado,c.Observaciones FROM Citas c JOIN Clientes cl ON cl.Id=c.Cliente JOIN Empleados e ON e.Id=c.Empleado LEFT JOIN DetalleCita d ON d.Cita=c.Id LEFT JOIN Servicios s ON s.Id=d.Servicio WHERE EXISTS(SELECT 1 FROM UsuarioEmpleado ue JOIN Usuarios u ON u.Id=ue.UsuarioId WHERE ue.EmpleadoId=c.Empleado AND u.Usuario=@usuario AND u.Rol='Barbero' AND u.Activo=1) ORDER BY c.Fecha,c.Hora",P("@usuario",Context.User.Identity.Name));
lista.DataBind();
if (id>0 && lista.Rows.Count==0) lista.EmptyDataText="No hay citas asignadas a tu cuenta (empleado #" + id.ToString() + ").";
lista.DataBind();
}
protected void Reservar(object s, EventArgs e) {
try {
var id = PerfilId("Cliente");
if (RolActual()!="Cliente" || id==0) throw new Exception("Acceso no autorizado");
var f = DateTime.Parse(fecha.Text); var h = TimeSpan.Parse(hora.Text);
if (f.Date.Add(h)<=DateTime.Now) throw new Exception("Seleccione una fecha futura");
GuardarOperacion("INSERT INTO Citas(Cliente,Empleado,Fecha,Hora,Estado,Observaciones) SELECT @c,Id,@f,@h,'Pendiente','' FROM Empleados WHERE Id=@e AND Activo=1 AND EXISTS(SELECT 1 FROM UsuarioEmpleado ue JOIN Usuarios u ON u.Id=ue.UsuarioId WHERE ue.EmpleadoId=@e AND u.Activo=1 AND u.Rol='Barbero'); IF @@ROWCOUNT=0 THROW 50002,'Barbero no disponible',1; INSERT INTO DetalleCita(Cita,Servicio,Cantidad,PrecioUnitario) SELECT SCOPE_IDENTITY(),Id,1,Precio FROM Servicios WHERE Id=@s AND Activo=1; IF @@ROWCOUNT=0 THROW 50001,'Servicio no disponible',1;",P("@c",id),P("@e",Convert.ToInt32(empleados.SelectedValue)),P("@f",f),P("@h",h),P("@s",Convert.ToInt32(servicios.SelectedValue)));
mensaje.Text="Cita solicitada."; Cargar();
fecha.Text="";
hora.Text="";
} catch (Exception ex) {
mensaje.Text=Server.HtmlEncode(ex.Message);
}
}
protected void Cambiar(object s,EventArgs e){try{if(Datos.RolActual()!="Cliente")throw new Exception("Acceso denegado");int id=int.Parse(citaId.Text);bool cancelar=((Button)s).CommandArgument=="cancelar";var f=cancelar?DateTime.Today:DateTime.Parse(fecha.Text);var h=cancelar?TimeSpan.Zero:TimeSpan.Parse(hora.Text);if(!cancelar && f.Date.Add(h)<=DateTime.Now)throw new Exception("Seleccione fecha futura");Datos.GuardarOperacion((cancelar?"UPDATE Citas SET Estado='Cancelada'":"UPDATE Citas SET Fecha=@f,Hora=@h")+" WHERE Id=@id AND Cliente=@c AND Estado IN ('Pendiente','Confirmada'); IF @@ROWCOUNT=0 THROW 50001,'Cita no disponible',1;",Datos.P("@id",id),Datos.P("@c",Datos.PerfilId("Cliente")),Datos.P("@f",f),Datos.P("@h",h));Cargar();mensaje.Text="Cita actualizada";}catch(Exception ex){mensaje.Text=Server.HtmlEncode(ex.Message);}}
</script><asp:Content ContentPlaceHolderID="Contenido" runat="server"><section class="hero"><div class="eyebrow">BARBERÍA</div><h1><%= RolActual()=="Cliente" ? "Agendar cita" : "Mis citas" %></h1></section><asp:Panel ID="reserva" runat="server" CssClass="panel"><h2>Reservar cita</h2><label>Barbero</label><asp:DropDownList ID="empleados" runat="server"/><label>Servicio</label><asp:DropDownList ID="servicios" runat="server"/><label>Fecha</label><asp:TextBox ID="fecha" runat="server" TextMode="Date"/><label>Hora</label><asp:TextBox ID="hora" runat="server" TextMode="Time"/><asp:Button runat="server" Text="Reservar" OnClick="Reservar"/><asp:Label ID="mensaje" runat="server" CssClass="mensaje"/></asp:Panel><asp:Panel ID="historial" runat="server" CssClass="panel"><h2>Mis citas</h2><input type="search" placeholder="Buscar citas" oninput="document.querySelectorAll('table tr').forEach((r,i)=>{if(i)r.style.display=r.innerText.toLowerCase().includes(this.value.toLowerCase())?'':'none'})"/><asp:GridView ID="lista" runat="server" EmptyDataText="No hay citas"/></asp:Panel><asp:Panel ID="cambios" runat="server" CssClass="panel"><h2>Reprogramar o cancelar</h2><p>Para reprogramar, indica la nueva fecha y hora en el formulario superior.</p><asp:TextBox ID="citaId" runat="server" placeholder="ID de cita"/><asp:Button runat="server" Text="Reprogramar" OnClick="Cambiar"/><asp:Button runat="server" Text="Cancelar cita" CommandArgument="cancelar" OnClick="Cambiar"/><h2>Recordatorios internos</h2><asp:GridView ID="avisos" runat="server" EmptyDataText="Sin avisos"/></asp:Panel></asp:Content>